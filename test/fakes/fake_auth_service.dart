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

  /// Tài khoản email đã đăng ký: email (chữ thường) -> (mật khẩu, uid).
  final _accounts = <String, ({String password, String uid})>{};

  /// Nếu khác null, mọi thao tác email ném lỗi này (giả lập mất mạng...).
  Object? emailFailure;
  String? lastPasswordResetEmail;

  /// Tạo sẵn một tài khoản email, như thể đã đăng ký từ trước.
  void addAccount(String email, String password, {String? uid}) {
    _accounts[_normalize(email)] = (
      password: password,
      uid: uid ?? 'email-${_accounts.length + 1}',
    );
  }

  @override
  Future<AppAuthUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(Duration.zero);
    final failure = emailFailure;
    if (failure != null) throw failure;

    final key = _normalize(email);
    if (_accounts.containsKey(key)) {
      throw const AuthException('email-already-in-use');
    }
    if (password.length < 6) throw const AuthException('weak-password');

    final current = _currentUser;
    final isLinking = current != null && current.isAnonymous;
    final uid = isLinking ? current.uid : 'email-${_accounts.length + 1}';
    _accounts[key] = (password: password, uid: uid);

    final user = AppAuthUser(
      uid: uid,
      isAnonymous: false,
      email: key,
      providers: const [AppAuthUser.passwordProvider],
    );
    // Giống Firebase: gắn email vào tài khoản khách không đổi uid nên không
    // phát sự kiện; tạo tài khoản mới thì có.
    if (isLinking) {
      _currentUser = user;
    } else {
      emitUser(user);
    }
    return user;
  }

  @override
  Future<AppAuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(Duration.zero);
    final failure = emailFailure;
    if (failure != null) throw failure;

    final key = _normalize(email);
    final account = _accounts[key];
    if (account == null || account.password != password) {
      throw const AuthException('invalid-credential');
    }
    final user = AppAuthUser(
      uid: account.uid,
      isAnonymous: false,
      email: key,
      providers: const [AppAuthUser.passwordProvider],
    );
    emitUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final failure = emailFailure;
    if (failure != null) throw failure;
    lastPasswordResetEmail = _normalize(email);
  }

  /// Tài khoản Google mà người dùng sẽ chọn ở cửa sổ đăng nhập.
  ({String email, String name}) googleAccount =
      (email: 'duy@gmail.com', name: 'Phạm Duy');

  /// Nếu khác null, đăng nhập Google ném lỗi này (vd. người dùng hủy).
  Object? googleFailure;

  /// uid của tài khoản Google đã từng dùng trong app: email -> uid.
  final _googleUids = <String, String>{};

  @override
  Future<AppAuthUser> signInWithGoogle() async {
    await Future<void>.delayed(Duration.zero);
    final failure = googleFailure;
    if (failure != null) throw failure;

    final email = googleAccount.email;
    final current = _currentUser;
    final existingUid = _googleUids[email];
    final isLinking =
        existingUid == null && current != null && current.isAnonymous;
    final uid = existingUid ??
        (isLinking ? current.uid : 'google-${_googleUids.length + 1}');
    _googleUids[email] = uid;

    final user = AppAuthUser(
      uid: uid,
      isAnonymous: false,
      email: email,
      displayName: googleAccount.name,
      providers: const [AppAuthUser.googleProvider],
    );
    if (isLinking) {
      _currentUser = user;
    } else {
      emitUser(user);
    }
    return user;
  }

  static String _normalize(String email) => email.trim().toLowerCase();

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
