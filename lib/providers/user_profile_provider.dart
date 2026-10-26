import 'package:flutter/material.dart';

import '../models/study_preferences.dart';
import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import '../utils/app_error.dart';

/// Quản lý hồ sơ và tùy chọn của người học: tên hiển thị, mục tiêu mỗi
/// ngày, giao diện sáng/tối và chuỗi ngày học liên tiếp.
///
/// Mọi thay đổi được áp dụng ngay trên giao diện rồi mới lưu; nếu lưu lỗi
/// thì trả về giá trị cũ và đặt [errorMessage].
class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final UserProfileRepository _repository;
  final DateTime Function() _clock;

  UserProfile _profile = const UserProfile();
  bool _isLoading = false;
  String? _errorMessage;

  /// Tăng mỗi lần [load], để bỏ qua kết quả của một lần tải cũ hơn (vd. khi
  /// đăng xuất rồi đăng nhập tài khoản khác lúc lần tải trước chưa xong).
  int _loadGeneration = 0;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get displayName => _profile.displayName;
  String get initial => _profile.initial;
  int get dailyGoal => _profile.dailyGoal;
  ThemeMode get themeMode => _profile.themeMode;
  int get streak => _profile.streakOn(_clock());
  int get longestStreak => _profile.longestStreak;
  StudyPreferences get preferences => _profile.preferences;

  /// Hôm nay đã trả lời ít nhất một thẻ hay câu quiz chưa.
  bool get hasStudiedToday => _profile.hasStudiedOn(_clock());

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.load();
      if (generation != _loadGeneration) return;
      _profile = loaded ?? const UserProfile();
    } catch (e, stack) {
      if (generation != _loadGeneration) return;
      AppError.log('UserProfileProvider.load', e, stack);
      _errorMessage = AppError.message(e, action: 'tải hồ sơ');
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Trả về thông báo lỗi nếu tên không hợp lệ, null nếu đã đổi được.
  Future<String?> updateDisplayName(String name) async {
    final error = UserProfile.validateDisplayName(name);
    if (error != null) return error;
    await _update(_profile.copyWith(displayName: name.trim()));
    return null;
  }

  Future<void> setDailyGoal(int goal) async {
    if (!UserProfile.dailyGoalOptions.contains(goal)) {
      throw ArgumentError.value(goal, 'goal', 'Không nằm trong các lựa chọn');
    }
    await _update(_profile.copyWith(dailyGoal: goal));
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(_profile.copyWith(themeMode: mode));

  Future<void> setPreferences(StudyPreferences preferences) =>
      _update(_profile.copyWith(preferences: preferences));

  /// Gọi mỗi khi người học trả lời một thẻ. Chỉ lưu lần đầu trong ngày.
  Future<void> recordStudyActivity() =>
      _update(_profile.recordStudyDay(_clock()));

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _update(UserProfile next) async {
    if (next == _profile) return;

    final previous = _profile;
    _profile = next;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.save(next);
    } catch (e, stack) {
      AppError.log('UserProfileProvider.save', e, stack);
      // Chỉ hoàn tác nếu chưa có thay đổi nào mới hơn ghi đè lên [next].
      if (identical(_profile, next)) _profile = previous;
      _errorMessage = AppError.message(e, action: 'lưu thay đổi');
      notifyListeners();
    }
  }
}
