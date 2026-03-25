import 'package:flutter/material.dart';

/// 디바이스 유형
enum DeviceType { phone, tablet, desktop }

/// 반응형 유틸리티 — 화면 크기 기반 스케일링
class Responsive {
  Responsive._();

  // K-Poker 기준 해상도 (디자인 기준)
  static const double _baseWidth = 1200.0;
  static const double _baseHeight = 700.0;

  /// 현재 디바이스 유형 판별
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return DeviceType.phone;
    if (width < 1200) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// 가로 기준 스케일 팩터
  static double scaleX(BuildContext context) {
    return (MediaQuery.of(context).size.width / _baseWidth).clamp(0.4, 2.0);
  }

  /// 세로 기준 스케일 팩터
  static double scaleY(BuildContext context) {
    return (MediaQuery.of(context).size.height / _baseHeight).clamp(0.4, 2.0);
  }

  /// 균등 스케일 팩터 (가로/세로 중 작은 것 기준)
  static double scale(BuildContext context) {
    final sx = scaleX(context);
    final sy = scaleY(context);
    return (sx < sy ? sx : sy).clamp(0.4, 1.5);
  }

  /// 큰 쪽 기준 균등 스케일 팩터 (글꼴 등이 너무 작아지지 않게)
  static double scaleMax(BuildContext context) {
    final sx = scaleX(context);
    final sy = scaleY(context);
    return (sx > sy ? sx : sy).clamp(0.5, 1.5);
  }

  /// 반응형 폰트 크기
  static double fontSize(BuildContext context, double baseFontSize) {
    return baseFontSize * scale(context);
  }

  /// 가로 모드 여부
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).size.width >= MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}
