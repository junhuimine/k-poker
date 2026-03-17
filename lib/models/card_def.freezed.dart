// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CardDef _$CardDefFromJson(Map<String, dynamic> json) {
  return _CardDef.fromJson(json);
}

/// @nodoc
mixin _$CardDef {
  String get id => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  CardGrade get grade => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nameKo => throw _privateConstructorUsedError;
  RibbonType get ribbonType => throw _privateConstructorUsedError;
  bool get doubleJunk => throw _privateConstructorUsedError;
  bool get isBird => throw _privateConstructorUsedError;

  /// Serializes this CardDef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardDef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardDefCopyWith<CardDef> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardDefCopyWith<$Res> {
  factory $CardDefCopyWith(CardDef value, $Res Function(CardDef) then) =
      _$CardDefCopyWithImpl<$Res, CardDef>;
  @useResult
  $Res call(
      {String id,
      int month,
      CardGrade grade,
      String name,
      String nameKo,
      RibbonType ribbonType,
      bool doubleJunk,
      bool isBird});
}

/// @nodoc
class _$CardDefCopyWithImpl<$Res, $Val extends CardDef>
    implements $CardDefCopyWith<$Res> {
  _$CardDefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardDef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? grade = null,
    Object? name = null,
    Object? nameKo = null,
    Object? ribbonType = null,
    Object? doubleJunk = null,
    Object? isBird = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as CardGrade,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      ribbonType: null == ribbonType
          ? _value.ribbonType
          : ribbonType // ignore: cast_nullable_to_non_nullable
              as RibbonType,
      doubleJunk: null == doubleJunk
          ? _value.doubleJunk
          : doubleJunk // ignore: cast_nullable_to_non_nullable
              as bool,
      isBird: null == isBird
          ? _value.isBird
          : isBird // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardDefImplCopyWith<$Res> implements $CardDefCopyWith<$Res> {
  factory _$$CardDefImplCopyWith(
          _$CardDefImpl value, $Res Function(_$CardDefImpl) then) =
      __$$CardDefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int month,
      CardGrade grade,
      String name,
      String nameKo,
      RibbonType ribbonType,
      bool doubleJunk,
      bool isBird});
}

/// @nodoc
class __$$CardDefImplCopyWithImpl<$Res>
    extends _$CardDefCopyWithImpl<$Res, _$CardDefImpl>
    implements _$$CardDefImplCopyWith<$Res> {
  __$$CardDefImplCopyWithImpl(
      _$CardDefImpl _value, $Res Function(_$CardDefImpl) _then)
      : super(_value, _then);

  /// Create a copy of CardDef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? grade = null,
    Object? name = null,
    Object? nameKo = null,
    Object? ribbonType = null,
    Object? doubleJunk = null,
    Object? isBird = null,
  }) {
    return _then(_$CardDefImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as CardGrade,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      ribbonType: null == ribbonType
          ? _value.ribbonType
          : ribbonType // ignore: cast_nullable_to_non_nullable
              as RibbonType,
      doubleJunk: null == doubleJunk
          ? _value.doubleJunk
          : doubleJunk // ignore: cast_nullable_to_non_nullable
              as bool,
      isBird: null == isBird
          ? _value.isBird
          : isBird // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardDefImpl extends _CardDef {
  const _$CardDefImpl(
      {required this.id,
      required this.month,
      required this.grade,
      required this.name,
      required this.nameKo,
      this.ribbonType = RibbonType.none,
      this.doubleJunk = false,
      this.isBird = false})
      : super._();

  factory _$CardDefImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardDefImplFromJson(json);

  @override
  final String id;
  @override
  final int month;
  @override
  final CardGrade grade;
  @override
  final String name;
  @override
  final String nameKo;
  @override
  @JsonKey()
  final RibbonType ribbonType;
  @override
  @JsonKey()
  final bool doubleJunk;
  @override
  @JsonKey()
  final bool isBird;

  @override
  String toString() {
    return 'CardDef(id: $id, month: $month, grade: $grade, name: $name, nameKo: $nameKo, ribbonType: $ribbonType, doubleJunk: $doubleJunk, isBird: $isBird)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardDefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameKo, nameKo) || other.nameKo == nameKo) &&
            (identical(other.ribbonType, ribbonType) ||
                other.ribbonType == ribbonType) &&
            (identical(other.doubleJunk, doubleJunk) ||
                other.doubleJunk == doubleJunk) &&
            (identical(other.isBird, isBird) || other.isBird == isBird));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, month, grade, name, nameKo,
      ribbonType, doubleJunk, isBird);

  /// Create a copy of CardDef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardDefImplCopyWith<_$CardDefImpl> get copyWith =>
      __$$CardDefImplCopyWithImpl<_$CardDefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardDefImplToJson(
      this,
    );
  }
}

abstract class _CardDef extends CardDef {
  const factory _CardDef(
      {required final String id,
      required final int month,
      required final CardGrade grade,
      required final String name,
      required final String nameKo,
      final RibbonType ribbonType,
      final bool doubleJunk,
      final bool isBird}) = _$CardDefImpl;
  const _CardDef._() : super._();

  factory _CardDef.fromJson(Map<String, dynamic> json) = _$CardDefImpl.fromJson;

  @override
  String get id;
  @override
  int get month;
  @override
  CardGrade get grade;
  @override
  String get name;
  @override
  String get nameKo;
  @override
  RibbonType get ribbonType;
  @override
  bool get doubleJunk;
  @override
  bool get isBird;

