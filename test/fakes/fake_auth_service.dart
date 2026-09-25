import 'dart:async';

import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/auth/auth_service.dart';

/// AuthService giả cho test: không import Firebase, không cần mạng.
class FakeAuthService implements AuthService {
  FakeAuthService({
    AppAuthUser? currentUser,
    this.shouldFailSignIn = false,
    this.failureException = const AuthException('network-request-failed'),
  }) : _currentUser = currentUser;

  AppAuthUser? _currentUser;
  final _controller = StreamController<AppAuthUser?>.broadcast();

  bool shouldFailSignIn;
  Object failureException;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  /// True khi còn subscriber đang nghe authStateChanges().
  bool get hasListeners => _controller.hasListener;

  @override
  AppAuthUser? get currentUser => _currentUser;

  @override
  Stream<AppAuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<AppAuthUser> signInAnonymously() async {
    signInCallCount++;
    // Tạo khoảng trễ bất đồng bộ thật, để test bắt được lời gọi đồng thời.
    await Future<void>.delayed(Duration.zero);
    if (shouldFailSignIn) throw failureException;

    final user = AppAuthUser(
      uid: 'anonymous-$signInCallCount',
      isAnonymous: true,
    );
    emitUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    emitUser(null);
  }

  /// Giả lập Firebase phát một thay đổi trạng thái đăng nhập.
  void emitUser(AppAuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> close() => _controller.close();
}
