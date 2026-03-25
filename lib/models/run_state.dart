/// 🎴 K-Poker -- 런(Run) 전체 상태 모델
///
/// 판돈, 소지금, 스테이지, 기술/부적, 저장/불러오기 포함
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/skills.dart';

part 'run_state.freezed.dart';
part 'run_state.g.dart';

/// 전체 게임(런)의 상태
@freezed
class RunState with _$RunState {
  const factory RunState({
    @Default(1) int stage,           // 현재 스테이지 (1~6+)
    @Default(1000000) int gold,      // 테스트 및 상점 올클리어용 100만 골드 지급
    @Default(50000) double money,    // 소지금 (화폐 기준)
    @Default(0) double stageEarned,  // 레거시 (호환용, 미사용)
    @Default(0) int currentOpponentIndex, // 현재 상대 인덱스 (0 또는 1)
    @Default(0) double opponentMoney,     // 현재 상대의 남은 자금
    @Default([]) List<String> activeSkillIds,     // 레거시 호환용
    @Default([]) List<String> activeTalismanIds,  // 레거시 호환용

    // 신규 상점 아이템 시스템 스키마
    @Default({}) Map<String, int> inventorySkills,      // 인게임 액티브(즉발성) 스킬 보유량
    @Default({}) Map<String, int> inventoryRoundItems,  // 라운드 장착(시작전 세팅) 소모품 보유량
    @Default([]) List<String> equippedRoundItemIds,     // 이번 라운드에 장착된 소모품 ID
    @Default([]) List<String> ownedTalismanIds,         // 영구 보유 중인 패시브 부적 ID 목록

    @Default(0) int wins,            // 총 승리
    @Default(0) int losses,          // 총 패배
    @Default(0) int winStreak,       // 연승 카운터
    @Default(0) int highestScore,    // 최고 점수
    @Default(0) double highestMoney, // 최고 소지금
    @Default([]) List<double> moneyHistory, // 소지금 그래프용
    @Default('ko') String currencyLocale,   // 화폐 로케일
  }) = _RunState;

  const RunState._();

  factory RunState.fromJson(Map<String, dynamic> json) => _$RunStateFromJson(json);

  /// 활성 기술 가져오기 (ID → SkillDef 변환)
  List<SkillDef> get activeSkills =>
      activeSkillIds.map((id) => allSkills.firstWhere(
        (s) => s.id == id,
        orElse: () => allSkills.first,
      )).toList();

  /// 활성 부적 가져오기
  List<Talisman> get activeTalismans =>
      activeTalismanIds.map((id) => allTalismans.firstWhere(
        (t) => t.id == id,
        orElse: () => allTalismans.first,
      )).toList();
}
