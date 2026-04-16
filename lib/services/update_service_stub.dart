/// 업데이트 체크 no-op stub — 웹/Windows용.
class UpdateService {
  UpdateService._();

  /// 앱 시작 시 호출 — 업데이트 가능하면 다이얼로그 표시
  static Future<void> checkForUpdate() async {
    // 웹/Windows에서는 아무것도 하지 않음
  }
}
