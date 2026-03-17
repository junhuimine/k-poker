// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardDefImpl _$$CardDefImplFromJson(Map<String, dynamic> json) =>
    _$CardDefImpl(
      id: json['id'] as String,
      month: (json['month'] as num).toInt(),
      grade: $enumDecode(_$CardGradeEnumMap, json['grade']),
      name: json['name'] as String,
      nameKo: json['nameKo'] as String,
      ribbonType:
          $enumDecodeNullable(_$RibbonTypeEnumMap, json['ribbonType']) ??
              RibbonType.none,
      doubleJunk: json['doubleJunk'] as bool? ?? false,
      isBird: json['isBird'] as bool? ?? false,
    );

Map<String, dynamic> _$$CardDefImplToJson(_$CardDefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'month': instance.month,
      'grade': _$CardGradeEnumMap[instance.grade]!,
      'name': instance.name,
      'nameKo': instance.nameKo,
      'ribbonType': _$RibbonTypeEnumMap[instance.ribbonType]!,
      'doubleJunk': instance.doubleJunk,
      'isBird': instance.isBird,
    };

const _$CardGradeEnumMap = {
  CardGrade.bright: 'bright',
  CardGrade.animal: 'animal',
  CardGrade.ribbon: 'ribbon',
  CardGrade.junk: 'junk',
};

const _$RibbonTypeEnumMap = {
  RibbonType.red: 'red',
  RibbonType.blue: 'blue',
  RibbonType.grass: 'grass',
  RibbonType.plain: 'plain',
  RibbonType.none: 'none',
};

_$CardInstanceImpl _$$CardInstanceImplFromJson(Map<String, dynamic> json) =>
    _$CardInstanceImpl(
      def: CardDef.fromJson(json['def'] as Map<String, dynamic>),
      enhancement:
          $enumDecodeNullable(_$EnhancementEnumMap, json['enhancement']) ??
              Enhancement.none,
      edition: $enumDecodeNullable(_$EditionEnumMap, json['edition']) ??
          Edition.base,
      isDeckDraw: json['isDeckDraw'] as bool? ?? false,
    );

Map<String, dynamic> _$$CardInstanceImplToJson(_$CardInstanceImpl instance) =>
    <String, dynamic>{
      'def': instance.def,
      'enhancement': _$EnhancementEnumMap[instance.enhancement]!,
      'edition': _$EditionEnumMap[instance.edition]!,
      'isDeckDraw': instance.isDeckDraw,
    };

const _$EnhancementEnumMap = {
  Enhancement.none: 'none',
  Enhancement.fire: 'fire',
  Enhancement.moonlight: 'moonlight',
  Enhancement.rainbow: 'rainbow',
  Enhancement.shadow: 'shadow',
};

const _$EditionEnumMap = {
  Edition.base: 'base',
  Edition.foil: 'foil',
  Edition.holographic: 'holographic',
  Edition.polychrome: 'polychrome',
};
