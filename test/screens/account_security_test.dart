import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/auth/auth_service.dart';
import 'package:chibakanji/widgets/chibi_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_user_data_cleaner.dart';
import '../helpers/test_app.dart';

const _email = 'duy@gmail.com';

/// Đăng nhập sẵn bằng email/mật khẩu, mở Cá nhân > Tài khoản.
Future<FakeAuthService> _openAccount(
  WidgetTester tester, {
  FakeUserDataCleaner? cleaner,
  bool guest = false,
}) async {
  final auth = FakeAuthService(
    currentUser: guest
        ? const AppAuthUser(uid: 'guest', isAnonymous: true)
        : const AppAuthUser(
            uid: 'email-1',
            isAnonymous: false,
            email: _email,
            providers: [AppAuthUser.passwordProvider],
          ),
  )..addAccount(_email, 'matkhau1', uid: 'email-1');
  await tester.pumpWidget(
    buildTestApp(authService: auth, userDataCleaner: cleaner),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Cá nhân'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Tài khoản'), 200);
  await tester.ensureVisible(find.text('Tài khoản'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tài khoản'));
  await tester.pumpAndSettle();
  return auth;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  group('Đổi mật khẩu', () {
    testWidgets('nhập đúng mật khẩu hiện tại thì đổi được', (tester) async {
      final auth = await _openAccount(tester);

      await _tap(tester, find.text('Đổi mật khẩu'));
      await tester.enterText(_field('Mật khẩu hiện tại'), 'matkhau1');
      await tester.enterText(_field('Mật khẩu mới'), 'matkhau2');
      await tester.enterText(_field('Nhập lại mật khẩu mới'), 'matkhau2');
      await _tap(tester, find.widgetWithText(TextButton, 'Đổi mật khẩu'));

      expect(find.text('Đã đổi mật khẩu.'), findsOneWidget);
      // Mật khẩu mới xác thực được, mật khẩu cũ thì không.
      await auth.reauthenticate(password: 'matkhau2');
      await expectLater(
        auth.reauthenticate(password: 'matkhau1'),
        throwsA(isA<AuthException>()),
      );
    });

    testWidgets('sai mật khẩu hiện tại thì báo lỗi, không đổi', (tester) async {
      await _openAccount(tester);

      await _tap(tester, find.text('Đổi mật khẩu'));
      await tester.enterText(_field('Mật khẩu hiện tại'), 'sai-roi');
      await tester.enterText(_field('Mật khẩu mới'), 'matkhau2');
      await tester.enterText(_field('Nhập lại mật khẩu mới'), 'matkhau2');
      await _tap(tester, find.widgetWithText(TextButton, 'Đổi mật khẩu'));

      expect(find.text('Mật khẩu hiện tại không đúng.'), findsOneWidget);
    });

    testWidgets('mật khẩu nhập lại không khớp thì form báo lỗi', (
      tester,
    ) async {
      await _openAccount(tester);

      await _tap(tester, find.text('Đổi mật khẩu'));
      await tester.enterText(_field('Mật khẩu hiện tại'), 'matkhau1');
      await tester.enterText(_field('Mật khẩu mới'), 'matkhau2');
      await tester.enterText(_field('Nhập lại mật khẩu mới'), 'khac');
      await _tap(tester, find.widgetWithText(TextButton, 'Đổi mật khẩu'));

      expect(find.text('Mật khẩu xác nhận chưa khớp.'), findsOneWidget);
    });
  });

  group('Xóa tài khoản', () {
    testWidgets(
        'xác nhận bằng mật khẩu thì xóa dữ liệu, xóa tài khoản rồi '
        'về màn khởi động', (tester) async {
      final cleaner = FakeUserDataCleaner();
      final auth = await _openAccount(tester, cleaner: cleaner);

      await _tap(tester, find.text('Xóa tài khoản và dữ liệu'));
      await tester.enterText(find.byType(TextField).last, 'matkhau1');
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(cleaner.deleteCount, 1);
      expect(auth.deleteAccountCallCount, 1);
      expect(find.byType(ChibiMascot), findsOneWidget);
    });

    testWidgets('sai mật khẩu thì dừng lại, dữ liệu chưa bị xóa', (
      tester,
    ) async {
      final cleaner = FakeUserDataCleaner();
      final auth = await _openAccount(tester, cleaner: cleaner);

      await _tap(tester, find.text('Xóa tài khoản và dữ liệu'));
      await tester.enterText(find.byType(TextField).last, 'sai-roi');
      await _tap(tester, find.text('Xóa vĩnh viễn'));

      expect(find.text('Mật khẩu không đúng.'), findsOneWidget);
      expect(cleaner.deleteCount, 0);
      expect(auth.deleteAccountCallCount, 0);
    });

    testWidgets('lỗi khi xóa dữ liệu thì giữ tài khoản và báo lỗi', (
      tester,
    ) async {
      final cleaner = FakeUserDataCleaner()..failure = Exception('mất mạng');
      final auth = await _openAccount(tester, cleaner: cleaner);

      await _tap(tester, find.text('Xóa tài khoản và dữ liệu'));
      await tester.enterText(find.byType(TextField).last, 'matkhau1');
      await _tap(tester, find.text('Xóa vĩnh viễn'));

      expect(find.textContaining('Không thể xóa dữ liệu học'), findsOneWidget);
      expect(auth.deleteAccountCallCount, 0);
    });

    testWidgets('tài khoản khách xóa được mà không cần mật khẩu', (
      tester,
    ) async {
      final cleaner = FakeUserDataCleaner();
      final auth = await _openAccount(tester, cleaner: cleaner, guest: true);

      await _tap(tester, find.text('Xóa tài khoản và dữ liệu'));
      expect(find.text('Mật khẩu'), findsNothing);
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(cleaner.deleteCount, 1);
      expect(auth.deleteAccountCallCount, 1);
    });
  });
}
