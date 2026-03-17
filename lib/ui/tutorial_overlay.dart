/// 🎴 K-Poker — 인터랙티브 튜토리얼 (5단계)

import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  static const _steps = [
    _TutorialStep(
      title: '🎴 화투란?',
      body: '화투는 같은 월(月)의 카드를 매칭하는 한국 전통 카드 게임이에요!\n\n'
            '총 48장(12월 × 4장)의 카드가 있어요.\n'
            '같은 꽃 무늬 = 같은 월이에요!',
      emoji: '🌸',
    ),
    _TutorialStep(
      title: '🃏 카드 내기',
      body: '손에 들고 있는 카드를 터치하면,\n'
            '필드의 같은 월 카드로 날아가서 매칭돼요!\n\n'
            '💡 매칭 가능한 카드는 위로 살짝 올라와 있어요.',
      emoji: '👆',
    ),
    _TutorialStep(
      title: '📦 덱 뒤집기',
      body: '카드를 낸 후, 덱에서 1장을 뒤집어요.\n'
            '뒤집은 카드도 필드와 매칭되면 획득!\n\n'
            '이것이 한 턴의 흐름이에요.',
      emoji: '🔄',
    ),
    _TutorialStep(
      title: '⭐ 족보 모으기',
      body: '획득한 카드로 족보를 만들어 점수를 올려요!\n\n'
            '🌟 광: 오광(15점) → 사광(4) → 삼광(3)\n'
            '🐦 고도리: 새 3마리 = 5점\n'
            '🎀 홍단/청단/초단: 각 3점\n'
            '🐾 동물 5장+: 1점+\n'
            '🍂 피 10장+: 1점+',
      emoji: '📊',
    ),
    _TutorialStep(
      title: '🔥 Go or Stop?',
      body: '3점 이상 되면 선택해요!\n\n'
            '🔥 Go = 계속! 배율이 2배로 올라가지만 위험!\n'
            '🛑 Stop = 정산! 안전하게 수입 확인!\n\n'
            '💡 판돈을 모아 다음 스테이지로 올라가세요!\n'
            '💡 기술과 부적으로 더 강해지세요!',
      emoji: '🎯',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return GestureDetector(
      onTap: () {}, // 배경 클릭 무시
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF30363D), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 진행 바
                Row(
                  children: List.generate(_steps.length, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _step ? const Color(0xFFFFD700) : Colors.white12,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 20),

                // 이모지
                Text(step.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 16),

                // 제목
                Text(step.title, style: const TextStyle(
                  color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 16),

                // 본문
                Text(step.body, style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.6,
                )),
                const SizedBox(height: 24),

                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_step > 0)
                      TextButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('← 이전', style: TextStyle(color: Colors.white54)),
                      )
                    else
                      const SizedBox(),
                    
                    ElevatedButton(
                      onPressed: isLast ? widget.onComplete : () => setState(() => _step++),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isLast ? '게임 시작! 🎴' : '다음 →',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                // 건너뛰기
                if (!isLast)
                  TextButton(
                    onPressed: widget.onComplete,
                    child: const Text('건너뛰기', style: TextStyle(color: Colors.white30, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String title;
  final String body;
  final String emoji;
  const _TutorialStep({required this.title, required this.body, required this.emoji});
}
