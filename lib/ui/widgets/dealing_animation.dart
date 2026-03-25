/// 🎴 K-Poker — 카드 분배(Dealing) 애니메이션 위젯
/// 
/// 카드가 덱에서 각자의 위치로 날아가는 연출 담당.
library;

import 'package:flutter/material.dart';

class DealingAnimation extends StatelessWidget {
  final Widget child;
  final Offset startOffset;
  final Offset endOffset;
  final Duration delay;

  const DealingAnimation({
    super.key,
    required this.child,
    required this.startOffset,
    required this.endOffset,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final currentOffset = Offset.lerp(startOffset, endOffset, value)!;
        return Positioned(
          left: currentOffset.dx,
          top: currentOffset.dy,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
