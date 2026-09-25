import 'package:flutter_test/flutter_test.dart';
import 'package:chibakanji/app.dart';
import 'package:chibakanji/providers/app_providers.dart';

void main() {
  testWidgets('hiển thị giao diện chính và đổi tab', (tester) async {
    await tester.pumpWidget(const AppProviders(child: ChibaKanjiApp()));
    await tester.pumpAndSettle();

    expect(find.text('Chào Duy!'), findsOneWidget);
    expect(find.text('9 từ vựng'), findsOneWidget);
    expect(find.text('Đến giờ ôn rồi!'), findsOneWidget);

    await tester.tap(find.text('Học mới'));
    await tester.pumpAndSettle();

    expect(find.text('Chào hỏi và giao tiếp'), findsOneWidget);

    await tester.tap(find.text('Chào hỏi và giao tiếp'));
    await tester.pumpAndSettle();

    expect(find.text('Chào hỏi cơ bản'), findsOneWidget);
  });
}
