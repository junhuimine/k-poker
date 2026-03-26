/// K-Poker -- ai_player 전수검사 테스트
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/ai_player.dart';
import 'package:k_poker/engine/game_engine.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/models/round_state.dart';
import 'package:k_poker/data/all_cards.dart';

CardInstance _inst(CardDef def) => CardInstance(def: def);

void main() {
  group('AiPlayer.getStrategy 단계별 전략 매핑', () {
    test('Stage 1-2 = RandomAi', () {
      expect(AiPlayer.getStrategy(1), isA<RandomAi>());
      expect(AiPlayer.getStrategy(2), isA<RandomAi>());
    });

    test('Stage 3-4 = GreedyAi', () {
      expect(AiPlayer.getStrategy(3), isA<GreedyAi>());
      expect(AiPlayer.getStrategy(4), isA<GreedyAi>());
    });

    test('Stage 5-6 = StrategicAi', () {
      expect(AiPlayer.getStrategy(5), isA<StrategicAi>());
      expect(AiPlayer.getStrategy(6), isA<StrategicAi>());
    });

    test('Stage 7+ = StrategicAi (aggressive)', () {
      final strategy = AiPlayer.getStrategy(7);
      expect(strategy, isA<StrategicAi>());
    });
  });

  group('RandomAi 테스트', () {
    test('chooseCard -- 핸드에서 카드 반환', () {
      final ai = RandomAi();
      final state = GameEngine.createInitialState().copyWith(
        currentTurn: 'opponent',
      );
      final card = ai.chooseCard(state);
      expect(state.opponentHand, contains(card));
    });

    test('chooseMatch -- 매칭 목록에서 반환', () {
      final ai = RandomAi();
      final card = _inst(allCards[0]);
      final matches = [_inst(allCards[1]), _inst(allCards[2])];
      final chosen = ai.chooseMatch(card, matches);
      expect(matches, contains(chosen));
    });

    test('decideGoStop -- 항상 false (스톱)', () {
      final ai = RandomAi();
      const state = RoundState(opponentScore: 5);
      expect(ai.decideGoStop(state), isFalse);
    });
  });

  group('GreedyAi 테스트', () {
    test('chooseCard -- 광 매칭 우선', () {
      final ai = GreedyAi();
      // 바닥에 1월 광 + 핸드에 1월 피
      final brightOnField = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final ribbonInHand = _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon'));
      final junkInHand = _inst(allCards.firstWhere((c) => c.id == 'm05_junk_1'));

      final state = RoundState(
        currentTurn: 'opponent',
        opponentHand: [ribbonInHand, junkInHand],
        field: [brightOnField],
        deck: allCards.skip(10).take(20).map(_inst).toList(),
      );

      final card = ai.chooseCard(state);
      // 1월 리본이 선택되어야 함 (1월 광과 매칭 가능)
      expect(card.def.month, 1);
    });

    test('chooseMatch -- 높은 등급 우선', () {
      final ai = GreedyAi();
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon'));
      final brightMatch = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final junkMatch = _inst(allCards.firstWhere((c) => c.id == 'm01_junk_1'));

      final chosen = ai.chooseMatch(played, [junkMatch, brightMatch]);
      expect(chosen.def.grade, CardGrade.bright);
    });

    test('decideGoStop -- 7점 이상이면 스톱', () {
      final ai = GreedyAi();
      expect(ai.decideGoStop(const RoundState(opponentScore: 7)), isFalse);
      expect(ai.decideGoStop(const RoundState(opponentScore: 3)), isTrue);
    });
  });

  group('StrategicAi 테스트', () {
    test('chooseCard -- 빈 핸드 에러 방지', () {
      final ai = StrategicAi();
      final card = _inst(allCards[0]);
      final state = RoundState(
        currentTurn: 'opponent',
        opponentHand: [card],
        field: [],
        deck: [],
      );

      final chosen = ai.chooseCard(state);
      expect(chosen, card);
    });

    test('chooseMatch -- 광 최우선', () {
      final ai = StrategicAi();
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon'));
      final bright = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final junk = _inst(allCards.firstWhere((c) => c.id == 'm01_junk_1'));

      final chosen = ai.chooseMatch(played, [junk, bright]);
      expect(chosen.def.grade, CardGrade.bright);
    });

    test('chooseMatch -- 고도리 새 우선 (광 없을 때)', () {
      final ai = StrategicAi();
      final played = _inst(allCards.firstWhere((c) => c.id == 'm02_ribbon'));
      final bird = _inst(allCards.firstWhere((c) => c.id == 'm02_animal')); // 새
      final junk = _inst(allCards.firstWhere((c) => c.id == 'm02_junk_1'));

      final chosen = ai.chooseMatch(played, [junk, bird]);
      expect(chosen.def.isBird, isTrue);
    });

    test('decideGoStop -- 점수 3 미만이면 고', () {
      final ai = StrategicAi();
      final state = RoundState(
        opponentScore: 2,
        deck: allCards.take(20).map(_inst).toList(),
      );
      expect(ai.decideGoStop(state), isTrue);
    });

    test('decideGoStop -- 점수 7 이상 기본 스톱', () {
      final ai = StrategicAi();
      final state = RoundState(
        opponentScore: 8,
        deck: allCards.take(5).map(_inst).toList(),
      );
      expect(ai.decideGoStop(state), isFalse);
    });
  });
}
