/// 🎴 K-Poker — Riverpod 상태 관리 (GDD 2.0)
///
/// AI 자동 턴, 고/스톱, 점수 계산, 판돈/소지금, 저장/불러오기 포함.
library;

import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/round_state.dart';
import '../models/run_state.dart';
import '../models/card_def.dart';
import '../engine/game_engine.dart';
import '../engine/score_calculator.dart';
import '../engine/card_matcher.dart';
import '../engine/shop_generator.dart';
import '../data/item_catalog.dart';
import '../models/shop_state.dart';
import '../data/stage_config.dart';
import '../data/economy_config.dart';
import '../state/game_save_manager.dart';
import '../state/audio_manager.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_provider.dart';

part 'game_providers.g.dart';

/// 게임 이벤트 로그 (UI 피드백용)
class GameEvent {
  final String type; // 'match', 'sweep', 'go', 'stop', 'ppuk', 'ai_play', 'round_end'
  final String message;
  final DateTime time;
  GameEvent({required this.type, required this.message}) : time = DateTime.now();
}

/// 게임 이벤트 Provider
@riverpod
class GameEvents extends _$GameEvents {
  @override
  List<GameEvent> build() => [];

  void addEvent(String type, String message) {
    state = [...state, GameEvent(type: type, message: message)];
  }

  void clear() {
    state = [];
  }
}

/// 고/스톱 선택 대기 Provider (플레이어용)
@riverpod
class GoStopPending extends _$GoStopPending {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

/// AI 고/스톱 알림 Provider (화면 애니메이션용)
/// 값: null = 없음, 'go_1', 'go_2', 'go_3', 'stop' 등
@riverpod
class AiGoStopAnnounce extends _$AiGoStopAnnounce {
  @override
  String? build() => null;

  void announce(String value) => state = value;
  void clear() => state = null;
}

/// 족보 달성 알림 Provider (화면 중앙 플래시)
/// 값: null = 없음, '오광', '삼광', '홍단' 등
@riverpod
class YakuAnnounce extends _$YakuAnnounce {
  @override
  String? build() => null;

  void announce(String value) => state = value;
  void clear() => state = null;
}

/// 게임 세션(라운드) 상태 관리자
@riverpod
class GameState extends _$GameState {
  AppStrings get _s => ref.read(appStringsProvider);

  @override
  RoundState build() {
    return const RoundState();
  }

  /// 게임 시작 (딜링)
  void startGame() {
    ref.read(gameEventsProvider.notifier).clear();
    ref.read(goStopPendingProvider.notifier).hide();

    // t_samshin_granny: 매 라운드 시작 시 Common 패시브 지급 시도
    ref.read(runStateNotifierProvider.notifier).applySamshinGranny();

    final runState = ref.read(runStateNotifierProvider);
    final firstTurn = GameEngine.determineFirstTurn(runState.lastRoundWinner);
    state = GameEngine.createInitialState(run: runState, firstTurn: firstTurn);
    ref.read(gameEventsProvider.notifier).addEvent('start', _s.eventMatchStart);
  }

  /// 저장된 라운드 복원 (앱 시작 시 호출)
  Future<bool> restoreSavedRound() async {
    final savedRound = await GameSaveManager.loadRound();
    if (savedRound != null && !savedRound.isFinished) {
      state = savedRound;
      ref.read(gameEventsProvider.notifier).addEvent('start', _s.eventMatchStart);
      return true;
    }
    return false;
  }

  /// 총통 감지 (핸드에 같은 월 4장)
  int? getPlayerChongtong() => GameEngine.getChongtongMonth(state.playerHand);

  /// 총통 선언! (전통 규칙: 즉시 종료 + 피 2장 탈취 + ScoreCalculator 통과)
  /// 같은 월 4장을 핸드에 보유한 경우 선언 가능
  void declareChongtong(int month) {
    if (state.isFinished || state.currentTurn != 'player') return;

    // 핸드에서 해당 월 4장 추출
    final chongtongCards = state.playerHand.where((c) => c.def.month == month).toList();
    if (chongtongCards.length < 4) return;

    // 1. 핸드에서 제거 + 획득 영역으로 이동 + bombUsed 설정 (총통도 폭탄 계열)
    var newState = state.copyWith(
      playerHand: state.playerHand.where((c) => c.def.month != month).toList(),
      playerCaptured: [...state.playerCaptured, ...chongtongCards],
      isFinished: true,
      winner: 'player',
      bombUsed: true,
    );

    // 2. 피 2장 탈취 (총통 규칙)
    newState = GameEngine.stealPi(newState, 'player', 2);

    // 3. ScoreCalculator로 점수 계산 (박 배율, 시너지 등 반영), 최소 3점 보장
    final run = ref.read(runStateNotifierProvider);
    final scoreResult = ScoreCalculator.calculate(newState, run);
    final finalScore = scoreResult.finalScore < 3 ? 3 : scoreResult.finalScore;
    newState = newState.copyWith(
      playerScore: finalScore,
      baseChips: scoreResult.baseChips,
      multiplier: scoreResult.multiplier,
      scoreBreakdown: scoreResult.breakdown.map((e) => e.toJson()).toList(),
    );

    AudioManager().cardSweep();
    ref.read(gameEventsProvider.notifier)
        .addEvent('bomb', _s.eventChongtong(month));
    ref.read(yakuAnnounceProvider.notifier).announce('chongtong');
    Future.delayed(const Duration(milliseconds: 2000), () {
      ref.read(yakuAnnounceProvider.notifier).clear();
    });

    state = newState;
    _handleRoundEnd();
  }

  /// 인게임 액티브 스킬 사용 타겟 로직 구현
  void useActiveSkill(String skillId) {
    if (state.isFinished) return;

    // 보유 수량 체크 -- 0이면 사용 불가
    final run = ref.read(runStateNotifierProvider);
    final count = run.inventorySkills[skillId] ?? 0;
    if (count <= 0) return;

    // 레거시 ID 정규화
    final normalizedId = migrateItemId(skillId);

    switch (normalizedId) {
      case 'a_shuffle':
        // [덱 셔플] 필드 + 덱 합쳐서 다시 깔기
        final pool = [...state.field, ...state.deck]..shuffle();
        final fSize = state.field.length;
        state = state.copyWith(
          field: pool.sublist(0, fSize),
          deck: pool.sublist(fSize),
        );
        ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillShuffle);

      case 'a_sniper':
        // [스나이퍼] 상대 캡처 카드 중 랜덤 1장 탈취 (전체 대상)
        if (state.opponentCaptured.isNotEmpty) {
          final rng = Random();
          final target = state.opponentCaptured[rng.nextInt(state.opponentCaptured.length)];
          state = state.copyWith(
            opponentCaptured: state.opponentCaptured.where((c) => c != target).toList(),
            playerCaptured: [...state.playerCaptured, target],
          );
          ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillSniperSuccess);
        } else {
          ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillSniperFail);
        }

      case 'a_joker':
        // [전용 조커] 유저 선택 필요 → 다이얼로그에서 useJokerOnCard() 호출
        // 스킬 소모는 useJokerOnCard에서 처리
        return;

      case 'a_trick':
        // [속임수] 유저 선택 필요 → 다이얼로그에서 useTrickOnCards() 호출
        return;

