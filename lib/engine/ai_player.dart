// 🎴 K-Poker — AI 상대 시스템
//
// 스테이지별로 다른 전략을 사용하는 AI 플레이어 로직.
// 순수 로직 — UI 의존 없음.

import 'dart:math';
import '../models/card_def.dart';
import '../models/round_state.dart';
import 'card_matcher.dart';

abstract class AiStrategy {
  /// 내야 할 카드 선택
  CardInstance chooseCard(RoundState state);

  /// 매칭 가능한 카드가 여러 장일 때 선택
  CardInstance chooseMatch(CardInstance played, List<CardInstance> matches);

  /// 고/스톱 결정
  bool decideGoStop(RoundState state);
}

class AiPlayer {

  /// 난이도별 AI 전략 생성
  /// Stage 1-2: RandomAi (쉬움)
  /// Stage 3-4: GreedyAi (보통)
  /// Stage 5-6: StrategicAi (어려움)
  /// Stage 7+: StrategicAi aggressive (매우 어려움)
  static AiStrategy getStrategy(int stage) {
    if (stage <= 2) return RandomAi();
    if (stage <= 4) return GreedyAi();
    if (stage <= 6) return StrategicAi();
    return StrategicAi(aggressive: true);
  }
}

/// 1~2단계: 완전 랜덤 AI
class RandomAi implements AiStrategy {
  final Random _random = Random();

  @override
  CardInstance chooseCard(RoundState state) {
    return state.opponentHand[_random.nextInt(state.opponentHand.length)];
  }

  @override
  CardInstance chooseMatch(CardInstance played, List<CardInstance> matches) {
    return matches[_random.nextInt(matches.length)];
  }

  @override
  bool decideGoStop(RoundState state) {
    return false; // 무조건 스톱
  }
}

/// 3~4단계: 점수가 높은 카드 우선 매칭 (탐욕적)
class GreedyAi implements AiStrategy {
  @override
  CardInstance chooseCard(RoundState state) {
    final hand = state.opponentHand;
    if (hand.length <= 1) return hand.first;

    // 1. 매칭 가능한 카드 중 가장 높은 등급 우선 (광 > 동물 > 띠 > 피)
    CardInstance? bestCard;
    int bestScore = -1;

    for (var card in hand) {
      final matches = findMatchableCards(card, state.field);
      if (matches.isEmpty) continue;

      // 매칭으로 획득 가능한 최고 등급 카드의 점수
      final matchScore = _evaluateMatchValue(card, matches);
      if (matchScore > bestScore) {
        bestScore = matchScore;
        bestCard = card;
      }
    }

    // 2. 매칭 가능한 카드가 없으면 가장 가치 낮은 카드를 버림
    if (bestCard == null) {
      return _pickLowestValueCard(hand);
    }

    return bestCard;
  }

  @override
  CardInstance chooseMatch(CardInstance played, List<CardInstance> matches) {
    // 등급순: 광 > 동물 > 띠 > 피
    matches.sort((a, b) => _cardGradeValue(b).compareTo(_cardGradeValue(a)));
    return matches.first;
  }

  @override
  bool decideGoStop(RoundState state) {
    // 7점 이상이면 스톱 (안전주의)
    return state.opponentScore < 7;
  }

  /// 카드 등급의 가치 점수
  int _cardGradeValue(CardInstance card) {
    switch (card.def.grade) {
      case CardGrade.bright:
        return 100;
      case CardGrade.animal:
        return card.def.isBird ? 60 : 40; // 새(고도리)는 더 높은 가치
      case CardGrade.ribbon:
        switch (card.def.ribbonType) {
          case RibbonType.red:
          case RibbonType.blue:
          case RibbonType.grass:
            return 30; // 홍단/청단/초단용 띠
          case RibbonType.plain:
          case RibbonType.none:
            return 20;
        }
      case CardGrade.junk:
        return card.def.doubleJunk ? 8 : 5;
    }
  }

  /// 매칭 시 얻을 수 있는 가치 평가
  int _evaluateMatchValue(CardInstance playedCard, List<CardInstance> fieldMatches) {
    int value = _cardGradeValue(playedCard);
    for (var match in fieldMatches) {
      value += _cardGradeValue(match);
    }
    return value;
  }

