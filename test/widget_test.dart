import 'package:flutter_test/flutter_test.dart';
import 'package:chibakanji/app.dart';

void main() {
  testWidgets('hiển thị giao diện chính và đổi tab', (tester) async {
    await tester.pumpWidget(const ChibaKanjiApp());

    expect(find.text('Chào Duy!'), findsOneWidget);
    expect(find.text('9 từ vựng'), findsOneWidget);
    expect(find.text('Đến giờ ôn rồi!'), findsOneWidget);

    await tester.tap(find.text('Học mới'));
    await tester.pump();

    expect(
      find.text('Màn hình Học mới sẽ được hoàn thiện tiếp.'),
      findsOneWidget,
    );
  });
}