      case 'a_keen_eye':
        // [눈썰미] 유저 선택 필요 → 다이얼로그에서 useKeenEyeReorder() 호출
        return;

      case 'a_card_laundry':
        // [카드 세탁] 유저 선택 필요 → 다이얼로그에서 useLaundryOnCard() 호출
        return;

      default:
        ref.read(gameEventsProvider.notifier).addEvent('skill', _s.ui('skillUsed'));
    }

    // 사용 후 보유량 차감
    ref.read(runStateNotifierProvider.notifier).consumeActiveSkill(skillId);
  }

  /// [조커] 지정 바닥 카드 1장 획득
  void useJokerOnCard(CardInstance card) {
    if (state.isFinished) return;
    if (!state.field.contains(card)) return;
    state = state.copyWith(
      field: state.field.where((c) => c != card).toList(),
      playerCaptured: [...state.playerCaptured, card],
    );
    ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillJokerCapture(card.def.nameKo));
    ref.read(runStateNotifierProvider.notifier).consumeActiveSkill('a_joker');
  }

  /// [속임수] 지정 바닥 카드의 월을 지정 핸드 카드 월로 변경
  void useTrickOnCards(int fieldIndex, int handMonth) {
    if (state.isFinished) return;
    if (fieldIndex < 0 || fieldIndex >= state.field.length) return;
    final fieldCard = state.field[fieldIndex];
    final newDef = CardDef(
      id: fieldCard.def.id,
      month: handMonth,
      grade: fieldCard.def.grade,
      name: fieldCard.def.name,
      nameKo: fieldCard.def.nameKo,
      ribbonType: fieldCard.def.ribbonType,
      isBird: fieldCard.def.isBird,
      doubleJunk: fieldCard.def.doubleJunk,
      isBonus: fieldCard.def.isBonus,
    );
    final newCard = CardInstance(def: newDef, edition: fieldCard.edition);
    final newField = List<CardInstance>.from(state.field);
    newField[fieldIndex] = newCard;
    state = state.copyWith(field: newField);
    ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillTrick(handMonth));
    ref.read(runStateNotifierProvider.notifier).consumeActiveSkill('a_trick');
  }

  /// [카드 세탁] 지정 바닥 카드를 덱 맨 아래로 이동
  void useLaundryOnCard(int fieldIndex) {
    if (state.isFinished) return;
    if (fieldIndex < 0 || fieldIndex >= state.field.length) return;
    final target = state.field[fieldIndex];
    final newField = List<CardInstance>.from(state.field)..removeAt(fieldIndex);
    state = state.copyWith(
      field: newField,
      deck: [...state.deck, target],
    );
    ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillLaundry(target.def.nameKo));
    ref.read(runStateNotifierProvider.notifier).consumeActiveSkill('a_card_laundry');
  }

  /// [눈썰미] 덱 상위 3장 순서 변경
  void useKeenEyeReorder(List<int> newOrder) {
    if (state.isFinished) return;
    final deckLen = state.deck.length;
    final topCount = deckLen < 3 ? deckLen : 3;
    if (topCount == 0) return;
    // newOrder는 원래 인덱스(0,1,2)의 재배치
    final topCards = state.deck.sublist(0, topCount);
    final reordered = <CardInstance>[];
    for (final idx in newOrder) {
      if (idx >= 0 && idx < topCards.length) {
        reordered.add(topCards[idx]);
      }
    }
    // 혹시 누락된 카드 보정
    for (final c in topCards) {
      if (!reordered.contains(c)) reordered.add(c);
    }
    final newDeck = [...reordered, ...state.deck.sublist(topCount)];
    state = state.copyWith(deck: newDeck);
    ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillKeenEyeReorder);
    ref.read(runStateNotifierProvider.notifier).consumeActiveSkill('a_keen_eye');
  }

  /// 흔들기 가능한 모든 월 리스트 (이미 선언한 월은 제외)
  List<int> getShakeMonths() {
    final monthCount = <int, int>{};
    for (final c in state.playerHand) {
      monthCount[c.def.month] = (monthCount[c.def.month] ?? 0) + 1;
    }
    return monthCount.entries
        .where((e) => e.value >= 3)
        .where((e) => !state.shakeMonths.contains(e.key))
        .map((e) => e.key)
        .toList();
  }

  /// 흔들기 선언 (복수 월 가능: 1벌=2배, 2벌=4배)
  void declareShake(int month) {
    if (state.shakeMonths.contains(month)) return;
    state = state.copyWith(
      shakeMonths: [...state.shakeMonths, month],
    );
    ref.read(gameEventsProvider.notifier).addEvent('shake', _s.shakeAnnounce(month));
    ref.read(yakuAnnounceProvider.notifier).announce('shake');
    Future.delayed(const Duration(milliseconds: 2000), () {
      ref.read(yakuAnnounceProvider.notifier).clear();
    });
  }

  /// 전체 흔들기 (가능한 모든 월 한꺼번에 선언)
  void declareShakeAll(List<int> months) {
    final newMonths = months.where((m) => !state.shakeMonths.contains(m)).toList();
    if (newMonths.isEmpty) return;
    state = state.copyWith(
      shakeMonths: [...state.shakeMonths, ...newMonths],
    );
    for (final month in newMonths) {
      ref.read(gameEventsProvider.notifier).addEvent('shake', _s.shakeAnnounce(month));
    }
    ref.read(yakuAnnounceProvider.notifier).announce('shake');
    Future.delayed(const Duration(milliseconds: 2000), () {
      ref.read(yakuAnnounceProvider.notifier).clear();
    });
  }

  // ps_time_rewind: 직전 플레이어 턴 상태 저장 (undo용)
  RoundState? _previousPlayerState;

  /// ps_time_rewind (시간 되감기): 마지막 플레이어 턴 undo (1회/판)
  void useTimeRewind() {
    if (_previousPlayerState == null) return;
    final run = ref.read(runStateNotifierProvider);
    if (!run.ownedPassiveIds.contains('ps_time_rewind')) return;
    if (state.rewindUsed) return;

    state = _previousPlayerState!.copyWith(rewindUsed: true);
    _previousPlayerState = null;
    ref.read(gameEventsProvider.notifier).addEvent('skill', 'Time Rewind!');
  }

  /// 카드 플레이 (플레이어)
  void playCard(CardInstance card, {CardInstance? selectedMatch}) {
    if (state.isFinished || state.currentTurn != 'player') return;

    // ps_time_rewind: 턴 실행 전 상태 저장
    final run0 = ref.read(runStateNotifierProvider);
    if (run0.ownedPassiveIds.contains('ps_time_rewind') && !state.rewindUsed) {
      _previousPlayerState = state;
    }

    // 1. 플레이어 턴 실행
    final prevCaptured = state.playerCaptured.length;
    final run = ref.read(runStateNotifierProvider);
    final nextState = GameEngine.playTurn(state, card, selectedMatch: selectedMatch, run: run);

    // ── 보너스 카드: 즉시 획득 + 덱 1장 핸드 추가 → 턴 소비 없이 리턴 ──
    if (card.def.isBonus) {
      // 점수만 갱신하고 고/스톱 판정/턴 전환 없이 리턴 (플레이어가 다시 카드를 냄)
      final scoreResult = ScoreCalculator.calculate(nextState, run);
      state = nextState.copyWith(
        playerScore: scoreResult.finalScore,
        baseChips: scoreResult.baseChips,
        multiplier: scoreResult.multiplier,
        scoreBreakdown: scoreResult.breakdown.map((e) => e.toJson()).toList(),
      );
      AudioManager().cardMatch();
      ref.read(gameEventsProvider.notifier)
          .addEvent('bonus', _s.eventPlayerMatch(card.def.nameKo, 1));
      return; // 턴 소비 없음 — 고/스톱 판정 안 함
    }

    // 2. 매칭 피드백 이벤트 + SFX
    final newCaptured = nextState.playerCaptured.length - prevCaptured;
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    var modifiedNextState = nextState;

    // 특수 이벤트 처리 (엔진 v2.0 lastSpecialEvent 기반)
    final specialEvent = modifiedNextState.lastSpecialEvent;
    final stolenPi = modifiedNextState.lastStolenPiCount;

    if (specialEvent.isNotEmpty) {
      _announceSpecialEvent(specialEvent, stolenPi, ai);
    } else if (newCaptured > 0) {
      AudioManager().cardMatch();
      final hasBright = modifiedNextState.playerCaptured.any((c) => c.def.grade == CardGrade.bright && !state.playerCaptured.contains(c));
      if (hasBright) AudioManager().brightCapture();
      ref.read(gameEventsProvider.notifier)
          .addEvent('match', _s.eventPlayerMatch(card.def.nameKo, newCaptured));

      final matchLine = _s.getAiDialogue(ai.id, 'player_match', ai.dialogues['player_match'] ?? ['흥!']);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$matchLine"');
    } else {
      ref.read(gameEventsProvider.notifier)
          .addEvent('miss', _s.eventPlayerMiss(card.def.nameKo));

      final missLine = _s.getAiDialogue(ai.id, 'player_miss', ai.dialogues['player_miss'] ?? ['쯧쯧']);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$missLine"');
    }

    // 3. 점수 업데이트 (이전 점수 저장 — 고/스톱 판정용)
    final prevPlayerScore = state.playerScore;
    final prevYaku = state.playerScore > 0
        ? ScoreCalculator.calculate(state, run).appliedYaku
        : <String>[];
    final scoreResult = ScoreCalculator.calculate(modifiedNextState, run);

    state = modifiedNextState.copyWith(
      playerScore: scoreResult.finalScore,
      baseChips: scoreResult.baseChips,
      multiplier: scoreResult.multiplier,
      scoreBreakdown: scoreResult.breakdown.map((e) => e.toJson()).toList(),
    );

    // 족보 달성 알림 (#4) — i18n 키로 announce
    // 'shake'는 선언 시 이미 announce 했으므로 매턴 반복 방지를 위해 제외
    final newYaku = scoreResult.appliedYaku;
    for (final yaku in newYaku) {
      if (yaku == 'shake') continue; // 흔들기는 declareShake()에서 이미 표시
      if (!prevYaku.contains(yaku)) {
        // yaku_ 접두어 제거하여 이벤트 코드 추출 (SpecialEventEffect 호환)
        final announceKey = _yakuKeyToEventType(yaku);
        if (announceKey == null) continue; // 이펙트 표시 불필요한 키 스킵
        ref.read(yakuAnnounceProvider.notifier).announce(announceKey);
        Future.delayed(const Duration(milliseconds: 1800), () {
          ref.read(yakuAnnounceProvider.notifier).clear();
        });
        break; // 한 번에 하나만
      }
    }

    if (specialEvent == 'triple_ppeok') {
      state = state.copyWith(isFinished: true, winner: 'player');
      _handleRoundEnd();
      return;
    }

    // 4. 게임 종료 체크
    if (state.isFinished) {
      _handleRoundEnd();
      return;
    }

    // 5. 고/스톱 판정 (점수 기준) — 덱이 남아있을 때만
    //    덱 소진 시에는 고/스톱 없이 바로 라운드 종료
    if (scoreResult.finalScore >= 3 && state.deck.isNotEmpty) {
      if (state.goCount == 0) {
        // 첫 3점 도달: 무조건 고/스톱 선택
        ref.read(goStopPendingProvider.notifier).show();
        return;
      } else if (scoreResult.finalScore > prevPlayerScore) {
        // 고 선언 후: 점수가 실제로 올라야만 재판정
        ref.read(goStopPendingProvider.notifier).show();
        return;
      }
    }

    // 6. AI 턴 (UI에서 애니메이션과 함께 호출하도록 위임)
    if (state.currentTurn == 'opponent' && !state.isFinished) {
      if (state.opponentHand.isEmpty) {
        state = state.copyWith(isFinished: true, isDraw: true);
        _handleRoundEnd();
        return;
      }
    }

    if (state.playerHand.isEmpty && state.opponentHand.isEmpty && !state.isFinished) {
      state = state.copyWith(isFinished: true, isDraw: true);
      _handleRoundEnd();
      return;
    }

    // 라운드 중간 자동 저장
    GameSaveManager.saveRound(state);
  }

  /// 특수 이벤트 알림 처리
  void _announceSpecialEvent(String event, int stolenPi, dynamic ai) {
    String text;

    switch (event) {
      case 'ppeok':
        AudioManager().cardMatch();
        text = _s.eventPpeok;
        break;
      case 'double_ppeok':
        AudioManager().cardSweep();
        text = _s.eventDoublePpeok;
        break;
      case 'triple_ppeok':
        AudioManager().cardSweep();
        text = _s.eventTriplePpeok;
        break;
      case 'chok':
        AudioManager().cardMatch();
        text = _s.eventChok(stolenPi > 0);
        break;
      case 'chok_sweep':
        AudioManager().cardSweep();
        text = _s.eventChokSweep(stolenPi > 0);
        break;
      case 'tadak':
        AudioManager().cardMatch();
        text = _s.eventTadak(stolenPi > 0);
        break;
      case 'sweep':
        AudioManager().cardSweep();
        text = _s.eventSweep(stolenPi > 0);
        break;
      case 'ppeok_eat':
        AudioManager().cardSweep();
        text = _s.eventPpeokEat(stolenPi > 0);
        break;
      case 'self_ppeok':
        AudioManager().cardSweep();
        text = _s.eventSelfPpeok(stolenPi > 0);
        break;
      case 'bomb':
        AudioManager().cardSweep();
        text = _s.eventGeneralBomb(stolenPi > 0);
        break;
      default:
        return;
    }

    ref.read(gameEventsProvider.notifier).addEvent(event, text);
    ref.read(yakuAnnounceProvider.notifier).announce(event); // 엔진 이벤트 코드 그대로 전달
    Future.delayed(const Duration(milliseconds: 2000), () {
      ref.read(yakuAnnounceProvider.notifier).clear();
    });

    // AI 반응 대사
    final reactKey = event.contains('ppeok') ? 'sweep_react' : 'player_match';
    final reactLine = _s.getAiDialogue(ai.id, reactKey, ai.dialogues[reactKey] ?? ['...']);
    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$reactLine"');
  }

  /// 폭탄! (같은 월 3장 한번에 내기)
  void playBomb(int bombMonth) {
    if (state.isFinished || state.currentTurn != 'player') return;

    final prevPlayerScore = state.playerScore; // 고/스톱 판정용 이전 점수

    final prevOpJunks = state.opponentCaptured.where((c) => c.def.grade == CardGrade.junk).length;
    final nextState = GameEngine.playBomb(state, bombMonth);
    final newOpJunks = nextState.opponentCaptured.where((c) => c.def.grade == CardGrade.junk).length;
    final stolenJunk = prevOpJunks > newOpJunks;

    // 이벤트
    AudioManager().cardSweep(); // 폭탄은 쓸과 비슷한 임팩트 SFX
    ref.read(gameEventsProvider.notifier)
        .addEvent('bomb', _s.eventPlayerBomb(bombMonth, stolenJunk));

    // AI 반응 대사
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    final bombReactLine = _s.getAiDialogue(ai.id, 'bomb_react', ai.dialogues['bomb_react'] ?? ['앗!']);
    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$bombReactLine"');

    // 점수 업데이트
    final scoreResult = ScoreCalculator.calculate(nextState, run);
    state = nextState.copyWith(
      playerScore: scoreResult.finalScore,
      baseChips: scoreResult.baseChips,
      multiplier: scoreResult.multiplier,
      scoreBreakdown: scoreResult.breakdown.map((e) => e.toJson()).toList(),
    );

    if (state.isFinished) {
      _handleRoundEnd();
      return;
    }

    // 고/스톱 판정 — playCard와 동일한 로직 적용
    if (scoreResult.finalScore >= 3 && state.deck.isNotEmpty) {
      if (state.goCount == 0) {
        // 첫 3점 도달: 무조건 고/스톱 선택
        ref.read(goStopPendingProvider.notifier).show();
        return;
      } else if (scoreResult.finalScore > prevPlayerScore) {
        // 고 선언 후: 점수가 실제로 올라야만 재판정
        ref.read(goStopPendingProvider.notifier).show();
        return;
      }
    }

    // AI 턴 (UI에서 애니메이션과 함께 호출하도록 위임)
    if (state.currentTurn == 'opponent' && !state.isFinished) {
      if (state.opponentHand.isEmpty) {
        state = state.copyWith(isFinished: true, isDraw: true);
        _handleRoundEnd();
        return;
      }
      // UI에서 _executeAiTurn을 호출하게 됨
    }

    if (state.playerHand.isEmpty && state.opponentHand.isEmpty && !state.isFinished) {
      state = state.copyWith(isFinished: true, isDraw: true);
      _handleRoundEnd();
      return;
    }

    // 라운드 중간 자동 저장
    GameSaveManager.saveRound(state);
  }

  /// 고! 선언
  void declareGo() {
    ref.read(goStopPendingProvider.notifier).hide();
    AudioManager().goDeclare();
    ref.read(gameEventsProvider.notifier).addEvent('go', _s.eventPlayerGo);

    // AI 반응 대사 (고 횟수에 따라 다름)
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    final isFear = state.goCount >= 2; // 3고 이상 (현재 count 2일때 선언하면 3고가 됨)
    final sit = isFear ? 'player_go_fear' : 'player_go';
    final goLine = _s.getAiDialogue(ai.id, sit, ai.dialogues[sit] ?? (isFear ? ['안돼!'] : ['오호, 대담하네!']));
    
    // 두려운 상황이면 추가 놀라는 SFX 플레이 가능
    if (isFear) AudioManager().cardSweep(); // 에러음 대신 쓸과 비슷한 임팩트음 사용

    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$goLine"');

    // 고 배율은 ScoreCalculator에서만 처리 (이중적용 방지)
    state = state.copyWith(
      goCount: state.goCount + 1,
    );

    // 고 선언 직후 multiplier 즉시 갱신 (사이드 패널 실시간 반영)
    final scoreResult = ScoreCalculator.calculate(state, ref.read(runStateNotifierProvider));
    state = state.copyWith(
      playerScore: scoreResult.finalScore,
      baseChips: scoreResult.baseChips,
      multiplier: scoreResult.multiplier,
      scoreBreakdown: scoreResult.breakdown.map((e) => e.toJson()).toList(),
    );

    if (state.currentTurn == 'opponent') {
      // UI의 Go 버튼 쪽에서 _triggerAiTurnIfNeeded()를 호출하도록 위임
    }
  }

  /// 스톱! 선언
  void declareStop() {
    ref.read(goStopPendingProvider.notifier).hide();
    AudioManager().stopDeclare();
    ref.read(gameEventsProvider.notifier).addEvent('stop', _s.eventPlayerStop);

    // AI 반응 대사 (점수에 따라 다름)
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    final isBig = state.playerScore >= 10;
    final sit = isBig ? 'player_stop_big' : 'player_stop_small';
    final stopLine = _s.getAiDialogue(ai.id, sit, ai.dialogues[sit] ?? (isBig ? ['너무하네!'] : ['소박하네~']));
    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$stopLine"');

    state = state.copyWith(isFinished: true, winner: 'player');
    _handleRoundEnd();
  }

  /// AI가 어떤 카드를 낼지 선택만 반환 (애니메이션용)
  CardInstance? getAiChoice() {
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);

    // 폭탄 체크 (핸드 3장 + 바닥 1장 이상)
    if (ai.matchPriority >= 0.7) {
      final aiBombMonth = GameEngine.getBombMonth(
        List<CardInstance>.from(state.opponentHand),
        List<CardInstance>.from(state.field),
      );
      if (aiBombMonth != null) return null; // 폭탄은 기존 로직으로
    }

    // 최적 카드 선택 (기존 _playAiTurn 로직과 동일)
    CardInstance? bestCard;
    int bestScore = -1;
    for (final card in state.opponentHand) {
      final matchable = findMatchableCards(card, state.field);
      if (matchable.isNotEmpty) {
        int cardScore = 0;
        if (card.def.grade == CardGrade.bright) {
          cardScore = 100;
        } else if (card.def.grade == CardGrade.animal) {
          cardScore = 50;
        } else if (card.def.grade == CardGrade.ribbon) {
          cardScore = 30;
        } else {
          cardScore = 10;
        }
        if (ai.matchPriority < 0.5) {
          cardScore = (cardScore * ai.matchPriority).round();
        }
        if (cardScore > bestScore) {
          bestScore = cardScore;
          bestCard = card;
        }
      }
    }
    return bestCard ?? (state.opponentHand.isNotEmpty ? state.opponentHand.first : null);
  }

  /// AI 턴 처리 (UI에서 애니메이션 후 호출)
  void playAiCard(CardInstance card) {
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);

    final prevCaptured = state.opponentCaptured.length;
    final nextState = GameEngine.playTurn(state, card, run: run);
    final newCaptured = nextState.opponentCaptured.length - prevCaptured;

    if (newCaptured > 0) {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', _s.eventAiMatch(card.def.nameKo, newCaptured));
      final matchLine = _s.getAiDialogue(ai.id, 'match', ai.dialogues['match'] ?? ['...']);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$matchLine"');
    } else {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', _s.eventAiMiss(card.def.nameKo));
      final missLine = _s.getAiDialogue(ai.id, 'miss', ai.dialogues['miss'] ?? ['...']);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$missLine"');
    }

    state = nextState;

    // AI 점수 계산 (AI의 고 횟수 반영)
    final aiRun = ref.read(runStateNotifierProvider);
    final aiScoreState = nextState.copyWith(
      playerCaptured: nextState.opponentCaptured,
      opponentCaptured: nextState.playerCaptured,
      goCount: nextState.opponentGoCount,
    );
    final aiResult = ScoreCalculator.calculate(aiScoreState, aiRun);
    state = state.copyWith(opponentScore: aiResult.finalScore);

    if (state.isFinished) {
      _handleRoundEnd();
      return;
    }

    // AI 고/스톱 판정 — 덱 소진 시 건너뜀
    if (aiResult.finalScore >= 3 && state.deck.isNotEmpty) {
      final aiGoCount = state.opponentGoCount;
      final shouldStop = aiResult.finalScore >= 7
          || aiGoCount >= 2
          || (aiGoCount >= 1 && ai.goAggressiveness < 0.4)
          || (aiResult.finalScore >= 5 && ai.goAggressiveness < 0.3);
      
      if (shouldStop) {
        AudioManager().stopDeclare(); // AI 스톱 효과음
        ref.read(aiGoStopAnnounceProvider.notifier).announce('stop');
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', _s.eventAiStop);
        
        final stopLine = _s.getAiDialogue(ai.id, 'stop', ai.dialogues['stop'] ?? ['스톱!']);
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$stopLine"');

        state = state.copyWith(isFinished: true, winner: 'opponent');
        Future.delayed(const Duration(milliseconds: 1500), () {
          ref.read(aiGoStopAnnounceProvider.notifier).clear();
          _handleRoundEnd();
        });
      } else {
        AudioManager().goDeclare(); // AI 고 효과음
        final newGoCount = aiGoCount + 1;
        ref.read(aiGoStopAnnounceProvider.notifier).announce('go_$newGoCount');
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', _s.eventAiGo(newGoCount));
        
        final goLine = _s.getAiDialogue(ai.id, 'go', ai.dialogues['go'] ?? ['고!']);
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$goLine"');

        state = state.copyWith(
          opponentGoCount: newGoCount,
          opponentScore: aiResult.finalScore,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          ref.read(aiGoStopAnnounceProvider.notifier).clear();
        });
      }
    }
  }

  /// AI 턴 실행 (기존 - 폭탄/fallback용)
  // ignore: unused_element
  void _playAiTurn() {
    if (state.isFinished || state.currentTurn != 'opponent') return;

    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);

    // AI 폭탄 체크: 높은 난이도 AI만 폭탄 사용 (바닥 카드 필수)
    if (ai.matchPriority >= 0.7) {
      final aiBombMonth = GameEngine.getBombMonth(
        List<CardInstance>.from(state.opponentHand),
        List<CardInstance>.from(state.field),
      );
      if (aiBombMonth != null) {
        AudioManager().cardSweep(); // 폭탄 효과음
        final nextState = GameEngine.playBomb(state, aiBombMonth);
        ref.read(gameEventsProvider.notifier)
            .addEvent('ai_play', _s.eventAiBomb(aiBombMonth));
        
        final bombLine = _s.getAiDialogue(ai.id, 'bomb', ai.dialogues['bomb'] ?? ['폭탄이다!']);
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$bombLine"');
        
        // AI 점수 계산
        final aiScoreState = nextState.copyWith(
          playerCaptured: nextState.opponentCaptured,
          opponentCaptured: nextState.playerCaptured,
        );
        final aiResult = ScoreCalculator.calculate(aiScoreState, run);
        state = nextState.copyWith(opponentScore: aiResult.finalScore);

        if (state.isFinished) {
          _handleRoundEnd();
        }
        return;
      }
    }

    // AI 전략: matchPriority에 따라 최적 카드 선택
    CardInstance? bestCard;
    int bestScore = -1;
    
    for (final card in state.opponentHand) {
      final matchable = findMatchableCards(card, state.field);
      if (matchable.isNotEmpty) {
        // 높은 등급 카드 우선 (AI 난이도에 따라)
        int cardScore = 0;
        if (card.def.grade == CardGrade.bright) {
          cardScore = 100;
        } else if (card.def.grade == CardGrade.animal) {
          cardScore = 50;
        } else if (card.def.grade == CardGrade.ribbon) {
          cardScore = 30;
        } else {
          cardScore = 10;
        }
        
        // AI 난이도: 낮으면 랜덤 요소 추가
        if (ai.matchPriority < 0.5) {
          cardScore = (cardScore * ai.matchPriority).round();
        }
        
        if (cardScore > bestScore) {
          bestScore = cardScore;
          bestCard = card;
        }
      }
    }
    bestCard ??= state.opponentHand.isNotEmpty ? state.opponentHand.first : null;

    if (bestCard == null) {
      // AI 핸드가 비어서 카드를 낼 수 없음 → 나가리
      state = state.copyWith(isFinished: true);
      _handleRoundEnd();
      return;
    }

    final prevCaptured = state.opponentCaptured.length;
    final nextState = GameEngine.playTurn(state, bestCard, run: run);
    final newCaptured = nextState.opponentCaptured.length - prevCaptured;

    if (newCaptured > 0) {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', _s.eventAiMatch(bestCard.def.nameKo, newCaptured));
      // #6 AI 대사
      final matchLine = _s.getAiDialogue(ai.id, 'match', ai.dialogues['match'] ?? ['...']);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$matchLine"');
    } else {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', _s.eventAiMiss(bestCard.def.nameKo));
      final missLine = _s.getAiDialogue(ai.id, 'miss', ai.dialogues['miss'] ?? ['...']);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$missLine"');
    }

    state = nextState;

    // AI 점수 계산 (상대 시점 — AI의 고 횟수 반영)
    final aiRun = ref.read(runStateNotifierProvider);
    final aiScoreState = nextState.copyWith(
      playerCaptured: nextState.opponentCaptured,
      opponentCaptured: nextState.playerCaptured,
      goCount: nextState.opponentGoCount,
    );
    final aiResult = ScoreCalculator.calculate(aiScoreState, aiRun);
    state = state.copyWith(opponentScore: aiResult.finalScore);

    if (state.isFinished) {
      _handleRoundEnd();
      return;
    }

    // AI 고/스톱 판정: 3점 이상이면 AI가 자동 결정 — 덱 소진 시 건너뜀
    if (aiResult.finalScore >= 3 && state.deck.isNotEmpty) {
      final aiGoCount = state.opponentGoCount;
      // AI 전략: goAggressiveness 반영 (#1)
      final shouldStop = aiResult.finalScore >= 7
          || aiGoCount >= 2
          || (aiGoCount >= 1 && ai.goAggressiveness < 0.4)
          || (aiResult.finalScore >= 5 && ai.goAggressiveness < 0.3);
      
      if (shouldStop) {
        // AI 스톱! → AI 승리 (플레이어가 고를 선언한 상태면 독박)
        ref.read(aiGoStopAnnounceProvider.notifier).announce('stop');
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', _s.eventAiStop);
        state = state.copyWith(isFinished: true, winner: 'opponent');
        // 애니메이션 후 라운드 종료 처리 (UI에서 처리)
        Future.delayed(const Duration(milliseconds: 1500), () {
          ref.read(aiGoStopAnnounceProvider.notifier).clear();
          _handleRoundEnd();
        });
      } else {
        // AI 고!
        final newGoCount = aiGoCount + 1;
        ref.read(aiGoStopAnnounceProvider.notifier).announce('go_$newGoCount');
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', _s.eventAiGo(newGoCount));
        state = state.copyWith(
          opponentGoCount: newGoCount,
          opponentScore: aiResult.finalScore,
        );
        // 애니메이션 후 알림 제거
        Future.delayed(const Duration(milliseconds: 1500), () {
          ref.read(aiGoStopAnnounceProvider.notifier).clear();
        });
      }
    }
  }

  /// i18n 키를 SpecialEventEffect의 eventType으로 변환
  /// 이펙트 표시 대상이 아닌 키는 null 반환
  String? _yakuKeyToEventType(String yakuKey) {
    const keyToEvent = {
      'yaku_ogwang': 'ogwang',
      'yaku_sagwang': 'sagwang',
      'yaku_bisagwang': 'bisagwang',
      'yaku_bisamgwang': 'bisamgwang',
      'yaku_samgwang': 'samgwang',
      'yaku_godori': 'godori',
      'yaku_hongdan': 'hongdan',
      'yaku_cheongdan': 'cheongdan',
      'yaku_chodan': 'chodan',
      'yaku_sweep': 'sweep',
    };
    // 이펙트 표시 불필요한 키들 (점수 브레이크다운에서만 표시)
    if (yakuKey.startsWith('penalty_') ||
        yakuKey.startsWith('talisman_') ||
        yakuKey.startsWith('consumable_') ||
        yakuKey.startsWith('synergy_') ||
        yakuKey.startsWith('passive_') ||
        yakuKey.startsWith('yaku_go_') ||
        yakuKey == 'yaku_ribbon_count' ||
        yakuKey == 'yaku_animal_count' ||
        yakuKey == 'yaku_junk_count' ||
        yakuKey == 'yaku_cup_as_junk') {
      return null;
    }
    return keyToEvent[yakuKey];
  }

  /// 라운드 종료 처리 (판돈 정산)
  void _handleRoundEnd() {
    final run = ref.read(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    
    // 무승부 (나가리) 처리
    // 1) 명시적 isDraw 플래그
    // 2) 양쪽 모두 0점 (아무도 점수 못 냄)
    // 3) 고를 선언했지만 덱 소진으로 끝남 → 점수가 더 안 올라갔으므로 나가리
    final anyoneGo = state.goCount > 0 || state.opponentGoCount > 0;
    final goButNoIncrease = anyoneGo && state.winner == null && !state.isDraw;
    final isDraw = state.isDraw
        || (state.winner == null && state.playerScore == state.opponentScore && state.playerScore == 0)
        || goButNoIncrease;
    if (isDraw) {
      ref.read(gameEventsProvider.notifier).addEvent('round_end', _s.eventDraw);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${_s.aiTalkDraw}"');
      // 나가리 시: 선 결정용 빈 문자열 (다음 판 랜덤)
      ref.read(runStateNotifierProvider.notifier).setLastRoundWinner('');
      // 나가리 시 골드 손실
      ref.read(runStateNotifierProvider.notifier).onNagari();
    } else {
      // 명시적인 승자가 있으면 우선 적용, 없으면 점수 비교
      final isPlayerWin = state.winner == 'player' || (state.winner == null && state.playerScore > state.opponentScore);

      // 선 결정용: 이번 판 승자 저장
      ref.read(runStateNotifierProvider.notifier).setLastRoundWinner(isPlayerWin ? 'player' : 'opponent');

      if (isPlayerWin) {
        // 플레이어 승리 → AI는 lose 대사
        // playerScore = (baseChips + passiveChips) * multiplier — 패시브 보너스 포함 최종 점수
        var earnings = state.playerScore * currency.pointValue;

        // 상대 고박 (AI가 고를 불렀는데 유저가 스톱으로 이긴 경우 2배)
        if (state.opponentGoCount > 0) {
          earnings *= 2;
          ref.read(gameEventsProvider.notifier).addEvent('round_end', _s.eventRewardGoBak);
        }

        final loseLine = _s.getAiDialogue(ai.id, 'lose', ai.dialogues['lose'] ?? ['다음엔 지지 않을 거야...']);
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$loseLine"');
        
        ref.read(runStateNotifierProvider.notifier).onWin(earnings, state.playerScore);
        ref.read(gameEventsProvider.notifier)
            .addEvent('round_end', _s.eventWin(currency.formatAmount(earnings)));
      } else {
        // 플레이어 패배 → AI는 win 대사
        final winLine = _s.getAiDialogue(ai.id, 'win', ai.dialogues['win'] ?? ['내가 이겼다!']);
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$winLine"');
        
        // 패배 시 정산
        var opScore = state.opponentScore > 0 ? state.opponentScore : 1;
        
        // 내 고박 (내가 고를 불렀는데 AI가 스톱하여 패배한 경우 벌금 2배)
        if (state.goCount > 0) {
          opScore *= 2;
          ref.read(gameEventsProvider.notifier).addEvent('round_end', _s.eventPenaltyGoBak);
        }

        final penalty = opScore * currency.pointValue;
        ref.read(runStateNotifierProvider.notifier).onLose(penalty);
        ref.read(gameEventsProvider.notifier)
            .addEvent('round_end', _s.eventLose(currency.formatAmount(penalty)));
      }
    }

    // 자동 저장 (라운드 끝났으므로 라운드 세이브 삭제)
    GameSaveManager.deleteRoundSave();
    final updatedRun = ref.read(runStateNotifierProvider);
    GameSaveManager.save(updatedRun);
  }
}

