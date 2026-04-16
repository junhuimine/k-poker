import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Google Play In-App Update 서비스 — Android 전용.
class UpdateService {
  UpdateService._();

  /// 앱 시작 시 호출 — 업데이트 가능하면 자동 처리
  static Future<void> checkForUpdate() async {
    if (!Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;

      // 7일 이상 미업데이트 → immediate (강제 전체화면)
      if (info.immediateUpdateAllowed &&
          (info.clientVersionStalenessDays ?? 0) >= 7) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      // 그 외 → flexible (백그라운드 다운로드)
      if (info.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      debugPrint('InAppUpdate error: $e');
      // 업데이트 체크 실패는 무시 — 게임 실행에 지장 없음
    }
  }
}
