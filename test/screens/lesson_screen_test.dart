import 'package:chibakanji/app.dart';
import 'package:chibakanji/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'LessonScreen lấy tên chủ đề làm tiêu đề, thẻ hiện thêm số từ và cấp độ',
    (tester) async {
      await tester.pumpWidget(const AppProviders(child: ChibaKanjiApp()));

      await tester.tap(find.text('Học mới'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chào hỏi và giao tiếp'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Chào hỏi và giao tiếp'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Các câu chào hỏi thông dụng nhất trong ngày.\n5 từ · N5'),
        findsOneWidget,
      );

      // getSubtitle() có xuống dòng nên GenericListScreen dùng thẻ ba dòng.
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Chào hỏi cơ bản'),
      );
      expect(tile.isThreeLine, isTrue);
    },
  );
}
