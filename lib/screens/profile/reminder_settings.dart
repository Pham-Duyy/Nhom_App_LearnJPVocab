import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/study_preferences.dart';
import '../../providers/daily_reminder.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/error_view.dart';

/// Bật/tắt nhắc học và chọn giờ nhắc. Bật hoặc đổi giờ thì xin quyền gửi
/// thông báo; DailyReminder tự lập lại lịch khi hồ sơ được lưu.
class ReminderSettings extends StatelessWidget {
  const ReminderSettings({Key? key}) : super(key: key);

  Future<void> _save(BuildContext context, StudyPreferences next) async {
    final reminder = context.read<DailyReminder>();
    final profile = context.read<UserProfileProvider>();
    if (next.dailyReminder && reminder.isSupported) {
      final granted = await reminder.requestPermission();
      if (!granted && context.mounted) {
        showErrorSnackBar(
          context,
          'Hãy cho phép ChibaKanji gửi thông báo trong Cài đặt của máy.',
        );
      }
    }
    await profile.setPreferences(next);
    final error = profile.errorMessage;
    if (error != null && context.mounted) {
      profile.clearError();
      showErrorSnackBar(context, error);
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    StudyPreferences preferences,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: preferences.reminderHour,
        minute: preferences.reminderMinute,
      ),
      helpText: 'Chọn giờ nhắc học',
    );
    if (picked == null || !context.mounted) return;
    await _save(
      context,
      preferences.copyWith(
        reminderHour: picked.hour,
        reminderMinute: picked.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<UserProfileProvider>().preferences;
    final supported = context.read<DailyReminder>().isSupported;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Nhắc học mỗi ngày'),
          subtitle: Text(
            supported
                ? 'Gửi thông báo vào giờ bạn chọn và nhắc trên trang chủ '
                    'khi hôm nay bạn chưa học.'
                : 'Nhắc trên trang chủ khi hôm nay bạn chưa học. Thông báo '
                    'theo giờ chỉ có trên app điện thoại.',
          ),
          value: preferences.dailyReminder,
          onChanged: (value) =>
              _save(context, preferences.copyWith(dailyReminder: value)),
        ),
        if (supported)
          ListTile(
            contentPadding: EdgeInsets.zero,
            enabled: preferences.dailyReminder,
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Giờ nhắc'),
            trailing: Text(
              preferences.reminderTimeLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: () => _pickTime(context, preferences),
          ),
      ],
    );
  }
}
