/// 🎴 K-Poker — 라운드 상태 모델 (freezed 업그레이드)
library;

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
    String? winner, // 'player', 'opponent', or 'draw'
    @Default(false) bool isDraw,
    
    // Balatro 스타일 시너지 추적을 위한 추가 필드
    @Default(0) int baseChips,
    @Default(1.0) double multiplier,
    @Default(false) bool isSweep, // 싹쓸이 여부
    @Default(0) int comboCount,   // 연속 매칭 성공 횟수 (쪽/따닥 등)
    @Default(0) int sweepCount,   // 쓸어먹기 횟수

    // 연뻑/삼뻑 추적
    @Default(0) int playerPpeokCount,   // 플레이어 연속 뻑 횟수
    @Default(0) int opponentPpeokCount, // AI 연속 뻑 횟수

    // 마지막 특수 이벤트 (UI 애니메이션 트리거)
    @Default('') String lastSpecialEvent, // 'ppeok', 'chok', 'tadak', 'sweep', 'chok_sweep', 'ppeok_eat', 'self_ppeok', 'double_ppeok', 'triple_ppeok', 'bomb', ''
    @Default(0) int lastStolenPiCount,    // 이번 턴에 뺏은 피 개수

    // 뻑 추적 (자뻑 판정용)
    @Default('') String lastPpeokOwner,   // 뻑 낸 사람 ('player' or 'opponent' or '')
    @Default(0) int lastPpeokMonth,       // 뻑 난 월 (0 = 없음)

    // 아이템 효과 추적용
    @Default(false) bool mentalGuardUsed, // T-002 멘탈가드 사용 여부 (1회용)
    @Default(false) bool bombUsed,        // 이 라운드에서 폭탄/총통 사용 여부 (c_bomb_fuse용)
    @Default(false) bool gloveUsedThisTurn, // t_cheaters_glove 이번 턴 사용 여부
    @Default(false) bool ppukBonusUsed,   // ps_ppuk_inducer 이번 판 보너스 사용 여부
    @Default(false) bool flowerLordUsed,  // ps_flower_lord 이번 판 사용 여부
    @Default(false) bool rewindUsed,      // ps_time_rewind 이번 판 사용 여부
    @Default(false) bool hadTripleMonth,  // ps_flower_bomb: 핸드에 같은 월 3장 보유 여부

    // 흔들기: 핸드에 같은 월 3장 보유 시 선언, 1벌=2배, 2벌=4배
    @Default([]) List<int> shakeMonths,   // 흔들기 선언한 월 목록 (빈 리스트 = 미선언)

    // 점수 상세 breakdown (라운드 종료 오버레이 표시용)
    @Default([]) List<Map<String, dynamic>> scoreBreakdown,
  }) = _RoundState;

  factory RoundState.fromJson(Map<String, dynamic> json) => _$RoundStateFromJson(json);
}
