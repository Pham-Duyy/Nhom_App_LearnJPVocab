import 'package:chibakanji/models/study_preferences.dart';
import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/providers/daily_reminder.dart';
import 'package:chibakanji/providers/user_profile_provider.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_reminder_scheduler.dart';

void main() {
  late FakeReminderScheduler scheduler;
  late UserProfileProvider profile;

  Future<void> setUpWith(StudyPreferences preferences) async {
    scheduler = FakeReminderScheduler();
    profile = UserProfileProvider(MockUserProfileRepository(
      initialProfile: UserProfile(preferences: preferences),
    ));
    DailyReminder(scheduler, profile);
  }

  test('chưa tải hồ sơ thì chưa lập lịch theo giá trị mặc định', () async {
    await setUpWith(const StudyPreferences(reminderHour: 7));

    expect(scheduler.scheduled, isNull);
  });

  test('tải hồ sơ xong thì nhắc mỗi ngày đúng giờ đã chọn', () async {
    await setUpWith(
      const StudyPreferences(reminderHour: 7, reminderMinute: 30),
    );

    await profile.load();

    expect(scheduler.scheduled, (7, 30));
  });

  test('đổi giờ nhắc thì lập lại lịch', () async {
    await setUpWith(const StudyPreferences());
    await profile.load();

    await profile.setPreferences(
      profile.preferences.copyWith(reminderHour: 21, reminderMinute: 15),
    );

    expect(scheduler.scheduled, (21, 15));
  });

  test('tắt nhắc học thì hủy lịch, bật lại thì lập lại', () async {
    await setUpWith(const StudyPreferences());
    await profile.load();

    await profile.setPreferences(
      profile.preferences.copyWith(dailyReminder: false),
    );
    expect(scheduler.scheduled, isNull);

    await profile.setPreferences(
      profile.preferences.copyWith(dailyReminder: true),
    );
    expect(scheduler.scheduled, (StudyPreferences.defaultReminderHour, 0));
  });

  test('giờ nhắc lưu và đọc lại từ Firestore (ORM)', () {
    const preferences = StudyPreferences(reminderHour: 6, reminderMinute: 45);

    final restored = StudyPreferences.fromMap(preferences.toMap());

    expect(restored, preferences);
    expect(restored.reminderTimeLabel, '06:45');
  });

  test('giờ nhắc sai phạm vi thì dùng mặc định', () {
    final restored = StudyPreferences.fromMap(
      {'reminderHour': 30, 'reminderMinute': -1},
    );

    expect(restored.reminderHour, StudyPreferences.defaultReminderHour);
    expect(restored.reminderMinute, 0);
  });
}
