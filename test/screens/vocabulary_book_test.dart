import 'package:chibakanji/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Mở tab Sổ từ; dữ liệu mẫu có sẵn 9 từ đã học.
Future<void> _openBook(WidgetTester tester) async {
  await pumpTestApp(tester);
  await tester.tap(find.text('Sổ từ'));
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String keyword) async {
  await tester.enterText(find.byType(TextField), keyword);
  await tester.pumpAndSettle();
}

/// Chữ [text] trong danh sách kết quả (không tính ô tìm kiếm đang chứa nó).
Finder _inResults(String text) => find.descendant(
      of: find.byType(ListView).last,
      matching: find.text(text),
    );

/// Mỗi từ trong danh sách có đúng một nút yêu thích.
int _visibleWordCount(WidgetTester tester) =>
    find.byType(FavoriteButton).evaluate().length;

void main() {
  group('US13: tìm từ đã học', () {
    testWidgets('tìm theo romaji chỉ còn đúng từ đó', (tester) async {
      await _openBook(tester);
      expect(_visibleWordCount(tester), greaterThan(1));

      await _search(tester, 'chichi');

      expect(_visibleWordCount(tester), 1);
      expect(_inResults('ちち · chichi'), findsOneWidget);
    });

    testWidgets('tìm theo nghĩa tiếng Việt, không phân biệt hoa thường', (
      tester,
    ) async {
      await _openBook(tester);

      await _search(tester, 'GIA ĐÌNH');

      expect(_visibleWordCount(tester), 1);
    });

    testWidgets('không có từ nào khớp thì báo không tìm thấy', (tester) async {
      await _openBook(tester);

      await _search(tester, 'không-có-từ-này');

      expect(_visibleWordCount(tester), 0);
      expect(find.text('Không tìm thấy từ phù hợp'), findsOneWidget);
    });
  });

  testWidgets('US14: đánh dấu yêu thích rồi lọc Yêu thích chỉ còn từ đó', (
    tester,
  ) async {
    await _openBook(tester);

    await tester.tap(find.text('Yêu thích'));
    await tester.pumpAndSettle();
    expect(_visibleWordCount(tester), 0);

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FavoriteButton>(find.byType(FavoriteButton).first)
          .isFavorite,
      isTrue,
    );

    await tester.tap(find.text('Yêu thích'));
    await tester.pumpAndSettle();
    expect(_visibleWordCount(tester), 1);
  });

  testWidgets('US15: chạm vào một từ thì xem được cách đọc, nghĩa và ví dụ', (
    tester,
  ) async {
    await _openBook(tester);
    await _search(tester, 'chichi');

    await tester.tap(_inResults('ちち · chichi'));
    await tester.pumpAndSettle();

    expect(find.text('ちち · chichi'), findsOneWidget);
    expect(find.text('Bố (của mình)'), findsOneWidget);
    expect(find.text('VÍ DỤ'), findsOneWidget);
    // Nút nằm cuối trang: cuộn tới cho ListView dựng nó rồi mới kiểm tra.
    await tester.scrollUntilVisible(find.text('Ôn từ này'), 200);
    expect(find.widgetWithText(ElevatedButton, 'Ôn từ này'), findsOneWidget);
  });
}
