/// 🎴 K-Poker — 카드 정의 모델 (freezed 업그레이드)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_def.freezed.dart';
part 'card_def.g.dart';

/// 카드 월(月) — 1~12월
typedef Month = int;

/// 카드 등급
enum CardGrade { bright, animal, ribbon, junk }

/// 띠 종류
enum RibbonType { red, blue, grass, plain, none }

/// 카드 강화 타입 (Balatro 스타일)
enum Enhancement { none, fire, moonlight, rainbow, shadow }

/// 카드 에디션 (Balatro 포일/홀로 느낌)
enum Edition { base, foil, holographic, polychrome }

/// 카드 정의 (불변 데이터)
@freezed
class CardDef with _$CardDef {
  const factory CardDef({
    required String id,
    required Month month,
    required CardGrade grade,
    required String name,
    required String nameKo,
    @Default(RibbonType.none) RibbonType ribbonType,
    @Default(false) bool doubleJunk,
    @Default(false) bool isBird,
    @Default(false) bool isBonus, // 보너스 쌍피 (조커) 카드
  }) = _CardDef;

  factory CardDef.fromJson(Map<String, dynamic> json) => _$CardDefFromJson(json);

  const CardDef._();

  /// 카드 이미지 경로
  /// _upgraded 접미사가 붙은 가상 카드는 기본 카드 이미지를 사용
  String get imagePath {
    final baseId = id.endsWith('_upgraded') ? id.replaceFirst('_upgraded', '') : id;
    return 'assets/images/cards/$baseId.jpg';
  }
}

/// 게임 중 카드 인스턴스 (강화/에디션 상태 포함)
@freezed
class CardInstance with _$CardInstance {
  const factory CardInstance({
    required CardDef def,
    @Default(Enhancement.none) Enhancement enhancement,
    @Default(Edition.base) Edition edition,
    @Default(false) bool isDeckDraw, // 폭탄 후 덱 뒤집기 전용 카드
  }) = _CardInstance;

  factory CardInstance.fromJson(Map<String, dynamic> json) => _$CardInstanceFromJson(json);
}
