import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Bấm [finder]; ListView chỉ dựng mục gần màn hình nên cuộn tới trước nếu
/// chưa thấy.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

/// Mở tab Sổ từ rồi vào Kho từ của tôi.
Future<void> _openStore(WidgetTester tester) async {
  await pumpTestApp(tester);
  await _tap(
    tester,
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Sổ từ'),
    ),
  );
  await _tap(tester, find.text('Kho từ của tôi'));
}

void main() {
  testWidgets('US22: tạo chủ đề, thêm từ mới vào chủ đề rồi học bằng flashcard',
      (
    tester,
  ) async {
    await _openStore(tester);

    await _tap(tester, find.text('Tạo chủ đề'));
    await _enter(tester, 'Tên chủ đề', 'Công việc');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Tạo chủ đề'));
    expect(find.text('Đã tạo chủ đề.'), findsOneWidget);
    await _waitSnackBar(tester);

    await _tap(tester, find.text('Thêm từ vựng mới'));
    await _enter(tester, 'Chữ Hán (không bắt buộc)', '工場');
    await _enter(tester, 'Cách đọc kana', 'こうじょう');
    await _enter(tester, 'Nghĩa tiếng Việt', 'Nhà máy');
    await _tap(tester, find.text('Không thêm vào chủ đề nào'));
    await _tap(tester, find.text('Công việc (0 từ)').last);
    await _tap(tester, find.text('Thêm vào kho'));
    expect(find.text('Đã thêm "こうじょう".'), findsOneWidget);
    await _waitSnackBar(tester);

    await _tap(tester, find.text('Quản lý chủ đề'));
    await _tap(tester, find.text('Công việc'));
    expect(find.text('1 từ'), findsOneWidget);
    expect(find.text('Nhà máy'), findsOneWidget);

    await _tap(tester, find.widgetWithText(ElevatedButton, 'Học'));
    expect(find.text('工場'), findsOneWidget);
    expect(find.text('Từ 1/1'), findsOneWidget);
  });

  testWidgets('US22: form báo lỗi ngay khi thiếu cách đọc và nghĩa', (
    tester,
  ) async {
    await _openStore(tester);
    await _tap(tester, find.text('Thêm từ vựng mới'));

    await _tap(tester, find.text('Thêm vào kho'));

    expect(find.text('Hãy nhập cách đọc.'), findsOneWidget);
    expect(find.text('Hãy nhập nghĩa.'), findsOneWidget);
  });

  testWidgets('US23: import 2 từ rồi thấy chúng trong "Của tôi"', (
    tester,
  ) async {
    await _openStore(tester);
    await _tap(tester, find.text('Import từ vựng'));

    await tester.enterText(
      find.byType(TextField).first,
      '工場 | こうじょう | koujou | Nhà máy\n'
      '安全 | あんぜん | anzen | An toàn\n'
      'dòng lỗi',
    );
    await tester.pump();
    expect(find.text('XEM TRƯỚC · 2/3 DÒNG HỢP LỆ'), findsOneWidget);
    await _tap(tester, find.text('Import 2 từ'));
    expect(find.text('Đã thêm 2 từ.'), findsOneWidget);
    await _waitSnackBar(tester);

    await _tap(tester, find.text('Xem tất cả từ vựng'));
    await _tap(tester, find.text('Của tôi (2)'));
    expect(find.text('Nhà máy'), findsOneWidget);
    expect(find.text('An toàn'), findsOneWidget);
  });
}

/// Chờ SnackBar thông báo tự tắt để nó không che nút ở cuối màn hình.
Future<void> _waitSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
