/// K-Poker -- 상점 상태 모델 (freezed)
///
/// 상점 슬롯, 리롤, 비밀 해금 등 상점 관련 런타임 상태.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_state.freezed.dart';
part 'shop_state.g.dart';

/// 상점 개별 슬롯
@freezed
class ShopSlot with _$ShopSlot {
  const factory ShopSlot({
    required String itemId,
    required int price,
    @Default(false) bool sold,
    @Default(false) bool locked,
  }) = _ShopSlot;

  factory ShopSlot.fromJson(Map<String, dynamic> json) =>
      _$ShopSlotFromJson(json);
}

/// 상점 전체 상태
@freezed
class ShopState with _$ShopState {
  const factory ShopState({
    @Default([]) List<ShopSlot> slots,
    @Default(0) int rerollCount,
    @Default(50) int rerollCost,
    @Default([]) List<String> unlockedSecretIds,
  }) = _ShopState;

  factory ShopState.fromJson(Map<String, dynamic> json) =>
      _$ShopStateFromJson(json);
}
