import 'package:chibakanji/app.dart';
import 'package:chibakanji/providers/app_providers.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openFirstLesson(WidgetTester tester) async {
  await tester.pumpWidget(const AppProviders(child: ChibaKanjiApp()));

  await tester.tap(find.text('Học mới'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Chào hỏi và giao tiếp'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Chào hỏi cơ bản'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('chạm vào thẻ để lật xem nghĩa', (tester) async {
    await _openFirstLesson(tester);

    expect(find.text('Từ 1/5'), findsOneWidget);
    expect(find.text('Xin chào (ban ngày)'), findsNothing);

    await tester.tap(find.text('こんにちは'));
    await tester.pump();

    expect(find.text('Xin chào (ban ngày)'), findsOneWidget);
  });

  testWidgets('học hết 5 từ trong bài thì mở màn hình kết quả', (
    tester,
  ) async {
    await _openFirstLesson(tester);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Đã nhớ'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Kết quả buổi học'), findsOneWidget);
    expect(find.textContaining('Hoàn thành bài'), findsOneWidget);
    expect(find.text('Đã nhớ: 5 · Chưa nhớ: 0'), findsOneWidget);
  });

  testWidgets('nhấn Về trang chủ thoát khỏi luồng flashcard', (tester) async {
    await _openFirstLesson(tester);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Đã nhớ'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Về trang chủ'));
    await tester.pumpAndSettle();

    // popUntil(isFirst) quay về MainScreen, nhưng MainScreen giữ nguyên
    // tab đang chọn ("Học mới") vì State của nó không bị huỷ khi push/pop
    // các route con — nên thấy lại danh sách chủ đề, không phải tab "Ôn tập".
    expect(find.text('Kết quả buổi học'), findsNothing);
    expect(find.text('Chào hỏi và giao tiếp'), findsOneWidget);
  });
}
