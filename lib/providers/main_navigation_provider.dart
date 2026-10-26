import 'package:flutter/foundation.dart';

/// Quản lý tab đang chọn ở thanh điều hướng dưới của [MainScreen], tách
/// riêng khỏi widget để các màn hình khác (vd. LearningResultScreen) có thể
/// điều hướng về một tab cụ thể mà không cần biết MainScreen dựng thế nào.
class MainNavigationProvider extends ChangeNotifier {
  /// Vị trí các tab, cùng thứ tự với thanh điều hướng của MainScreen.
  static const reviewTab = 0;
  static const learnTab = 1;
  static const examTab = 2;
  static const wordsTab = 3;
  static const profileTab = 4;

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goHome() {
    selectTab(reviewTab);
  }
}