  /// 가장 가치 낮은 카드를 선택 (버릴 때)
  CardInstance _pickLowestValueCard(List<CardInstance> hand) {
    CardInstance lowest = hand.first;
    int lowestValue = _cardGradeValue(hand.first);

    for (var card in hand.skip(1)) {
      final value = _cardGradeValue(card);
      if (value < lowestValue) {
        lowestValue = value;
        lowest = card;
      }
    }
    return lowest;
  }
}

/// 5단계 이상: 전략적 AI (고도화 완료)
///
/// 전략:
/// - 광 카드 캡처 최우선
/// - 같은 월 매칭 우선 (폭탄 방지 + 점수 극대화)
/// - 상대에게 쉬운 매칭을 주지 않도록 카드 선택
/// - 고/스톱: 현재 점수, 상대 캡처 상황, 남은 카드를 종합 판단
class StrategicAi extends GreedyAi {
  final bool aggressive;
  final Random _random = Random();

  StrategicAi({this.aggressive = false});

  @override
  CardInstance chooseCard(RoundState state) {
    final hand = state.opponentHand;
    if (hand.length <= 1) return hand.first;

    // 모든 카드에 대해 전략적 점수 계산
    CardInstance? bestCard;
    double bestScore = double.negativeInfinity;

    for (var card in hand) {
      final score = _evaluatePlayScore(card, state);
      if (score > bestScore) {
        bestScore = score;
        bestCard = card;
      }
    }

    return bestCard ?? hand.first;
  }

  @override
  CardInstance chooseMatch(CardInstance played, List<CardInstance> matches) {
    // 전략적 매칭 선택:
    // 1. 광 카드 최우선
    final bright = matches.where((c) => c.def.grade == CardGrade.bright);
    if (bright.isNotEmpty) return bright.first;

    // 2. 고도리 새 카드 (2, 4, 8월 새)
    final bird = matches.where((c) => c.def.isBird);
    if (bird.isNotEmpty) return bird.first;

    // 3. 홍단/청단/초단 세트용 띠
    final specialRibbon = matches.where(
      (c) => c.def.ribbonType == RibbonType.red ||
             c.def.ribbonType == RibbonType.blue ||
             c.def.ribbonType == RibbonType.grass,
    );
    if (specialRibbon.isNotEmpty) return specialRibbon.first;

    // 4. 동물 > 일반띠 > 쌍피 > 피
    matches.sort((a, b) => _strategicCardValue(b).compareTo(_strategicCardValue(a)));
    return matches.first;
  }

  @override
  bool decideGoStop(RoundState state) {
    final myScore = state.opponentScore;
    final theirScore = state.playerScore;
    final myGoCount = state.opponentGoCount;
    final remainingCards = state.deck.length;

    // 점수 < 3: 무조건 고 (최소 점수 확보 필요)
    if (myScore < 3) return true;

    // 점수 3~5: 상대보다 유리하면 고, 아니면 스톱
    if (myScore >= 3 && myScore < 5) {
      final myCaptures = state.opponentCaptured.length;
      final theirCaptures = state.playerCaptured.length;
      // 캡처 수가 많거나 같으면 고
      if (myCaptures >= theirCaptures) return true;
      // 상대 점수가 낮으면 고
      if (theirScore <= 1) return true;
      return false;
    }

    // 점수 5~7: 좋은 위치에 있으면 고
    if (myScore >= 5 && myScore < 7) {
      // 남은 카드가 많으면 더 먹을 수 있으므로 고
      if (remainingCards > 10) {
        // 고 3회 이상이면 배율 폭증 → 스톱 고려
        if (myGoCount >= 3) return false;
        // 상대 점수가 높으면 위험 → 스톱
        if (theirScore >= 5) return false;
        return true;
      }
      // 남은 카드 적으면 스톱
      return false;
    }

    // 점수 7 이상: 기본적으로 스톱, aggressive 모드면 더 공격적
    if (myScore >= 7) {
      if (aggressive) {
        // 공격적: 고 3회 미만이고 남은 카드 많으면 추가 고
        if (myGoCount < 3 && remainingCards > 8) {
          // 상대 점수가 낮으면 안전하게 더 고
          if (theirScore < 3) return true;
          // 50% 확률로 도박
          return _random.nextBool();
        }
      }
      // 기본: 스톱
      return false;
    }

    return false;
  }

