/// 🎴 K-Poker — Riverpod 상태 관리 (GDD 2.0)
///
/// AI 자동 턴, 고/스톱, 점수 계산, 판돈/소지금, 저장/불러오기 포함.

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
  @override
  RoundState build() {
    return const RoundState();
  }

  /// 게임 시작 (딜링)
  void startGame() {
    ref.read(gameEventsProvider.notifier).clear();
    ref.read(goStopPendingProvider.notifier).hide();
    state = GameEngine.createInitialState();
    ref.read(gameEventsProvider.notifier).addEvent('start', '🎴 새 라운드 시작!');
  }

  /// 총통 감지 (핸드에 같은 월 4장)
  int? getPlayerChongtong() => GameEngine.getChongtongMonth(state.playerHand);

  /// 총통 선언! (같은 월 4장 즉시 획득 + 상대 피 2장 빼앗기 + 3배)
  void declareChongtong(int month) {
    if (state.isFinished || state.currentTurn != 'player') return;

    // 핸드에서 해당 월 4장 추출
    final chongtongCards = state.playerHand.where((c) => c.def.month == month).toList();
    if (chongtongCards.length < 4) return;

    // 바닥에서도 같은 월 제거 (있으면)
    final fieldSameMonth = state.field.where((c) => c.def.month == month).toList();
    final allCaptured = [...chongtongCards, ...fieldSameMonth];

    // 상대 피 2장 빼앗기
    final opJunks = state.opponentCaptured.where((c) => c.def.grade == CardGrade.junk).toList();
    final stolenCount = opJunks.length >= 2 ? 2 : opJunks.length;
    final stolenJunks = opJunks.take(stolenCount).toList();
    
    var newState = state.copyWith(
      playerHand: state.playerHand.where((c) => c.def.month != month).toList(),
      field: state.field.where((c) => c.def.month != month).toList(),
      playerCaptured: [...state.playerCaptured, ...allCaptured, ...stolenJunks],
      opponentCaptured: state.opponentCaptured.where((c) => !stolenJunks.contains(c)).toList(),
      sweepCount: state.sweepCount + 1, // 총통 = 쓸 1회 추가
    );

    AudioManager().cardSweep();
    ref.read(gameEventsProvider.notifier)
        .addEvent('bomb', '🎆 총통! ${month}월 4장! 즉시 획득!${stolenCount > 0 ? ' + 피 ${stolenCount}장 빼앗기!' : ''}');
    ref.read(yakuAnnounceProvider.notifier).announce('🎆 총통!');
    Future.delayed(const Duration(milliseconds: 2000), () {
      ref.read(yakuAnnounceProvider.notifier).clear();
    });

    // 점수 업데이트
    final run = ref.read(runStateNotifierProvider);
    final scoreResult = ScoreCalculator.calculate(newState, run);
    state = newState.copyWith(
      playerScore: scoreResult.finalScore,
      baseChips: scoreResult.baseChips,
      multiplier: scoreResult.multiplier,
    );

    // 총통이면 무조건 3점 이상 → 고/스톱 선택
    if (scoreResult.finalScore >= 3) {
      ref.read(goStopPendingProvider.notifier).show();
    }
  }

  /// 카드 플레이 (플레이어)
  void playCard(CardInstance card, {CardInstance? selectedMatch}) {
    if (state.isFinished || state.currentTurn != 'player') return;

    // 1. 플레이어 턴 실행
    final prevCaptured = state.playerCaptured.length;
    final nextState = GameEngine.playTurn(state, card, selectedMatch: selectedMatch);

    // 2. 매칭 피드백 이벤트 + SFX
    final newCaptured = nextState.playerCaptured.length - prevCaptured;
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.wins + run.losses);
    var modifiedNextState = nextState;

    if (newCaptured > 0) {
      AudioManager().cardMatch();
      final hasBright = modifiedNextState.playerCaptured.any((c) => c.def.grade == CardGrade.bright && !state.playerCaptured.contains(c));
      if (hasBright) AudioManager().brightCapture();
      ref.read(gameEventsProvider.notifier)
          .addEvent('match', '✅ ${card.def.nameKo} → $newCaptured장 획득!');
      
      final lines = ai.dialogues['player_match'] ?? ['흥!'];
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${lines[DateTime.now().millisecond % lines.length]}"');
    } else {
      ref.read(gameEventsProvider.notifier)
          .addEvent('miss', '❌ ${card.def.nameKo} → 매칭 실패');
      
      final lines = ai.dialogues['player_miss'] ?? ['쯧쯧'];
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${lines[DateTime.now().millisecond % lines.length]}"');
    }

    // 쓸(sweep) 감지 및 피 뺏기
    if (modifiedNextState.sweepCount > state.sweepCount || (modifiedNextState.field.isEmpty && newCaptured > 0)) {
      AudioManager().cardSweep();
      
      // 상대 피 1장 빼앗기 로직
      final opJunks = modifiedNextState.opponentCaptured.where((c) => c.def.grade == CardGrade.junk).toList();
      String sweepText = '🌊 쓸! 바닥을 쓸었다!';
      if (opJunks.isNotEmpty) {
        final stolenJunk = opJunks.first;
        modifiedNextState = modifiedNextState.copyWith(
          sweepCount: modifiedNextState.sweepCount == state.sweepCount ? modifiedNextState.sweepCount + 1 : modifiedNextState.sweepCount,
          playerCaptured: [...modifiedNextState.playerCaptured, stolenJunk],
          opponentCaptured: modifiedNextState.opponentCaptured.where((c) => c != stolenJunk).toList(),
        );
        sweepText += ' + 상대 피 빼앗기!';
      }
      ref.read(gameEventsProvider.notifier).addEvent('sweep', sweepText);
      
      // AI 쓸 반응 대사
      final sweepLines = ai.dialogues['sweep_react'] ?? ['내 피...!'];
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${sweepLines[DateTime.now().millisecond % sweepLines.length]}"');
    }

    // 3. 점수 업데이트
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

    // 4. 게임 종료 체크
    if (state.isFinished) {
      _handleRoundEnd();
      return;
    }

    // 5. 고/스톱 판정 (점수 3점 이상 달성 + 새 족보 추가되었을 때)
    final prevPoints = state.goCount > 0 ? state.baseChips : 0; // 고 선언 후로도 점수 증가 시 재판정
    if (scoreResult.finalScore >= 3 && scoreResult.baseChips > prevPoints) {
      ref.read(goStopPendingProvider.notifier).show();
      return;
    }

    // 6. AI 턴
    if (state.currentTurn == 'opponent' && !state.isFinished) {
      // AI 핸드가 비면 나가리 처리
      if (state.opponentHand.isEmpty) {
        state = state.copyWith(isFinished: true);
        _handleRoundEnd();
        return;
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!state.isFinished) _playAiTurn();
      });
    }
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
        .addEvent('bomb', '💣 폭탄! ${bombMonth}월 3장 일괄 획득!${stolenJunk ? ' + 상대 피 빼앗기!' : ''}');

    // AI 반응 대사
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.wins + run.losses);
    final bombLines = ai.dialogues['bomb_react'] ?? ['앗!'];
    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${bombLines[DateTime.now().millisecond % bombLines.length]}"');

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

    // AI 턴
    if (state.currentTurn == 'opponent' && !state.isFinished) {
      // AI 핸드가 비면 나가리 처리
      if (state.opponentHand.isEmpty) {
        state = state.copyWith(isFinished: true);
        _handleRoundEnd();
        return;
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!state.isFinished) _playAiTurn();
      });
    }
  }

  /// 고! 선언
  void declareGo() {
    ref.read(goStopPendingProvider.notifier).hide();
    AudioManager().goDeclare();
    ref.read(gameEventsProvider.notifier).addEvent('go', '🔥 고! 선언! (배율 증가)');

    // AI 반응 대사 (고 횟수에 따라 다름)
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.wins + run.losses);
    final isFear = state.goCount >= 2; // 3고 이상 (현재 count 2일때 선언하면 3고가 됨)
    final goLines = isFear 
        ? (ai.dialogues['player_go_fear'] ?? ['안돼!'])
        : (ai.dialogues['player_go'] ?? ['오호, 대담하네!']);
    final goLine = goLines[DateTime.now().millisecond % goLines.length];
    
    // 두려운 상황이면 추가 놀라는 SFX 플레이 가능
    if (isFear) AudioManager().cardSweep(); // 에러음 대신 쓸과 비슷한 임팩트음 사용

    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$goLine"');

    state = state.copyWith(
      goCount: state.goCount + 1,
      multiplier: state.multiplier * 2.0,
    );

    if (state.currentTurn == 'opponent') {
      Future.delayed(const Duration(milliseconds: 1200), () => _playAiTurn());
    }
  }

  /// 스톱! 선언
  void declareStop() {
    ref.read(goStopPendingProvider.notifier).hide();
    AudioManager().stopDeclare();
    ref.read(gameEventsProvider.notifier).addEvent('stop', '🛑 스톱! 라운드 종료!');

    // AI 반응 대사 (점수에 따라 다름)
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.wins + run.losses);
    final isBig = state.playerScore >= 10;
    final stopLines = isBig 
        ? (ai.dialogues['player_stop_big'] ?? ['너무하네!'])
        : (ai.dialogues['player_stop_small'] ?? ['소박하네~']);
    final stopLine = stopLines[DateTime.now().millisecond % stopLines.length];
    ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$stopLine"');

    state = state.copyWith(isFinished: true);
    _handleRoundEnd();
  }

  /// AI가 어떤 카드를 낼지 선택만 반환 (애니메이션용)
  CardInstance? getAiChoice() {
    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.wins + run.losses);

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
        if (card.def.grade == CardGrade.bright) cardScore = 100;
        else if (card.def.grade == CardGrade.animal) cardScore = 50;
        else if (card.def.grade == CardGrade.ribbon) cardScore = 30;
        else cardScore = 10;
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
    final ai = getAiForStage(run.stage, run.wins + run.losses);

    final prevCaptured = state.opponentCaptured.length;
    final nextState = GameEngine.playTurn(state, card);
    final newCaptured = nextState.opponentCaptured.length - prevCaptured;

    if (newCaptured > 0) {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', '🤖 AI: ${card.def.nameKo} → $newCaptured장 획득');
      final matchLine = ai.getDialogue('match');
      if (matchLine != null) {
        ref.read(gameEventsProvider.notifier)
            .addEvent('ai_talk', '💬 ${ai.emoji} "$matchLine"');
      }
    } else {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', '🤖 AI: ${card.def.nameKo}');
      final missLine = ai.getDialogue('miss');
      if (missLine != null) {
        ref.read(gameEventsProvider.notifier)
            .addEvent('ai_talk', '💬 ${ai.emoji} "$missLine"');
      }
    }

    state = nextState;

    // AI 점수 계산
    final aiRun = ref.read(runStateNotifierProvider);
    final aiScoreState = nextState.copyWith(
      playerCaptured: nextState.opponentCaptured,
      opponentCaptured: nextState.playerCaptured,
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
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', '🤖 AI: 스톱! 라운드 종료!');
        
        final stopLines = ai.dialogues['stop'] ?? ['스톱!'];
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${stopLines[DateTime.now().millisecond % stopLines.length]}"');

        state = state.copyWith(isFinished: true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          ref.read(aiGoStopAnnounceProvider.notifier).clear();
          _handleRoundEnd();
        });
      } else {
        AudioManager().goDeclare(); // AI 고 효과음
        final newGoCount = aiGoCount + 1;
        ref.read(aiGoStopAnnounceProvider.notifier).announce('go_$newGoCount');
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', '🤖🔥 AI: 고! ×$newGoCount');
        
        final goLines = ai.dialogues['go'] ?? ['고!'];
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${goLines[DateTime.now().millisecond % goLines.length]}"');

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
  void _playAiTurn() {
    if (state.isFinished || state.currentTurn != 'opponent') return;

    final run = ref.read(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.wins + run.losses);

    // AI 폭탄 체크: 높은 난이도 AI만 폭탄 사용
    if (ai.matchPriority >= 0.7) {
      final aiBombMonth = GameEngine.getBombMonth(
        List<CardInstance>.from(state.opponentHand),
      );
      if (aiBombMonth != null) {
        AudioManager().cardSweep(); // 폭탄 효과음
        final nextState = GameEngine.playBomb(state, aiBombMonth);
        ref.read(gameEventsProvider.notifier)
            .addEvent('ai_play', '🤖💣 AI: ${aiBombMonth}월 폭탄!');
        
        final bombLines = ai.dialogues['bomb'] ?? ['폭탄이다!'];
        ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "${bombLines[DateTime.now().millisecond % bombLines.length]}"');
        
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
        if (card.def.grade == CardGrade.bright) cardScore = 100;
        else if (card.def.grade == CardGrade.animal) cardScore = 50;
        else if (card.def.grade == CardGrade.ribbon) cardScore = 30;
        else cardScore = 10;
        
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
    final nextState = GameEngine.playTurn(state, bestCard);
    final newCaptured = nextState.opponentCaptured.length - prevCaptured;

    if (newCaptured > 0) {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', '🤖 AI: ${bestCard.def.nameKo} → $newCaptured장 획득');
      // #6 AI 대사
      final matchLine = ai.getDialogue('match');
      if (matchLine != null) {
        ref.read(gameEventsProvider.notifier)
            .addEvent('ai_talk', '💬 ${ai.emoji} "$matchLine"');
      }
    } else {
      ref.read(gameEventsProvider.notifier)
          .addEvent('ai_play', '🤖 AI: ${bestCard.def.nameKo}');
      final missLine = ai.getDialogue('miss');
      if (missLine != null) {
        ref.read(gameEventsProvider.notifier)
            .addEvent('ai_talk', '💬 ${ai.emoji} "$missLine"');
      }
    }

    state = nextState;

    // AI 점수 계산 (상대 시점)
    final aiRun = ref.read(runStateNotifierProvider);
    final aiScoreState = nextState.copyWith(
      playerCaptured: nextState.opponentCaptured,
      opponentCaptured: nextState.playerCaptured,
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
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', '🤖 AI: 스톱! 라운드 종료!');
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
        ref.read(gameEventsProvider.notifier).addEvent('ai_play', '🤖🔥 AI: 고! ×$newGoCount');
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
    
    // 수입 계산: 점수(baseChips) × 판돈 단위(pointValue) × 배율(multiplier)
    // 공식 고스톱: 점수 × 판돈 = 수입
    final baseScore = state.baseChips; // score_calculator에서 계산된 기본 점수
    final mult = state.multiplier;     // 박 배율
    final earnings = baseScore * currency.pointValue * mult;

    // AI 반응 대사 (win/lose)
    final ai = getAiForStage(run.stage, run.wins + run.losses);
    if (state.playerScore > state.opponentScore) {
      // 플레이어 승리 → AI는 lose 대사
      final loseLines = ai.dialogues['lose'] ?? ['다음엔 지지 않을 거야...'];
      final loseLine = loseLines[DateTime.now().millisecond % loseLines.length];
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$loseLine"');
      
      ref.read(runStateNotifierProvider.notifier).onWin(earnings, state.playerScore);
      ref.read(gameEventsProvider.notifier)
          .addEvent('round_end', '🏆 승리! +${currency.formatAmount(earnings)}');
    } else {
      // 플레이어 패배 → AI는 win 대사
      final winLines = ai.dialogues['win'] ?? ['내가 이겼다!'];
      final winLine = winLines[DateTime.now().millisecond % winLines.length];
      ref.read(gameEventsProvider.notifier).addEvent('ai_talk', '💬 ${ai.emoji} "$winLine"');
      
      // 패배 시: 상대 점수 × 판돈 단위
      final opScore = state.opponentScore > 0 ? state.opponentScore : 1;
      final penalty = opScore * currency.pointValue;
      ref.read(runStateNotifierProvider.notifier).onLose(penalty);
      ref.read(gameEventsProvider.notifier)
          .addEvent('round_end', '💀 패배... -${currency.formatAmount(penalty)}');
    }

    // 자동 저장
    final updatedRun = ref.read(runStateNotifierProvider);
    GameSaveManager.save(updatedRun);
  }
}

/// 전체 런 상태 관리자
@riverpod
class RunStateNotifier extends _$RunStateNotifier {
  @override
  RunState build() => const RunState();

  /// 저장된 게임 불러오기
  Future<bool> loadGame() async {
    final saved = await GameSaveManager.load();
    if (saved != null) {
      state = saved;
      return true;
    }
    return false;
  }

  /// 새 게임 시작
  void newGame(String locale) {
    final currency = getCurrencyForLocale(locale);
    final initialMoney = stageConfigs[0].stakeMultiplier * currency.pointValue * 5; // 판돈 5배
    state = RunState(
      stage: 1,
      money: initialMoney,
      currencyLocale: locale,
    );
    _autoSave();
  }

  /// 승리 시 정산
  void onWin(double earnings, int score) {
    final newMoney = state.money + earnings;
    final stageConfig = getStageConfig(state.stage);
    final currency = getCurrencyForLocale(state.currencyLocale);
    final stake = stageConfig.getStake(currency.pointValue);
    final newStageEarned = state.stageEarned + earnings;

    // 스테이지 클리어 판정
    int newStage = state.stage;
    double resetEarned = newStageEarned;
    if (newStageEarned >= stake) {
      newStage = state.stage + 1;
      resetEarned = 0;
    }

    state = state.copyWith(
      money: newMoney,
      stageEarned: resetEarned,
      stage: newStage,
      wins: state.wins + 1,
      winStreak: state.winStreak + 1,
      highestScore: score > state.highestScore ? score : state.highestScore,
      highestMoney: newMoney > state.highestMoney ? newMoney : state.highestMoney,
      moneyHistory: [...state.moneyHistory, newMoney],
    );
    _autoSave();
  }

  /// 패배 시 정산
  void onLose(double penalty) {
    final newMoney = (state.money - penalty).clamp(0, double.infinity);
    state = state.copyWith(
      money: newMoney.toDouble(),
      losses: state.losses + 1,
      winStreak: 0,
      moneyHistory: [...state.moneyHistory, newMoney.toDouble()],
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

  /// 금화 추가 (레거시 호환)
  void addGold(int amount) {
    state = state.copyWith(gold: state.gold + amount);
  }

  /// 기술 구매
  void buySkill(String skillId, double cost) {
    if (state.money < cost) return;
    state = state.copyWith(
      activeSkillIds: [...state.activeSkillIds, skillId],
      money: state.money - cost,
    );
    _autoSave();
  }

  /// 부적 구매
  void buyTalisman(String talismanId, double cost) {
    if (state.money < cost) return;
    state = state.copyWith(
      activeTalismanIds: [...state.activeTalismanIds, talismanId],
      money: state.money - cost,
    );
    _autoSave();
  }

  /// 자동 저장
  void _autoSave() {
    GameSaveManager.save(state);
  }
}