/// 전체 런 상태 관리자
@riverpod
class RunStateNotifier extends _$RunStateNotifier {
  @override
  RunState build() => const RunState();

  /// 저장된 게임 불러오기 (레거시 세이브 마이그레이션 포함)
  Future<bool> loadGame() async {
    final saved = await GameSaveManager.load();
    if (saved != null) {
      var migrated = saved;

      // 세이브 보정: opponentMoney가 0 이하이거나 비정상적이면 현재 스테이지에 맞게 초기화
      final currency = getCurrencyForLocale(migrated.currencyLocale);
      final expectedFund = getOpponentFund(migrated.stage, migrated.currentOpponentIndex, currency.pointValue);
      if (migrated.opponentMoney <= 0 || migrated.opponentMoney > expectedFund * 2) {
        migrated = migrated.copyWith(opponentMoney: expectedFund);
      }

      // 레거시 마이그레이션: activeSkillIds → inventorySkills
      if (migrated.activeSkillIds.isNotEmpty) {
        final Map<String, int> newInv = Map<String, int>.from(migrated.inventorySkills);
        for (final oldId in migrated.activeSkillIds) {
          final newId = migrateItemId(oldId);
          newInv[newId] = (newInv[newId] ?? 0) + 1;
        }
        migrated = migrated.copyWith(
          inventorySkills: newInv,
          activeSkillIds: const [],
        );
      }

      // 레거시 마이그레이션: activeTalismanIds → ownedTalismanIds
      if (migrated.activeTalismanIds.isNotEmpty) {
        final newTalismans = <String>{
          ...migrated.ownedTalismanIds,
          ...migrated.activeTalismanIds.map(migrateItemId),
        }.toList();
        migrated = migrated.copyWith(
          ownedTalismanIds: newTalismans,
          activeTalismanIds: const [],
        );
      }

      state = migrated;
      return true;
    }
    return false;
  }

