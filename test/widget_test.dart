import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_poker/main.dart';

void main() {
  testWidgets('KPokerApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KPokerApp()),
    );
    // 앱이 크래시 없이 렌더링되는지 확인
    expect(find.byType(KPokerApp), findsOneWidget);
  });
}
