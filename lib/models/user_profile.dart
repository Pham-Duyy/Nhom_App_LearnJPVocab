import 'package:flutter/material.dart' show StringCharacters, ThemeMode;

import 'study_preferences.dart';

/// Hồ sơ và tùy chọn của một người học, lưu tại document `users/{uid}`.
///
/// Chuỗi ngày học được tính theo ngày lịch (năm-tháng-ngày) của máy, không
/// theo số giờ đã trôi qua: học lúc 23:59 rồi 00:01 hôm sau vẫn là 2 ngày
/// liên tiếp.
class UserProfile {
  static const defaultDisplayName = 'Bạn';
  static const maxDisplayNameLength = 30;
  static const dailyGoalOptions = [5, 10, 15, 20];
  static const defaultDailyGoal = 10;

  final String displayName;
  final int dailyGoal;
  final ThemeMode themeMode;

  /// Số ngày học liên tiếp tính đến [lastStudyDate].
  final int currentStreak;

  /// Ngày học gần nhất, chỉ giữ phần ngày (giờ luôn là 00:00).
  final DateTime? lastStudyDate;

  /// Chuỗi ngày dài nhất từng đạt, để thành tích không mất khi chuỗi đứt.
  final int longestStreak;

  final StudyPreferences preferences;

  const UserProfile({
    this.displayName = defaultDisplayName,
    this.dailyGoal = defaultDailyGoal,
    this.themeMode = ThemeMode.system,
    this.currentStreak = 0,
    this.lastStudyDate,
    this.longestStreak = 0,
    this.preferences = const StudyPreferences(),
  });

  /// Hôm nay ([now]) đã học chưa.
  bool hasStudiedOn(DateTime now) {
    final last = lastStudyDate;
    return last != null && _daysBetween(last, now) == 0;
  }

  /// Chữ cái đầu cho ảnh đại diện; dùng `characters` để không cắt đôi một
  /// ký tự nhiều byte (emoji, chữ có dấu tổ hợp).
  String get initial =>
      displayName.isEmpty ? '?' : displayName.characters.first.toUpperCase();

  /// Chuỗi ngày đang hiển thị vào thời điểm [now]: chuỗi chỉ còn giữ khi lần
  /// học gần nhất là hôm nay hoặc hôm qua, bỏ lỡ một ngày thì về 0.
  int streakOn(DateTime now) {
    final last = lastStudyDate;
    if (last == null) return 0;
    return _daysBetween(last, now) <= 1 ? currentStreak : 0;
  }

  /// Ghi nhận người học vừa học vào [now]. Trả về chính object này nếu hôm
  /// nay đã được tính, để bên gọi biết là không cần lưu lại.
  UserProfile recordStudyDay(DateTime now) {
    final today = _dateOnly(now);
    final last = lastStudyDate;
    if (last != null && _daysBetween(last, today) == 0) return this;

    final continuesStreak = last != null && _daysBetween(last, today) == 1;
    final streak = continuesStreak ? currentStreak + 1 : 1;
    return copyWith(
      currentStreak: streak,
      lastStudyDate: today,
      longestStreak: streak > longestStreak ? streak : longestStreak,
    );
  }

  /// Trả về thông báo lỗi nếu [name] không dùng được làm tên hiển thị.
  static String? validateDisplayName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Tên không được để trống.';
    if (trimmed.length > maxDisplayNameLength) {
      return 'Tên tối đa $maxDisplayNameLength ký tự.';
    }
    return null;
  }

  UserProfile copyWith({
    String? displayName,
    int? dailyGoal,
    ThemeMode? themeMode,
    int? currentStreak,
    DateTime? lastStudyDate,
    int? longestStreak,
    StudyPreferences? preferences,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      themeMode: themeMode ?? this.themeMode,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      longestStreak: longestStreak ?? this.longestStreak,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Ngày được lưu dạng `yyyy-MM-dd` để không phụ thuộc múi giờ của máy.
  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'dailyGoal': dailyGoal,
        'themeMode': themeMode.name,
        'currentStreak': currentStreak,
        'lastStudyDate':
            lastStudyDate == null ? null : _formatDate(lastStudyDate!),
        'longestStreak': longestStreak,
        'preferences': preferences.toMap(),
      };

  /// Đọc an toàn: trường thiếu hoặc sai kiểu được thay bằng giá trị mặc định,
  /// để một document hỏng không làm app lỗi khi mở.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final name = map['displayName'];
    final goal = map['dailyGoal'];
    final streak = map['currentStreak'];
    final longest = map['longestStreak'];
    final lastDate = map['lastStudyDate'];
    final preferences = map['preferences'];
    final currentStreak = streak is int && streak > 0 ? streak : 0;

    return UserProfile(
      displayName: name is String && validateDisplayName(name) == null
          ? name.trim()
          : defaultDisplayName,
      dailyGoal:
          dailyGoalOptions.contains(goal) ? goal as int : defaultDailyGoal,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == map['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      currentStreak: currentStreak,
      lastStudyDate: lastDate is String ? DateTime.tryParse(lastDate) : null,
      // Dữ liệu cũ chưa có longestStreak: ít nhất bằng chuỗi hiện tại.
      longestStreak:
          longest is int && longest > currentStreak ? longest : currentStreak,
      preferences: preferences is Map
          ? StudyPreferences.fromMap(Map<String, dynamic>.from(preferences))
          : const StudyPreferences(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.displayName == displayName &&
      other.dailyGoal == dailyGoal &&
      other.themeMode == themeMode &&
      other.currentStreak == currentStreak &&
      other.lastStudyDate == lastStudyDate &&
      other.longestStreak == longestStreak &&
      other.preferences == preferences;

  @override
  int get hashCode => Object.hash(
        displayName,
        dailyGoal,
        themeMode,
        currentStreak,
        lastStudyDate,
        longestStreak,
        preferences,
      );

  @override
  String toString() =>
      'UserProfile($displayName, goal: $dailyGoal, streak: $currentStreak)';

  static DateTime _dateOnly(DateTime time) =>
      DateTime(time.year, time.month, time.day);

  /// Số ngày lịch từ [from] đến [to]. Tính trên giờ UTC để ngày chuyển giờ
  /// mùa hè (ngày dài 23 hoặc 25 giờ) không làm sai kết quả.
  static int _daysBetween(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
