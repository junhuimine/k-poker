/// 🎴 K-Poker — 카드 매칭 엔진
/// 
/// 화투 매칭 핵심: "같은 월(月)의 카드를 매칭하면 먹는다"
/// 순수 로직 — UI 의존 없음.
library;

import '../models/card_def.dart';

/// 매칭 결과
class MatchResult {
  /// 매칭 성공 여부
  bool matched;

  /// 매칭된 필드 카드 (성공 시)
  final List<CardInstance> matchedFieldCards;

  /// 플레이어가 가져가는 카드들
  List<CardInstance> capturedCards;

  /// 뻑 발생 여부 (필드에 같은 월 3장 쌓임)
  final bool isPpuk;

  /// 쓸어먹기 여부 (필드가 비었음)
  final bool isSweep;

  MatchResult({
    required this.matched,
    this.matchedFieldCards = const [],
    this.capturedCards = const [],
    this.isPpuk = false,
    this.isSweep = false,
  });
}

/// 플레이어 카드와 필드에서 매칭 가능한 카드를 찾는다.
List<CardInstance> findMatchableCards(
  CardInstance playedCard,
  List<CardInstance> field,
) {
  return field.where((fc) => fc.def.month == playedCard.def.month).toList();
}

/// 카드 매칭을 실행한다.
MatchResult executeMatch(
  CardInstance playedCard,
  List<CardInstance> field, {
  CardInstance? selectedMatch,
}) {
  final matchable = findMatchableCards(playedCard, field);

  // 매칭 가능한 카드 없음
  if (matchable.isEmpty) {
    return MatchResult(matched: false);
  }

  // 1장 → 자동 매칭
  if (matchable.length == 1) {
    final captured = [playedCard, matchable[0]];
    final remaining = field.where((fc) => fc != matchable[0]).toList();
    return MatchResult(
      matched: true,
      matchedFieldCards: [matchable[0]],
      capturedCards: captured,
      isSweep: remaining.isEmpty,
    );
  }

  // 2장 → 플레이어 선택 (없으면 첫 번째)
  if (matchable.length == 2) {
    final target = selectedMatch ?? matchable[0];
    final captured = [playedCard, target];
    final remaining = field.where((fc) => fc != target).toList();
    return MatchResult(
      matched: true,
      matchedFieldCards: [target],
      capturedCards: captured,
      isSweep: remaining.isEmpty,
    );
  }

  // 3장 → 뻑! (4번째 카드로 전부 가져감)
  if (matchable.length == 3) {
    final captured = [playedCard, ...matchable];
    final remaining = field.where((fc) => fc.def.month != playedCard.def.month).toList();
    return MatchResult(
      matched: true,
      matchedFieldCards: matchable,
      capturedCards: captured,
      isPpuk: true,
      isSweep: remaining.isEmpty,
    );
  }

  return MatchResult(matched: false);
}

/// 덱에서 카드를 뒤집어 필드 매칭을 시도한다.
MatchResult executeDeckFlip(CardInstance flippedCard, List<CardInstance> field) {
  return executeMatch(flippedCard, field);
}

/// 한 턴의 전체 매칭 결과
class TurnResult {
  final MatchResult handMatch;
  final MatchResult deckMatch;
  final bool isChain; // 핸드+덱 둘 다 성공
  final int totalCaptured;

  TurnResult({
    required this.handMatch,
    required this.deckMatch,
  })  : isChain = handMatch.matched && deckMatch.matched,
        totalCaptured = handMatch.capturedCards.length + deckMatch.capturedCards.length;
}
