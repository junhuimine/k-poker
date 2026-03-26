/// 🎴 카드 스킨 관리 (뒷면 + 앞면)
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════
// 카드 뒷면 스킨
// ═══════════════════════════════════════════════════

/// 사용 가능한 뒷면 스킨 목록
enum CardSkin {
  original('Original', 'assets/images/cards/card_back.png', '🎴'),
  classic('Classic', 'assets/images/cards/card_back_classic.png', '🌟'),
  midnight('Midnight', 'assets/images/cards/card_back_midnight.png', '🌙'),
  jade('Jade', 'assets/images/cards/card_back_jade.png', '💎'),
  sakura('Sakura', 'assets/images/cards/card_back_sakura.png', '🌸');

  final String displayName;
  final String assetPath;
  final String emoji;
  const CardSkin(this.displayName, this.assetPath, this.emoji);
}

/// 현재 선택된 뒷면 스킨 상태
class CardSkinNotifier extends StateNotifier<CardSkin> {
  CardSkinNotifier() : super(CardSkin.original) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final skinName = prefs.getString('card_skin') ?? 'classic';
    try {
      state = CardSkin.values.firstWhere((s) => s.name == skinName);
    } catch (_) {
      state = CardSkin.classic;
    }
  }

  Future<void> setSkin(CardSkin skin) async {
    state = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('card_skin', skin.name);
  }
}

final cardSkinProvider = StateNotifierProvider<CardSkinNotifier, CardSkin>(
  (ref) => CardSkinNotifier(),
);

// ═══════════════════════════════════════════════════
// 카드 앞면 스킨
// ═══════════════════════════════════════════════════

/// 앞면 스킨 목록
/// - original: 기본 이미지 (assets/images/cards/)
/// - manga: 만화 스타일 필터 적용
/// - (향후 추가 스킨은 assets/images/cards_xxx/ 폴더에 50장 넣으면 자동 적용)
enum FrontSkin {
  original('Original', '🎴', null),
  manga('Manga', '📖', 'assets/images/cards_manga');

  final String displayName;
  final String emoji;
  /// 커스텀 에셋 폴더 (null이면 기본 폴더 + 필터)
  final String? assetFolder;
  const FrontSkin(this.displayName, this.emoji, this.assetFolder);

  /// 카드 ID에 대한 이미지 경로
  String getAssetPath(String cardId) {
    if (assetFolder != null) {
      return '$assetFolder/$cardId.png';
    }
    return 'assets/images/cards/$cardId.png';
  }
}

/// 만화 스타일 ColorFilter — 고대비 + 채도 부스트 + 볼드 톤
/// RGBA 색상 행렬 (5x4)을 사용한 comic/manga 느낌
const ColorFilter mangaColorFilter = ColorFilter.matrix(<double>[
  1.4,  0.0,  0.0, 0.0, -30, // R: 대비 증가
  0.0,  1.3,  0.0, 0.0, -20, // G: 약간 밝게
  0.0,  0.0,  1.5, 0.0, -40, // B: 파란 톤 강조
  0.0,  0.0,  0.0, 1.0,   0, // A: 그대로
]);

/// 만화 스타일 위젯 래퍼 — 이미지에 만화 필터 + 외곽선 효과 적용
class MangaStyleCard extends StatelessWidget {
  final Widget child;
  const MangaStyleCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 색상 필터 적용 (고대비 + 채도 부스트)
        ColorFiltered(
          colorFilter: mangaColorFilter,
          child: child,
        ),
        // 2. 만화 스타일 오버레이 (하프톤 도트 느낌)
        CustomPaint(
          painter: _MangaOverlayPainter(),
        ),
      ],
    );
  }
}

/// 만화 스타일 하프톤 + 스피드라인 오버레이
class _MangaOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 하프톤 도트 패턴 (경미한 톤 오버레이)
    final dotPaint = Paint()
      ..color = const Color(0x08000000)
      ..style = PaintingStyle.fill;

    const spacing = 6.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    // 외곽 강조선 (만화 패널 느낌)
    final borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(6),
      ),
      borderPaint,
    );

    // 코너 스피드라인 효과 (좌상단)
    final linePaint = Paint()
      ..color = const Color(0x15000000)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final offset = i * 3.0;
      canvas.drawLine(
        Offset(0, offset + 4),
        Offset(offset + 4, 0),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 현재 선택된 앞면 스킨 상태
class FrontSkinNotifier extends StateNotifier<FrontSkin> {
  FrontSkinNotifier() : super(FrontSkin.original) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final skinName = prefs.getString('front_skin') ?? 'original';
    try {
      state = FrontSkin.values.firstWhere((s) => s.name == skinName);
    } catch (_) {
      state = FrontSkin.original;
    }
  }

  Future<void> setSkin(FrontSkin skin) async {
    state = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('front_skin', skin.name);
  }
}

final frontSkinProvider = StateNotifierProvider<FrontSkinNotifier, FrontSkin>(
  (ref) => FrontSkinNotifier(),
);
