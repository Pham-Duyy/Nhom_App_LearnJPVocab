import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Lập lịch thông báo nhắc học mỗi ngày. Giao diện chỉ biết interface này,
/// nên test dùng được bản giả mà không cần thông báo thật của máy.
abstract class ReminderScheduler {
  /// Máy có hỗ trợ thông báo theo lịch không (web thì không).
  bool get isSupported;

  /// Xin quyền gửi thông báo; trả về false nếu người dùng từ chối.
  Future<bool> requestPermission();

  /// Nhắc mỗi ngày vào [hour]:[minute] (giờ của máy), thay lịch cũ nếu có.
  Future<void> scheduleDaily(int hour, int minute);

  Future<void> cancel();
}

/// Thông báo của hệ điều hành qua flutter_local_notifications, chỉ trên
/// Android và iOS. Nền tảng khác (web, máy tính) bỏ qua mọi lời gọi; lời
/// nhắc khi đó chỉ hiện trên trang chủ.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _id = 1;
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminder',
      'Nhắc học mỗi ngày',
      channelDescription: 'Nhắc ôn từ vựng vào giờ bạn chọn',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _ensureReady() => _ready ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await _ensureReady();
    final granted = defaultTargetPlatform == TargetPlatform.android
        ? await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission()
        : await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  @override
  Future<void> scheduleDaily(int hour, int minute) async {
    if (!isSupported) return;
    await _ensureReady();
    final now = tz.TZDateTime.now(tz.local);
    var next =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      scheduledDate: next,
      notificationDetails: _details,
      // Không cần giờ chính xác tới từng giây nên không phải xin quyền
      // báo thức chính xác (exact alarm).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: 'ChibaKanji 🌸',
      body: 'Đến giờ ôn từ vựng rồi! Chibi đang chờ bạn.',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() async {
    if (!isSupported) return;
    await _ensureReady();
    await _plugin.cancel(id: _id);
  }
}
