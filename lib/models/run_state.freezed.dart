// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RunState _$RunStateFromJson(Map<String, dynamic> json) {
  return _RunState.fromJson(json);
}

/// @nodoc
mixin _$RunState {
  int get stage => throw _privateConstructorUsedError; // 현재 스테이지 (1~6+)
  int get gold => throw _privateConstructorUsedError; // 레거시 (호환용)
  double get money => throw _privateConstructorUsedError; // 소지금 (화폐 기준)
  double get stageEarned =>
      throw _privateConstructorUsedError; // 레거시 (호환용, 미사용)
  int get currentOpponentIndex =>
      throw _privateConstructorUsedError; // 현재 상대 인덱스 (0 또는 1)
  double get opponentMoney =>
      throw _privateConstructorUsedError; // 현재 상대의 남은 자금
  List<String> get activeSkillIds =>
      throw _privateConstructorUsedError; // 기술 ID 목록 (저장용)
  List<String> get activeTalismanIds =>
      throw _privateConstructorUsedError; // 부적 ID 목록 (저장용)
  int get wins => throw _privateConstructorUsedError; // 총 승리
  int get losses => throw _privateConstructorUsedError; // 총 패배
  int get winStreak => throw _privateConstructorUsedError; // 연승 카운터
  int get highestScore => throw _privateConstructorUsedError; // 최고 점수
  double get highestMoney => throw _privateConstructorUsedError; // 최고 소지금
  List<double> get moneyHistory =>
      throw _privateConstructorUsedError; // 소지금 그래프용
  String get currencyLocale => throw _privateConstructorUsedError;

  /// Serializes this RunState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RunState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RunStateCopyWith<RunState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunStateCopyWith<$Res> {
  factory $RunStateCopyWith(RunState value, $Res Function(RunState) then) =
      _$RunStateCopyWithImpl<$Res, RunState>;
  @useResult
  $Res call(
      {int stage,
      int gold,
      double money,
      double stageEarned,
      int currentOpponentIndex,
      double opponentMoney,
      List<String> activeSkillIds,
      List<String> activeTalismanIds,
      int wins,
      int losses,
      int winStreak,
      int highestScore,
      double highestMoney,
      List<double> moneyHistory,
      String currencyLocale});
}

