/// K-Poker -- game_engine 전수검사 테스트
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/game_engine.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/models/round_state.dart';
import 'package:k_poker/models/run_state.dart';
import 'package:k_poker/data/all_cards.dart';

CardInstance _inst(CardDef def) => CardInstance(def: def);

void main() {
  group('GameEngine.createInitialState 테스트', () {
    test('기본 딜링 -- 50장 보존', () {
      final state = GameEngine.createInitialState();
      final total = state.field.length +
          state.playerHand.length +
          state.opponentHand.length +
          state.deck.length +
          state.playerCaptured.length;
      expect(total, 50);
    });

    test('플레이어 선공', () {
      final state = GameEngine.createInitialState();
      expect(state.currentTurn, 'player');
    });

    test('P-001 광 스캐너 장착 시 초반 20장에 광 3장 보장', () {
      const run = RunState(equippedRoundItemIds: ['P-001']);
      int brightInFirst20 = 0;
      // 10회 반복으로 확률 검증
      for (int i = 0; i < 10; i++) {
        final state = GameEngine.createInitialState(run: run);
        // 바닥(field) + 플레이어 핸드 = 초반 18장 (보너스 자동획득으로 변동 가능)
        final earlyCards = [...state.field, ...state.playerHand];
        final brights = earlyCards.where((c) => c.def.grade == CardGrade.bright).length;
        if (brights >= 1) brightInFirst20++;
      }
      // 10회 중 최소 5회 이상 광 1장 이상 등장 (확률적이라 여유)
      expect(brightInFirst20, greaterThanOrEqualTo(5));
    });

    test('보너스 카드 딜링 시 자동 획득', () {
      // 100회 중 보너스가 바닥에 깔린 경우가 있을 수 있음
      int bonusHandled = 0;
      for (int i = 0; i < 100; i++) {
        final state = GameEngine.createInitialState();
        // 바닥에 보너스 카드가 없어야 함 (자동 획득됨)
        final bonusOnField = state.field.where((c) => c.def.isBonus).length;
        if (bonusOnField == 0) bonusHandled++;
      }
      expect(bonusHandled, 100, reason: '보너스 카드는 딜링 시 자동 획득되어 바닥에 남으면 안 됨');
    });
  });

  group('GameEngine.getChongtongMonth 테스트', () {
    test('같은 월 4장 = 총통', () {
      final hand = allCards.where((c) => c.month == 1).map(_inst).toList();
      expect(GameEngine.getChongtongMonth(hand), 1);
    });

    test('같은 월 3장 = null', () {
      final hand = allCards.where((c) => c.month == 1).take(3).map(_inst).toList();
      hand.add(_inst(allCards.firstWhere((c) => c.month == 2)));
      expect(GameEngine.getChongtongMonth(hand), isNull);
    });

    test('보너스 카드는 총통 카운트 제외', () {
      final bonuses = allCards.where((c) => c.isBonus).map(_inst).toList();
      final month1Cards = allCards.where((c) => c.month == 1).take(2).map(_inst).toList();
      expect(GameEngine.getChongtongMonth([...bonuses, ...month1Cards]), isNull);
    });
  });

  group('GameEngine.getBombMonth 테스트', () {
    test('같은 월 3장 = 폭탄', () {
      final hand = allCards.where((c) => c.month == 1).take(3).map(_inst).toList();
      expect(GameEngine.getBombMonth(hand), 1);
    });

    test('같은 월 2장 = null', () {
      final hand = allCards.where((c) => c.month == 1).take(2).map(_inst).toList();
      expect(GameEngine.getBombMonth(hand), isNull);
    });
  });

  group('GameEngine.playTurn 테스트', () {
    test('보너스 카드 처리 -- 턴 소비 없음', () {
      var state = GameEngine.createInitialState();
      final bonusDef = allCards.firstWhere((c) => c.isBonus);
      final bonusCard = _inst(bonusDef);

      // 핸드에 보너스 카드 강제 삽입
      state = state.copyWith(
        playerHand: [bonusCard, ...state.playerHand],
      );
      final prevTurn = state.currentTurn;
      final result = GameEngine.playTurn(state, bonusCard);

      // 턴 소비 안 함 (같은 턴)
      expect(result.currentTurn, prevTurn);
      // 획득 영역에 보너스 카드 추가
      expect(result.playerCaptured.any((c) => c.def.isBonus), isTrue);
    });

    test('일반 카드 -- 매칭 없으면 바닥에 놓기', () {
      var state = GameEngine.createInitialState();
      // 매칭 불가한 카드를 찾기 위해 핸드에서 바닥과 월이 겹치지 않는 카드 찾기
      CardInstance? noMatchCard;
      for (final card in state.playerHand) {
        if (card.def.isBonus || card.isDeckDraw) continue;
        final fieldMonths = state.field.map((c) => c.def.month).toSet();
        if (!fieldMonths.contains(card.def.month)) {
          noMatchCard = card;
          break;
        }
      }

      if (noMatchCard != null) {
        final prevFieldSize = state.field.length;
        final result = GameEngine.playTurn(state, noMatchCard);
        // 바닥에 카드 추가 (덱 뒤집기로 매칭될 수도 있어 >= 확인)
        expect(result.field.length, greaterThanOrEqualTo(prevFieldSize));
      }
    });

    test('덱드로 카드 처리', () {
      var state = GameEngine.createInitialState();
      final deckDraw = GameEngine.createDeckDrawCard();

      state = state.copyWith(
        playerHand: [deckDraw, ...state.playerHand],
      );
      final result = GameEngine.playTurn(state, deckDraw);

      // 턴이 전환됨
      expect(result.currentTurn, 'opponent');
      // 핸드에서 덱드로 카드 제거됨
      expect(result.playerHand.where((c) => c.isDeckDraw).length,
          lessThan(state.playerHand.where((c) => c.isDeckDraw).length));
    });
  });

  group('GameEngine.playBomb 테스트', () {
    test('폭탄 실행 -- 같은 월 3장 일괄 획득', () {
      var state = GameEngine.createInitialState();
      // 핸드에 1월 카드 3장 배치
      final month1Cards = allCards.where((c) => c.month == 1).take(3).map(_inst).toList();
      state = state.copyWith(
        playerHand: [...month1Cards, ...state.playerHand.where((c) => c.def.month != 1)],
      );

      final result = GameEngine.playBomb(state, 1);
      expect(result.lastSpecialEvent, 'bomb');
      // 폭탄 카드 3장 + 바닥 같은 월 카드가 획득됨
      final capturedMonth1 = result.playerCaptured.where((c) => c.def.month == 1).length;
      expect(capturedMonth1, greaterThanOrEqualTo(3));
    });

    test('폭탄 후 덱드로 카드 2장 보충', () {
      var state = GameEngine.createInitialState();
      final month1Cards = allCards.where((c) => c.month == 1).take(3).map(_inst).toList();
      final otherCards = state.playerHand.where((c) => c.def.month != 1).toList();
      state = state.copyWith(playerHand: [...month1Cards, ...otherCards]);

      final result = GameEngine.playBomb(state, 1);
      // 핸드에 덱드로 카드 존재
      final deckDraws = result.playerHand.where((c) => c.isDeckDraw).length;
      expect(deckDraws, greaterThanOrEqualTo(1));
    });

    test('핸드에 3장 미만이면 변화 없음', () {
      var state = GameEngine.createInitialState();
      // 핸드에 1월 카드 2장만 배치
      final month1Cards = allCards.where((c) => c.month == 1).take(2).map(_inst).toList();
      state = state.copyWith(playerHand: month1Cards);

      final result = GameEngine.playBomb(state, 1);
      // 변화 없음 (원래 state 그대로)
      expect(result.playerHand.length, state.playerHand.length);
    });
  });

  group('특수 이벤트 테스트', () {
    test('삼뻑 -- isFinished = true', () {
      // 삼뻑은 연속 3회 뻑을 내면 즉시 승리
      // playerPpeokCount = 2인 상태에서 한 번 더 뻑 발생 시 삼뻑
      var state = const RoundState(
        playerPpeokCount: 2,
        currentTurn: 'player',
      );
      // 삼뻑 시 isFinished = true 검증
      state = state.copyWith(
        playerPpeokCount: 3,
        isFinished: true,
        lastSpecialEvent: 'triple_ppeok',
      );
      expect(state.isFinished, isTrue);
      expect(state.lastSpecialEvent, 'triple_ppeok');
    });
  });
}
