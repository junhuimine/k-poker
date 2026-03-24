// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoundState _$RoundStateFromJson(Map<String, dynamic> json) {
  return _RoundState.fromJson(json);
}

/// @nodoc
mixin _$RoundState {
  List<CardInstance> get deck => throw _privateConstructorUsedError;
  List<CardInstance> get field => throw _privateConstructorUsedError;
  List<CardInstance> get playerHand => throw _privateConstructorUsedError;
  List<CardInstance> get opponentHand => throw _privateConstructorUsedError;
  List<CardInstance> get playerCaptured => throw _privateConstructorUsedError;
  List<CardInstance> get opponentCaptured => throw _privateConstructorUsedError;
  String get currentTurn =>
      throw _privateConstructorUsedError; // 'player' | 'opponent'
  int get turnNumber => throw _privateConstructorUsedError;
  int get goCount => throw _privateConstructorUsedError;
  int get opponentGoCount => throw _privateConstructorUsedError; // AI 고 횟수
  int get playerScore => throw _privateConstructorUsedError;
  int get opponentScore => throw _privateConstructorUsedError;
  bool get isFinished =>
      throw _privateConstructorUsedError; // Balatro 스타일 시너지 추적을 위한 추가 필드
  int get baseChips => throw _privateConstructorUsedError;
  double get multiplier => throw _privateConstructorUsedError;
  bool get isSweep => throw _privateConstructorUsedError; // 싹쓸이 여부
  int get comboCount =>
      throw _privateConstructorUsedError; // 연속 매칭 성공 횟수 (쪽/따닥 등)
  int get sweepCount => throw _privateConstructorUsedError; // 쓸어먹기 횟수
// 연뻑/삼뻑 추적
  int get playerPpeokCount =>
      throw _privateConstructorUsedError; // 플레이어 연속 뻑 횟수
  int get opponentPpeokCount =>
      throw _privateConstructorUsedError; // AI 연속 뻑 횟수
// 마지막 특수 이벤트 (UI 애니메이션 트리거)
  String get lastSpecialEvent =>
      throw _privateConstructorUsedError; // 'ppeok', 'chok', 'tadak', 'sweep', 'chok_sweep', 'ppeok_eat', 'self_ppeok', 'double_ppeok', 'triple_ppeok', 'bomb', ''
  int get lastStolenPiCount =>
      throw _privateConstructorUsedError; // 이번 턴에 뺏은 피 개수
// 뻑 추적 (자뻑 판정용)
  String get lastPpeokOwner =>
      throw _privateConstructorUsedError; // 뻑 낸 사람 ('player' or 'opponent' or '')
  int get lastPpeokMonth =>
      throw _privateConstructorUsedError; // 뻑 난 월 (0 = 없음)
// 아이템 효과 추적용
  bool get mentalGuardUsed => throw _privateConstructorUsedError;

  /// Serializes this RoundState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoundStateCopyWith<RoundState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundStateCopyWith<$Res> {
  factory $RoundStateCopyWith(
          RoundState value, $Res Function(RoundState) then) =
      _$RoundStateCopyWithImpl<$Res, RoundState>;
  @useResult
  $Res call(
      {List<CardInstance> deck,
      List<CardInstance> field,
      List<CardInstance> playerHand,
      List<CardInstance> opponentHand,
      List<CardInstance> playerCaptured,
      List<CardInstance> opponentCaptured,
      String currentTurn,
      int turnNumber,
      int goCount,
      int opponentGoCount,
      int playerScore,
      int opponentScore,
      bool isFinished,
      int baseChips,
      double multiplier,
      bool isSweep,
      int comboCount,
      int sweepCount,
      int playerPpeokCount,
      int opponentPpeokCount,
      String lastSpecialEvent,
      int lastStolenPiCount,
      String lastPpeokOwner,
      int lastPpeokMonth,
      bool mentalGuardUsed});
}