  /// Create a copy of CardDef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardDefImplCopyWith<_$CardDefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardInstance _$CardInstanceFromJson(Map<String, dynamic> json) {
  return _CardInstance.fromJson(json);
}

/// @nodoc
mixin _$CardInstance {
  CardDef get def => throw _privateConstructorUsedError;
  Enhancement get enhancement => throw _privateConstructorUsedError;
  Edition get edition => throw _privateConstructorUsedError;
  bool get isDeckDraw => throw _privateConstructorUsedError;

  /// Serializes this CardInstance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardInstance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardInstanceCopyWith<CardInstance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardInstanceCopyWith<$Res> {
  factory $CardInstanceCopyWith(
          CardInstance value, $Res Function(CardInstance) then) =
      _$CardInstanceCopyWithImpl<$Res, CardInstance>;
  @useResult
  $Res call(
      {CardDef def, Enhancement enhancement, Edition edition, bool isDeckDraw});

  $CardDefCopyWith<$Res> get def;
}

/// @nodoc
class _$CardInstanceCopyWithImpl<$Res, $Val extends CardInstance>
    implements $CardInstanceCopyWith<$Res> {
  _$CardInstanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardInstance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? def = null,
    Object? enhancement = null,
    Object? edition = null,
    Object? isDeckDraw = null,
  }) {
    return _then(_value.copyWith(
      def: null == def
          ? _value.def
          : def // ignore: cast_nullable_to_non_nullable
              as CardDef,
      enhancement: null == enhancement
          ? _value.enhancement
          : enhancement // ignore: cast_nullable_to_non_nullable
              as Enhancement,
      edition: null == edition
          ? _value.edition
          : edition // ignore: cast_nullable_to_non_nullable
              as Edition,
      isDeckDraw: null == isDeckDraw
          ? _value.isDeckDraw
          : isDeckDraw // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of CardInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CardDefCopyWith<$Res> get def {
    return $CardDefCopyWith<$Res>(_value.def, (value) {
      return _then(_value.copyWith(def: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CardInstanceImplCopyWith<$Res>
    implements $CardInstanceCopyWith<$Res> {
  factory _$$CardInstanceImplCopyWith(
          _$CardInstanceImpl value, $Res Function(_$CardInstanceImpl) then) =
      __$$CardInstanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CardDef def, Enhancement enhancement, Edition edition, bool isDeckDraw});

  @override
  $CardDefCopyWith<$Res> get def;
}

/// @nodoc
class __$$CardInstanceImplCopyWithImpl<$Res>
    extends _$CardInstanceCopyWithImpl<$Res, _$CardInstanceImpl>
    implements _$$CardInstanceImplCopyWith<$Res> {
  __$$CardInstanceImplCopyWithImpl(
      _$CardInstanceImpl _value, $Res Function(_$CardInstanceImpl) _then)
      : super(_value, _then);

  /// Create a copy of CardInstance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? def = null,
    Object? enhancement = null,
    Object? edition = null,
    Object? isDeckDraw = null,
  }) {
    return _then(_$CardInstanceImpl(
      def: null == def
          ? _value.def
          : def // ignore: cast_nullable_to_non_nullable
              as CardDef,
      enhancement: null == enhancement
          ? _value.enhancement
          : enhancement // ignore: cast_nullable_to_non_nullable
              as Enhancement,
      edition: null == edition
          ? _value.edition
          : edition // ignore: cast_nullable_to_non_nullable
              as Edition,
      isDeckDraw: null == isDeckDraw
          ? _value.isDeckDraw
          : isDeckDraw // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardInstanceImpl implements _CardInstance {
  const _$CardInstanceImpl(
      {required this.def,
      this.enhancement = Enhancement.none,
      this.edition = Edition.base,
      this.isDeckDraw = false});

  factory _$CardInstanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardInstanceImplFromJson(json);

  @override
  final CardDef def;
  @override
  @JsonKey()
  final Enhancement enhancement;
  @override
  @JsonKey()
  final Edition edition;
  @override
  @JsonKey()
  final bool isDeckDraw;

  @override
  String toString() {
    return 'CardInstance(def: $def, enhancement: $enhancement, edition: $edition, isDeckDraw: $isDeckDraw)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardInstanceImpl &&
            (identical(other.def, def) || other.def == def) &&
            (identical(other.enhancement, enhancement) ||
                other.enhancement == enhancement) &&
            (identical(other.edition, edition) || other.edition == edition) &&
            (identical(other.isDeckDraw, isDeckDraw) ||
                other.isDeckDraw == isDeckDraw));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, def, enhancement, edition, isDeckDraw);

  /// Create a copy of CardInstance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardInstanceImplCopyWith<_$CardInstanceImpl> get copyWith =>
      __$$CardInstanceImplCopyWithImpl<_$CardInstanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardInstanceImplToJson(
      this,
    );
  }
}

abstract class _CardInstance implements CardInstance {
  const factory _CardInstance(
      {required final CardDef def,
      final Enhancement enhancement,
      final Edition edition,
      final bool isDeckDraw}) = _$CardInstanceImpl;

  factory _CardInstance.fromJson(Map<String, dynamic> json) =
      _$CardInstanceImpl.fromJson;

  @override
  CardDef get def;
  @override
  Enhancement get enhancement;
  @override
  Edition get edition;
  @override
  bool get isDeckDraw;

  /// Create a copy of CardInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardInstanceImplCopyWith<_$CardInstanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
