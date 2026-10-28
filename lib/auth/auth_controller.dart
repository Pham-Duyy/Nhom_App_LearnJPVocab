import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_auth_user.dart';
import 'auth_service.dart';
import 'auth_status.dart';

/// Quản lý trạng thái xác thực cho UI. Chỉ phụ thuộc [AuthService].
///
/// Chỉ tự động đăng nhập ẩn danh trong [initialize] và [retry]. Việc lắng
/// nghe `authStateChanges()` chỉ cập nhật trạng thái, không bao giờ tự đăng
/// nhập lại — tránh vòng lặp "stream phát null -> đăng nhập -> lỗi -> ...".
class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  AppAuthUser? _user;
  String? _errorMessage;
  Future<void>? _initializeFuture;
  StreamSubscription<AppAuthUser?>? _subscription;
  bool _disposed = false;

  AuthStatus get status => _status;
  AppAuthUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isInitializing => _initializeFuture != null;

  String? get uid => _user?.uid;
  bool get isAnonymous => _user?.isAnonymous ?? false;

  /// Nếu đang chạy thì trả về đúng Future của lần chạy đó, nên hai lời gọi
  /// đồng thời không bao giờ tạo hai tài khoản ẩn danh.
  Future<void> initialize() {
    return _initializeFuture ??= _runInitialize().whenComplete(() {
      _initializeFuture = null;
    });
  }

  Future<void> retry() => initialize();

  /// Trả về thông báo lỗi, hoặc null nếu đăng ký thành công. Lỗi ở đây chỉ
  /// thuộc về form nên không đổi [status] hay [errorMessage] của cả app.
  Future<String?> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _runSignInAction(
      'register',
      () => _authService.registerWithEmail(email: email, password: password),
    );
  }

  /// Trả về thông báo lỗi, hoặc null nếu đăng nhập thành công.
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runSignInAction(
      'signIn',
      () => _authService.signInWithEmail(email: email, password: password),
    );
  }

  /// Trả về thông báo lỗi (kể cả khi người dùng đóng cửa sổ Google), hoặc
  /// null nếu đăng nhập thành công.
  Future<String?> signInWithGoogle() {
    return _runSignInAction('signInWithGoogle', _authService.signInWithGoogle);
  }

  /// Trả về thông báo lỗi, hoặc null nếu đã gửi email đặt lại mật khẩu.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return null;
    } catch (error) {
      _logError('sendPasswordReset', error);
      return _signInErrorMessage(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (error) {
      _logError('signOut', error);
    }
  }

  /// Đổi mật khẩu sau khi xác nhận mật khẩu hiện tại. Trả về thông báo lỗi,
  /// hoặc null nếu đã đổi.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.reauthenticate(password: currentPassword);
      await _authService.updatePassword(newPassword);
      return null;
    } catch (error) {
      _logError('changePassword', error);
      final code = _codeOf(error);
      if (code == 'invalid-credential' || code == 'wrong-password') {
        return 'Mật khẩu hiện tại không đúng.';
      }
      return _signInErrorMessage(error);
    }
  }

  /// Xóa tài khoản: xác thực lại trước (sai mật khẩu thì dừng, chưa mất gì),
  /// rồi [deleteData] xóa dữ liệu học, cuối cùng xóa tài khoản. Trả về thông
  /// báo lỗi, hoặc null nếu đã xóa xong.
  Future<String?> deleteAccount({
    String? password,
    required Future<void> Function() deleteData,
  }) async {
    try {
      await _authService.reauthenticate(password: password);
      await deleteData();
      await _authService.deleteAccount();
      return null;
    } catch (error) {
      _logError('deleteAccount', error);
      if (error is! AuthException) {
        return 'Không thể xóa dữ liệu học. Vui lòng kiểm tra mạng và thử lại.';
      }
      final code = error.code;
      if (code == 'invalid-credential' || code == 'wrong-password') {
        return 'Mật khẩu không đúng.';
      }
      return _signInErrorMessage(error);
    }
  }

  Future<String?> _runSignInAction(
    String name,
    Future<AppAuthUser> Function() action,
  ) async {
    try {
      _user = await action();
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _notify();
      return null;
    } catch (error) {
      _logError(name, error);
      return _signInErrorMessage(error);
    }
  }

  Future<void> _runInitialize() async {
    _listenToAuthChanges();
    _status = AuthStatus.loading;
    _errorMessage = null;
    _notify();

    try {
      final existing = _authService.currentUser;
      _user = existing ?? await _authService.signInAnonymously();
      _status = AuthStatus.authenticated;
    } catch (error) {
      _logError('initialize', error);
      _user = null;
      _status = AuthStatus.failure;
      _errorMessage = _friendlyMessage(error);
    }
    _notify();
  }

  void _listenToAuthChanges() {
    _subscription ??= _authService.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(AppAuthUser? user) {
    if (user != null) {
      _user = user;
      _errorMessage = null;
      _status = AuthStatus.authenticated;
      _notify();
    } else if (_status == AuthStatus.authenticated) {
      // Firebase phát null khi mới bắt đầu nghe: chưa phải đăng xuất.
      _user = null;
      _status = AuthStatus.unauthenticated;
      _notify();
    }
  }

  /// Chỉ log tên thao tác và mã lỗi, không log nguyên văn exception vì thông
  /// điệp của nó có thể chứa dữ liệu nhạy cảm (token, email...).
  void _logError(String action, Object error) {
    debugPrint(
      'Auth $action failed: '
      '${error is AuthException ? error.code : error.runtimeType}',
    );
  }

  static String? _codeOf(Object error) =>
      error is AuthException ? error.code : null;

  /// Thông báo cho các lỗi dùng chung giữa đăng nhập khách và đăng nhập email.
  static String? _commonMessage(String? code) {
    switch (code) {
      case 'network-request-failed':
        return 'Không thể kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';
      case 'too-many-requests':
        return 'Có quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      default:
        return null;
    }
  }

  String _friendlyMessage(Object error) {
    final code = _codeOf(error);
    switch (code) {
      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'Đăng nhập ẩn danh chưa được bật trong Firebase.';
      default:
        return _commonMessage(code) ??
            'Không thể khởi tạo tài khoản. Vui lòng thử lại.';
    }
  }

  static String _signInErrorMessage(Object error) {
    final code = _codeOf(error);
    switch (code) {
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return 'Email này đã được dùng cho một tài khoản khác.';
      case 'invalid-email':
        return 'Email không đúng định dạng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu, cần ít nhất 6 ký tự.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email hoặc mật khẩu không đúng.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được bật trong Firebase.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
      case 'web-context-canceled':
      case 'web-context-cancelled':
        return 'Bạn đã hủy đăng nhập Google.';
      case 'popup-blocked':
        return 'Trình duyệt đã chặn cửa sổ đăng nhập. '
            'Hãy cho phép cửa sổ bật lên rồi thử lại.';
      case 'account-exists-with-different-credential':
        return 'Email này đã được đăng ký bằng mật khẩu. '
            'Hãy đăng nhập bằng email và mật khẩu.';
      case 'unauthorized-domain':
        return 'Trang web này chưa được cấp phép đăng nhập trong Firebase.';
      case 'invalid-cert-hash':
      case 'google-config-error':
        return 'Đăng nhập Google trên Android chưa được cấu hình đủ '
            '(mã SHA hoặc file google-services.json). Hãy dùng email tạm thời.';
      case 'requires-recent-login':
        return 'Vì lý do bảo mật, hãy đăng xuất rồi đăng nhập lại '
            'trước khi thực hiện thao tác này.';
      default:
        return _commonMessage(code) ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
