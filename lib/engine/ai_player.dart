// 🎴 K-Poker — AI 상대 시스템
//
// 스테이지별로 다른 전략을 사용하는 AI 플레이어 로직.

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
  static AiStrategy getStrategy(int stage) {
    if (stage <= 1) return RandomAi();
    if (stage <= 3) return GreedyAi();
    return StrategicAi();
  }
}

/// 1단계: 완전 랜덤 AI
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

/// 2~3단계: 점수가 높은 카드 우선 매칭 (탐욕적)
class GreedyAi implements AiStrategy {
  @override
  CardInstance chooseCard(RoundState state) {
    // 1. 매칭 가능한 카드 중 가장 높은 등급(광 > 띠 > 동물 > 피) 찾기
    for (var card in state.opponentHand) {
      final matches = findMatchableCards(card, state.field);
      if (matches.isNotEmpty && card.def.grade == CardGrade.bright) return card;
    }
    // 2. 없으면 그냥 첫 번째 카드
    return state.opponentHand.first;
  }

  @override
  CardInstance chooseMatch(CardInstance played, List<CardInstance> matches) {
    // 광이 있으면 광 선택
    return matches.firstWhere((c) => c.def.grade == CardGrade.bright, orElse: () => matches.first);
  }

  @override
  bool decideGoStop(RoundState state) {
    // 자기 점수가 7점 이상이면 일단 스톱 (안전주의)
    return state.opponentScore < 7;
  }
}

/// 4단계 이상: 전략적 AI (미구현 - 향후 고도화 예정)
class StrategicAi extends GreedyAi {
  @override
  bool decideGoStop(RoundState state) {
    // 플레이어의 점수를 고려하여 역전 가능성이 보이면 '고'
    return super.decideGoStop(state);
  }
}
