import 'dart:convert';
import 'dart:typed_data';

import 'package:chibakanji/screens/my_vocabulary/import_words_screen.dart';
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

    // Tạo chủ đề bằng bảng nhỏ, không phải mở form.
    await _tap(tester, find.text('Tạo chủ đề mới'));
    await tester.enterText(find.byType(TextField).last, 'Công việc');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Tạo chủ đề'));
    expect(find.text('Công việc'), findsOneWidget);
    expect(find.text('0 từ'), findsOneWidget);

    await _tap(tester, find.text('Từ mới'));
    await _enter(tester, 'Chữ Hán (không bắt buộc)', '工場');
    await _enter(tester, 'Cách đọc kana', 'こうじょう');
    await _enter(tester, 'Nghĩa tiếng Việt', 'Nhà máy');
    await _tap(tester, find.text('Không thêm vào chủ đề nào'));
    await _tap(tester, find.text('Công việc (0 từ)').last);
    await _tap(tester, find.text('Thêm vào kho'));
    expect(find.text('Đã thêm "こうじょう".'), findsOneWidget);
    await _waitSnackBar(tester);
    expect(find.text('1 từ'), findsOneWidget);

    // Bấm "Học" ngay trên thẻ chủ đề là vào flashcard.
    await _tap(tester, find.text('Học'));
    expect(find.text('工場'), findsOneWidget);
    expect(find.text('Từ 1/1'), findsOneWidget);
  });

  testWidgets('US22: mở chủ đề thì thấy các từ trong đó', (tester) async {
    await _openStore(tester);
    await _tap(tester, find.text('Tạo chủ đề mới'));
    await tester.enterText(find.byType(TextField).last, 'Chào hỏi');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Tạo chủ đề'));

    await _tap(tester, find.text('Chào hỏi'));

    expect(find.text('0 từ'), findsOneWidget);
    expect(find.textContaining('Chủ đề chưa có từ nào'), findsOneWidget);
  });

  testWidgets('US22: tên chủ đề trống thì báo lỗi ngay trong bảng', (
    tester,
  ) async {
    await _openStore(tester);
    await _tap(tester, find.text('Tạo chủ đề mới'));

    await _tap(tester, find.widgetWithText(ElevatedButton, 'Tạo chủ đề'));

    expect(find.text('Hãy nhập tên chủ đề.'), findsOneWidget);
  });

  testWidgets('US22: form báo lỗi ngay khi thiếu cách đọc và nghĩa', (
    tester,
  ) async {
    await _openStore(tester);
    await _tap(tester, find.text('Từ mới'));

    await _tap(tester, find.text('Thêm vào kho'));

    expect(find.text('Hãy nhập cách đọc.'), findsOneWidget);
    expect(find.text('Hãy nhập nghĩa.'), findsOneWidget);
  });

  testWidgets('US23: import tạo luôn chủ đề mới đặt theo tên file', (
    tester,
  ) async {
    await _importFile(
      tester,
      'tu-vung-cong-viec.txt',
      '工場 | こうじょう | koujou | Nhà máy\n'
          '安全 | あんぜん | anzen | An toàn\n'
          'dòng lỗi',
    );

    expect(find.text('XEM TRƯỚC · 2/3 DÒNG HỢP LỆ'), findsOneWidget);
    expect(find.text('Cong viec'), findsOneWidget);
    await _tap(tester, find.text('Import 2 từ'));
    expect(find.text('Đã thêm 2 từ.'), findsOneWidget);

    // Import xong vào học ngay bằng flashcard, tiêu đề là tên chủ đề mới.
    expect(find.text('Cong viec'), findsOneWidget);
    expect(find.text('Từ 1/2'), findsOneWidget);
    expect(find.text('工場'), findsOneWidget);
  });

  testWidgets('US23: không chọn chủ đề vẫn học ngay các từ vừa import', (
    tester,
  ) async {
    await _importFile(
      tester,
      'tu-vung.txt',
      '工場 | こうじょう | koujou | Nhà máy',
    );

    await _tap(tester, find.text('Chủ đề có sẵn'));
    await _tap(tester, find.text('Import 1 từ'));

    expect(find.text('Từ vừa import'), findsOneWidget);
    expect(find.text('Từ 1/1'), findsOneWidget);
  });

  testWidgets('US22: chủ đề tự tạo hiện ở tab Học mới, mục "Của tôi"', (
    tester,
  ) async {
    await _openStore(tester);
    await _tap(tester, find.text('Tạo chủ đề mới'));
    await tester.enterText(find.byType(TextField).last, 'Công việc');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Tạo chủ đề'));
    await _tap(tester, find.byTooltip('Back'));
    await _tap(
      tester,
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Học mới'),
      ),
    );

    await _tap(tester, find.text('Của tôi'));

    expect(find.text('1 chủ đề'), findsOneWidget);
    expect(find.text('Công việc'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
  });

  testWidgets('US23: chọn file CSV thì hiện tên file và xem trước', (
    tester,
  ) async {
    await _importFile(
      tester,
      'tu-vung.csv',
      'Kanji,Kana,Romaji,Nghĩa\n'
          '工場,こうじょう,koujou,"Nhà máy, xưởng"\n'
          ',マスク,masuku,Khẩu trang\n',
    );

    expect(find.text('tu-vung.csv'), findsOneWidget);
    expect(find.text('2 dòng'), findsOneWidget);
    expect(find.text('XEM TRƯỚC · 2/2 DÒNG HỢP LỆ'), findsOneWidget);
    expect(find.text('工場 · Nhà máy, xưởng'), findsOneWidget);
    expect(find.text('マスク · Khẩu trang'), findsOneWidget);
    await _tap(tester, find.text('Import 2 từ'));
    expect(find.text('Từ 1/2'), findsOneWidget);
  });

  testWidgets('US23: file sai định dạng thì báo lỗi, không đổi gì', (
    tester,
  ) async {
    await _importFile(tester, 'tu-vung.xlsx', 'không phải excel');

    expect(find.textContaining('File Excel bị hỏng'), findsOneWidget);
    expect(find.text('Chọn file từ vựng'), findsOneWidget);
    expect(find.text('Chưa có dòng hợp lệ'), findsOneWidget);
  });
}

/// Mở màn Import với một file giả [name] có nội dung [content], rồi bấm vùng
/// chọn file (thay cho hộp thoại chọn file thật).
Future<void> _importFile(
  WidgetTester tester,
  String name,
  String content,
) async {
  await pumpTestApp(tester);
  tester.state<NavigatorState>(find.byType(Navigator).first).push(
        MaterialPageRoute(
          builder: (_) => ImportWordsScreen(
            pickFile: () async => (
              name: name,
              bytes: Uint8List.fromList(utf8.encode(content)),
            ),
          ),
        ),
      );
  await tester.pumpAndSettle();
  await _tap(tester, find.text('Chọn file từ vựng'));
}

/// Chờ SnackBar thông báo tự tắt để nó không che nút ở cuối màn hình.
Future<void> _waitSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
