/// 🎴 K-Poker — main.dart
///
/// 앱 엔트리 포인트. Flutter + Riverpod 기반.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 모바일: 가로 모드 우선 + 상태바/네비게이션 숨기기
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp, // fallback
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: KPokerApp()));
}

class KPokerApp extends StatelessWidget {
  const KPokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-Poker: Hwatu Roguelike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4FACFE),
          secondary: const Color(0xFFFF6B35),
          surface: const Color(0xFF1A1A2E),
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