  /// 상대 자금이 0이면 현재 스테이지에 맞게 보정
  void fixOpponentMoney() {
    if (state.opponentMoney <= 0) {
      final currency = getCurrencyForLocale(state.currencyLocale);
      final fund = getOpponentFund(state.stage, state.currentOpponentIndex, currency.pointValue);
      state = state.copyWith(opponentMoney: fund);
      _autoSave();
    }
  }

  /// 새 게임 시작
  void newGame(String locale) {
    final currency = getCurrencyForLocale(locale);
    const initialMoney = 50.0; // $50 시작 소지금
    final firstOpponentFund = getOpponentFund(1, 0, currency.pointValue);

    // t_samshin_granny (삼신할머니): 런 시작 시 랜덤 Common 패시브 1개 지급
    List<String> initialPassives = [];
    // 새 게임 시작 시에는 부적이 없으므로 여기서는 빈 상태 유지
    // 삼신할머니 효과는 loadGame 시 이미 ownedTalismanIds에 포함되어 있으므로
    // 해당 시점에서 자동 적용됨 (아래 _applySamshinGranny 메서드 참조)

    state = RunState(
      stage: 1,
      money: initialMoney,
      highestMoney: initialMoney,
      gold: EconomyConfig.startingGold,
      currencyLocale: locale,
      currentOpponentIndex: 0,
      opponentMoney: firstOpponentFund,
      ownedPassiveIds: initialPassives,
    );
    _autoSave();
  }

