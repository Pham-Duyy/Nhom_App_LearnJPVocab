/// Xóa toàn bộ dữ liệu cá nhân của người đang đăng nhập (hồ sơ, tiến độ,
/// lịch sử quiz, kho từ) khi người dùng xóa tài khoản.
abstract class UserDataCleaner {
  Future<void> deleteAll();
}
