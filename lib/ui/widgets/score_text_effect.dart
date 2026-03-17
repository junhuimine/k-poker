/// 🎴 K-Poker — 점수 팝업 텍스트 이펙트
/// 
/// Balatro 스타일의 화려한 숫자 상승 연출.

import 'package:flutter/material.dart';

class ScoreTextEffect extends StatefulWidget {
  final String text;
  final Offset position;
  final Color color;

  const ScoreTextEffect({
    super.key,
    required this.text,
    required this.position,
    this.color = Colors.yellowAccent,
  });

  @override
  State<ScoreTextEffect> createState() => _ScoreTextEffectState();
}

class _ScoreTextEffectState extends State<ScoreTextEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _move;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.5).chain(CurveTween(curve: Curves.elasticOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 70),
    ]).animate(_controller);

    _move = Tween<Offset>(
      begin: widget.position,
      end: widget.position + const Offset(0, -100),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _move.value.dx,
          top: _move.value.dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 10),
                    Shadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
