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

  /// Đăng ký bằng email. Nếu đang là tài khoản khách thì gắn email vào chính
  /// tài khoản đó (giữ nguyên uid và tiến độ đã học); nếu không thì tạo tài
  /// khoản mới. Ném [AuthException] nếu thất bại.
  Future<AppAuthUser> registerWithEmail({
    required String email,
    required String password,
  });

  /// Ném [AuthException] nếu thất bại.
  Future<AppAuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Gửi email đặt lại mật khẩu. Ném [AuthException] nếu thất bại.
  Future<void> sendPasswordResetEmail(String email);

  /// Đăng nhập bằng Google. Nếu đang là tài khoản khách thì gắn Google vào
  /// chính tài khoản đó để giữ tiến độ; nếu tài khoản Google này đã dùng
  /// trong app trước đó thì đăng nhập vào tài khoản cũ.
  /// Ném [AuthException] nếu thất bại hoặc người dùng hủy.
  Future<AppAuthUser> signInWithGoogle();

  Future<void> signOut();
}
