import 'package:flutter/material.dart';

/// AdMob stub — 웹/Windows 플랫폼에서 사용. 모든 메서드 no-op.
class AdService {
  AdService._();

  static const String bannerAdUnitId = '';

  static Future<void> init() async {}

  static Future<void> loadRewardedAd() async {}

  static Future<bool> showRewardedAd({
    required void Function() onRewarded,
    void Function(String error)? onError,
  }) async {
    return false;
  }

  /// 배너 위젯 반환 — stub은 항상 빈 위젯
  static Widget getBannerWidget({bool vertical = false}) => const SizedBox.shrink();

  static void dispose() {}
}