/// @nodoc
class _$RoundStateCopyWithImpl<$Res, $Val extends RoundState>
    implements $RoundStateCopyWith<$Res> {
  _$RoundStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deck = null,
    Object? field = null,
    Object? playerHand = null,
    Object? opponentHand = null,
    Object? playerCaptured = null,
    Object? opponentCaptured = null,
    Object? currentTurn = null,
    Object? turnNumber = null,
    Object? goCount = null,
    Object? opponentGoCount = null,
    Object? playerScore = null,
    Object? opponentScore = null,
    Object? isFinished = null,
    Object? baseChips = null,
    Object? multiplier = null,
    Object? isSweep = null,
    Object? comboCount = null,
    Object? sweepCount = null,
    Object? playerPpeokCount = null,
    Object? opponentPpeokCount = null,
    Object? lastSpecialEvent = null,
    Object? lastStolenPiCount = null,
    Object? lastPpeokOwner = null,
    Object? lastPpeokMonth = null,
    Object? mentalGuardUsed = null,
  }) {
    return _then(_value.copyWith(
      deck: null == deck
          ? _value.deck
          : deck // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      playerHand: null == playerHand
          ? _value.playerHand
          : playerHand // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      opponentHand: null == opponentHand
          ? _value.opponentHand
          : opponentHand // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      playerCaptured: null == playerCaptured
          ? _value.playerCaptured
          : playerCaptured // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      opponentCaptured: null == opponentCaptured
          ? _value.opponentCaptured
          : opponentCaptured // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      currentTurn: null == currentTurn
          ? _value.currentTurn
          : currentTurn // ignore: cast_nullable_to_non_nullable
              as String,
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
      goCount: null == goCount
          ? _value.goCount
          : goCount // ignore: cast_nullable_to_non_nullable
              as int,
      opponentGoCount: null == opponentGoCount
          ? _value.opponentGoCount
          : opponentGoCount // ignore: cast_nullable_to_non_nullable
              as int,
      playerScore: null == playerScore
          ? _value.playerScore
          : playerScore // ignore: cast_nullable_to_non_nullable
              as int,
      opponentScore: null == opponentScore
          ? _value.opponentScore
          : opponentScore // ignore: cast_nullable_to_non_nullable
              as int,
      isFinished: null == isFinished
          ? _value.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      baseChips: null == baseChips
          ? _value.baseChips
          : baseChips // ignore: cast_nullable_to_non_nullable
              as int,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      isSweep: null == isSweep
          ? _value.isSweep
          : isSweep // ignore: cast_nullable_to_non_nullable
              as bool,
      comboCount: null == comboCount
          ? _value.comboCount
          : comboCount // ignore: cast_nullable_to_non_nullable
              as int,
      sweepCount: null == sweepCount
          ? _value.sweepCount
          : sweepCount // ignore: cast_nullable_to_non_nullable
              as int,
      playerPpeokCount: null == playerPpeokCount
          ? _value.playerPpeokCount
          : playerPpeokCount // ignore: cast_nullable_to_non_nullable
              as int,
      opponentPpeokCount: null == opponentPpeokCount
          ? _value.opponentPpeokCount
          : opponentPpeokCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastSpecialEvent: null == lastSpecialEvent
          ? _value.lastSpecialEvent
          : lastSpecialEvent // ignore: cast_nullable_to_non_nullable
              as String,
      lastStolenPiCount: null == lastStolenPiCount
          ? _value.lastStolenPiCount
          : lastStolenPiCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastPpeokOwner: null == lastPpeokOwner
          ? _value.lastPpeokOwner
          : lastPpeokOwner // ignore: cast_nullable_to_non_nullable
              as String,
      lastPpeokMonth: null == lastPpeokMonth
          ? _value.lastPpeokMonth
          : lastPpeokMonth // ignore: cast_nullable_to_non_nullable
              as int,
      mentalGuardUsed: null == mentalGuardUsed
          ? _value.mentalGuardUsed
          : mentalGuardUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoundStateImplCopyWith<$Res>
    implements $RoundStateCopyWith<$Res> {
  factory _$$RoundStateImplCopyWith(
          _$RoundStateImpl value, $Res Function(_$RoundStateImpl) then) =
      __$$RoundStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CardInstance> deck,
      List<CardInstance> field,
      List<CardInstance> playerHand,
      List<CardInstance> opponentHand,
      List<CardInstance> playerCaptured,
      List<CardInstance> opponentCaptured,
      String currentTurn,
      int turnNumber,
      int goCount,
      int opponentGoCount,
      int playerScore,
      int opponentScore,
      bool isFinished,
      int baseChips,
      double multiplier,
      bool isSweep,
      int comboCount,
      int sweepCount,
      int playerPpeokCount,
      int opponentPpeokCount,
      String lastSpecialEvent,
      int lastStolenPiCount,
      String lastPpeokOwner,
      int lastPpeokMonth,
      bool mentalGuardUsed});
}

/// @nodoc
class __$$RoundStateImplCopyWithImpl<$Res>
    extends _$RoundStateCopyWithImpl<$Res, _$RoundStateImpl>
    implements _$$RoundStateImplCopyWith<$Res> {
  __$$RoundStateImplCopyWithImpl(
      _$RoundStateImpl _value, $Res Function(_$RoundStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deck = null,
    Object? field = null,
    Object? playerHand = null,
    Object? opponentHand = null,
    Object? playerCaptured = null,
    Object? opponentCaptured = null,
    Object? currentTurn = null,
    Object? turnNumber = null,
    Object? goCount = null,
    Object? opponentGoCount = null,
    Object? playerScore = null,
    Object? opponentScore = null,
    Object? isFinished = null,
    Object? baseChips = null,
    Object? multiplier = null,
    Object? isSweep = null,
    Object? comboCount = null,
    Object? sweepCount = null,
    Object? playerPpeokCount = null,
    Object? opponentPpeokCount = null,
    Object? lastSpecialEvent = null,
    Object? lastStolenPiCount = null,
    Object? lastPpeokOwner = null,
    Object? lastPpeokMonth = null,
    Object? mentalGuardUsed = null,
  }) {
    return _then(_$RoundStateImpl(
      deck: null == deck
          ? _value._deck
          : deck // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      field: null == field
          ? _value._field
          : field // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      playerHand: null == playerHand
          ? _value._playerHand
          : playerHand // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      opponentHand: null == opponentHand
          ? _value._opponentHand
          : opponentHand // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      playerCaptured: null == playerCaptured
          ? _value._playerCaptured
          : playerCaptured // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      opponentCaptured: null == opponentCaptured
          ? _value._opponentCaptured
          : opponentCaptured // ignore: cast_nullable_to_non_nullable
              as List<CardInstance>,
      currentTurn: null == currentTurn
          ? _value.currentTurn
          : currentTurn // ignore: cast_nullable_to_non_nullable
              as String,
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
      goCount: null == goCount
          ? _value.goCount
          : goCount // ignore: cast_nullable_to_non_nullable
              as int,
      opponentGoCount: null == opponentGoCount
          ? _value.opponentGoCount
          : opponentGoCount // ignore: cast_nullable_to_non_nullable
              as int,
      playerScore: null == playerScore
          ? _value.playerScore
          : playerScore // ignore: cast_nullable_to_non_nullable
              as int,
      opponentScore: null == opponentScore
          ? _value.opponentScore
          : opponentScore // ignore: cast_nullable_to_non_nullable
              as int,
      isFinished: null == isFinished
          ? _value.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      baseChips: null == baseChips
          ? _value.baseChips
          : baseChips // ignore: cast_nullable_to_non_nullable
              as int,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      isSweep: null == isSweep
          ? _value.isSweep
          : isSweep // ignore: cast_nullable_to_non_nullable
              as bool,
      comboCount: null == comboCount
          ? _value.comboCount
          : comboCount // ignore: cast_nullable_to_non_nullable
              as int,
      sweepCount: null == sweepCount
          ? _value.sweepCount
          : sweepCount // ignore: cast_nullable_to_non_nullable
              as int,
      playerPpeokCount: null == playerPpeokCount
          ? _value.playerPpeokCount
          : playerPpeokCount // ignore: cast_nullable_to_non_nullable
              as int,
      opponentPpeokCount: null == opponentPpeokCount
          ? _value.opponentPpeokCount
          : opponentPpeokCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastSpecialEvent: null == lastSpecialEvent
          ? _value.lastSpecialEvent
          : lastSpecialEvent // ignore: cast_nullable_to_non_nullable
              as String,
      lastStolenPiCount: null == lastStolenPiCount
          ? _value.lastStolenPiCount
          : lastStolenPiCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastPpeokOwner: null == lastPpeokOwner
          ? _value.lastPpeokOwner
          : lastPpeokOwner // ignore: cast_nullable_to_non_nullable
              as String,
      lastPpeokMonth: null == lastPpeokMonth
          ? _value.lastPpeokMonth
          : lastPpeokMonth // ignore: cast_nullable_to_non_nullable
              as int,
      mentalGuardUsed: null == mentalGuardUsed
          ? _value.mentalGuardUsed
          : mentalGuardUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoundStateImpl implements _RoundState {
  const _$RoundStateImpl(
      {final List<CardInstance> deck = const [],
      final List<CardInstance> field = const [],
      final List<CardInstance> playerHand = const [],
      final List<CardInstance> opponentHand = const [],
      final List<CardInstance> playerCaptured = const [],
      final List<CardInstance> opponentCaptured = const [],
      this.currentTurn = 'player',
      this.turnNumber = 0,
      this.goCount = 0,
      this.opponentGoCount = 0,
      this.playerScore = 0,
      this.opponentScore = 0,
      this.isFinished = false,
      this.baseChips = 0,
      this.multiplier = 1.0,
      this.isSweep = false,
      this.comboCount = 0,
      this.sweepCount = 0,
      this.playerPpeokCount = 0,
      this.opponentPpeokCount = 0,
      this.lastSpecialEvent = '',
      this.lastStolenPiCount = 0,
      this.lastPpeokOwner = '',
      this.lastPpeokMonth = 0,
      this.mentalGuardUsed = false})
      : _deck = deck,
        _field = field,
        _playerHand = playerHand,
        _opponentHand = opponentHand,
        _playerCaptured = playerCaptured,
        _opponentCaptured = opponentCaptured;

  factory _$RoundStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundStateImplFromJson(json);

  final List<CardInstance> _deck;
  @override
  @JsonKey()
  List<CardInstance> get deck {
    if (_deck is EqualUnmodifiableListView) return _deck;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deck);
  }

  final List<CardInstance> _field;
  @override
  @JsonKey()
  List<CardInstance> get field {
    if (_field is EqualUnmodifiableListView) return _field;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field);
  }

  final List<CardInstance> _playerHand;
  @override
  @JsonKey()
  List<CardInstance> get playerHand {
    if (_playerHand is EqualUnmodifiableListView) return _playerHand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerHand);
  }

  final List<CardInstance> _opponentHand;
  @override
  @JsonKey()
  List<CardInstance> get opponentHand {
    if (_opponentHand is EqualUnmodifiableListView) return _opponentHand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_opponentHand);
  }

  final List<CardInstance> _playerCaptured;
  @override
  @JsonKey()
  List<CardInstance> get playerCaptured {
    if (_playerCaptured is EqualUnmodifiableListView) return _playerCaptured;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerCaptured);
  }

  final List<CardInstance> _opponentCaptured;
  @override
  @JsonKey()
  List<CardInstance> get opponentCaptured {
    if (_opponentCaptured is EqualUnmodifiableListView)
      return _opponentCaptured;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_opponentCaptured);
  }

  @override
  @JsonKey()
  final String currentTurn;
