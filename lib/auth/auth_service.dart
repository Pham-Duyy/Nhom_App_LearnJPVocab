import 'app_auth_user.dart';

/// Lỗi xác thực ở dạng độc lập với Firebase. Implementation cụ thể (vd.
/// FirebaseAuthService) chịu trách nhiệm đổi exception của nó sang lỗi này,
/// với [code] giữ nguyên mã lỗi (vd. `network-request-failed`).
class AuthException implements Exception {
  const AuthException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() =>
      'AuthException($code${message == null ? '' : ': $message'})';
}

/// Lớp trừu tượng cho xác thực. Toàn bộ code phía trên (AuthController, UI)
/// chỉ biết interface này, nên đổi backend hoặc dùng bản giả khi test không
/// cần sửa gì.
abstract class AuthService {
  AppAuthUser? get currentUser;

  Stream<AppAuthUser?> authStateChanges();

  /// Đăng nhập ẩn danh. Ném [AuthException] nếu thất bại.
  Future<AppAuthUser> signInAnonymously();

  /// Chỉ để chuẩn bị cho tài khoản thật trong tương lai; chưa có nút đăng
  /// xuất nào cho người dùng ẩn danh.
  Future<void> signOut();
}
