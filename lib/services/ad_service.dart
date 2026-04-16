// AdMob 서비스 — 조건부 export.
// Android: google_mobile_ads 실제 구현.
// 웹/Windows: no-op stub.
export 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_android.dart';
