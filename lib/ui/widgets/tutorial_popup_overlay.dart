/// 🎴 K-Poker — 인게임 튜토리얼 팝업 (최초 발생 이벤트 안내용)
library;

import 'package:flutter/material.dart';

class TutorialPopupOverlay extends StatefulWidget {
  final String title;
  final String body;
  final String btnText;
  final String doNotShowAgainText;
  final Function(bool) onDismiss;

  const TutorialPopupOverlay({
    super.key,
    required this.title,
    required this.body,
    required this.btnText,
    required this.doNotShowAgainText,
    required this.onDismiss,
  });

  @override
  State<TutorialPopupOverlay> createState() => _TutorialPopupOverlayState();
}

class _TutorialPopupOverlayState extends State<TutorialPopupOverlay> {
  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 40),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _doNotShowAgain,
                    activeColor: const Color(0xFFFFD700),
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    onChanged: (val) {
                      setState(() {
                        _doNotShowAgain = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _doNotShowAgain = !_doNotShowAgain;
                    });
                  },
                  child: Text(
                    widget.doNotShowAgainText,
                    style: TextStyle(
                      color: _doNotShowAgain ? const Color(0xFFFFD700) : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => widget.onDismiss(_doNotShowAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                widget.btnText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
