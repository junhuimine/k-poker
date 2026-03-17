/// 🎴 K-Poker — 라운드 상태 모델 (freezed 업그레이드)

import 'package:freezed_annotation/freezed_annotation.dart';
import 'card_def.dart';

part 'round_state.freezed.dart';
part 'round_state.g.dart';

/// 한 판(라운드)의 상태
@freezed
class RoundState with _$RoundState {
  const factory RoundState({
    @Default([]) List<CardInstance> deck,
    @Default([]) List<CardInstance> field,
    @Default([]) List<CardInstance> playerHand,
    @Default([]) List<CardInstance> opponentHand,
    @Default([]) List<CardInstance> playerCaptured,
    @Default([]) List<CardInstance> opponentCaptured,
    @Default('player') String currentTurn, // 'player' | 'opponent'
    @Default(0) int turnNumber,
    @Default(0) int goCount,
    @Default(0) int opponentGoCount, // AI 고 횟수
    @Default(0) int playerScore,
    @Default(0) int opponentScore,
    @Default(false) bool isFinished,
    
    // Balatro 스타일 시너지 추적을 위한 추가 필드
    @Default(0) int baseChips,
    @Default(1.0) double multiplier,
    @Default(false) bool isSweep, // 싹쓸이 여부
    @Default(0) int comboCount,   // 연속 매칭 성공 횟수 (쪽/따닥 등)
    @Default(0) int sweepCount,   // 쓸어먹기 횟수
  }) = _RoundState;

  factory RoundState.fromJson(Map<String, dynamic> json) => _$RoundStateFromJson(json);
}
