/// 🎴 K-Poker — 특수 이벤트 그래픽 이펙트 시스템
///
/// 뻑, 쪽, 따닥, 쓸, 폭탄 등 각 이벤트마다 완전히 다른 비주얼 이펙트.
/// CustomPainter + AnimationController 기반.

import 'dart:math';
import 'package:flutter/material.dart';

/// 이벤트 타입에 따라 다른 이펙트를 재생하는 풀스크린 오버레이 위젯
class SpecialEventEffect extends StatefulWidget {
  final String eventType; // 'ppeok', 'chok', 'tadak', 'sweep', 'chok_sweep', 'ppeok_eat', 'double_ppeok', 'triple_ppeok', 'bomb', 족보이름 등
  final VoidCallback? onComplete;

  const SpecialEventEffect({
    super.key,
    required this.eventType,
    this.onComplete,
  });

  @override
  State<SpecialEventEffect> createState() => _SpecialEventEffectState();
}

class _SpecialEventEffectState extends State<SpecialEventEffect>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shakeController;
  late Animation<double> _progress;
  final Random _rng = Random();

  // 파티클 시스템
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    final duration = _getDuration(widget.eventType);
    _mainController = AnimationController(vsync: this, duration: duration);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _progress = CurvedAnimation(parent: _mainController, curve: Curves.easeOut);
    _particles = _generateParticles(widget.eventType);

    _mainController.forward().then((_) {
      widget.onComplete?.call();
    });

    // 진동이 필요한 이벤트
    if (_needsShake(widget.eventType)) {
      _shakeController.repeat(reverse: true);
      Future.delayed(duration - const Duration(milliseconds: 200), () {
        if (mounted) _shakeController.stop();
      });
    }
  }

  Duration _getDuration(String type) {
    switch (type) {
      case 'triple_ppeok':
        return const Duration(milliseconds: 2200);
      case 'double_ppeok':
      case 'bomb':
      case 'chongtong':
        return const Duration(milliseconds: 1600);
      case 'ppeok':
      case 'ppeok_eat':
      case 'self_ppeok':
      case 'tadak':
      case 'sweep':
      case 'chok_sweep':
        return const Duration(milliseconds: 1200);
      case 'chok':
        return const Duration(milliseconds: 1000);
      default:
        return const Duration(milliseconds: 1200);
    }
  }

  bool _needsShake(String type) {
    return const {'ppeok', 'ppeok_eat', 'self_ppeok', 'bomb', 'chongtong', 'double_ppeok', 'triple_ppeok', 'tadak'}
        .contains(type);
  }

  List<_Particle> _generateParticles(String type) {
    final count = _getParticleCount(type);
    return List.generate(count, (i) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 80 + _rng.nextDouble() * 220;
      final size = 3.0 + _rng.nextDouble() * 8;
      final life = 0.4 + _rng.nextDouble() * 0.6;
      return _Particle(
        angle: angle,
        speed: speed,
        size: size,
        life: life,
        color: _getParticleColor(type, _rng),
        shape: _rng.nextBool() ? _PShape.circle : _PShape.diamond,
      );
    });
  }

  int _getParticleCount(String type) {
    switch (type) {
      case 'bomb':
      case 'chongtong':
        return 60;
      case 'triple_ppeok':
        return 80;
      case 'double_ppeok':
        return 50;
      case 'self_ppeok':
        return 45;
      case 'sweep':
      case 'chok_sweep':
        return 40;
      case 'tadak':
        return 45;
      case 'ppeok_eat':
        return 35;
      case 'ppeok':
        return 20;
      case 'chok':
        return 25;
      default:
        return 30;
    }
  }

  Color _getParticleColor(String type, Random rng) {
    switch (type) {
      case 'bomb':
      case 'chongtong':
        return [Colors.orange, Colors.red, Colors.yellow, Colors.deepOrange][rng.nextInt(4)];
      case 'ppeok':
      case 'ppeok_eat':
      case 'self_ppeok':
        return [Colors.amber, Colors.orange, Colors.white][rng.nextInt(3)];
      case 'double_ppeok':
      case 'triple_ppeok':
        return [Colors.red, Colors.deepOrange, Colors.yellow, const Color(0xFFFF1744)][rng.nextInt(4)];
      case 'chok':
        return [Colors.cyanAccent, Colors.lightBlueAccent, Colors.white][rng.nextInt(3)];
      case 'tadak':
        return [Colors.purpleAccent, Colors.deepPurpleAccent, Colors.lightBlueAccent, Colors.white][rng.nextInt(4)];
      case 'sweep':
      case 'chok_sweep':
        return [Colors.tealAccent, Colors.cyanAccent, Colors.lightBlue, Colors.white][rng.nextInt(4)];
      default:
        return [Colors.amber, Colors.white, Colors.cyanAccent][rng.nextInt(3)];
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _shakeController]),
      builder: (context, _) {
        final t = _progress.value;
        // 화면 전체 진동 오프셋
        double shakeX = 0, shakeY = 0;
        if (_needsShake(widget.eventType) && _shakeController.isAnimating) {
          final intensity = _getShakeIntensity(widget.eventType);
          shakeX = sin(_shakeController.value * pi * 8) * intensity;
          shakeY = cos(_shakeController.value * pi * 6) * intensity * 0.7;
        }

        return IgnorePointer(
          child: Transform.translate(
            offset: Offset(shakeX, shakeY),
            child: Stack(
              children: [
                // 배경 플래시
                _buildBackgroundFlash(t),
                // 파티클 시스템
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: t,
                      eventType: widget.eventType,
                    ),
                  ),
                ),
                // 이벤트별 고유 이펙트
                _buildEventSpecificEffect(t),
                // 중앙 텍스트 이펙트
                _buildCenterText(t),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getShakeIntensity(String type) {
    switch (type) {
      case 'bomb':
        return 12;
      case 'triple_ppeok':
        return 15;
      case 'double_ppeok':
        return 10;
      case 'ppeok':
      case 'ppeok_eat':
        return 8;
      case 'tadak':
        return 6;
      default:
        return 4;
    }
  }

  // ━━━ 배경 플래시 ━━━
  Widget _buildBackgroundFlash(double t) {
    final flashOpacity = t < 0.15 ? t / 0.15 * 0.5 : (1.0 - t) * 0.3;
    Color flashColor;

    switch (widget.eventType) {
      case 'bomb':
      case 'chongtong':
        flashColor = Colors.orange;
        break;
      case 'triple_ppeok':
        flashColor = Colors.red;
        break;
      case 'double_ppeok':
        flashColor = const Color(0xFFFF3D00);
        break;
      case 'ppeok':
      case 'ppeok_eat':
        flashColor = Colors.amber;
        break;
      case 'sweep':
      case 'chok_sweep':
        flashColor = Colors.teal;
        break;
      case 'tadak':
        flashColor = Colors.deepPurple;
        break;
      case 'chok':
        flashColor = Colors.cyan;
        break;
      default:
        flashColor = Colors.amber;
    }

    return Positioned.fill(
      child: Container(
        color: flashColor.withValues(alpha: flashOpacity.clamp(0.0, 0.5)),
      ),
    );
  }

  // ━━━ 이벤트별 고유 이펙트 ━━━
  Widget _buildEventSpecificEffect(double t) {
    switch (widget.eventType) {
      case 'bomb':
      case 'chongtong':
        return _buildBombShockwave(t);
      case 'sweep':
      case 'chok_sweep':
        return _buildWaveEffect(t);
      case 'tadak':
        return _buildLightningSlash(t);
      case 'ppeok_eat':
      case 'self_ppeok':
        return _buildVortexEffect(t);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 💣 폭탄 충격파 — 원형 확산 링
  Widget _buildBombShockwave(double t) {
    return Center(
      child: CustomPaint(
        size: const Size(400, 400),
        painter: _ShockwavePainter(progress: t),
      ),
    );
  }

  /// 🌊 쓸 — 바닥에서 위로 쓸려가는 파도
  Widget _buildWaveEffect(double t) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WavePainter(
          progress: t,
          isChokSweep: widget.eventType == 'chok_sweep',
        ),
      ),
    );
  }

  /// ⚡ 따닥 — X자 교차 슬래시
  Widget _buildLightningSlash(double t) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _LightningSlashPainter(progress: t),
      ),
    );
  }

  /// 💥 뻑먹기 — 중앙 흡수 소용돌이
  Widget _buildVortexEffect(double t) {
    return Center(
      child: CustomPaint(
        size: const Size(300, 300),
        painter: _VortexPainter(progress: t),
      ),
    );
  }

  // ━━━ 중앙 텍스트 이펙트 ━━━
  Widget _buildCenterText(double t) {
    final config = _getTextConfig(widget.eventType);
    // 등장(0~0.3) → 유지(0.3~0.7) → 소멸(0.7~1.0)
    double opacity;
    double scale;
    double rotation;

    if (t < 0.15) {
      // 등장: 작다가 폭발적으로 커짐
      final enter = t / 0.15;
      opacity = enter;
      scale = 0.3 + enter * 1.2; // 0.3 → 1.5
      rotation = (1.0 - enter) * 0.1;
    } else if (t < 0.3) {
      // 바운스 안정화
      final stabilize = (t - 0.15) / 0.15;
      opacity = 1.0;
      scale = 1.5 - stabilize * 0.5; // 1.5 → 1.0
      rotation = 0.0;
    } else if (t < 0.75) {
      // 유지
      opacity = 1.0;
      scale = 1.0 + sin(t * pi * 4) * 0.03; // 미세한 펄싱
      rotation = 0.0;
    } else {
      // 소멸: 위로 날아가며 사라짐
      final exit = (t - 0.75) / 0.25;
      opacity = 1.0 - exit;
      scale = 1.0 + exit * 0.5; // 커지면서 사라짐
      rotation = 0.0;
    }

    return Center(
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale.clamp(0.0, 3.0),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이벤트 아이콘 (크게)
                Text(
                  config.icon,
                  style: TextStyle(
                    fontSize: config.iconSize,
                    shadows: [
                      Shadow(color: config.glowColor, blurRadius: 30),
                      Shadow(color: config.glowColor, blurRadius: 60),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 이벤트 텍스트
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.bgColor.withValues(alpha: 0.9),
                        config.bgColor2.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: config.borderColor, width: 3),
                    boxShadow: [
                      BoxShadow(color: config.glowColor.withValues(alpha: 0.7), blurRadius: 40, spreadRadius: 8),
                    ],
                  ),
                  child: Text(
                    config.text,
                    style: TextStyle(
                      color: config.textColor,
                      fontSize: config.fontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: config.letterSpacing,
                      shadows: [
                        Shadow(color: config.glowColor, blurRadius: 20),
                        const Shadow(color: Colors.black, blurRadius: 8),
                      ],
                    ),
                  ),
                ),
                // 서브텍스트 (있을 경우)
                if (config.subText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      config.subText,
                      style: TextStyle(
                        color: config.textColor.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: config.glowColor, blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _TextConfig _getTextConfig(String type) {
    switch (type) {
      case 'ppeok':
        return _TextConfig(
          icon: '💥',
          iconSize: 64,
          text: '뻑',
          fontSize: 52,
          letterSpacing: 12,
          textColor: Colors.amber,
          glowColor: Colors.orange,
          bgColor: const Color(0xFF1A0A00),
          bgColor2: const Color(0xFF2E1500),
          borderColor: Colors.orange,
        );
      case 'double_ppeok':
        return _TextConfig(
          icon: '🔥🔥',
          iconSize: 56,
          text: '연뻑',
          fontSize: 48,
          letterSpacing: 10,
          subText: '+3점',
          textColor: const Color(0xFFFF3D00),
          glowColor: Colors.red,
          bgColor: const Color(0xFF2A0000),
          bgColor2: const Color(0xFF4A0000),
          borderColor: Colors.red,
        );
      case 'triple_ppeok':
        return _TextConfig(
          icon: '🔥🔥🔥',
          iconSize: 52,
          text: '삼뻑',
          fontSize: 56,
          letterSpacing: 14,
          subText: '즉시 승리',
          textColor: Colors.white,
          glowColor: const Color(0xFFFF1744),
          bgColor: const Color(0xFF4A0000),
          bgColor2: const Color(0xFF7A0000),
          borderColor: const Color(0xFFFF1744),
        );
      case 'chok':
        return _TextConfig(
          icon: '✌️',
          iconSize: 60,
          text: '쪽',
          fontSize: 52,
          letterSpacing: 10,
          textColor: Colors.cyanAccent,
          glowColor: Colors.cyan,
          bgColor: const Color(0xFF001A2E),
          bgColor2: const Color(0xFF002A4A),
          borderColor: Colors.cyanAccent,
        );
      case 'chok_sweep':
        return _TextConfig(
          icon: '✌️🌊',
          iconSize: 56,
          text: '쪽쓸',
          fontSize: 48,
          letterSpacing: 10,
          subText: '피 2장 빼앗기',
          textColor: Colors.tealAccent,
          glowColor: Colors.teal,
          bgColor: const Color(0xFF001A1A),
          bgColor2: const Color(0xFF003333),
          borderColor: Colors.tealAccent,
        );
      case 'tadak':
        return _TextConfig(
          icon: '⚡',
          iconSize: 64,
          text: '따닥',
          fontSize: 48,
          letterSpacing: 10,
          textColor: Colors.purpleAccent,
          glowColor: Colors.deepPurple,
          bgColor: const Color(0xFF0A001A),
          bgColor2: const Color(0xFF1A0033),
          borderColor: Colors.purpleAccent,
        );
      case 'sweep':
        return _TextConfig(
          icon: '🌊',
          iconSize: 64,
          text: '쓸',
          fontSize: 56,
          letterSpacing: 14,
          textColor: Colors.lightBlueAccent,
          glowColor: Colors.blue,
          bgColor: const Color(0xFF00001A),
          bgColor2: const Color(0xFF000033),
          borderColor: Colors.lightBlueAccent,
        );
      case 'ppeok_eat':
        return _TextConfig(
          icon: '😈',
          iconSize: 60,
          text: '뻑 먹기',
          fontSize: 42,
          letterSpacing: 8,
          subText: '4장 흡수',
          textColor: Colors.orangeAccent,
          glowColor: Colors.deepOrange,
          bgColor: const Color(0xFF1A0500),
          bgColor2: const Color(0xFF2E0A00),
          borderColor: Colors.orangeAccent,
        );
      case 'self_ppeok':
        return _TextConfig(
          icon: '🔥😈',
          iconSize: 58,
          text: '자뻑',
          fontSize: 48,
          letterSpacing: 10,
          subText: '4장 + 피 2장 빼앗기!',
          textColor: const Color(0xFFFF6D00),
          glowColor: const Color(0xFFFF3D00),
          bgColor: const Color(0xFF2A0500),
          bgColor2: const Color(0xFF4A0A00),
          borderColor: const Color(0xFFFF6D00),
        );
      case 'bomb':
        return _TextConfig(
          icon: '💣',
          iconSize: 70,
          text: '폭탄',
          fontSize: 52,
          letterSpacing: 12,
          textColor: Colors.yellow,
          glowColor: Colors.orange,
          bgColor: const Color(0xFF1A0A00),
          bgColor2: const Color(0xFF331500),
          borderColor: Colors.yellow,
        );
      case 'chongtong':
        return _TextConfig(
          icon: '🎆',
          iconSize: 70,
          text: '총통',
          fontSize: 56,
          letterSpacing: 14,
          subText: '4장 즉시 획득',
          textColor: Colors.yellow,
          glowColor: Colors.orange,
          bgColor: const Color(0xFF1A0A00),
          bgColor2: const Color(0xFF331500),
          borderColor: Colors.yellow,
        );
      default:
        // 족보 달성(오광, 삼광, 홍단 등)
        return _TextConfig(
          icon: _getYakuEmoji(type),
          iconSize: 56,
          text: type,
          fontSize: 40,
          letterSpacing: 6,
          textColor: const Color(0xFFFFD700),
          glowColor: Colors.amber,
          bgColor: const Color(0xFF0A0A1A),
          bgColor2: const Color(0xFF1A1A2E),
          borderColor: const Color(0xFFFFD700),
        );
    }
  }

  String _getYakuEmoji(String yaku) {
    const map = {
      '오광': '🌟',
      '사광': '⭐',
      '삼광': '✨',
      '비삼광': '🌧️',
      '홍단': '🔴',
      '청단': '🔵',
      '초단': '🟢',
      '고도리': '🐦',
      '오끗': '🦌',
    };
    return map[yaku] ?? '🎴';
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 텍스트 설정 데이터 클래스
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TextConfig {
  final String icon;
  final double iconSize;
  final String text;
  final double fontSize;
  final double letterSpacing;
  final String subText;
  final Color textColor;
  final Color glowColor;
  final Color bgColor;
  final Color bgColor2;
  final Color borderColor;

  const _TextConfig({
    required this.icon,
    required this.iconSize,
    required this.text,
    required this.fontSize,
    required this.letterSpacing,
    this.subText = '',
    required this.textColor,
    required this.glowColor,
    required this.bgColor,
    required this.bgColor2,
    required this.borderColor,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 파티클 시스템
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enum _PShape { circle, diamond }

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double life; // 0.0~1.0: 파티클이 활성화되는 진행도 범위
  final Color color;
  final _PShape shape;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.life,
    required this.color,
    required this.shape,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final String eventType;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.eventType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      // 파티클 등장 시점 (이벤트 초기에 한번에 터지는 느낌)
      final startT = (1.0 - p.life) * 0.2;
      if (progress < startT) continue;

      final localT = ((progress - startT) / (1.0 - startT)).clamp(0.0, 1.0);
      if (localT >= p.life) continue;

      final normalizedLife = localT / p.life;
      final alpha = (1.0 - normalizedLife).clamp(0.0, 1.0);
      final dist = p.speed * localT;

      // 중력효과: 시간이 지남에 따라 Y가 아래로
      final gravity = eventType == 'bomb' ? 60.0 : 30.0;
      final dx = center.dx + cos(p.angle) * dist;
      final dy = center.dy + sin(p.angle) * dist + gravity * localT * localT;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      final particleSize = p.size * (1.0 - normalizedLife * 0.5);

      if (p.shape == _PShape.circle) {
        canvas.drawCircle(Offset(dx, dy), particleSize, paint);
      } else {
        // 다이아몬드 모양
        final path = Path()
          ..moveTo(dx, dy - particleSize)
          ..lineTo(dx + particleSize * 0.7, dy)
          ..lineTo(dx, dy + particleSize)
          ..lineTo(dx - particleSize * 0.7, dy)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 💣 폭탄 충격파 링
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ShockwavePainter extends CustomPainter {
  final double progress;
  _ShockwavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 3개의 충격파 링이 시차를 두고 확산
    for (int ring = 0; ring < 3; ring++) {
      final delay = ring * 0.1;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final radius = t * size.width * 0.5;
      final alpha = (1.0 - t) * 0.8;
      final strokeWidth = (1.0 - t) * 6 + 1;

      final paint = Paint()
        ..color = Colors.orange.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + t * 6);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ShockwavePainter old) => old.progress != progress;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🌊 파도 웨이브
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _WavePainter extends CustomPainter {
  final double progress;
  final bool isChokSweep;
  _WavePainter({required this.progress, this.isChokSweep = false});

  @override
  void paint(Canvas canvas, Size size) {
    // 바닥에서 위로 쓸려가는 복수개의 파도
    final waveCount = isChokSweep ? 4 : 3;
    for (int i = 0; i < waveCount; i++) {
      final delay = i * 0.08;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final baseY = size.height * (1.0 - t); // 바닥 → 위로
      final alpha = (1.0 - t) * 0.4;
      final color = isChokSweep
          ? Color.lerp(Colors.cyan, Colors.tealAccent, i / waveCount)!
          : Color.lerp(Colors.blue, Colors.lightBlueAccent, i / waveCount)!;

      final path = Path();
      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      // 물결 모양
      for (double x = 0; x <= size.width; x += 4) {
        final waveY = baseY + sin(x * 0.03 + t * pi * 6 + i * pi / 3) * (20 - t * 15);
        path.lineTo(x, waveY);
      }
      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚡ 번개 X-슬래시
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LightningSlashPainter extends CustomPainter {
  final double progress;
  _LightningSlashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1 || progress > 0.8) return;

    final t = ((progress - 0.1) / 0.7).clamp(0.0, 1.0);
    final alpha = t < 0.5 ? t * 2 : (1.0 - t) * 2;
    final rng = Random(42); // 고정 시드로 일관된 번개

    void drawLightning(Offset start, Offset end, double width) {
      final path = Path();
      path.moveTo(start.dx, start.dy);

      final segments = 8;
      for (int i = 1; i < segments; i++) {
        final ratio = i / segments;
        final x = start.dx + (end.dx - start.dx) * ratio;
        final y = start.dy + (end.dy - start.dy) * ratio;
        final jitter = (rng.nextDouble() - 0.5) * 40;
        path.lineTo(x + jitter, y + jitter);
      }
      path.lineTo(end.dx, end.dy);

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.purpleAccent.withValues(alpha: alpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 2),
      );

      // 코어 (밝은선)
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: (alpha * 0.8).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.3
          ..strokeCap = StrokeCap.round,
      );
    }

    // X자 슬래시
    final drawLen = t.clamp(0.0, 1.0);
    final cx = size.width / 2, cy = size.height / 2;
    final span = 150.0;

    drawLightning(
      Offset(cx - span * drawLen, cy - span * drawLen),
      Offset(cx + span * drawLen, cy + span * drawLen),
      4,
    );
    drawLightning(
      Offset(cx + span * drawLen, cy - span * drawLen),
      Offset(cx - span * drawLen, cy + span * drawLen),
      4,
    );
  }

  @override
  bool shouldRepaint(_LightningSlashPainter old) => old.progress != progress;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 😈 뻑먹기 소용돌이
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _VortexPainter extends CustomPainter {
  final double progress;
  _VortexPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.45;

    // 소용돌이 나선 — 바깥에서 안으로 빨려드는 느낌
    for (int arm = 0; arm < 6; arm++) {
      final baseAngle = arm * pi / 3;
      final path = Path();
      bool first = true;

      for (double r = maxRadius; r > 5; r -= 3) {
        final normalizedR = r / maxRadius;
        final angle = baseAngle + (1.0 - normalizedR) * pi * 3 + progress * pi * 4;
        // 진행도에 따라 소용돌이가 중앙으로 빨려듦
        final actualR = r * (1.0 - progress * 0.7);
        final x = center.dx + cos(angle) * actualR;
        final y = center.dy + sin(angle) * actualR;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      final alpha = (1.0 - progress) * 0.6;
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.deepOrange.withValues(alpha: alpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_VortexPainter old) => old.progress != progress;
}
