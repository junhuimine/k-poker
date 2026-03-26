/// 🎴 K-Poker — 화투 카드 위젯 (최종 버전)
///
/// 실제 PNG + 카드 뒷면(card_back.png) + 상단 월 뱃지 + 하단 카드 특징 표시
library;

import 'package:flutter/material.dart';
import '../../i18n/app_strings.dart';
import '../../models/card_def.dart';
import '../../state/card_skin_provider.dart';

/// 등급별 보더 색상
const Map<CardGrade, Color> gradeBorderColors = {
  CardGrade.bright: Color(0xFFFFD700),
  CardGrade.animal: Color(0xFF00E5FF),
  CardGrade.ribbon: Color(0xFFFF4081),
  CardGrade.junk: Color(0xFF78909C),
};

/// 카드 특징 텍스트 (하단 중앙 표시용)
String getCardFeatureLabel(CardDef def, {AppStrings? strings}) {
  if (strings != null) {
    switch (def.grade) {
      case CardGrade.bright:
        return strings.ui('cardGradeBright');
      case CardGrade.animal:
        return strings.ui('cardGradeAnimal');
      case CardGrade.ribbon:
        switch (def.ribbonType) {
          case RibbonType.red:
            return strings.ui('cardGradeRedRibbon');
          case RibbonType.blue:
            return strings.ui('cardGradeBlueRibbon');
          case RibbonType.grass:
            return strings.ui('cardGradeGrassRibbon');
          case RibbonType.plain:
            return strings.ui('cardGradeRibbon');
          default:
            return strings.ui('cardGradeRibbon');
        }
      case CardGrade.junk:
        if (def.isBonus) return strings.ui('doublePi');
        if (def.doubleJunk) return strings.ui('doublePi');
        return strings.ui('cardGradeJunk');
    }
  }
  // 폴백: AppStrings 없으면 한국어 기본값
  switch (def.grade) {
    case CardGrade.bright:
      return '광';
    case CardGrade.animal:
      return '열끗';
    case CardGrade.ribbon:
      switch (def.ribbonType) {
        case RibbonType.red:
          return '홍단';
        case RibbonType.blue:
          return '청단';
        case RibbonType.grass:
          return '초단';
        case RibbonType.plain:
          return '띠';
        default:
          return '띠';
      }
    case CardGrade.junk:
      if (def.isBonus) return '쌍피';
      if (def.doubleJunk) return '쌍피';
      return '피';
  }
}

/// 카드 특징 배경색
Color getFeatureColor(CardDef def) {
  switch (def.grade) {
    case CardGrade.bright:
      return const Color(0xFFFFD700);
    case CardGrade.animal:
      return const Color(0xFF00BCD4);
    case CardGrade.ribbon:
      switch (def.ribbonType) {
        case RibbonType.red:
          return const Color(0xFFE53935);
        case RibbonType.blue:
          return const Color(0xFF1E88E5);
        case RibbonType.grass:
          return const Color(0xFF43A047);
        default:
          return const Color(0xFFAB47BC);
      }
    case CardGrade.junk:
      return const Color(0xFF78909C);
  }
}

class HwatuCard extends StatefulWidget {
  final CardInstance card;
  final double size;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isField;
  final bool isFaceDown;
  final String skinPath;
  final AppStrings? strings;
  /// 앞면 스킨 (manga 등). null이면 기본 original.
  final FrontSkin frontSkin;

  const HwatuCard({
    super.key,
    required this.card,
    this.size = 80,
    this.onTap,
    this.isSelected = false,
    this.isField = false,
    this.isFaceDown = false,
    this.skinPath = 'assets/images/cards/card_back.png',
    this.strings,
    this.frontSkin = FrontSkin.original,
  });

  @override
  State<HwatuCard> createState() => _HwatuCardState();
}

