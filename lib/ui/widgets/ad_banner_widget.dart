import 'package:flutter/material.dart';
import '../../services/ad_service.dart';

/// AdMob 배너 위젯.
/// Android: 실제 광고 표시 / 웹·Windows: 빈 위젯 반환.
class AdBannerWidget extends StatelessWidget {
  /// true = 세로 배너 (게임 화면 좌측), false = 가로 배너 (메인 화면 하단)
  final bool vertical;

  const AdBannerWidget({super.key, this.vertical = false});

  @override
  Widget build(BuildContext context) => AdService.getBannerWidget(vertical: vertical);
}
