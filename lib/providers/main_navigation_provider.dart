import 'package:flutter/foundation.dart';

/// Quản lý tab đang chọn ở thanh điều hướng dưới của [MainScreen], tách
/// riêng khỏi widget để các màn hình khác (vd. LearningResultScreen) có thể
/// điều hướng về một tab cụ thể mà không cần biết MainScreen dựng thế nào.
class MainNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goHome() {
    selectTab(0);
  }
}