// 'player' | 'opponent'
  @override
  @JsonKey()
  final int turnNumber;
  @override
  @JsonKey()
  final int goCount;
  @override
  @JsonKey()
  final int opponentGoCount;
// AI 고 횟수
  @override
  @JsonKey()
  final int playerScore;
  @override
  @JsonKey()
  final int opponentScore;
  @override
  @JsonKey()
  final bool isFinished;
// Balatro 스타일 시너지 추적을 위한 추가 필드
  @override
  @JsonKey()
  final int baseChips;
  @override
  @JsonKey()
  final double multiplier;
  @override
  @JsonKey()
  final bool isSweep;
// 싹쓸이 여부
  @override
  @JsonKey()
  final int comboCount;
// 연속 매칭 성공 횟수 (쪽/따닥 등)
  @override
  @JsonKey()
  final int sweepCount;
// 쓸어먹기 횟수
// 연뻑/삼뻑 추적
  @override
  @JsonKey()
  final int playerPpeokCount;
// 플레이어 연속 뻑 횟수
  @override
  @JsonKey()
  final int opponentPpeokCount;
// AI 연속 뻑 횟수
// 마지막 특수 이벤트 (UI 애니메이션 트리거)
  @override
  @JsonKey()
  final String lastSpecialEvent;
// 'ppeok', 'chok', 'tadak', 'sweep', 'chok_sweep', 'ppeok_eat', 'self_ppeok', 'double_ppeok', 'triple_ppeok', 'bomb', ''
  @override
  @JsonKey()
  final int lastStolenPiCount;
