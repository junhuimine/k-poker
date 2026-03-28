// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameEventsHash() => r'31b127fb97c2aed219357e8b053100f2059340a2';

/// 게임 이벤트 Provider
///
/// Copied from [GameEvents].
@ProviderFor(GameEvents)
final gameEventsProvider =
    AutoDisposeNotifierProvider<GameEvents, List<GameEvent>>.internal(
  GameEvents.new,
  name: r'gameEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gameEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameEvents = AutoDisposeNotifier<List<GameEvent>>;
String _$goStopPendingHash() => r'62c02aef078dd2977575c633045f4d72af97ed7e';

/// 고/스톱 선택 대기 Provider (플레이어용)
///
/// Copied from [GoStopPending].
@ProviderFor(GoStopPending)
final goStopPendingProvider =
    AutoDisposeNotifierProvider<GoStopPending, bool>.internal(
  GoStopPending.new,
  name: r'goStopPendingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goStopPendingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoStopPending = AutoDisposeNotifier<bool>;
String _$aiGoStopAnnounceHash() => r'25dc61645ccae3d223bfd85d4bf650b3f4cb04b2';

/// AI 고/스톱 알림 Provider (화면 애니메이션용)
/// 값: null = 없음, 'go_1', 'go_2', 'go_3', 'stop' 등
///
/// Copied from [AiGoStopAnnounce].
@ProviderFor(AiGoStopAnnounce)
final aiGoStopAnnounceProvider =
    AutoDisposeNotifierProvider<AiGoStopAnnounce, String?>.internal(
  AiGoStopAnnounce.new,
  name: r'aiGoStopAnnounceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiGoStopAnnounceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiGoStopAnnounce = AutoDisposeNotifier<String?>;
String _$yakuAnnounceHash() => r'dd9f6e5cec87721d311e714c98ae31dbdb1fa73f';

/// 족보 달성 알림 Provider (화면 중앙 플래시)
/// 값: null = 없음, '오광', '삼광', '홍단' 등
///
/// Copied from [YakuAnnounce].
@ProviderFor(YakuAnnounce)
final yakuAnnounceProvider =
    AutoDisposeNotifierProvider<YakuAnnounce, String?>.internal(
  YakuAnnounce.new,
  name: r'yakuAnnounceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$yakuAnnounceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$YakuAnnounce = AutoDisposeNotifier<String?>;
String _$gameStateHash() => r'bd7763ff8d65e007a306acf408436275fa912f6d';

/// 게임 세션(라운드) 상태 관리자
///
/// Copied from [GameState].
@ProviderFor(GameState)
final gameStateProvider =
    AutoDisposeNotifierProvider<GameState, RoundState>.internal(
  GameState.new,
  name: r'gameStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gameStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameState = AutoDisposeNotifier<RoundState>;
String _$runStateNotifierHash() => r'825bbe2eb536db2b862649cca5f045b06d1dda49';

/// 전체 런 상태 관리자
///
/// Copied from [RunStateNotifier].
@ProviderFor(RunStateNotifier)
final runStateNotifierProvider =
    AutoDisposeNotifierProvider<RunStateNotifier, RunState>.internal(
  RunStateNotifier.new,
  name: r'runStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$runStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RunStateNotifier = AutoDisposeNotifier<RunState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
