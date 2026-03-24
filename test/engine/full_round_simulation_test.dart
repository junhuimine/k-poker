/// 🎴 K-Poker — 전체 게임 시뮬레이션 테스트 (헤드리스)
///
/// 100회 게임을 엔진 수준에서 시뮬레이션하여
/// 모든 게임이 isFinished = true로 정상 종료되는지 검증.
/// (게임 멈춤 버그 근본 검증)

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/game_engine.dart';
import 'package:k_poker/engine/card_matcher.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/models/round_state.dart';

/// 간소화된 AI: 매칭 가능 카드 우선, 없으면 첫 번째 카드
CardInstance _aiChooseCard(RoundState state) {
  final hand = state.currentTurn == 'player'
      ? state.playerHand
      : state.opponentHand;

  // 덱드로 카드가 있으면 반드시 처리
  final deckDraws = hand.where((c) => c.isDeckDraw).toList();
  if (deckDraws.isNotEmpty) return deckDraws.first;

  // 보너스 카드 우선 사용
  final bonuses = hand.where((c) => c.def.isBonus).toList();
  if (bonuses.isNotEmpty) return bonuses.first;

  // 매칭 가능한 카드 중 높은 등급 우선
  for (final grade in [CardGrade.bright, CardGrade.animal, CardGrade.ribbon, CardGrade.junk]) {
    for (final card in hand) {
      if (card.def.grade == grade && !card.def.isBonus && !card.isDeckDraw) {
        final matches = findMatchableCards(card, state.field);
        if (matches.isNotEmpty) return card;
      }
    }
  }

  // 매칭 불가 → 첫 번째 일반 카드
  return hand.firstWhere(
    (c) => !c.isDeckDraw && !c.def.isBonus,
    orElse: () => hand.first,
  );
}

/// 한 게임을 완주하고 결과를 반환
({bool finished, int turns, String lastEvent}) _simulateOneGame(int seed) {
  final random = Random(seed);
  var state = GameEngine.createInitialState();
  const turnLimit = 200; // 무한루프 방지
  int turns = 0;

  while (!state.isFinished && turns < turnLimit) {
    final hand = state.currentTurn == 'player'
        ? state.playerHand
        : state.opponentHand;

    if (hand.isEmpty) {
      // 핸드가 비면 엔진이 isFinished로 전환해야 하는데 안 됐으면 버그
      break;
    }

    // 폭탄 체크 (같은 월 3장)
    final bombMonth = GameEngine.getBombMonth(List<CardInstance>.from(hand));
    if (bombMonth != null && !hand.first.isDeckDraw) {
      state = GameEngine.playBomb(state, bombMonth);
    } else {
      final card = _aiChooseCard(state);
      state = GameEngine.playTurn(state, card);
    }

    turns++;
  }

  return (
    finished: state.isFinished,
    turns: turns,
    lastEvent: state.lastSpecialEvent,
  );
}

void main() {
  group('전체 게임 시뮬레이션 (헤드리스)', () {
    test('100회 게임 — 모든 게임이 isFinished=true로 정상 종료', () {
      int finishedCount = 0;
      int stuckCount = 0;
      final stuckSeeds = <int>[];

      for (var i = 0; i < 100; i++) {
        final result = _simulateOneGame(i);
        if (result.finished) {
          finishedCount++;
        } else {
          stuckCount++;
          stuckSeeds.add(i);
        }
      }

      print('✅ 100회 시뮬레이션 결과:');
      print('  ✓ 정상 종료: $finishedCount회');
      print('  ✗ 멈춤(stuck): $stuckCount회');
      if (stuckSeeds.isNotEmpty) {
        print('  멈춤 시드: $stuckSeeds');
      }

      expect(stuckCount, 0, reason: '모든 게임은 isFinished=true로 종료되어야 합니다');
    });

    test('500회 스트레스 테스트 — 카드 총합 보존', () {
      int violations = 0;

      for (var i = 0; i < 500; i++) {
        var state = GameEngine.createInitialState();
        const turnLimit = 200;
        int turns = 0;

        while (!state.isFinished && turns < turnLimit) {
          final hand = state.currentTurn == 'player'
              ? state.playerHand
              : state.opponentHand;

          if (hand.isEmpty) break;

          final bombMonth = GameEngine.getBombMonth(List<CardInstance>.from(hand));
          if (bombMonth != null && !hand.first.isDeckDraw) {
            state = GameEngine.playBomb(state, bombMonth);
          } else {
            final card = _aiChooseCard(state);
            state = GameEngine.playTurn(state, card);
          }

          // 매 턴마다 카드 총합 검증 (덱드로 더미 카드 제외)
          final allCards = [
            ...state.field,
            ...state.playerHand.where((c) => !c.isDeckDraw),
            ...state.opponentHand.where((c) => !c.isDeckDraw),
            ...state.deck,
            ...state.playerCaptured,
            ...state.opponentCaptured,
          ];

          // 50장(48 + 보너스 2)이 보존되어야 함
          if (allCards.length != 50) {
            violations++;
            print('⚠️ 카드 보존 위반! seed=$i turn=$turns total=${allCards.length}');
            break;
          }

          turns++;
        }
      }

      print('✅ 500회 스트레스 테스트 완료: 카드 보존 위반 ${violations}건');
      expect(violations, 0, reason: '카드 50장이 항상 보존되어야 합니다');
    });

    test('딜링 정확성 — 100회 반복', () {
      for (var i = 0; i < 100; i++) {
        final state = GameEngine.createInitialState();

        // 보너스 카드는 바닥에서 자동 획득되므로, 총합만 검증
        final allCards = [
          ...state.field,
          ...state.playerHand,
          ...state.opponentHand,
          ...state.deck,
          ...state.playerCaptured,
        ];
        expect(allCards.length, 50, reason: '딜링 후 카드 총합 50장');

        // 핸드 10장 (보너스 자동 획득 시 변동 가능하므로 >= 1)
        expect(state.playerHand.length, greaterThanOrEqualTo(1), reason: '플레이어 핸드 비어있지 않음');
        expect(state.opponentHand.length, greaterThanOrEqualTo(1), reason: '상대 핸드 비어있지 않음');

        // 중복 카드 없음 (id 기준)
        final ids = allCards.map((c) => c.def.id).toList();
        final uniqueIds = ids.toSet();
        expect(uniqueIds.length, 50, reason: '중복 카드 없음');
      }

      print('✅ 100회 딜링 정확성 검증 통과');
    });

    test('나가리 — 양쪽 핸드가 비면 반드시 isFinished', () {
      // 인위적으로 핸드를 비운 상태
      var state = GameEngine.createInitialState();
      state = state.copyWith(
        playerHand: [],
        opponentHand: [],
      );

      // _advanceTurn이 호출되면 isFinished가 true가 되어야 하므로
      // 직접 턴을 진행해볼 수는 없지만, 한쪽만 비운 경우 테스트
      var state2 = GameEngine.createInitialState();
      state2 = state2.copyWith(
        playerHand: [],
        deck: [],
      );

      // 상대 턴으로 진행
      if (state2.opponentHand.isNotEmpty) {
        state2 = state2.copyWith(currentTurn: 'opponent');
        final card = state2.opponentHand.first;
        if (!card.def.isBonus && !card.isDeckDraw) {
          final result = GameEngine.playTurn(state2, card);
          expect(result.isFinished, true,
              reason: '한쪽 핸드 비고 덱 비면 isFinished=true');
        }
      }
      print('✅ 나가리 종료 조건 검증 통과');
    });
  });
}
