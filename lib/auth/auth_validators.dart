/// Kiểm tra dữ liệu nhập ở form đăng nhập/đăng ký. Mỗi hàm trả về thông
/// báo lỗi, hoặc null nếu hợp lệ — đúng kiểu `validator` của TextFormField.
class AuthValidators {
  AuthValidators._();

  /// Firebase từ chối mật khẩu ngắn hơn 6 ký tự (`weak-password`).
  static const minPasswordLength = 6;

  /// Đủ để bắt lỗi gõ nhầm phổ biến; email có thật hay không do Firebase
  /// kiểm tra.
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Vui lòng nhập email.';
    if (!_emailPattern.hasMatch(email)) return 'Email không đúng định dạng.';
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < minPasswordLength) {
      return 'Mật khẩu cần ít nhất $minPasswordLength ký tự.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    return value == password ? null : 'Mật khẩu xác nhận chưa khớp.';
  }
}
