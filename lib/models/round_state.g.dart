// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoundStateImpl _$$RoundStateImplFromJson(Map<String, dynamic> json) =>
    _$RoundStateImpl(
      deck: (json['deck'] as List<dynamic>?)
              ?.map((e) => CardInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      field: (json['field'] as List<dynamic>?)
              ?.map((e) => CardInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      playerHand: (json['playerHand'] as List<dynamic>?)
              ?.map((e) => CardInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      opponentHand: (json['opponentHand'] as List<dynamic>?)
              ?.map((e) => CardInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      playerCaptured: (json['playerCaptured'] as List<dynamic>?)
              ?.map((e) => CardInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      opponentCaptured: (json['opponentCaptured'] as List<dynamic>?)
              ?.map((e) => CardInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentTurn: json['currentTurn'] as String? ?? 'player',
      turnNumber: (json['turnNumber'] as num?)?.toInt() ?? 0,
      goCount: (json['goCount'] as num?)?.toInt() ?? 0,
      opponentGoCount: (json['opponentGoCount'] as num?)?.toInt() ?? 0,
      playerScore: (json['playerScore'] as num?)?.toInt() ?? 0,
      opponentScore: (json['opponentScore'] as num?)?.toInt() ?? 0,
      isFinished: json['isFinished'] as bool? ?? false,
      winner: json['winner'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
      baseChips: (json['baseChips'] as num?)?.toInt() ?? 0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      isSweep: json['isSweep'] as bool? ?? false,
      comboCount: (json['comboCount'] as num?)?.toInt() ?? 0,
      sweepCount: (json['sweepCount'] as num?)?.toInt() ?? 0,
      playerPpeokCount: (json['playerPpeokCount'] as num?)?.toInt() ?? 0,
      opponentPpeokCount: (json['opponentPpeokCount'] as num?)?.toInt() ?? 0,
      lastSpecialEvent: json['lastSpecialEvent'] as String? ?? '',
      lastStolenPiCount: (json['lastStolenPiCount'] as num?)?.toInt() ?? 0,
      lastPpeokOwner: json['lastPpeokOwner'] as String? ?? '',
      lastPpeokMonth: (json['lastPpeokMonth'] as num?)?.toInt() ?? 0,
      mentalGuardUsed: json['mentalGuardUsed'] as bool? ?? false,
    );

Map<String, dynamic> _$$RoundStateImplToJson(_$RoundStateImpl instance) =>
    <String, dynamic>{
      'deck': instance.deck,
      'field': instance.field,
      'playerHand': instance.playerHand,
      'opponentHand': instance.opponentHand,
      'playerCaptured': instance.playerCaptured,
      'opponentCaptured': instance.opponentCaptured,
      'currentTurn': instance.currentTurn,
      'turnNumber': instance.turnNumber,
      'goCount': instance.goCount,
      'opponentGoCount': instance.opponentGoCount,
      'playerScore': instance.playerScore,
      'opponentScore': instance.opponentScore,
      'isFinished': instance.isFinished,
      'winner': instance.winner,
      'isDraw': instance.isDraw,
      'baseChips': instance.baseChips,
      'multiplier': instance.multiplier,
      'isSweep': instance.isSweep,
      'comboCount': instance.comboCount,
      'sweepCount': instance.sweepCount,
      'playerPpeokCount': instance.playerPpeokCount,
      'opponentPpeokCount': instance.opponentPpeokCount,
      'lastSpecialEvent': instance.lastSpecialEvent,
      'lastStolenPiCount': instance.lastStolenPiCount,
      'lastPpeokOwner': instance.lastPpeokOwner,
      'lastPpeokMonth': instance.lastPpeokMonth,
      'mentalGuardUsed': instance.mentalGuardUsed,
    };
