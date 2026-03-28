/// K-Poker -- 런(Run) 전체 상태 모델
///
/// 판돈, 소지금, 스테이지, 아이템, 저장/불러오기 포함
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/item_catalog.dart';
import 'shop_state.dart';

part 'run_state.freezed.dart';
part 'run_state.g.dart';

/// 전체 게임(런)의 상태
@freezed
class RunState with _$RunState {
  const factory RunState({
    @Default(1) int stage,           // 현재 스테이지 (1~6+)
    @Default(0) int gold,             // 골드 (시작값은 newGame에서 설정)
    @Default(50000) double money,    // 소지금 (화폐 기준)
    @Default(0) double stageEarned,  // 레거시 (호환용, 미사용)
    @Default(0) int currentOpponentIndex, // 현재 상대 인덱스 (0 또는 1)
    @Default(0) double opponentMoney,     // 현재 상대의 남은 자금

    // @deprecated 레거시 호환용 (기존 세이브 역직렬화 지원)
    @Default([]) List<String> activeSkillIds,
    // @deprecated 레거시 호환용
    @Default([]) List<String> activeTalismanIds,

    // 신규 상점 아이템 시스템
    @Default(ShopState()) ShopState shopState,       // 현재 상점 상태
    @Default([]) List<String> ownedPassiveIds,       // 보유 패시브 스킬 목록
    @Default({}) Map<String, int> inventorySkills,   // 인게임 액티브(즉발성) 스킬 보유량
    @Default({}) Map<String, int> inventoryRoundItems, // 라운드 장착(시작전 세팅) 소모품 보유량
    @Default([]) List<String> equippedRoundItemIds,  // 이번 라운드에 장착된 소모품 ID
    @Default([]) List<String> ownedTalismanIds,      // 영구 보유 중인 부적 ID 목록

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

  /// 보유 중인 모든 패시브 아이템 정의 목록
  List<ItemDef> get ownedPassiveItems =>
      ownedPassiveIds
          .map(findCatalogItem)
          .whereType<ItemDef>()
          .toList();

  /// 보유 중인 모든 부적 아이템 정의 목록
  List<ItemDef> get ownedTalismanItems =>
      ownedTalismanIds
          .map(findCatalogItem)
          .whereType<ItemDef>()
          .toList();

  /// 시너지 평가용: 패시브 + 부적의 전체 ID 목록
  List<String> get allOwnedItemIds => [
    ...ownedPassiveIds,
    ...ownedTalismanIds,
  ];
}
