import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('US06, US07: tab Học mới hiện chủ đề, chạm chủ đề hiện bài học',
      (tester) async {
    await pumpTestApp(tester);

    expect(find.text('Chào Duy!'), findsOneWidget);
    expect(find.text('9 từ vựng'), findsOneWidget);
    expect(find.text('Đến giờ ôn tập'), findsOneWidget);

    await tester.tap(find.text('Học mới'));
    await tester.pumpAndSettle();

    expect(find.text('Chào hỏi và giao tiếp'), findsOneWidget);

    await tester.tap(find.text('Chào hỏi và giao tiếp'));
    await tester.pumpAndSettle();

    expect(find.text('Chào hỏi cơ bản'), findsOneWidget);
  });

  testWidgets('8e: hiển thị giao diện Sổ từ và Cá nhân', (tester) async {
    await pumpTestApp(tester);

    await tester.tap(find.text('Sổ từ'));
    await tester.pumpAndSettle();

    expect(find.text('Sổ từ'), findsNWidgets(2));
    expect(find.text('9 từ đã học'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Đến hạn · 3'), findsOneWidget);

    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();

    expect(find.text('Cá nhân'), findsNWidgets(2));
    expect(find.text('Duy'), findsOneWidget);
    expect(find.text('Mục tiêu hôm nay'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Thành tích'), 180);
    expect(find.text('Thành tích'), findsOneWidget);
  });
}
