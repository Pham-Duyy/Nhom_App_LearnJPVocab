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

  testWidgets('hiển thị giao diện Sổ từ và Cá nhân', (tester) async {
    await tester.pumpWidget(const AppProviders(child: ChibaKanjiApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sổ từ'));
    await tester.pumpAndSettle();

    expect(find.text('Sổ từ của bạn'), findsOneWidget);
    expect(find.text('9 từ đã học'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Đến hạn'), findsOneWidget);

    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();

    expect(find.text('Cá nhân'), findsNWidgets(2));
    expect(find.text('Duy'), findsOneWidget);
    expect(find.text('Mục tiêu hôm nay'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Thành tích'), 180);
    expect(find.text('Thành tích'), findsOneWidget);
  });
}
