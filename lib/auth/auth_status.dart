/// Trạng thái xác thực của ứng dụng.
enum AuthStatus {
  /// Chưa khởi tạo.
  initial,

  /// Đang kiểm tra hoặc đăng nhập.
  loading,

  /// Có người dùng hợp lệ.
  authenticated,

  /// Không có người dùng sau khi hệ thống đã khởi tạo (vd. sau khi đăng xuất).
  unauthenticated,

  /// Kiểm tra hoặc đăng nhập thất bại.
  failure,
}
