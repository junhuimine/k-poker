import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_poker/main.dart';

void main() {
  // KPokerApp은 GameScreen을 직접 렌더링하며 AudioManager/애니메이션 타이머를 시작함.
  // pumpAndSettle로 타이머를 최대한 소진해 'Timer is still pending' 경고 방지.
  testWidgets('KPokerApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KPokerApp()),
    );
    // 앱이 크래시 없이 렌더링되는지 확인
    expect(find.byType(KPokerApp), findsOneWidget);
    // 남은 프레임/타이머 소진 (최대 5초, 타임아웃 에러는 무시)
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    } catch (_) {
      // 무한 애니메이션이 있을 경우 pumpAndSettle이 타임아웃 — 무시
    }
  });
}