  /// t_samshin_granny 효과: Common 패시브 풀에서 랜덤 1개 지급
  /// 스테이지 시작(상점 후 라운드 진입) 시 호출
  void applySamshinGranny() {
    if (!state.ownedTalismanIds.contains('t_samshin_granny')) return;

    final commonPassives = itemCatalog
        .where((i) => i.slot == ItemSlot.passiveAlways && i.rarity == Rarity.common)
        .where((i) => !state.ownedPassiveIds.contains(i.id))
        .toList();
    if (commonPassives.isEmpty) return;

    final rng = Random();
    final gift = commonPassives[rng.nextInt(commonPassives.length)];
    state = state.copyWith(
      ownedPassiveIds: [...state.ownedPassiveIds, gift.id],
    );
    _autoSave();
  }

  /// 승리 시 정산 — 상대 자금 차감 + 골드 수입 + 연승 보너스
  void onWin(double earnings, int score) {
    final newMoney = state.money + earnings;
    final currency = getCurrencyForLocale(state.currencyLocale);
    final newOpponentMoney = state.opponentMoney - earnings;

    int newStage = state.stage;
    int newOpIdx = state.currentOpponentIndex;
    double nextOpMoney = newOpponentMoney;

    if (newOpponentMoney <= 0) {
      // 상대 탈락!
      final aiIds = stageAiMapping[state.stage.clamp(1, 6)]!;
      if (newOpIdx + 1 < aiIds.length) {
        // 같은 스테이지 다음 상대
        newOpIdx = newOpIdx + 1;
        nextOpMoney = getOpponentFund(state.stage, newOpIdx, currency.pointValue);
      } else {
        // 스테이지 클리어! -> 다음 스테이지
        newStage = state.stage + 1;
        newOpIdx = 0;
        nextOpMoney = getOpponentFund(newStage, 0, currency.pointValue);
      }
    }

    // ── 골드 수입 계산 (로케일 무관 고정 공식) ──
    final gpp = EconomyConfig.effectiveGoldPerPoint(state.stage);
    int goldEarned = score * gpp;

    // 연승 보너스: N연승마다 +50G (winStreak는 아직 증가 전이므로 +1 해서 판정)
    final newStreak = state.winStreak + 1;
    if (newStreak > 0 &&
        newStreak % EconomyConfig.winStreakBonusInterval == 0) {
      goldEarned += EconomyConfig.winStreakBonusGold;
    }

    // t_golden_mat 부적: 승리 시 골드 +15%
    if (state.ownedTalismanIds.contains('t_golden_mat')) {
      goldEarned = (goldEarned * 1.15).round();
    }

    // ps_coin_picker 패시브: 잔여 점수당 +5G
    if (state.ownedPassiveIds.contains('ps_coin_picker')) {
      final item = findCatalogItem('ps_coin_picker');
      final coinGpp = (item?.params['goldPerPoint'] as int?) ?? 5;
      goldEarned += score * coinGpp;
    }

    // t_dokkaebi_mallet (도깨비 방망이): 캡처된 피 카드 수 x 10% 확률 x +2G
    if (state.ownedTalismanIds.contains('t_dokkaebi_mallet')) {
      final roundState = ref.read(gameStateProvider);
      final capturedJunkCount = roundState.playerCaptured
          .where((c) => c.def.grade == CardGrade.junk)
          .length;
      final rng = Random();
      for (int i = 0; i < capturedJunkCount; i++) {
        if (rng.nextDouble() < 0.1) {
          goldEarned += 2;
        }
      }
    }

    // syn_moonlight (월광 지배): 캡처된 광 카드 수 x +10G
    if (state.allOwnedItemIds.contains('ps_full_moon') &&
        state.allOwnedItemIds.contains('x_ogwang_crown')) {
      final roundState = ref.read(gameStateProvider);
      final capturedBrightCount = roundState.playerCaptured
          .where((c) => c.def.grade == CardGrade.bright)
          .length;
      goldEarned += capturedBrightCount * 10;
    }

    state = state.copyWith(
      money: newMoney,
      gold: state.gold + goldEarned,
      stage: newStage,
      currentOpponentIndex: newOpIdx,
      opponentMoney: nextOpMoney,
      wins: state.wins + 1,
      winStreak: newStreak,
      highestScore: score > state.highestScore ? score : state.highestScore,
      highestMoney: newMoney > state.highestMoney ? newMoney : state.highestMoney,
      moneyHistory: [...state.moneyHistory, newMoney],
      equippedRoundItemIds: const [], // 장착된 1회용 아이템 소멸
    );
    _autoSave();
  }

