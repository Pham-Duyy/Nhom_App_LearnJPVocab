import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';
import '../helpers/test_app.dart';

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
    'đăng xuất cảnh báo tài khoản khách, gọi signOut và đăng nhập lại được',
    (tester) async {
      final authService = FakeAuthService(
        currentUser: const AppAuthUser(uid: 'guest-1', isAnonymous: true),
      );
      await tester.pumpWidget(buildTestApp(authService: authService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cá nhân'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Đăng xuất'), 200);
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      expect(find.textContaining('tài khoản khách'), findsOneWidget);

      await tester.tap(find.text('Đăng xuất').last);
      await _pumpFrames(tester);

      expect(authService.signOutCallCount, 1);
      expect(find.text('Bắt đầu cùng Chibi →'), findsOneWidget);

      final loginLink = find.textContaining('Đã có tài khoản?');
      await tester.ensureVisible(loginLink);
      await tester.tap(loginLink);
      await _pumpFrames(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'lan_hocnhat');
      await tester.enterText(fields.at(1), '123456');
      final submit = find.widgetWithText(ElevatedButton, 'Đăng nhập');
      await tester.scrollUntilVisible(
        submit,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(authService.signInCallCount, 1);
      expect(find.text('Chào Duy!'), findsOneWidget);
    },
  );
}
