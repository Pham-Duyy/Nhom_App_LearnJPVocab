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
      // Chỉ log loại lỗi/mã lỗi, không log nguyên văn exception vì thông
      // điệp của nó có thể chứa dữ liệu nhạy cảm (token...).
      debugPrint(
        'Auth initialize failed: '
        '${error is AuthException ? error.code : error.runtimeType}',
      );
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
      // Chỉ coi là đã đăng xuất khi trước đó đang đăng nhập. Firebase phát
      // null ngay khi bắt đầu nghe trên máy mới; lúc đó (đang loading) hoặc
      // sau lỗi (failure) không được ghi đè trạng thái hiện tại.
      _user = null;
      _status = AuthStatus.unauthenticated;
      _notify();
    }
  }

  String _friendlyMessage(Object error) {
    final code = error is AuthException ? error.code : null;
    switch (code) {
      case 'network-request-failed':
        return 'Không thể kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';
      case 'operation-not-allowed':
        return 'Đăng nhập ẩn danh chưa được bật trong Firebase.';
      case 'too-many-requests':
        return 'Có quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      default:
        return 'Không thể khởi tạo tài khoản. Vui lòng thử lại.';
    }
  }

  // Một lần initialize() có thể còn đang chờ khi controller bị dispose (vd.
  // đóng app giữa lúc đăng nhập); notifyListeners() sau dispose sẽ ném lỗi.
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