  /// 패배 시 정산 — 상대 자금 증가 + 골드 손실
  void onLose(double penalty) {
    // P-002 / c_safety_helmet 파산 방지 로직
    final currency = getCurrencyForLocale(state.currencyLocale);
    final minStake = currency.pointValue * 3; // 3점 금액 (파산 기준선)
    double newMoney = (state.money - penalty).clamp(0, double.infinity);

    if (newMoney <= minStake &&
        (state.equippedRoundItemIds.contains('P-002') ||
         state.equippedRoundItemIds.contains('c_safety_helmet'))) {
      // 파산 위기 탈출! (최소 판돈 + 10점의 부조금 지급)
      newMoney = minStake + (currency.pointValue * 10);
    }

    // 골드는 패배 시 손실 없음 (판돈 money만 손실)

    final newOpponentMoney = state.opponentMoney + penalty;
    state = state.copyWith(
      money: newMoney.toDouble(),
      opponentMoney: newOpponentMoney,
      losses: state.losses + 1,
      winStreak: 0,
      moneyHistory: [...state.moneyHistory, newMoney.toDouble()],
      equippedRoundItemIds: const [], // 장착된 1회용 아이템 소멸
    );
    _autoSave();
  }

  /// 선(先) 결정용: 전판 승자 저장
  void setLastRoundWinner(String winner) {
    state = state.copyWith(lastRoundWinner: winner);
  }

