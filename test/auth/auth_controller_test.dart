import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/auth/auth_controller.dart';
import 'package:chibakanji/auth/auth_service.dart';
import 'package:chibakanji/auth/auth_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';

void main() {
  const existingUser = AppAuthUser(uid: 'existing-uid', isAnonymous: true);

  test('US02: đã có currentUser: không đăng nhập lại và giữ nguyên UID',
      () async {
    final service = FakeAuthService(currentUser: existingUser);
    final controller = AuthController(service);

    await controller.initialize();

    expect(service.signInCallCount, 0);
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.uid, 'existing-uid');
  });

  test('US02: chưa có currentUser: đăng nhập ẩn danh đúng một lần', () async {
    final service = FakeAuthService();
    final controller = AuthController(service);

    await controller.initialize();

    expect(service.signInCallCount, 1);
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.isAnonymous, isTrue);
  });

  test('initialize gọi đồng thời hai lần chỉ tạo một tài khoản', () async {
    final service = FakeAuthService();
    final controller = AuthController(service);

    final first = controller.initialize();
    final second = controller.initialize();
    expect(controller.isInitializing, isTrue);
    await Future.wait([first, second]);

    expect(service.signInCallCount, 1);
    expect(controller.isInitializing, isFalse);
  });

  test('đăng nhập lỗi: failure, không có user, thông báo thân thiện', () async {
    final service = FakeAuthService(shouldFailSignIn: true);
    final controller = AuthController(service);

    await controller.initialize();

    expect(controller.status, AuthStatus.failure);
    expect(controller.user, isNull);
    expect(
      controller.errorMessage,
      'Không thể kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
    );
  });

  test('mã lỗi Firebase được ánh xạ sang thông báo tương ứng', () async {
    const expected = {
      'operation-not-allowed':
          'Đăng nhập ẩn danh chưa được bật trong Firebase.',
      'too-many-requests': 'Có quá nhiều yêu cầu. Vui lòng thử lại sau.',
      'user-disabled': 'Tài khoản đã bị vô hiệu hóa.',
      'ma-loi-la': 'Không thể khởi tạo tài khoản. Vui lòng thử lại.',
    };

    for (final entry in expected.entries) {
      final service = FakeAuthService(
        shouldFailSignIn: true,
        failureException: AuthException(entry.key),
      );
      final controller = AuthController(service);

      await controller.initialize();

      expect(controller.errorMessage, entry.value, reason: entry.key);
    }
  });

  test('exception không phải AuthException cũng không lộ chi tiết kỹ thuật',
      () async {
    final service = FakeAuthService(
      shouldFailSignIn: true,
      failureException: StateError('token=abc123'),
    );
    final controller = AuthController(service);

    await controller.initialize();

    expect(controller.status, AuthStatus.failure);
    expect(controller.errorMessage, isNot(contains('abc123')));
  });

  test('retry sau lỗi: đăng nhập lại thành công và xóa lỗi cũ', () async {
    final service = FakeAuthService(shouldFailSignIn: true);
    final controller = AuthController(service);
    await controller.initialize();
    expect(controller.status, AuthStatus.failure);

    service.shouldFailSignIn = false;
    await controller.retry();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.errorMessage, isNull);
    expect(service.signInCallCount, 2);
  });

  test('lỗi rồi stream phát null không ghi đè trạng thái failure', () async {
    final service = FakeAuthService(shouldFailSignIn: true);
    final controller = AuthController(service);
    await controller.initialize();

    service.emitUser(null);
    await pumpEventQueue();

    expect(controller.status, AuthStatus.failure);
    expect(service.signInCallCount, 1, reason: 'không tự đăng nhập lại');
  });

  test('stream phát user mới thì controller cập nhật user', () async {
    final service = FakeAuthService(currentUser: existingUser);
    final controller = AuthController(service);
    await controller.initialize();

    service.emitUser(const AppAuthUser(uid: 'other-uid', isAnonymous: false));
    await pumpEventQueue();

    expect(controller.uid, 'other-uid');
    expect(controller.isAnonymous, isFalse);
    expect(controller.status, AuthStatus.authenticated);
  });

  test('stream phát null sau khi đăng nhập thì thành unauthenticated',
      () async {
    final service = FakeAuthService(currentUser: existingUser);
    final controller = AuthController(service);
    await controller.initialize();

    service.emitUser(null);
    await pumpEventQueue();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
    expect(service.signInCallCount, 0, reason: 'không tự đăng nhập lại');
  });

  test('US05: signOut gọi service, chuyển unauthenticated, retry tạo khách mới',
      () async {
    final service = FakeAuthService(currentUser: existingUser);
    final controller = AuthController(service);
    await controller.initialize();

    await controller.signOut();
    await pumpEventQueue();

    expect(service.signOutCallCount, 1);
    expect(controller.status, AuthStatus.unauthenticated);

    await controller.retry();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.uid, 'anonymous-1');
  });

  test('dispose hủy subscription và không notify sau dispose', () async {
    final service = FakeAuthService();
    final controller = AuthController(service);

    final pending = controller.initialize();
    expect(service.hasListeners, isTrue);
    controller.dispose();
    expect(service.hasListeners, isFalse);

    // initialize() vẫn đang chờ đăng nhập khi controller đã bị dispose;
    // hoàn tất không được ném lỗi "used after being disposed".
    await pending;
  });

  group('US03: đăng ký bằng email', () {
    test('đang là khách thì gắn email vào chính tài khoản đó, giữ nguyên uid',
        () async {
      final service = FakeAuthService(currentUser: existingUser);
      final controller = AuthController(service);
      await controller.initialize();

      final error = await controller.registerWithEmail(
        email: 'duy@gmail.com',
        password: '123456',
      );

      expect(error, isNull);
      expect(controller.uid, 'existing-uid');
      expect(controller.isAnonymous, isFalse);
      expect(controller.user!.email, 'duy@gmail.com');
      expect(controller.status, AuthStatus.authenticated);
    });

    test('chưa có tài khoản nào thì tạo tài khoản mới', () async {
      final service = FakeAuthService();
      final controller = AuthController(service);

      final error = await controller.registerWithEmail(
        email: 'lan@gmail.com',
        password: '123456',
      );

      expect(error, isNull);
      expect(controller.status, AuthStatus.authenticated);
      expect(controller.isAnonymous, isFalse);
    });

    test('email đã được dùng thì báo lỗi và không đổi tài khoản hiện tại',
        () async {
      final service = FakeAuthService(currentUser: existingUser)
        ..addAccount('duy@gmail.com', '123456');
      final controller = AuthController(service);
      await controller.initialize();

      final error = await controller.registerWithEmail(
        email: 'DUY@gmail.com',
        password: 'abcdef',
      );

      expect(error, 'Email này đã được dùng cho một tài khoản khác.');
      expect(controller.uid, 'existing-uid');
      expect(controller.isAnonymous, isTrue);
    });

    test('mật khẩu yếu thì báo lỗi tiếng Việt', () async {
      final controller = AuthController(FakeAuthService());

      final error = await controller.registerWithEmail(
        email: 'lan@gmail.com',
        password: '123',
      );

      expect(error, 'Mật khẩu quá yếu, cần ít nhất 6 ký tự.');
    });
  });

  group('US04: đăng nhập bằng email', () {
    test('đúng email và mật khẩu thì chuyển sang tài khoản đó', () async {
      final service = FakeAuthService(currentUser: existingUser)
        ..addAccount('duy@gmail.com', '123456', uid: 'duy-uid');
      final controller = AuthController(service);
      await controller.initialize();

      final error = await controller.signInWithEmail(
        email: ' duy@gmail.com ',
        password: '123456',
      );

      expect(error, isNull);
      expect(controller.uid, 'duy-uid');
      expect(controller.isAnonymous, isFalse);
    });

    test('sai mật khẩu hoặc email chưa đăng ký có cùng một thông báo',
        () async {
      final service = FakeAuthService(currentUser: existingUser)
        ..addAccount('duy@gmail.com', '123456');
      final controller = AuthController(service);
      await controller.initialize();

      final wrongPassword = await controller.signInWithEmail(
        email: 'duy@gmail.com',
        password: 'sai-mat-khau',
      );
      final unknownEmail = await controller.signInWithEmail(
        email: 'ai-do@gmail.com',
        password: '123456',
      );

      expect(wrongPassword, 'Email hoặc mật khẩu không đúng.');
      expect(unknownEmail, wrongPassword);
      expect(controller.uid, 'existing-uid');
    });

    test('lỗi của form không làm cả app chuyển sang trạng thái lỗi', () async {
      final service = FakeAuthService(currentUser: existingUser);
      final controller = AuthController(service);
      await controller.initialize();

      await controller.signInWithEmail(
        email: 'ai-do@gmail.com',
        password: '123456',
      );

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.errorMessage, isNull);
    });

    test('mất mạng và lỗi lạ đều có thông báo thân thiện, không lộ chi tiết',
        () async {
      final service = FakeAuthService()
        ..emailFailure = const AuthException('network-request-failed');
      final controller = AuthController(service);

      expect(
        await controller.signInWithEmail(email: 'a@b.co', password: '123456'),
        'Không thể kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
      );

      service.emailFailure = StateError('token=abc123');
      final unknown =
          await controller.signInWithEmail(email: 'a@b.co', password: '123456');
      expect(unknown, 'Đã có lỗi xảy ra. Vui lòng thử lại.');
      expect(unknown, isNot(contains('abc123')));
    });

    test('ánh xạ các mã lỗi Firebase khác của email', () async {
      const expected = {
        'credential-already-in-use':
            'Email này đã được dùng cho một tài khoản khác.',
        'invalid-email': 'Email không đúng định dạng.',
        'wrong-password': 'Email hoặc mật khẩu không đúng.',
        'user-not-found': 'Email hoặc mật khẩu không đúng.',
        'user-disabled': 'Tài khoản đã bị vô hiệu hóa.',
        'too-many-requests': 'Có quá nhiều yêu cầu. Vui lòng thử lại sau.',
        'operation-not-allowed':
            'Phương thức đăng nhập này chưa được bật trong Firebase.',
      };

      for (final entry in expected.entries) {
        final service = FakeAuthService()
          ..emailFailure = AuthException(entry.key);
        final controller = AuthController(service);

        final error = await controller.signInWithEmail(
          email: 'a@b.co',
          password: '123456',
        );

        expect(error, entry.value, reason: entry.key);
      }
    });
  });

  group('US04: quên mật khẩu', () {
    test('gửi email đặt lại thành công', () async {
      final service = FakeAuthService();
      final controller = AuthController(service);

      final error = await controller.sendPasswordResetEmail(' duy@gmail.com');

      expect(error, isNull);
      expect(service.lastPasswordResetEmail, 'duy@gmail.com');
    });

    test('gửi lỗi thì trả về thông báo', () async {
      final service = FakeAuthService()
        ..emailFailure = const AuthException('network-request-failed');
      final controller = AuthController(service);

      expect(
        await controller.sendPasswordResetEmail('duy@gmail.com'),
        isNotNull,
      );
    });
  });

  group('US04: đăng nhập bằng Google', () {
    test('đang là khách thì gắn Google vào tài khoản đó, giữ nguyên uid',
        () async {
      final service = FakeAuthService(currentUser: existingUser);
      final controller = AuthController(service);
      await controller.initialize();

      final error = await controller.signInWithGoogle();

      expect(error, isNull);
      expect(controller.uid, 'existing-uid');
      expect(controller.isAnonymous, isFalse);
      expect(controller.user!.displayName, 'Phạm Duy');
    });

    test('tài khoản Google đã dùng trước đó thì đăng nhập lại đúng uid cũ',
        () async {
      final service = FakeAuthService();
      final controller = AuthController(service);
      await controller.signInWithGoogle();
      final firstUid = controller.uid;
      await controller.signOut();

      service.emitUser(
        const AppAuthUser(uid: 'guest-moi', isAnonymous: true),
      );
      await controller.signInWithGoogle();

      expect(controller.uid, firstUid);
    });

    test('đóng cửa sổ Google thì báo đã hủy, vẫn giữ tài khoản khách',
        () async {
      final service = FakeAuthService(currentUser: existingUser)
        ..googleFailure = const AuthException('popup-closed-by-user');
      final controller = AuthController(service);
      await controller.initialize();

      final error = await controller.signInWithGoogle();

      expect(error, 'Bạn đã hủy đăng nhập Google.');
      expect(controller.uid, 'existing-uid');
      expect(controller.status, AuthStatus.authenticated);
    });

    test('ánh xạ các mã lỗi riêng của Google', () async {
      const expected = {
        'cancelled-popup-request': 'Bạn đã hủy đăng nhập Google.',
        'web-context-canceled': 'Bạn đã hủy đăng nhập Google.',
        'popup-blocked': 'Trình duyệt đã chặn cửa sổ đăng nhập. '
            'Hãy cho phép cửa sổ bật lên rồi thử lại.',
        'account-exists-with-different-credential':
            'Email này đã được đăng ký bằng mật khẩu. '
                'Hãy đăng nhập bằng email và mật khẩu.',
        'network-request-failed':
            'Không thể kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
      };

      for (final entry in expected.entries) {
        final service = FakeAuthService()
          ..googleFailure = AuthException(entry.key);
        final controller = AuthController(service);

        expect(await controller.signInWithGoogle(), entry.value,
            reason: entry.key);
      }
    });
  });
}
