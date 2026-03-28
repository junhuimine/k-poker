// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RunStateImpl _$$RunStateImplFromJson(Map<String, dynamic> json) =>
    _$RunStateImpl(
      stage: (json['stage'] as num?)?.toInt() ?? 1,
      gold: (json['gold'] as num?)?.toInt() ?? 0,
      money: (json['money'] as num?)?.toDouble() ?? 50000,
      stageEarned: (json['stageEarned'] as num?)?.toDouble() ?? 0,
      currentOpponentIndex:
          (json['currentOpponentIndex'] as num?)?.toInt() ?? 0,
      opponentMoney: (json['opponentMoney'] as num?)?.toDouble() ?? 0,
      activeSkillIds: (json['activeSkillIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      activeTalismanIds: (json['activeTalismanIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      shopState: json['shopState'] == null
          ? const ShopState()
          : ShopState.fromJson(json['shopState'] as Map<String, dynamic>),
      ownedPassiveIds: (json['ownedPassiveIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      inventorySkills: (json['inventorySkills'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      inventoryRoundItems:
          (json['inventoryRoundItems'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      equippedRoundItemIds: (json['equippedRoundItemIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ownedTalismanIds: (json['ownedTalismanIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      winStreak: (json['winStreak'] as num?)?.toInt() ?? 0,
      highestScore: (json['highestScore'] as num?)?.toInt() ?? 0,
      highestMoney: (json['highestMoney'] as num?)?.toDouble() ?? 0,
      moneyHistory: (json['moneyHistory'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      currencyLocale: json['currencyLocale'] as String? ?? 'ko',
    );

Map<String, dynamic> _$$RunStateImplToJson(_$RunStateImpl instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'gold': instance.gold,
      'money': instance.money,
      'stageEarned': instance.stageEarned,
      'currentOpponentIndex': instance.currentOpponentIndex,
      'opponentMoney': instance.opponentMoney,
      'activeSkillIds': instance.activeSkillIds,
      'activeTalismanIds': instance.activeTalismanIds,
      'shopState': instance.shopState,
      'ownedPassiveIds': instance.ownedPassiveIds,
      'inventorySkills': instance.inventorySkills,
      'inventoryRoundItems': instance.inventoryRoundItems,
      'equippedRoundItemIds': instance.equippedRoundItemIds,
      'ownedTalismanIds': instance.ownedTalismanIds,
      'wins': instance.wins,
      'losses': instance.losses,
      'winStreak': instance.winStreak,
      'highestScore': instance.highestScore,
      'highestMoney': instance.highestMoney,
      'moneyHistory': instance.moneyHistory,
      'currencyLocale': instance.currencyLocale,
    };
