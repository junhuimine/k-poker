/// 🎴 K-Poker — 카드 애니메이션 오버레이
///
/// 딜링, 카드 플레이, 덱 뒤집기, 획득 카드 이동 등
/// 모든 카드 모션을 관리하는 오버레이 레이어

import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/card_def.dart';
import 'hwatu_card.dart';

/// 날아가는 카드 하나의 애니메이션 상태
class FlyingCard {
  final CardInstance card;
  final Offset from;
  final Offset to;
  final double startAngle;
  final double endAngle;
  final bool isFaceDown;
  final Duration delay;
  final Duration duration;
  final double size;

  FlyingCard({
    required this.card,
    required this.from,
    required this.to,
    this.startAngle = 0,
    this.endAngle = 0,
    this.isFaceDown = false,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
    this.size = 72,
  });
}

/// 애니메이션 오버레이 — Stack 위에 올려서 카드 날아다니는 효과
class CardAnimationOverlay extends StatefulWidget {
  final List<FlyingCard> flyingCards;
  final VoidCallback? onAllComplete;

  const CardAnimationOverlay({
    super.key,
    required this.flyingCards,
    this.onAllComplete,
  });

  @override
  State<CardAnimationOverlay> createState() => _CardAnimationOverlayState();
}

class _CardAnimationOverlayState extends State<CardAnimationOverlay>
    with TickerProviderStateMixin {
  final List<_ActiveFlyingCard> _actives = [];

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  @override
  void didUpdateWidget(CardAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flyingCards != oldWidget.flyingCards && widget.flyingCards.isNotEmpty) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    // 기존 애니메이션 정리
    for (final a in _actives) {
      a.controller.dispose();
    }
    _actives.clear();

    int completedCount = 0;
    final total = widget.flyingCards.length;

    for (final fc in widget.flyingCards) {
      final controller = AnimationController(vsync: this, duration: fc.duration);
      final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

      final active = _ActiveFlyingCard(
        card: fc,
        controller: controller,
        animation: curved,
      );
      _actives.add(active);

      // 딜레이 후 시작
      Future.delayed(fc.delay, () {
        if (mounted) {
          controller.forward().then((_) {
            completedCount++;
            if (completedCount >= total) {
              widget.onAllComplete?.call();
            }
          });
        }
      });
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final a in _actives) {
      a.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _actives.map((a) {
        return AnimatedBuilder(
          animation: a.animation,
          builder: (context, child) {
            final t = a.animation.value;
            final x = a.card.from.dx + (a.card.to.dx - a.card.from.dx) * t;
            final y = a.card.from.dy + (a.card.to.dy - a.card.from.dy) * t;
            final angle = a.card.startAngle + (a.card.endAngle - a.card.startAngle) * t;
            // 약간 아치형 Y 오프셋 (포물선)
            final arcY = -sin(t * pi) * 40;

            return Positioned(
              left: x,
              top: y + arcY,
              child: Transform.rotate(
                angle: angle,
                child: Opacity(
                  opacity: t < 0.05 ? t * 20 : 1.0, // 페이드인
                  child: HwatuCard(
                    card: a.card.card,
                    size: a.card.size,
                    isFaceDown: a.card.isFaceDown,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _ActiveFlyingCard {
  final FlyingCard card;
  final AnimationController controller;
  final Animation<double> animation;

  _ActiveFlyingCard({
    required this.card,
    required this.controller,
    required this.animation,
  });
}
