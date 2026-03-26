/// 🎴 K-Poker — 언어 상태 관리 Provider
library;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

part 'locale_provider.g.dart';

const String _langPrefKey = 'app_language';

/// 현재 언어 상태 관리자
@riverpod
class LocaleState extends _$LocaleState {
  @override
  AppLanguage build() {
    _initFromSaved();
    return AppLanguage.ko; // 비동기 로드 완료 전 기본값
  }

  /// 저장된 설정 또는 시스템 로케일로 초기화
  Future<void> _initFromSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_langPrefKey);
    if (saved != null) {
      // 사용자가 수동 선택한 언어 복원
      final match = AppLanguage.values.where((l) => l.name == saved);
      if (match.isNotEmpty) {
        state = match.first;
      }
    } else {
      // 첫 실행: 시스템 로케일 자동 감지
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      state = detectLanguage(locale);
    }
  }

  /// 시스템 로케일로 초기화
  void initFromSystem(Locale systemLocale) {
    state = detectLanguage(systemLocale);
  }

  /// 수동 언어 변경 (SharedPreferences에 저장)
  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langPrefKey, lang.name);
  }
}

/// 현재 번역 문자열 (UI에서 ref.watch로 사용)
@riverpod
AppStrings appStrings(AppStringsRef ref) {
  final lang = ref.watch(localeStateProvider);
  return AppStrings(lang);
}
