/// K-Poker -- card_matcher 전수검사 테스트
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/card_matcher.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/data/all_cards.dart';

CardInstance _inst(CardDef def) => CardInstance(def: def);

void main() {
  group('findMatchableCards 테스트', () {
    test('같은 월 카드가 필드에 있으면 반환', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [
        _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon')),
        _inst(allCards.firstWhere((c) => c.id == 'm02_animal')),
      ];

      final matches = findMatchableCards(played, field);
      expect(matches.length, 1);
      expect(matches[0].def.id, 'm01_ribbon');
    });

    test('같은 월 카드가 없으면 빈 리스트', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [
        _inst(allCards.firstWhere((c) => c.id == 'm02_animal')),
        _inst(allCards.firstWhere((c) => c.id == 'm03_bright')),
      ];

      final matches = findMatchableCards(played, field);
      expect(matches, isEmpty);
    });

    test('같은 월 3장 모두 반환', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [
        _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon')),
        _inst(allCards.firstWhere((c) => c.id == 'm01_junk_1')),
        _inst(allCards.firstWhere((c) => c.id == 'm01_junk_2')),
      ];

      final matches = findMatchableCards(played, field);
      expect(matches.length, 3);
    });
  });

  group('executeMatch 테스트', () {
    test('매칭 없음 -- matched=false', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [_inst(allCards.firstWhere((c) => c.id == 'm05_animal'))];

      final result = executeMatch(played, field);
      expect(result.matched, isFalse);
      expect(result.capturedCards, isEmpty);
    });

    test('1장 매칭 -- 자동 캡처', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [_inst(allCards.firstWhere((c) => c.id == 'm01_ribbon'))];

      final result = executeMatch(played, field);
      expect(result.matched, isTrue);
      expect(result.capturedCards.length, 2);
      expect(result.isSweep, isTrue); // 필드 비게 됨
    });

    test('2장 매칭 -- 선택 없으면 첫 번째', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [
        _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon')),
        _inst(allCards.firstWhere((c) => c.id == 'm01_junk_1')),
      ];

      final result = executeMatch(played, field);
      expect(result.matched, isTrue);
      expect(result.capturedCards.length, 2);
      expect(result.isPpuk, isFalse);
    });

    test('2장 매칭 -- selectedMatch 지정', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final junk1 = _inst(allCards.firstWhere((c) => c.id == 'm01_junk_1'));
      final field = [
        _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon')),
        junk1,
      ];

      final result = executeMatch(played, field, selectedMatch: junk1);
      expect(result.matched, isTrue);
      expect(result.capturedCards, contains(junk1));
    });

    test('3장 매칭 -- 뻑! 전부 가져감', () {
      final played = _inst(allCards.firstWhere((c) => c.id == 'm01_bright'));
      final field = [
        _inst(allCards.firstWhere((c) => c.id == 'm01_ribbon')),
        _inst(allCards.firstWhere((c) => c.id == 'm01_junk_1')),
        _inst(allCards.firstWhere((c) => c.id == 'm01_junk_2')),
      ];

      final result = executeMatch(played, field);
      expect(result.matched, isTrue);
      expect(result.isPpuk, isTrue);
      expect(result.capturedCards.length, 4);
    });
  });

  group('executeDeckFlip 테스트', () {
    test('덱 뒤집기 매칭', () {
      final flipped = _inst(allCards.firstWhere((c) => c.id == 'm03_bright'));
      final field = [_inst(allCards.firstWhere((c) => c.id == 'm03_ribbon'))];

      final result = executeDeckFlip(flipped, field);
      expect(result.matched, isTrue);
      expect(result.capturedCards.length, 2);
    });
  });

  group('TurnResult 테스트', () {
    test('양쪽 매칭 성공 = chain', () {
      final handMatch = MatchResult(
        matched: true,
        capturedCards: [_inst(allCards[0]), _inst(allCards[1])],
      );
      final deckMatch = MatchResult(
        matched: true,
        capturedCards: [_inst(allCards[2]), _inst(allCards[3])],
      );

      final turn = TurnResult(handMatch: handMatch, deckMatch: deckMatch);
      expect(turn.isChain, isTrue);
      expect(turn.totalCaptured, 4);
    });

    test('한쪽만 매칭 = not chain', () {
      final handMatch = MatchResult(matched: true, capturedCards: [_inst(allCards[0])]);
      final deckMatch = MatchResult(matched: false);

      final turn = TurnResult(handMatch: handMatch, deckMatch: deckMatch);
      expect(turn.isChain, isFalse);
      expect(turn.totalCaptured, 1);
    });
  });
}