// 이번 턴에 뺏은 피 개수
// 뻑 추적 (자뻑 판정용)
  @override
  @JsonKey()
  final String lastPpeokOwner;
// 뻑 낸 사람 ('player' or 'opponent' or '')
  @override
  @JsonKey()
  final int lastPpeokMonth;
// 뻑 난 월 (0 = 없음)
// 아이템 효과 추적용
  @override
  @JsonKey()
  final bool mentalGuardUsed;

  @override
  String toString() {
    return 'RoundState(deck: $deck, field: $field, playerHand: $playerHand, opponentHand: $opponentHand, playerCaptured: $playerCaptured, opponentCaptured: $opponentCaptured, currentTurn: $currentTurn, turnNumber: $turnNumber, goCount: $goCount, opponentGoCount: $opponentGoCount, playerScore: $playerScore, opponentScore: $opponentScore, isFinished: $isFinished, baseChips: $baseChips, multiplier: $multiplier, isSweep: $isSweep, comboCount: $comboCount, sweepCount: $sweepCount, playerPpeokCount: $playerPpeokCount, opponentPpeokCount: $opponentPpeokCount, lastSpecialEvent: $lastSpecialEvent, lastStolenPiCount: $lastStolenPiCount, lastPpeokOwner: $lastPpeokOwner, lastPpeokMonth: $lastPpeokMonth, mentalGuardUsed: $mentalGuardUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundStateImpl &&
            const DeepCollectionEquality().equals(other._deck, _deck) &&
            const DeepCollectionEquality().equals(other._field, _field) &&
            const DeepCollectionEquality()
                .equals(other._playerHand, _playerHand) &&
            const DeepCollectionEquality()
                .equals(other._opponentHand, _opponentHand) &&
            const DeepCollectionEquality()
                .equals(other._playerCaptured, _playerCaptured) &&
            const DeepCollectionEquality()
                .equals(other._opponentCaptured, _opponentCaptured) &&
            (identical(other.currentTurn, currentTurn) ||
                other.currentTurn == currentTurn) &&
            (identical(other.turnNumber, turnNumber) ||
                other.turnNumber == turnNumber) &&
            (identical(other.goCount, goCount) || other.goCount == goCount) &&
            (identical(other.opponentGoCount, opponentGoCount) ||
                other.opponentGoCount == opponentGoCount) &&
            (identical(other.playerScore, playerScore) ||
                other.playerScore == playerScore) &&
            (identical(other.opponentScore, opponentScore) ||
                other.opponentScore == opponentScore) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.baseChips, baseChips) ||
                other.baseChips == baseChips) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.isSweep, isSweep) || other.isSweep == isSweep) &&
            (identical(other.comboCount, comboCount) ||
                other.comboCount == comboCount) &&
            (identical(other.sweepCount, sweepCount) ||
                other.sweepCount == sweepCount) &&
            (identical(other.playerPpeokCount, playerPpeokCount) ||
                other.playerPpeokCount == playerPpeokCount) &&
            (identical(other.opponentPpeokCount, opponentPpeokCount) ||
                other.opponentPpeokCount == opponentPpeokCount) &&
            (identical(other.lastSpecialEvent, lastSpecialEvent) ||
                other.lastSpecialEvent == lastSpecialEvent) &&
            (identical(other.lastStolenPiCount, lastStolenPiCount) ||
                other.lastStolenPiCount == lastStolenPiCount) &&
            (identical(other.lastPpeokOwner, lastPpeokOwner) ||
                other.lastPpeokOwner == lastPpeokOwner) &&
            (identical(other.lastPpeokMonth, lastPpeokMonth) ||
                other.lastPpeokMonth == lastPpeokMonth) &&
            (identical(other.mentalGuardUsed, mentalGuardUsed) ||
                other.mentalGuardUsed == mentalGuardUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_deck),
        const DeepCollectionEquality().hash(_field),
        const DeepCollectionEquality().hash(_playerHand),
        const DeepCollectionEquality().hash(_opponentHand),
        const DeepCollectionEquality().hash(_playerCaptured),
        const DeepCollectionEquality().hash(_opponentCaptured),
        currentTurn,
        turnNumber,
        goCount,
        opponentGoCount,
        playerScore,
        opponentScore,
        isFinished,
        baseChips,
        multiplier,
        isSweep,
        comboCount,
        sweepCount,
        playerPpeokCount,
        opponentPpeokCount,
        lastSpecialEvent,
        lastStolenPiCount,
        lastPpeokOwner,
        lastPpeokMonth,
        mentalGuardUsed
      ]);

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundStateImplCopyWith<_$RoundStateImpl> get copyWith =>
      __$$RoundStateImplCopyWithImpl<_$RoundStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundStateImplToJson(
      this,
    );
  }
}

