import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/auth/auth_service.dart';
import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';
import '../helpers/test_app.dart';

const _guest = AppAuthUser(uid: 'guest-1', isAnonymous: true);

/// Màn chào có animation lặp vô hạn nên không dùng pumpAndSettle được.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _openLoginForm(
  WidgetTester tester,
  FakeAuthService auth, {
  MockUserProfileRepository? profiles,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(buildTestApp(
    showWelcome: true,
    authService: auth,
    userProfileRepository: profiles,
  ));
  await _pumpFrames(tester);

  final loginLink = find.textContaining('Đã có tài khoản?');
  await tester.ensureVisible(loginLink);
  await tester.tap(loginLink);
  await _pumpFrames(tester);
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
}

void main() {
  testWidgets('US04: đăng nhập đúng thì vào trang chủ của tài khoản đó', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest)
      ..addAccount('duy@gmail.com', '123456', uid: 'duy-uid');
    await _openLoginForm(tester, auth);

    await _enter(tester, 'Ví dụ: duy@gmail.com', 'duy@gmail.com');
    await _enter(tester, 'Nhập mật khẩu', '123456');
    await _tapButton(tester, 'Đăng nhập');
    await tester.pumpAndSettle();

    expect(auth.currentUser!.uid, 'duy-uid');
    expect(find.text('Ôn tập'), findsWidgets);
  });

  testWidgets('US04: sai mật khẩu thì hiện lỗi và ở lại màn đăng nhập', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest)
      ..addAccount('duy@gmail.com', '123456');
    await _openLoginForm(tester, auth);

    await _enter(tester, 'Ví dụ: duy@gmail.com', 'duy@gmail.com');
    await _enter(tester, 'Nhập mật khẩu', 'sai-roi');
    await _tapButton(tester, 'Đăng nhập');
    await _pumpFrames(tester);

    expect(find.text('Email hoặc mật khẩu không đúng.'), findsOneWidget);
    expect(auth.currentUser!.uid, 'guest-1');
    // Nút được mở khóa lại để người dùng thử lần nữa.
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Đăng nhập'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('email sai định dạng thì báo lỗi ngay, không gọi Firebase', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest)
      ..emailFailure = const AuthException('không được gọi tới');
    await _openLoginForm(tester, auth);

    await _enter(tester, 'Ví dụ: duy@gmail.com', 'duy@gmail');
    await _enter(tester, 'Nhập mật khẩu', '123456');
    await _tapButton(tester, 'Đăng nhập');
    await _pumpFrames(tester);

    expect(find.text('Email không đúng định dạng.'), findsOneWidget);
    expect(find.text('Đã có lỗi xảy ra. Vui lòng thử lại.'), findsNothing);
  });

  testWidgets('quên mật khẩu khi chưa nhập email thì nhắc nhập email trước', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest);
    await _openLoginForm(tester, auth);

    await tester.tap(find.text('Quên mật khẩu?'));
    await _pumpFrames(tester);

    expect(find.textContaining('nhập đúng email'), findsOneWidget);
    expect(auth.lastPasswordResetEmail, isNull);
  });

  testWidgets('US04: đăng nhập Google thì vào trang chủ với tên Google', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest);
    final profiles = MockUserProfileRepository();
    await _openLoginForm(tester, auth, profiles: profiles);

    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pumpAndSettle();

    expect(auth.currentUser!.uid, 'guest-1');
    expect(find.text('Chào Phạm Duy!'), findsOneWidget);
    expect((await profiles.load())!.displayName, 'Phạm Duy');
  });

  testWidgets('đăng nhập Google không ghi đè tên người học đã tự đặt', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest);
    final profiles = MockUserProfileRepository(
      initialProfile: const UserProfile(displayName: 'Duy'),
    );
    await _openLoginForm(tester, auth, profiles: profiles);

    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pumpAndSettle();

    expect(find.text('Chào Duy!'), findsOneWidget);
  });

  testWidgets('hủy cửa sổ Google thì báo đã hủy và ở lại màn đăng nhập', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest)
      ..googleFailure = const AuthException('popup-closed-by-user');
    await _openLoginForm(tester, auth);

    await tester.tap(find.text('Tiếp tục với Google'));
    await _pumpFrames(tester);

    expect(find.text('Bạn đã hủy đăng nhập Google.'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
  });

  testWidgets('quên mật khẩu với email hợp lệ thì gửi và báo đã gửi', (
    tester,
  ) async {
    final auth = FakeAuthService(currentUser: _guest);
    await _openLoginForm(tester, auth);

    await _enter(tester, 'Ví dụ: duy@gmail.com', 'duy@gmail.com');
    await tester.tap(find.text('Quên mật khẩu?'));
    await _pumpFrames(tester);

    expect(auth.lastPasswordResetEmail, 'duy@gmail.com');
    expect(find.textContaining('Đã gửi hướng dẫn'), findsOneWidget);
  });
}