/// @nodoc
class _$RunStateCopyWithImpl<$Res, $Val extends RunState>
    implements $RunStateCopyWith<$Res> {
  _$RunStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RunState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? gold = null,
    Object? money = null,
    Object? stageEarned = null,
    Object? currentOpponentIndex = null,
    Object? opponentMoney = null,
    Object? activeSkillIds = null,
    Object? activeTalismanIds = null,
    Object? wins = null,
    Object? losses = null,
    Object? winStreak = null,
    Object? highestScore = null,
    Object? highestMoney = null,
    Object? moneyHistory = null,
    Object? currencyLocale = null,
  }) {
    return _then(_value.copyWith(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int,
      gold: null == gold
          ? _value.gold
          : gold // ignore: cast_nullable_to_non_nullable
              as int,
      money: null == money
          ? _value.money
          : money // ignore: cast_nullable_to_non_nullable
              as double,
      stageEarned: null == stageEarned
          ? _value.stageEarned
          : stageEarned // ignore: cast_nullable_to_non_nullable
              as double,
      currentOpponentIndex: null == currentOpponentIndex
          ? _value.currentOpponentIndex
          : currentOpponentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      opponentMoney: null == opponentMoney
          ? _value.opponentMoney
          : opponentMoney // ignore: cast_nullable_to_non_nullable
              as double,
      activeSkillIds: null == activeSkillIds
          ? _value.activeSkillIds
          : activeSkillIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeTalismanIds: null == activeTalismanIds
          ? _value.activeTalismanIds
          : activeTalismanIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      wins: null == wins
          ? _value.wins
          : wins // ignore: cast_nullable_to_non_nullable
              as int,
      losses: null == losses
          ? _value.losses
          : losses // ignore: cast_nullable_to_non_nullable
              as int,
      winStreak: null == winStreak
          ? _value.winStreak
          : winStreak // ignore: cast_nullable_to_non_nullable
              as int,
      highestScore: null == highestScore
          ? _value.highestScore
          : highestScore // ignore: cast_nullable_to_non_nullable
              as int,
      highestMoney: null == highestMoney
          ? _value.highestMoney
          : highestMoney // ignore: cast_nullable_to_non_nullable
              as double,
      moneyHistory: null == moneyHistory
          ? _value.moneyHistory
          : moneyHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      currencyLocale: null == currencyLocale
          ? _value.currencyLocale
          : currencyLocale // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RunStateImplCopyWith<$Res>
    implements $RunStateCopyWith<$Res> {
  factory _$$RunStateImplCopyWith(
          _$RunStateImpl value, $Res Function(_$RunStateImpl) then) =
      __$$RunStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int stage,
      int gold,
      double money,
      double stageEarned,
      int currentOpponentIndex,
      double opponentMoney,
      List<String> activeSkillIds,
      List<String> activeTalismanIds,
      int wins,
      int losses,
      int winStreak,
      int highestScore,
      double highestMoney,
      List<double> moneyHistory,
      String currencyLocale});
}

/// @nodoc
class __$$RunStateImplCopyWithImpl<$Res>
    extends _$RunStateCopyWithImpl<$Res, _$RunStateImpl>
    implements _$$RunStateImplCopyWith<$Res> {
  __$$RunStateImplCopyWithImpl(
      _$RunStateImpl _value, $Res Function(_$RunStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RunState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? gold = null,
    Object? money = null,
    Object? stageEarned = null,
    Object? currentOpponentIndex = null,
    Object? opponentMoney = null,
    Object? activeSkillIds = null,
    Object? activeTalismanIds = null,
    Object? wins = null,
    Object? losses = null,
    Object? winStreak = null,
    Object? highestScore = null,
    Object? highestMoney = null,
    Object? moneyHistory = null,
    Object? currencyLocale = null,
  }) {
    return _then(_$RunStateImpl(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int,
      gold: null == gold
          ? _value.gold
          : gold // ignore: cast_nullable_to_non_nullable
              as int,
      money: null == money
          ? _value.money
          : money // ignore: cast_nullable_to_non_nullable
              as double,
      stageEarned: null == stageEarned
          ? _value.stageEarned
          : stageEarned // ignore: cast_nullable_to_non_nullable
              as double,
      currentOpponentIndex: null == currentOpponentIndex
          ? _value.currentOpponentIndex
          : currentOpponentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      opponentMoney: null == opponentMoney
          ? _value.opponentMoney
          : opponentMoney // ignore: cast_nullable_to_non_nullable
              as double,
      activeSkillIds: null == activeSkillIds
          ? _value._activeSkillIds
          : activeSkillIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeTalismanIds: null == activeTalismanIds
          ? _value._activeTalismanIds
          : activeTalismanIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      wins: null == wins
          ? _value.wins
          : wins // ignore: cast_nullable_to_non_nullable
              as int,
      losses: null == losses
          ? _value.losses
          : losses // ignore: cast_nullable_to_non_nullable
              as int,
      winStreak: null == winStreak
          ? _value.winStreak
          : winStreak // ignore: cast_nullable_to_non_nullable
              as int,
      highestScore: null == highestScore
          ? _value.highestScore
          : highestScore // ignore: cast_nullable_to_non_nullable
              as int,
      highestMoney: null == highestMoney
          ? _value.highestMoney
          : highestMoney // ignore: cast_nullable_to_non_nullable
              as double,
      moneyHistory: null == moneyHistory
          ? _value._moneyHistory
          : moneyHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      currencyLocale: null == currencyLocale
          ? _value.currencyLocale
          : currencyLocale // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RunStateImpl extends _RunState {
  const _$RunStateImpl(
      {this.stage = 1,
      this.gold = 0,
      this.money = 50000,
      this.stageEarned = 0,
      this.currentOpponentIndex = 0,
      this.opponentMoney = 0,
      final List<String> activeSkillIds = const [],
      final List<String> activeTalismanIds = const [],
      this.wins = 0,
      this.losses = 0,
      this.winStreak = 0,
      this.highestScore = 0,
      this.highestMoney = 0,
      final List<double> moneyHistory = const [],
      this.currencyLocale = 'ko'})
      : _activeSkillIds = activeSkillIds,
        _activeTalismanIds = activeTalismanIds,
        _moneyHistory = moneyHistory,
        super._();

  factory _$RunStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunStateImplFromJson(json);

  @override
  @JsonKey()
  final int stage;
// 현재 스테이지 (1~6+)
  @override
  @JsonKey()
  final int gold;
// 레거시 (호환용)
  @override
  @JsonKey()
  final double money;
// 소지금 (화폐 기준)
  @override
  @JsonKey()
  final double stageEarned;
// 레거시 (호환용, 미사용)
  @override
  @JsonKey()
  final int currentOpponentIndex;
// 현재 상대 인덱스 (0 또는 1)
  @override
  @JsonKey()
  final double opponentMoney;
// 현재 상대의 남은 자금
  final List<String> _activeSkillIds;
// 현재 상대의 남은 자금
  @override
  @JsonKey()
  List<String> get activeSkillIds {
    if (_activeSkillIds is EqualUnmodifiableListView) return _activeSkillIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeSkillIds);
  }

// 기술 ID 목록 (저장용)
  final List<String> _activeTalismanIds;
// 기술 ID 목록 (저장용)
  @override
  @JsonKey()
  List<String> get activeTalismanIds {
    if (_activeTalismanIds is EqualUnmodifiableListView)
      return _activeTalismanIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeTalismanIds);
  }

// 부적 ID 목록 (저장용)
  @override
  @JsonKey()
  final int wins;
// 총 승리
  @override
  @JsonKey()
  final int losses;
// 총 패배
  @override
  @JsonKey()
  final int winStreak;
// 연승 카운터
  @override
  @JsonKey()
  final int highestScore;
// 최고 점수
  @override
  @JsonKey()
  final double highestMoney;
// 최고 소지금
  final List<double> _moneyHistory;
// 최고 소지금
  @override
  @JsonKey()
  List<double> get moneyHistory {
    if (_moneyHistory is EqualUnmodifiableListView) return _moneyHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moneyHistory);
  }

// 소지금 그래프용
  @override
  @JsonKey()
  final String currencyLocale;

  @override
  String toString() {
    return 'RunState(stage: $stage, gold: $gold, money: $money, stageEarned: $stageEarned, currentOpponentIndex: $currentOpponentIndex, opponentMoney: $opponentMoney, activeSkillIds: $activeSkillIds, activeTalismanIds: $activeTalismanIds, wins: $wins, losses: $losses, winStreak: $winStreak, highestScore: $highestScore, highestMoney: $highestMoney, moneyHistory: $moneyHistory, currencyLocale: $currencyLocale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunStateImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.gold, gold) || other.gold == gold) &&
            (identical(other.money, money) || other.money == money) &&
            (identical(other.stageEarned, stageEarned) ||
                other.stageEarned == stageEarned) &&
            (identical(other.currentOpponentIndex, currentOpponentIndex) ||
                other.currentOpponentIndex == currentOpponentIndex) &&
            (identical(other.opponentMoney, opponentMoney) ||
                other.opponentMoney == opponentMoney) &&
            const DeepCollectionEquality()
                .equals(other._activeSkillIds, _activeSkillIds) &&
            const DeepCollectionEquality()
                .equals(other._activeTalismanIds, _activeTalismanIds) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.winStreak, winStreak) ||
                other.winStreak == winStreak) &&
            (identical(other.highestScore, highestScore) ||
                other.highestScore == highestScore) &&
            (identical(other.highestMoney, highestMoney) ||
                other.highestMoney == highestMoney) &&
            const DeepCollectionEquality()
                .equals(other._moneyHistory, _moneyHistory) &&
            (identical(other.currencyLocale, currencyLocale) ||
                other.currencyLocale == currencyLocale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stage,
      gold,
      money,
      stageEarned,
      currentOpponentIndex,
      opponentMoney,
      const DeepCollectionEquality().hash(_activeSkillIds),
      const DeepCollectionEquality().hash(_activeTalismanIds),
      wins,
      losses,
      winStreak,
      highestScore,
      highestMoney,
      const DeepCollectionEquality().hash(_moneyHistory),
      currencyLocale);

  /// Create a copy of RunState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RunStateImplCopyWith<_$RunStateImpl> get copyWith =>
      __$$RunStateImplCopyWithImpl<_$RunStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunStateImplToJson(
      this,
    );
  }
}

