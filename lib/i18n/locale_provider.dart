/// 🎴 K-Poker — 언어 상태 관리 Provider

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_strings.dart';

part 'locale_provider.g.dart';

/// 현재 언어 상태 관리자
@riverpod
class LocaleState extends _$LocaleState {
  @override
  AppLanguage build() {
    // 기본값: 한국어
    return AppLanguage.ko;
  }

  /// 시스템 로케일로 초기화
  void initFromSystem(Locale systemLocale) {
    state = detectLanguage(systemLocale);
  }

  /// 수동 언어 변경
  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

/// 현재 번역 문자열 (UI에서 ref.watch로 사용)
@riverpod
AppStrings appStrings(AppStringsRef ref) {
  final lang = ref.watch(localeStateProvider);
  return AppStrings(lang);
}
