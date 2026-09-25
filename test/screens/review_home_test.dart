import 'package:chibakanji/app.dart';
import 'package:chibakanji/providers/app_providers.dart';
import 'package:chibakanji/widgets/memory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trang chủ hiển thị đúng thống kê từ ProgressProvider', (
    tester,
  ) async {
    await tester.pumpWidget(const AppProviders(child: ChibaKanjiApp()));
    await tester.pumpAndSettle();

    expect(find.text('9 từ vựng'), findsOneWidget);
    expect(find.text('3 từ đang chờ bạn · khoảng 2 phút'), findsOneWidget);

    final bars = tester.widgetList<MemoryBar>(find.byType(MemoryBar)).toList();
    expect(bars.map((bar) => bar.count).toList(), [3, 3, 1, 1, 1]);
  });

  testWidgets(
    'nhấn Ôn ngay chỉ mở đúng 3 từ đến hạn, học xong due count về 0',
    (tester) async {
      await tester.pumpWidget(const AppProviders(child: ChibaKanjiApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ôn ngay'));
      await tester.pumpAndSettle();

      // Đúng 3 từ đến hạn được đưa vào phiên, không phải 9 từ đã học hay
      // toàn bộ 30 từ mẫu — được đảm bảo bởi getDueForReview() + getByIds().
      expect(find.text('Từ 1/3'), findsOneWidget);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Đã nhớ'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Kết quả buổi học'), findsOneWidget);
      expect(find.text('Hoàn thành phiên ôn tập!'), findsOneWidget);

      await tester.tap(find.text('Về trang chủ'));
      await tester.pumpAndSettle();

      // markCorrect() đẩy lịch ôn của cả 3 từ ra tương lai, và 6 từ còn lại
      // vốn đã không đến hạn từ đầu, nên due count phải về đúng 0.
      expect(find.text('Bạn đã ôn xong hôm nay!'), findsOneWidget);
      expect(find.text('Quay lại vào ngày mai nhé.'), findsOneWidget);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ôn ngay'),
      );
      expect(button.onPressed, isNull);
    },
  );
}