abstract class _RunState extends RunState {
  const factory _RunState(
      {final int stage,
      final int gold,
      final double money,
      final double stageEarned,
      final int currentOpponentIndex,
      final double opponentMoney,
      final List<String> activeSkillIds,
      final List<String> activeTalismanIds,
      final int wins,
      final int losses,
      final int winStreak,
      final int highestScore,
      final double highestMoney,
      final List<double> moneyHistory,
      final String currencyLocale}) = _$RunStateImpl;
  const _RunState._() : super._();

  factory _RunState.fromJson(Map<String, dynamic> json) =
      _$RunStateImpl.fromJson;

  @override
  int get stage; // 현재 스테이지 (1~6+)
  @override
  int get gold; // 레거시 (호환용)
  @override
  double get money; // 소지금 (화폐 기준)
  @override
  double get stageEarned; // 레거시 (호환용, 미사용)
  @override
  int get currentOpponentIndex; // 현재 상대 인덱스 (0 또는 1)
  @override
  double get opponentMoney; // 현재 상대의 남은 자금
  @override
  List<String> get activeSkillIds; // 기술 ID 목록 (저장용)
  @override
  List<String> get activeTalismanIds; // 부적 ID 목록 (저장용)
  @override
  int get wins; // 총 승리
  @override
  int get losses; // 총 패배
  @override
  int get winStreak; // 연승 카운터
  @override
  int get highestScore; // 최고 점수
  @override
  double get highestMoney; // 최고 소지금
  @override
  List<double> get moneyHistory; // 소지금 그래프용
  @override
  String get currencyLocale;

  /// Create a copy of RunState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RunStateImplCopyWith<_$RunStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
