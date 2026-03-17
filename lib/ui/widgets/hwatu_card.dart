/// 🎴 K-Poker — 화투 카드 위젯 (최종 버전)
///
/// 실제 PNG + 카드 뒷면(card_back.png) + 상단 월 뱃지 + 하단 카드 특징 표시

import 'package:flutter/material.dart';
import '../../models/card_def.dart';

/// 등급별 보더 색상
const Map<CardGrade, Color> gradeBorderColors = {
  CardGrade.bright: Color(0xFFFFD700),
  CardGrade.animal: Color(0xFF00E5FF),
  CardGrade.ribbon: Color(0xFFFF4081),
  CardGrade.junk: Color(0xFF78909C),
};

/// 카드 특징 텍스트 (하단 중앙 표시용)
String getCardFeatureLabel(CardDef def) {
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

  const HwatuCard({
    super.key,
    required this.card,
    this.size = 80,
    this.onTap,
    this.isSelected = false,
    this.isField = false,
    this.isFaceDown = false,
  });

  @override
  State<HwatuCard> createState() => _HwatuCardState();
}

class _HwatuCardState extends State<HwatuCard> {
  bool _isHovered = false;

  Color get _borderColor => gradeBorderColors[widget.card.def.grade] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    final width = widget.size;
    final height = width * 1.5;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..setTranslationRaw(0.0, _isHovered ? -12.0 : (widget.isSelected ? -8.0 : 0.0), 0.0),
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
      'assets/images/cards/card_back.png',
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
          'assets/images/cards/card_back.png',
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
              Text('뒤집기', style: TextStyle(
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
    final featureLabel = getCardFeatureLabel(widget.card.def);
    final featureColor = getFeatureColor(widget.card.def);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 실제 카드 이미지
        Image.asset(
          'assets/images/cards/${widget.card.def.id}.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[800],
            child: Center(
              child: Text('${widget.card.def.month}월', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),

        // 2. 상단 좌측: 월 뱃지
        Positioned(
          left: 3,
          top: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderColor.withValues(alpha: 0.6), width: 1),
            ),
            child: Text(
              '${widget.card.def.month}월',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.14,
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
                fontSize: width * 0.14,
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
