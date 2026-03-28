// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShopSlot _$ShopSlotFromJson(Map<String, dynamic> json) {
  return _ShopSlot.fromJson(json);
}

/// @nodoc
mixin _$ShopSlot {
  String get itemId => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  bool get sold => throw _privateConstructorUsedError;
  bool get locked => throw _privateConstructorUsedError;

  /// Serializes this ShopSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopSlotCopyWith<ShopSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopSlotCopyWith<$Res> {
  factory $ShopSlotCopyWith(ShopSlot value, $Res Function(ShopSlot) then) =
      _$ShopSlotCopyWithImpl<$Res, ShopSlot>;
  @useResult
  $Res call({String itemId, int price, bool sold, bool locked});
}

/// @nodoc
class _$ShopSlotCopyWithImpl<$Res, $Val extends ShopSlot>
    implements $ShopSlotCopyWith<$Res> {
  _$ShopSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? price = null,
    Object? sold = null,
    Object? locked = null,
  }) {
    return _then(_value.copyWith(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as bool,
      locked: null == locked
          ? _value.locked
          : locked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopSlotImplCopyWith<$Res>
    implements $ShopSlotCopyWith<$Res> {
  factory _$$ShopSlotImplCopyWith(
          _$ShopSlotImpl value, $Res Function(_$ShopSlotImpl) then) =
      __$$ShopSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String itemId, int price, bool sold, bool locked});
}

/// @nodoc
class __$$ShopSlotImplCopyWithImpl<$Res>
    extends _$ShopSlotCopyWithImpl<$Res, _$ShopSlotImpl>
    implements _$$ShopSlotImplCopyWith<$Res> {
  __$$ShopSlotImplCopyWithImpl(
      _$ShopSlotImpl _value, $Res Function(_$ShopSlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShopSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? price = null,
    Object? sold = null,
    Object? locked = null,
  }) {
    return _then(_$ShopSlotImpl(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as bool,
      locked: null == locked
          ? _value.locked
          : locked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopSlotImpl implements _ShopSlot {
  const _$ShopSlotImpl(
      {required this.itemId,
      required this.price,
      this.sold = false,
      this.locked = false});

  factory _$ShopSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopSlotImplFromJson(json);

  @override
  final String itemId;
  @override
  final int price;
  @override
  @JsonKey()
  final bool sold;
  @override
  @JsonKey()
  final bool locked;

  @override
  String toString() {
    return 'ShopSlot(itemId: $itemId, price: $price, sold: $sold, locked: $locked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopSlotImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.sold, sold) || other.sold == sold) &&
            (identical(other.locked, locked) || other.locked == locked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemId, price, sold, locked);

  /// Create a copy of ShopSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopSlotImplCopyWith<_$ShopSlotImpl> get copyWith =>
      __$$ShopSlotImplCopyWithImpl<_$ShopSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopSlotImplToJson(
      this,
    );
  }
}

abstract class _ShopSlot implements ShopSlot {
  const factory _ShopSlot(
      {required final String itemId,
      required final int price,
      final bool sold,
      final bool locked}) = _$ShopSlotImpl;

  factory _ShopSlot.fromJson(Map<String, dynamic> json) =
      _$ShopSlotImpl.fromJson;

  @override
  String get itemId;
  @override
  int get price;
  @override
  bool get sold;
  @override
  bool get locked;

  /// Create a copy of ShopSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopSlotImplCopyWith<_$ShopSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopState _$ShopStateFromJson(Map<String, dynamic> json) {
  return _ShopState.fromJson(json);
}

/// @nodoc
mixin _$ShopState {
  List<ShopSlot> get slots => throw _privateConstructorUsedError;
  int get rerollCount => throw _privateConstructorUsedError;
  int get rerollCost => throw _privateConstructorUsedError;
  List<String> get unlockedSecretIds => throw _privateConstructorUsedError;

  /// Serializes this ShopState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopStateCopyWith<ShopState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopStateCopyWith<$Res> {
  factory $ShopStateCopyWith(ShopState value, $Res Function(ShopState) then) =
      _$ShopStateCopyWithImpl<$Res, ShopState>;
  @useResult
  $Res call(
      {List<ShopSlot> slots,
      int rerollCount,
      int rerollCost,
      List<String> unlockedSecretIds});
}

/// @nodoc
class _$ShopStateCopyWithImpl<$Res, $Val extends ShopState>
    implements $ShopStateCopyWith<$Res> {
  _$ShopStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slots = null,
    Object? rerollCount = null,
    Object? rerollCost = null,
    Object? unlockedSecretIds = null,
  }) {
    return _then(_value.copyWith(
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<ShopSlot>,
      rerollCount: null == rerollCount
          ? _value.rerollCount
          : rerollCount // ignore: cast_nullable_to_non_nullable
              as int,
      rerollCost: null == rerollCost
          ? _value.rerollCost
          : rerollCost // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedSecretIds: null == unlockedSecretIds
          ? _value.unlockedSecretIds
          : unlockedSecretIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopStateImplCopyWith<$Res>
    implements $ShopStateCopyWith<$Res> {
  factory _$$ShopStateImplCopyWith(
          _$ShopStateImpl value, $Res Function(_$ShopStateImpl) then) =
      __$$ShopStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ShopSlot> slots,
      int rerollCount,
      int rerollCost,
      List<String> unlockedSecretIds});
}

/// @nodoc
class __$$ShopStateImplCopyWithImpl<$Res>
    extends _$ShopStateCopyWithImpl<$Res, _$ShopStateImpl>
    implements _$$ShopStateImplCopyWith<$Res> {
  __$$ShopStateImplCopyWithImpl(
      _$ShopStateImpl _value, $Res Function(_$ShopStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShopState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slots = null,
    Object? rerollCount = null,
    Object? rerollCost = null,
    Object? unlockedSecretIds = null,
  }) {
    return _then(_$ShopStateImpl(
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<ShopSlot>,
      rerollCount: null == rerollCount
          ? _value.rerollCount
          : rerollCount // ignore: cast_nullable_to_non_nullable
              as int,
      rerollCost: null == rerollCost
          ? _value.rerollCost
          : rerollCost // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedSecretIds: null == unlockedSecretIds
          ? _value._unlockedSecretIds
          : unlockedSecretIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopStateImpl implements _ShopState {
  const _$ShopStateImpl(
      {final List<ShopSlot> slots = const [],
      this.rerollCount = 0,
      this.rerollCost = 50,
      final List<String> unlockedSecretIds = const []})
      : _slots = slots,
        _unlockedSecretIds = unlockedSecretIds;

  factory _$ShopStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopStateImplFromJson(json);

  final List<ShopSlot> _slots;
  @override
  @JsonKey()
  List<ShopSlot> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  @JsonKey()
  final int rerollCount;
  @override
  @JsonKey()
  final int rerollCost;
  final List<String> _unlockedSecretIds;
  @override
  @JsonKey()
  List<String> get unlockedSecretIds {
    if (_unlockedSecretIds is EqualUnmodifiableListView)
      return _unlockedSecretIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unlockedSecretIds);
  }

  @override
  String toString() {
    return 'ShopState(slots: $slots, rerollCount: $rerollCount, rerollCost: $rerollCost, unlockedSecretIds: $unlockedSecretIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopStateImpl &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            (identical(other.rerollCount, rerollCount) ||
                other.rerollCount == rerollCount) &&
            (identical(other.rerollCost, rerollCost) ||
                other.rerollCost == rerollCost) &&
            const DeepCollectionEquality()
                .equals(other._unlockedSecretIds, _unlockedSecretIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_slots),
      rerollCount,
      rerollCost,
      const DeepCollectionEquality().hash(_unlockedSecretIds));

  /// Create a copy of ShopState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopStateImplCopyWith<_$ShopStateImpl> get copyWith =>
      __$$ShopStateImplCopyWithImpl<_$ShopStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopStateImplToJson(
      this,
    );
  }
}

abstract class _ShopState implements ShopState {
  const factory _ShopState(
      {final List<ShopSlot> slots,
      final int rerollCount,
      final int rerollCost,
      final List<String> unlockedSecretIds}) = _$ShopStateImpl;

  factory _ShopState.fromJson(Map<String, dynamic> json) =
      _$ShopStateImpl.fromJson;

  @override
  List<ShopSlot> get slots;
  @override
  int get rerollCount;
  @override
  int get rerollCost;
  @override
  List<String> get unlockedSecretIds;

  /// Create a copy of ShopState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopStateImplCopyWith<_$ShopStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
