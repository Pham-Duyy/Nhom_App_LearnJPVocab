import 'package:chibakanji/services/welcome_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _openRegisterForm(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(buildTestApp(showWelcome: true));
  await _pumpFrames(tester);
  await passSplash(tester);
}

Future<void> _fillAndSubmit(
  WidgetTester tester,
  List<String> values,
) async {
  for (var i = 0; i < values.length; i++) {
    final field = find.byType(TextFormField).at(i);
    await tester.ensureVisible(field);
    await tester.enterText(field, values[i]);
  }
  final submit = find.widgetWithText(ElevatedButton, 'Tạo tài khoản');
  await tester.ensureVisible(submit);
  await tester.tap(submit);
}

void main() {
  testWidgets(
      'US03: màn chào → đăng ký → vào trang chủ với tên mới, '
      'giữ nguyên tiến độ của tài khoản khách', (tester) async {
    await _openRegisterForm(tester);
    await _fillAndSubmit(
      tester,
      ['Lan', 'lan@gmail.com', '123456', '123456'],
    );
    await tester.pumpAndSettle();

    expect(find.text('Chào Lan!'), findsOneWidget);
    expect(find.text('3 từ đến hạn · Khoảng 2 phút'), findsOneWidget);
    // Lần sau mở app sẽ vào thẳng trang chủ.
    expect(await WelcomeStore.hasSeen(), isTrue);
  });

  testWidgets('US03: mật khẩu xác nhận không khớp thì ở lại màn đăng ký', (
    tester,
  ) async {
    await _openRegisterForm(tester);
    await _fillAndSubmit(
      tester,
      ['Lan', 'lan@gmail.com', '123456', '654321'],
    );
    await _pumpFrames(tester);

    expect(await WelcomeStore.hasSeen(), isFalse);
    expect(find.text('Mật khẩu xác nhận chưa khớp.'), findsOneWidget);
    expect(find.text('Chào Lan!'), findsNothing);
  });
}