class _HwatuCardState extends State<HwatuCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  Color get _borderColor => gradeBorderColors[widget.card.def.grade] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    final width = widget.size;
    final height = width * 1.5;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() { _isHovered = false; _isPressed = false; }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()
            ..setTranslationRaw(0.0, _isPressed ? -4.0 : (_isHovered ? -15.0 : (widget.isSelected ? -10.0 : 0.0)), 0.0)
            // ignore: deprecated_member_use
            ..scale(_isPressed ? 0.94 : (_isHovered ? 1.05 : 1.0)),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.card.isDeckDraw
                  ? Colors.cyanAccent
                  : (widget.isSelected ? Colors.yellowAccent : (widget.isFaceDown ? Colors.purple.shade800 : _borderColor)),
              width: widget.isSelected || widget.card.isDeckDraw ? 3 : 2,
            ),
            boxShadow: widget.card.isDeckDraw
                ? [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 12)]
                : _buildShadows(),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: (widget.isFaceDown || widget.card.isDeckDraw)
                ? _buildDeckDrawFace(width)
                : _buildCardFront(width),
          ),
        ),
      ),
    );
  }

  /// ── 카드 뒷면 ──
  Widget _buildCardBack() {
    return Image.asset(
      widget.skinPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF2A1A3A), Color(0xFF1A0A2A)]),
        ),
        child: const Center(child: Text('🎴', style: TextStyle(fontSize: 28))),
      ),
    );
  }

  /// ── 덱드로 카드 (뒷면 + 뒤집기 표시) ──
  Widget _buildDeckDrawFace(double width) {
    // isFaceDown이면 일반 뒷면
    if (widget.isFaceDown && !widget.card.isDeckDraw) {
      return _buildCardBack();
    }
    // 덱드로 카드: 뒷면 이미지 + "덱 뒤집기" 오버레이
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          widget.skinPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2A1A3A), Color(0xFF1A0A2A)]),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.cyan.withValues(alpha: 0.0),
                Colors.cyan.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎴', style: TextStyle(fontSize: width * 0.35)),
              Text(widget.strings?.ui('flip') ?? '뒤집기', style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: width * 0.15,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// ── 카드 앞면 (실제 이미지 + 월 뱃지 + 특징 라벨) ──
  Widget _buildCardFront(double width) {
    final featureLabel = getCardFeatureLabel(widget.card.def, strings: widget.strings);
    final featureColor = getFeatureColor(widget.card.def);
    final isManga = widget.frontSkin == FrontSkin.manga;
    final imagePath = widget.frontSkin.getAssetPath(widget.card.def.id);

    Widget cardContent = Stack(
      fit: StackFit.expand,
      children: [
        // 1. 실제 카드 이미지
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[800],
            child: Center(
              child: Text(widget.card.def.isBonus ? (widget.strings?.ui('doublePi') ?? '쌍피') : (widget.strings?.monthFormatted(widget.card.def.month) ?? '${widget.card.def.month}월'), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),

        // 2. 상단 좌측: 월 뱃지
        Positioned(
          left: 3,
          top: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width < 50 ? 2 : 5, vertical: width < 50 ? 1 : 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderColor.withValues(alpha: 0.6), width: 1),
            ),
            child: Text(
              widget.card.def.isBonus ? (widget.strings?.ui('doublePi') ?? '쌍피') : (widget.strings?.monthFormatted(widget.card.def.month) ?? '${widget.card.def.month}월'),
              style: TextStyle(
                color: Colors.white,
                fontSize: (width * 0.18).clamp(10.0, 18.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // 3. 하단 중앙: 카드 특징 라벨 (광, 청단, 홍단, 초단, 열끗, 피)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  featureColor.withValues(alpha: 0.9),
                  featureColor.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Text(
              featureLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: (width * 0.18).clamp(10.0, 18.0),
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ),

        // 4. 에디션 오버레이 (Balatro)
        if (widget.card.edition != Edition.base)
          _buildEditionOverlay(),
      ],
    );

    // 만화 스킨이면 MangaStyleCard 래퍼 적용
    if (isManga) {
      return MangaStyleCard(child: cardContent);
    }
    return cardContent;
  }

  List<BoxShadow> _buildShadows() {
    if (widget.isSelected) {
      return [BoxShadow(color: Colors.yellowAccent.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 3)];
    }
    if (!_isHovered) {
      return [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(2, 3))];
    }
    return [BoxShadow(color: _borderColor.withValues(alpha: 0.7), blurRadius: 18, spreadRadius: 3)];
  }

  Widget _buildEditionOverlay() {
    List<Color> overlayColors;
    switch (widget.card.edition) {
      case Edition.foil:
        overlayColors = [Colors.blueAccent.withValues(alpha: 0.3), Colors.transparent, Colors.cyanAccent.withValues(alpha: 0.2)];
      case Edition.holographic:
        overlayColors = [Colors.purpleAccent.withValues(alpha: 0.3), Colors.transparent, Colors.pinkAccent.withValues(alpha: 0.2)];
      case Edition.polychrome:
        overlayColors = [Colors.redAccent.withValues(alpha: 0.3), Colors.transparent, Colors.orangeAccent.withValues(alpha: 0.2)];
      default:
        overlayColors = [Colors.transparent, Colors.transparent, Colors.transparent];
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: overlayColors),
      ),
    );
  }
}