  /// 나가리(무승부) 처리 — 골드 손실 없음
  /// ps_insurance: 나가리 시 연승 유지 (50% 확률)
  void onNagari() {
    int newWinStreak = 0;
    if (state.ownedPassiveIds.contains('ps_insurance')) {
      // 보험 효과: 나가리 시에도 연승 카운터 유지
      newWinStreak = state.winStreak;
    }
    state = state.copyWith(
      winStreak: newWinStreak,
      equippedRoundItemIds: const [], // 장착된 1회용 아이템 소멸
    );
    _autoSave();
  }

  /// 파산 여부 체크: 소지금이 3점 판돈(최소 한 판 비용) 미만이면 파산
  bool get isBankrupt {
    final currency = getCurrencyForLocale(state.currencyLocale);
    final minBet = currency.pointValue * 3; // 3점 최소 판 비용
    return state.money < minBet;
  }

  /// 언어 변경 시 화폐 변환 (포인트 기준 환산)
  void changeCurrency(String newLocale) {
    if (state.currencyLocale == newLocale) return;
    final oldCurrency = getCurrencyForLocale(state.currencyLocale);
    final newCurrency = getCurrencyForLocale(newLocale);
    final ratio = newCurrency.pointValue / oldCurrency.pointValue;

    state = state.copyWith(
      currencyLocale: newLocale,
      money: state.money * ratio,
      opponentMoney: state.opponentMoney * ratio,
      highestMoney: state.highestMoney * ratio,
      moneyHistory: state.moneyHistory.map((m) => m * ratio).toList(),
    );
    // opponentMoney가 0 이하면 복구
    if (state.opponentMoney <= 0) {
      fixOpponentMoney();
    }
    _autoSave();
  }

