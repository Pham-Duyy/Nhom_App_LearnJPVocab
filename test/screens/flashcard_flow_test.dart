import 'package:chibakanji/app.dart';
import 'package:chibakanji/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openFirstLesson(WidgetTester tester) async {
  await tester
      .pumpWidget(const AppProviders(child: ChibaKanjiApp(showWelcome: false)));

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
    await tester.pumpAndSettle();

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

  testWidgets('nhấn Về trang chủ chuyển hẳn về tab Ôn tập', (tester) async {
    await _openFirstLesson(tester);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Đã nhớ'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Về trang chủ'));
    await tester.pumpAndSettle();

    // Chỉ kiểm tra đã điều hướng đúng về tab Ôn tập — không kiểm tra nội
    // dung ReviewCard ở đây, vì bài "Chào hỏi cơ bản" chứa đúng 3 từ đang
    // đến hạn trong dữ liệu mock (v_greet_1/2/3); học xong bài này khiến
    // due count đổi thành 0, đó là hành vi đúng chứ không phải lỗi.
    expect(find.text('Kết quả buổi học'), findsNothing);
    expect(find.text('Chào Duy!'), findsOneWidget);
  });

  testWidgets('khoá nút khi đang lưu để tránh bấm đúp bỏ qua từ', (
    tester,
  ) async {
    await _openFirstLesson(tester);

    expect(find.text('Từ 1/5'), findsOneWidget);

    // Gọi trực tiếp closure onPressed đã bắt được lúc build, hai lần liên
    // tiếp trong cùng một tick — mô phỏng đúng race condition thực tế: hai
    // lần bấm đến trước khi khung hình kịp vẽ lại nút ở trạng thái bị khoá.
    // Dùng tester.tap() hai lần với await ở giữa sẽ không tái hiện được vì
    // await đã để cho lần lưu đầu tiên kịp hoàn tất và mở khoá lại nút.
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Đã nhớ'),
    );
    button.onPressed!();
    button.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Từ 2/5'), findsOneWidget);
  });

  testWidgets('vuốt thẻ sang phải đủ xa thì tính là Đã nhớ', (tester) async {
    await _openFirstLesson(tester);

    await tester.timedDrag(
      find.text('こんにちは'),
      const Offset(320, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Từ 2/5'), findsOneWidget);
    expect(find.text('1 nhớ · 0 cần ôn'), findsOneWidget);
  });

  testWidgets('vuốt sang trái đủ xa thì tính là Chưa nhớ', (tester) async {
    await _openFirstLesson(tester);

    await tester.timedDrag(
      find.text('こんにちは'),
      const Offset(-320, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Từ 2/5'), findsOneWidget);
    expect(find.text('0 nhớ · 1 cần ôn'), findsOneWidget);
  });

  testWidgets('vuốt ngắn thì thẻ quay về chỗ cũ, không chấm điểm', (
    tester,
  ) async {
    await _openFirstLesson(tester);

    await tester.timedDrag(
      find.text('こんにちは'),
      const Offset(50, 0),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();

    expect(find.text('Từ 1/5'), findsOneWidget);
    expect(find.text('0 nhớ · 0 cần ôn'), findsOneWidget);
  });
}
