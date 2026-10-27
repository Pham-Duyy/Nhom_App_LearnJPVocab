import '../services/reminder_scheduler.dart';
import '../utils/app_error.dart';
import 'user_profile_provider.dart';

/// Giữ lịch thông báo nhắc học khớp với tùy chọn trong hồ sơ: bật, tắt hoặc
/// đổi giờ nhắc thì lập lại lịch. Chỉ đồng bộ sau khi hồ sơ đã tải xong, để
/// không lập lịch theo giá trị mặc định rồi lại đổi.
class DailyReminder {
  DailyReminder(this._scheduler, this._profile) {
    _profile.addListener(_sync);
    _sync();
  }

  final ReminderScheduler _scheduler;
  final UserProfileProvider _profile;

  /// Trạng thái đã lập lịch gần nhất ("off" hoặc giờ "20:00").
  String? _synced;

  bool get isSupported => _scheduler.isSupported;

  Future<bool> requestPermission() => _scheduler.requestPermission();

  void _sync() {
    if (!_profile.hasLoaded) return;
    final preferences = _profile.preferences;
    final state =
        preferences.dailyReminder ? preferences.reminderTimeLabel : 'off';
    if (state == _synced) return;
    _synced = state;
    final task = preferences.dailyReminder
        ? _scheduler.scheduleDaily(
            preferences.reminderHour,
            preferences.reminderMinute,
          )
        : _scheduler.cancel();
    task.catchError(
      (Object e, StackTrace stack) => AppError.log('DailyReminder', e, stack),
    );
  }

  void dispose() => _profile.removeListener(_sync);
}
