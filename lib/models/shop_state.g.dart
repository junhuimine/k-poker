// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopSlotImpl _$$ShopSlotImplFromJson(Map<String, dynamic> json) =>
    _$ShopSlotImpl(
      itemId: json['itemId'] as String,
      price: (json['price'] as num).toInt(),
      sold: json['sold'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
    );

Map<String, dynamic> _$$ShopSlotImplToJson(_$ShopSlotImpl instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'price': instance.price,
      'sold': instance.sold,
      'locked': instance.locked,
    };

_$ShopStateImpl _$$ShopStateImplFromJson(Map<String, dynamic> json) =>
    _$ShopStateImpl(
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => ShopSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rerollCount: (json['rerollCount'] as num?)?.toInt() ?? 0,
      rerollCost: (json['rerollCost'] as num?)?.toInt() ?? 50,
      unlockedSecretIds: (json['unlockedSecretIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ShopStateImplToJson(_$ShopStateImpl instance) =>
    <String, dynamic>{
      'slots': instance.slots,
      'rerollCount': instance.rerollCount,
      'rerollCost': instance.rerollCost,
      'unlockedSecretIds': instance.unlockedSecretIds,
    };
