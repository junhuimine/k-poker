// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appStringsHash() => r'b93271bb0bfa9328410b300bd6d26973f93e83f3';

/// 현재 번역 문자열 (UI에서 ref.watch로 사용)
///
/// Copied from [appStrings].
@ProviderFor(appStrings)
final appStringsProvider = AutoDisposeProvider<AppStrings>.internal(
  appStrings,
  name: r'appStringsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStringsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppStringsRef = AutoDisposeProviderRef<AppStrings>;
String _$localeStateHash() => r'd23610d3572068c3cda5852b8ca77a8f0f06c4ee';

/// 현재 언어 상태 관리자
///
/// Copied from [LocaleState].
@ProviderFor(LocaleState)
final localeStateProvider =
    AutoDisposeNotifierProvider<LocaleState, AppLanguage>.internal(
  LocaleState.new,
  name: r'localeStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$localeStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleState = AutoDisposeNotifier<AppLanguage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
