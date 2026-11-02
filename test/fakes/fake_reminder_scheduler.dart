import 'package:chibakanji/services/reminder_scheduler.dart';

/// Lịch nhắc giả: ghi lại giờ đã lập lịch thay vì gửi thông báo thật.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.isSupported = true, this.grantPermission = true});

  @override
  final bool isSupported;
  bool grantPermission;
  int permissionRequests = 0;

  /// Giờ đang được nhắc, dạng (giờ, phút); null nếu không có lịch.
  (int, int)? scheduled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grantPermission;
  }

  @override
  Future<void> scheduleDaily(int hour, int minute) async =>
      scheduled = (hour, minute);

  @override
  Future<void> cancel() async => scheduled = null;
}
