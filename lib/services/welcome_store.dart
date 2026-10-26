import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_error.dart';

/// Ghi nhớ trên thiết bị rằng người dùng đã qua màn chào, để lần sau mở app
/// thì vào thẳng trang chủ. Lỗi đọc/ghi chỉ làm màn chào hiện lại, nên được
/// bỏ qua thay vì chặn app.
class WelcomeStore {
  WelcomeStore._();

  static const _key = 'welcome_seen';

  static Future<bool> hasSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (e, stack) {
      AppError.log('WelcomeStore.hasSeen', e, stack);
      return false;
    }
  }

  /// Đăng xuất thì gọi với `false` để lần sau mở app hiện lại màn chào.
  static Future<void> setSeen(bool seen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, seen);
    } catch (e, stack) {
      AppError.log('WelcomeStore.setSeen', e, stack);
    }
  }
}
