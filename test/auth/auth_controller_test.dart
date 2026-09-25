import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/auth/auth_controller.dart';
import 'package:chibakanji/auth/auth_service.dart';
import 'package:chibakanji/auth/auth_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';

void main() {
  const existingUser = AppAuthUser(uid: 'existing-uid', isAnonymous: true);

  test('đã có currentUser: không đăng nhập lại và giữ nguyên UID', () async {
    final service = FakeAuthService(currentUser: existingUser);
    final controller = AuthController(service);

    await controller.initialize();

    expect(service.signInCallCount, 0);
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.uid, 'existing-uid');
  });

  test('chưa có currentUser: đăng nhập ẩn danh đúng một lần', () async {
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
}