  /// 런 재시작 (처음부터 다시)
  Future<void> restartRun() async {
    await GameSaveManager.deleteSave();
    newGame(state.currencyLocale);
  }

  /// 광고 보상으로 부활 — 소지금을 시작 금액(50)으로 복구
  void reviveWithAd() {
    const reviveMoney = 50.0;
    state = state.copyWith(money: reviveMoney);
    _autoSave();
  }

  /// 금화 획득 (출석/광고 보상)
  void addGold(int amount) {
    state = state.copyWith(gold: state.gold + amount);
    _autoSave();
  }

  /// 1. 인게임 액티브 스킬 구매 (재화 소모 및 인벤토리 증가)
  void buyActiveSkill(String itemId, int cost) {
    if (state.gold < cost) return;
    final Map<String, int> newInv = Map.from(state.inventorySkills);
    newInv[itemId] = (newInv[itemId] ?? 0) + 1;
    state = state.copyWith(gold: state.gold - cost, inventorySkills: newInv);
    _autoSave();
  }

  /// 2. 라운드 장착 소모품 구매
  void buyPreRoundItem(String itemId, int cost) {
    if (state.gold < cost) return;
    final Map<String, int> newInv = Map.from(state.inventoryRoundItems);
    newInv[itemId] = (newInv[itemId] ?? 0) + 1;
    state = state.copyWith(gold: state.gold - cost, inventoryRoundItems: newInv);
    _autoSave();
  }

  /// 3. 영구 부적 구매 (중복 구매 불가)
  void buyPassiveTalisman(String itemId, int cost) {
    if (state.gold < cost) return;
    if (state.ownedTalismanIds.contains(itemId)) return;
    state = state.copyWith(
      gold: state.gold - cost,
      ownedTalismanIds: [...state.ownedTalismanIds, itemId],
    );
    _autoSave();
  }

  /// 4. 패시브 아이템 구매 (중복 구매 불가)
  void buyPassive(String itemId, int cost) {
    if (state.gold < cost) return;
    if (state.ownedPassiveIds.contains(itemId)) return;
    state = state.copyWith(
      gold: state.gold - cost,
      ownedPassiveIds: [...state.ownedPassiveIds, itemId],
    );
    _autoSave();
  }

  /// 인게임 액티브 스킬 소모
  void consumeActiveSkill(String itemId) {
    final count = state.inventorySkills[itemId] ?? 0;
    if (count <= 0) return;
    final Map<String, int> newInv = Map.from(state.inventorySkills);
    newInv[itemId] = count - 1;
    state = state.copyWith(inventorySkills: newInv);
    _autoSave();
  }

  /// 라운드 장착 (대기실에서 장착 슬롯으로 이동)
  void equipRoundItem(String itemId) {
    if (state.equippedRoundItemIds.contains(itemId)) return;
    final count = state.inventoryRoundItems[itemId] ?? 0;
    if (count <= 0) return;
    
    final Map<String, int> newInv = Map.from(state.inventoryRoundItems);
    newInv[itemId] = count - 1;
    state = state.copyWith(
      inventoryRoundItems: newInv,
      equippedRoundItemIds: [...state.equippedRoundItemIds, itemId],
    );
    _autoSave();
  }

  // ═══════════════════════════════════════
  //  로그라이크 상점 메서드
  // ═══════════════════════════════════════

  /// 상점 열기 (라운드 승리 후)
  void openShop(int stage) {
    final shopState = ShopGenerator.generate(stage: stage, run: state);
    state = state.copyWith(shopState: shopState);
    _autoSave();
  }

  /// 상점 아이템 구매
  void buyShopItem(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= state.shopState.slots.length) return;
    final slot = state.shopState.slots[slotIndex];
    if (slot.sold || slot.locked || state.gold < slot.price) return;

    final item = findCatalogItem(slot.itemId);
    if (item == null) return;

    // 슬롯별 적절한 인벤토리에 추가
    switch (item.slot) {
      case ItemSlot.activeInGame:
        buyActiveSkill(slot.itemId, slot.price);
      case ItemSlot.passiveAlways:
        buyPassive(slot.itemId, slot.price);
      case ItemSlot.talisman:
        buyPassiveTalisman(slot.itemId, slot.price);
      case ItemSlot.consumableRound:
        buyPreRoundItem(slot.itemId, slot.price);
    }

    // 슬롯 sold 마킹
    final newSlots = List<ShopSlot>.from(state.shopState.slots);
    newSlots[slotIndex] = slot.copyWith(sold: true);
    state = state.copyWith(
      shopState: state.shopState.copyWith(slots: newSlots),
    );
    _autoSave();
  }

  /// 리롤
  void rerollShop(int stage) {
    if (state.gold < state.shopState.rerollCost) return;
    final newGold = state.gold - state.shopState.rerollCost;
    final newShop = ShopGenerator.reroll(
      current: state.shopState,
      stage: stage,
      run: state,
    );
    state = state.copyWith(gold: newGold, shopState: newShop);
    _autoSave();
  }

  /// 자동 저장
  void _autoSave() {
    GameSaveManager.save(state);
  }
}

