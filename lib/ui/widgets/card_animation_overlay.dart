/// 🎴 K-Poker — 고퀄리티 카드 애니메이션 오버레이 v2.0
///
/// 고스톱/화투 스타일의 리얼한 카드 모션:
/// - 베지어 곡선 궤적 (포물선 아치)
/// - 이징 커브 다변화 (easeOutBack, elasticOut, bounceOut)
/// - 동적 크기 스케일 (멀리→가까이 느낌)
/// - 발광 + 그림자 효과
/// - 착지 바운스 + 흔들림
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../../i18n/app_strings.dart';
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
  /// 애니메이션 스타일: 'deal'(딜링), 'play'(카드 내기), 'capture'(획득), 'deck'(덱 플립)
  final String style;

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
    this.style = 'play',
  });
}

/// 애니메이션 오버레이 — Stack 위에 올려서 카드 날아다니는 효과
class CardAnimationOverlay extends StatefulWidget {
  final List<FlyingCard> flyingCards;
  final VoidCallback? onAllComplete;
  final String skinPath;
  final AppStrings? strings;

  const CardAnimationOverlay({
    super.key,
    required this.flyingCards,
    this.onAllComplete,
    this.skinPath = 'assets/images/cards/card_back.webp',
    this.strings,
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

  /// 스타일별 이징 커브 선택
  Curve _getCurveForStyle(String style) {
    switch (style) {
      case 'deal':
        return Curves.easeOutQuart;        // 딜링: 빠르게 출발 → 부드럽게 착지
      case 'play':
        return Curves.easeOutBack;         // 플레이: 살짝 오버슈트 → 되돌아오기
      case 'capture':
        return Curves.easeInOutCubic;      // 획득: 부드러운 가속·감속
      case 'deck':
        return Curves.easeOutCubic;        // 덱 플립: 자연스러운 감속
      default:
        return Curves.easeOutCubic;
    }
  }

  /// 스타일별 아치 높이 계산 (발라트로식 다이나믹 비행)
  double _getArcHeight(String style) {
    switch (style) {
      case 'deal':
        return 40;   // 딜링: 낮은 아치
      case 'play':
        return 100;  // 플레이: 높은 아치 (카드 던지는 느낌)
      case 'capture':
        return 50;   // 획득: 중간 아치
      case 'deck':
        return 65;   // 덱 플립: 중간~높은 아치
      default:
        return 50;
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
      final curve = _getCurveForStyle(fc.style);
      final curved = CurvedAnimation(parent: controller, curve: curve);

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
            final style = a.card.style;
            final arcHeight = _getArcHeight(style);

            // ── 위치: 2차 베지어 곡선 (포물선 아치) ──
            final dx = a.card.to.dx - a.card.from.dx;
            final dy = a.card.to.dy - a.card.from.dy;
            final x = a.card.from.dx + dx * t;
            // 포물선 아치: 중간에 최고점, 양 끝에서 0
            final arcY = -4 * arcHeight * t * (1 - t);
            // 바운스 착지: t > 0.85에서 미세 반동
            final bounceY = t > 0.85
                ? sin((t - 0.85) / 0.15 * pi * 2) * 6 * (1 - t) / 0.15
                : 0.0;
            final y = a.card.from.dy + dy * t + arcY + bounceY;

            // ── 회전: 날아가면서 자연스럽게 회전 ──
            final baseAngle = a.card.startAngle + (a.card.endAngle - a.card.startAngle) * t;
            // 비행 중 더 강한 흔들림
            final wobble = (style == 'play' || style == 'deck')
                ? sin(t * pi * 4) * 0.06 * (1 - t)  // 감쇠 흔들림 (강도 2x)
                : (style == 'capture')
                    ? sin(t * pi * 3) * 0.03 * (1 - t)
                    : 0.0;
            final angle = baseAngle + wobble;

            // ── 크기: 날아가면서 커졌다 원래로 (원근감) ──
            final scaleEffect = style == 'deal'
                ? 1.0  // 딜링: 크기 변화 없음 (깔끔하게)
                : 1.0 + sin(t * pi) * 0.12;

            // ── 투명도: 페이드인 ──
            final opacity = t < 0.05 ? t * 20 : 1.0;

            // ── 그림자 강도: 비행 중 강해졌다 착지 시 약해짐 ──
            final shadowIntensity = sin(t * pi) * 0.7;

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: scaleEffect,
                child: Transform.rotate(
                  angle: angle,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: style == 'deal'
                          ? [
                              // 딜링: 가벼운 그림자만 (플래시 방지)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              // 플레이/획득/덱: 발광 + 드롭 섀도우
                              BoxShadow(
                                color: _getGlowColor(style).withValues(alpha: shadowIntensity * 0.5),
                                blurRadius: 12 + shadowIntensity * 10,
                                spreadRadius: 1 + shadowIntensity * 2,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3 + shadowIntensity * 0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4 + shadowIntensity * 3),
                              ),
                            ],
                      ),
                      child: HwatuCard(
                        card: a.card.card,
                        size: a.card.size,
                        isFaceDown: a.card.isFaceDown,
                        skinPath: widget.skinPath,
                        strings: widget.strings,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// 스타일별 발광 색상
  Color _getGlowColor(String style) {
    switch (style) {
      case 'play':
        return Colors.amber;        // 플레이: 금빛 발광
      case 'capture':
        return Colors.greenAccent;  // 획득: 초록 발광
      case 'deck':
        return Colors.cyanAccent;   // 덱: 시안 발광
      case 'deal':
        return Colors.purple;       // 딜링: 보라 발광
      default:
        return Colors.white;
    }
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
