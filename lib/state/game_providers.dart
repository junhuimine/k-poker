/// 🎴 K-Poker — Riverpod 상태 관리 (GDD 2.0)
///
/// AI 자동 턴, 고/스톱, 점수 계산, 판돈/소지금, 저장/불러오기 포함.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/round_state.dart';
import '../models/run_state.dart';
import '../models/card_def.dart';
import '../engine/game_engine.dart';
import '../engine/score_calculator.dart';
import '../engine/card_matcher.dart';
import '../data/stage_config.dart';
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
    final runState = ref.read(runStateNotifierProvider);
    state = GameEngine.createInitialState(run: runState);
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

  /// 총통 선언! (전통 규칙: 즉시 종료 + 기본 3점)
  /// 같은 월 4장을 핸드에 보유한 경우 선언 가능
  void declareChongtong(int month) {
    if (state.isFinished || state.currentTurn != 'player') return;

    // 핸드에서 해당 월 4장 추출
    final chongtongCards = state.playerHand.where((c) => c.def.month == month).toList();
    if (chongtongCards.length < 4) return;

    // 전통 규칙: 즉시 게임 종료, 기본 3점 획득
    var newState = state.copyWith(
      playerHand: state.playerHand.where((c) => c.def.month != month).toList(),
      playerCaptured: [...state.playerCaptured, ...chongtongCards],
      playerScore: 3,
      isFinished: true,
      winner: 'player',
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

    if (skillId == 'S-003') { 
      // [덱 셔플] 필드 + 덱 합쳐서 다시 깔기
      final pool = [...state.field, ...state.deck]..shuffle();
      final fieldSize = state.field.length;
      state = state.copyWith(
        field: pool.sublist(0, fieldSize),
        deck: pool.sublist(fieldSize),
      );
      ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillShuffle);
    } else if (skillId == 'S-002') {
      // [스나이퍼] 상대방이 획득한 피(Junk) 1장을 훔침 (없으면 실패)
      final opJunks = state.opponentCaptured.where((c) => c.def.grade == CardGrade.junk).toList();
      if (opJunks.isNotEmpty) {
        final target = opJunks.last;
        state = state.copyWith(
          opponentCaptured: state.opponentCaptured.where((c) => c != target).toList(),
          playerCaptured: [...state.playerCaptured, target],
        );
        ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillSniperSuccess);
      } else {
        ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillSniperFail);
      }
    } else if (skillId == 'S-001') {
      // [전용 조커] 이벤트성
      ref.read(gameEventsProvider.notifier).addEvent('skill', _s.eventSkillJoker);
    }
  }

  /// 카드 플레이 (플레이어)
  void playCard(CardInstance card, {CardInstance? selectedMatch}) {
    if (state.isFinished || state.currentTurn != 'player') return;

    // 1. 플레이어 턴 실행
    final prevCaptured = state.playerCaptured.length;
    final run = ref.read(runStateNotifierProvider);
    final nextState = GameEngine.playTurn(state, card, selectedMatch: selectedMatch, run: run);

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
    );

    // 족보 달성 알림 (#4)
    final newYaku = scoreResult.appliedYaku;
    for (final yaku in newYaku) {
      if (!prevYaku.contains(yaku)) {
        ref.read(yakuAnnounceProvider.notifier).announce(yaku);
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

    // 5. 고/스톱 판정 (점수 기준)
    if (scoreResult.finalScore >= 3) {
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
    );

    if (state.isFinished) {
      _handleRoundEnd();
      return;
    }

    // 고/스톱 판정
    if (scoreResult.finalScore >= 3) {
      ref.read(goStopPendingProvider.notifier).show();
      return;
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

    // 폭탄 체크
    if (ai.matchPriority >= 0.7) {
      final aiBombMonth = GameEngine.getBombMonth(
        List<CardInstance>.from(state.opponentHand),
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

    // AI 고/스톱 판정
    if (aiResult.finalScore >= 3) {
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

        state = state.copyWith(isFinished: true);
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

    // AI 폭탄 체크: 높은 난이도 AI만 폭탄 사용
    if (ai.matchPriority >= 0.7) {
      final aiBombMonth = GameEngine.getBombMonth(
        List<CardInstance>.from(state.opponentHand),
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

    // AI 고/스톱 판정: 3점 이상이면 AI가 자동 결정
    if (aiResult.finalScore >= 3) {
      final aiGoCount = state.opponentGoCount;
      // AI 전략: goAggressiveness 반영 (#1)
      final shouldStop = aiResult.finalScore >= 7
          || aiGoCount >= 2
          || (aiGoCount >= 1 && ai.goAggressiveness < 0.4)
          || (aiResult.finalScore >= 5 && ai.goAggressiveness < 0.3);
      
      if (shouldStop) {
        // AI 스톱!
        ref.read(aiGoStopAnnounceProvider.notifier).announce('stop');
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', _s.eventAiStop);
        state = state.copyWith(isFinished: true);
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

  /// 라운드 종료 처리 (판돈 정산)
  void _handleRoundEnd() {
    final run = ref.read(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    
    // 무승부 (나가리) 처리
    final isDraw = state.isDraw || (state.winner == null && state.playerScore == state.opponentScore && state.playerScore == 0);
    if (isDraw) {
      ref.read(gameEventsProvider.notifier).addEvent('round_end', _s.eventDraw);
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${_s.aiTalkDraw}"');
    } else {
      // 명시적인 승자가 있으면 우선 적용, 없으면 점수 비교
      final isPlayerWin = state.winner == 'player' || (state.winner == null && state.playerScore > state.opponentScore);

      if (isPlayerWin) {
        // 플레이어 승리 → AI는 lose 대사
        var baseScore = state.baseChips > 0 ? state.baseChips : state.playerScore;

        // 상대 고박 (AI가 고를 불렀는데 유저가 스톱으로 이긴 경우 2배)
        if (state.opponentGoCount > 0) {
          baseScore *= 2;
          ref.read(gameEventsProvider.notifier).addEvent('round_end', _s.eventRewardGoBak);
        }

        final mult = state.multiplier;
        final earnings = baseScore * currency.pointValue * mult;

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
      // 레거시 세이브: opponentMoney가 0이면 현재 스테이지에 맞게 초기화
      if (saved.opponentMoney <= 0) {
        final currency = getCurrencyForLocale(saved.currencyLocale);
        final fund = getOpponentFund(saved.stage, saved.currentOpponentIndex, currency.pointValue);
        state = saved.copyWith(opponentMoney: fund);
      } else {
        state = saved;
      }
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
    final initialMoney = stageConfigs[0].stakeMultiplier * currency.pointValue * 5; // 판돈 5배
    final firstOpponentFund = getOpponentFund(1, 0, currency.pointValue);
    state = RunState(
      stage: 1,
      money: initialMoney,
      gold: 500,
      currencyLocale: locale,
      currentOpponentIndex: 0,
      opponentMoney: firstOpponentFund,
    );
    _autoSave();
  }

  /// 승리 시 정산 — 상대 자금 차감, 0 이하면 다음 상대/스테이지
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
        // 스테이지 클리어! → 다음 스테이지
        newStage = state.stage + 1;
        newOpIdx = 0;
        nextOpMoney = getOpponentFund(newStage, 0, currency.pointValue);
      }
    }

    state = state.copyWith(
      money: newMoney,
      stage: newStage,
      currentOpponentIndex: newOpIdx,
      opponentMoney: nextOpMoney,
      wins: state.wins + 1,
      winStreak: state.winStreak + 1,
      highestScore: score > state.highestScore ? score : state.highestScore,
      highestMoney: newMoney > state.highestMoney ? newMoney : state.highestMoney,
      moneyHistory: [...state.moneyHistory, newMoney],
      equippedRoundItemIds: const [], // 장착된 1회용 아이템 소멸
    );
    _autoSave();
  }

  /// 패배 시 정산 — 상대 자금 증가
  void onLose(double penalty) {
    // P-002 [안전모] 파산 방지 로직
    final currency = getCurrencyForLocale(state.currencyLocale);
    final minStake = currency.pointValue * 3; // 3점 금액 (파산 기준선)
    double newMoney = (state.money - penalty).clamp(0, double.infinity);
    
    if (newMoney <= minStake && state.equippedRoundItemIds.contains('P-002')) {
      // 파산 위기 탈출! (최소 판돈 + 10점의 부조금 지급)
      newMoney = minStake + (currency.pointValue * 10);
    }

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

  /// 파산 여부 체크 (남은 돈이 최소 판돈의 10% 이하면 파산)
  bool get isBankrupt {
    final currency = getCurrencyForLocale(state.currencyLocale);
    final minStake = currency.pointValue * 3; // 3점어치 금액 = 최소 판돈
    return state.money <= minStake;
  }

  /// 런 재시작 (처음부터 다시)
  Future<void> restartRun() async {
    await GameSaveManager.deleteSave();
    newGame(state.currencyLocale);
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

  /// 자동 저장
  void _autoSave() {
    GameSaveManager.save(state);
  }
}

