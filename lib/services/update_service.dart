// 앱 업데이트 체크 서비스 — 조건부 export.
// Android: Google Play In-App Update API 사용.
// 웹/Windows: no-op stub.
export 'update_service_stub.dart'
    if (dart.library.io) 'update_service_android.dart';