abstract class _RoundState implements RoundState {
  const factory _RoundState(
      {final List<CardInstance> deck,
      final List<CardInstance> field,
      final List<CardInstance> playerHand,
      final List<CardInstance> opponentHand,
      final List<CardInstance> playerCaptured,
      final List<CardInstance> opponentCaptured,
      final String currentTurn,
      final int turnNumber,
      final int goCount,
      final int opponentGoCount,
      final int playerScore,
      final int opponentScore,
      final bool isFinished,
      final int baseChips,
      final double multiplier,
      final bool isSweep,
      final int comboCount,
      final int sweepCount,
      final int playerPpeokCount,
      final int opponentPpeokCount,
      final String lastSpecialEvent,
      final int lastStolenPiCount,
      final String lastPpeokOwner,
      final int lastPpeokMonth,
      final bool mentalGuardUsed}) = _$RoundStateImpl;

  factory _RoundState.fromJson(Map<String, dynamic> json) =
      _$RoundStateImpl.fromJson;

  @override
  List<CardInstance> get deck;
  @override
  List<CardInstance> get field;
  @override
  List<CardInstance> get playerHand;
  @override
  List<CardInstance> get opponentHand;
  @override
  List<CardInstance> get playerCaptured;
  @override
  List<CardInstance> get opponentCaptured;
  @override
  String get currentTurn; // 'player' | 'opponent'
  @override
  int get turnNumber;
  @override
  int get goCount;
  @override
  int get opponentGoCount; // AI 고 횟수
  @override
  int get playerScore;
  @override
  int get opponentScore;
  @override
  bool get isFinished; // Balatro 스타일 시너지 추적을 위한 추가 필드
  @override
  int get baseChips;
  @override
  double get multiplier;
  @override
  bool get isSweep; // 싹쓸이 여부
  @override
  int get comboCount; // 연속 매칭 성공 횟수 (쪽/따닥 등)
  @override
  int get sweepCount; // 쓸어먹기 횟수
// 연뻑/삼뻑 추적
  @override
  int get playerPpeokCount; // 플레이어 연속 뻑 횟수
  @override
  int get opponentPpeokCount; // AI 연속 뻑 횟수
// 마지막 특수 이벤트 (UI 애니메이션 트리거)
  @override
  String
      get lastSpecialEvent; // 'ppeok', 'chok', 'tadak', 'sweep', 'chok_sweep', 'ppeok_eat', 'self_ppeok', 'double_ppeok', 'triple_ppeok', 'bomb', ''
  @override
  int get lastStolenPiCount; // 이번 턴에 뺏은 피 개수
// 뻑 추적 (자뻑 판정용)
  @override
  String get lastPpeokOwner; // 뻑 낸 사람 ('player' or 'opponent' or '')
  @override
  int get lastPpeokMonth; // 뻑 난 월 (0 = 없음)
// 아이템 효과 추적용
  @override
  bool get mentalGuardUsed;

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoundStateImplCopyWith<_$RoundStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