  /// 카드를 낼 때의 전략적 가치 평가
  double _evaluatePlayScore(CardInstance card, RoundState state) {
    double score = 0;
    final matches = findMatchableCards(card, state.field);

    // --- A. 매칭 가능 여부 ---
    if (matches.isNotEmpty) {
      // 매칭 성공 시 기본 점수
      score += 10;

      // 매칭으로 얻는 카드들의 가치
      for (var match in matches) {
        score += _strategicCardValue(match);
      }

      // 내가 내는 카드 자체의 가치 (광을 먹으러 감)
      score += _strategicCardValue(card) * 0.5;

      // 3장 매칭 (폭탄 = 전부 가져옴) 보너스
      if (matches.length == 3) {
        score += 50;
      }

      // 같은 월 2장 매칭 → 선택권 (1장만 가져감)
      if (matches.length == 2) {
        // 더 좋은 카드를 선택할 수 있으므로 약간 보너스
        score += 5;
      }

    } else {
      // --- B. 매칭 불가 — 카드를 바닥에 놓아야 함 ---
      // 상대에게 유리한 카드를 바닥에 놓는 것은 피해야 함
      score -= _strategicCardValue(card);

      // 광 카드를 바닥에 놓는 것은 최악 (상대에게 광을 줌)
      if (card.def.grade == CardGrade.bright) {
        score -= 100;
      }

      // 같은 월의 카드가 바닥에 이미 있으면 뻑 위험
      final sameMonthOnField = state.field.where(
        (c) => c.def.month == card.def.month,
      ).length;
      if (sameMonthOnField == 2) {
        // 3장 스택(뻑) 형성 → 상대가 4번째 카드로 전부 가져갈 위험
        score -= 30;
      }

      // 피 카드를 버리는 것은 덜 아까움
      if (card.def.grade == CardGrade.junk) {
        score += 3;
      }
    }

    // --- C. 광 캡처 우선순위 ---
    // 바닥에 광이 있고, 내 카드와 같은 월이면 대폭 보너스
    for (var match in matches) {
      if (match.def.grade == CardGrade.bright) {
        score += 80;
      }
    }

    // --- D. 고도리(새) 진행 상황 고려 ---
    final capturedBirdMonths = state.opponentCaptured
        .where((c) => c.def.isBird)
        .map((c) => c.def.month)
        .toSet();
    for (var match in matches) {
      if (match.def.isBird && !capturedBirdMonths.contains(match.def.month)) {
        // 고도리 완성에 필요한 새를 먹을 수 있음
        final neededBirds = {2, 4, 8}.difference(capturedBirdMonths);
        if (neededBirds.contains(match.def.month)) {
          score += 25;
          // 마지막 새면 고도리 완성 보너스
          if (neededBirds.length == 1) {
            score += 50;
          }
        }
      }
    }

    // --- E. 상대에게 도움이 되는 바닥 놓기 방지 ---
    if (matches.isEmpty) {
      // 상대(플레이어) 핸드에 같은 월이 있을 가능성 추정
      // (핸드를 직접 볼 수 없으므로 확률 기반)
      // 바닥에 같은 월이 없으면 안전한 버리기
      final sameMonthOnField = state.field.where(
        (c) => c.def.month == card.def.month,
      ).length;
      if (sameMonthOnField == 0) {
        score += 2; // 홀로 놓이면 매칭 확률 낮음
      }
    }

    return score;
  }

  /// 전략적 카드 가치 (캡처 시의 이득)
  int _strategicCardValue(CardInstance card) {
    switch (card.def.grade) {
      case CardGrade.bright:
        return 80;
      case CardGrade.animal:
        if (card.def.isBird) return 50; // 고도리용 새
        return 30;
      case CardGrade.ribbon:
        switch (card.def.ribbonType) {
          case RibbonType.red:
            return 25; // 홍단용
          case RibbonType.blue:
            return 25; // 청단용
          case RibbonType.grass:
            return 25; // 초단용
          case RibbonType.plain:
          case RibbonType.none:
            return 15;
        }
      case CardGrade.junk:
        return card.def.doubleJunk ? 8 : 3;
    }
  }
}
