import 'package:chibakanji/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('US19: chuỗi ngày học - recordStudyDay', () {
    test('lần học đầu tiên bắt đầu chuỗi 1 ngày', () {
      final profile =
          const UserProfile().recordStudyDay(DateTime(2026, 10, 25, 9));

      expect(profile.currentStreak, 1);
      expect(profile.lastStudyDate, DateTime(2026, 10, 25));
    });

    test('học thêm trong cùng ngày không tăng chuỗi và trả về chính object',
        () {
      final morning =
          const UserProfile().recordStudyDay(DateTime(2026, 10, 25, 8));
      final evening = morning.recordStudyDay(DateTime(2026, 10, 25, 22));

      expect(identical(evening, morning), isTrue);
      expect(evening.currentStreak, 1);
    });

    test('học ngày kế tiếp thì chuỗi tăng 1', () {
      final day1 = const UserProfile().recordStudyDay(DateTime(2026, 10, 25));
      final day2 = day1.recordStudyDay(DateTime(2026, 10, 26));
      final day3 = day2.recordStudyDay(DateTime(2026, 10, 27));

      expect(day3.currentStreak, 3);
      expect(day3.lastStudyDate, DateTime(2026, 10, 27));
    });

    test('23:59 rồi 00:01 hôm sau vẫn tính là 2 ngày liên tiếp', () {
      final lateNight =
          const UserProfile().recordStudyDay(DateTime(2026, 10, 25, 23, 59));
      final afterMidnight =
          lateNight.recordStudyDay(DateTime(2026, 10, 26, 0, 1));

      expect(afterMidnight.currentStreak, 2);
    });

    test('bỏ lỡ một ngày thì chuỗi bắt đầu lại từ 1', () {
      final profile = UserProfile(
        currentStreak: 5,
        lastStudyDate: DateTime(2026, 10, 20),
      ).recordStudyDay(DateTime(2026, 10, 22));

      expect(profile.currentStreak, 1);
      expect(profile.lastStudyDate, DateTime(2026, 10, 22));
    });

    test('chuỗi nối tiếp qua ranh giới tháng và năm', () {
      final endOfYear =
          UserProfile(currentStreak: 3, lastStudyDate: DateTime(2026, 12, 31));

      expect(endOfYear.recordStudyDay(DateTime(2027, 1, 1)).currentStreak, 4);
    });

    test('ghi nhận không làm mất các trường khác của hồ sơ', () {
      const original = UserProfile(
        displayName: 'Duy',
        dailyGoal: 15,
        themeMode: ThemeMode.dark,
      );
      final updated = original.recordStudyDay(DateTime(2026, 10, 25));

      expect(updated.displayName, 'Duy');
      expect(updated.dailyGoal, 15);
      expect(updated.themeMode, ThemeMode.dark);
    });
  });

  group('US19: chuỗi ngày đang hiển thị - streakOn', () {
    final studied = UserProfile(
      currentStreak: 4,
      lastStudyDate: DateTime(2026, 10, 25),
    );

    test('chưa từng học thì chuỗi là 0', () {
      expect(const UserProfile().streakOn(DateTime(2026, 10, 25)), 0);
    });

    test('vẫn giữ chuỗi trong ngày học và cả ngày hôm sau', () {
      expect(studied.streakOn(DateTime(2026, 10, 25, 23)), 4);
      expect(studied.streakOn(DateTime(2026, 10, 26, 20)), 4);
    });

    test('qua hết ngày hôm sau mà chưa học thì chuỗi về 0', () {
      expect(studied.streakOn(DateTime(2026, 10, 27)), 0);
    });
  });

  group('US20: kiểm tra tên hiển thị', () {
    test('tên hợp lệ không có lỗi', () {
      expect(UserProfile.validateDisplayName('Duy'), isNull);
    });

    test('tên rỗng hoặc chỉ có khoảng trắng bị từ chối', () {
      expect(UserProfile.validateDisplayName(''), isNotNull);
      expect(UserProfile.validateDisplayName('   '), isNotNull);
    });

    test('tên dài hơn giới hạn bị từ chối, đúng giới hạn thì được', () {
      const limit = UserProfile.maxDisplayNameLength;
      expect(UserProfile.validateDisplayName('a' * limit), isNull);
      expect(UserProfile.validateDisplayName('a' * (limit + 1)), isNotNull);
    });

    test('chữ cái đầu cho ảnh đại diện', () {
      expect(const UserProfile(displayName: 'duy').initial, 'D');
      expect(const UserProfile(displayName: 'Đức').initial, 'Đ');
    });
  });

  group('ORM: toMap / fromMap với Firestore', () {
    test('fromMap(toMap()) giữ nguyên toàn bộ dữ liệu', () {
      final profile = UserProfile(
        displayName: 'Duy',
        dailyGoal: 20,
        themeMode: ThemeMode.dark,
        currentStreak: 7,
        lastStudyDate: DateTime(2026, 10, 5),
      );

      expect(UserProfile.fromMap(profile.toMap()), profile);
    });

    test('ngày được lưu dạng yyyy-MM-dd, không kèm giờ', () {
      final map = UserProfile(lastStudyDate: DateTime(2026, 3, 7)).toMap();

      expect(map['lastStudyDate'], '2026-03-07');
    });

    test('document rỗng dùng toàn bộ giá trị mặc định', () {
      expect(UserProfile.fromMap({}), const UserProfile());
    });

    test('dữ liệu sai kiểu hoặc ngoài phạm vi được thay bằng mặc định', () {
      final profile = UserProfile.fromMap({
        'displayName': '   ',
        'dailyGoal': 7,
        'themeMode': 'neon',
        'currentStreak': -3,
        'lastStudyDate': 'không phải ngày',
      });

      expect(profile, const UserProfile());
    });

    test('tên có khoảng trắng thừa được cắt gọn khi đọc', () {
      expect(
          UserProfile.fromMap({'displayName': '  Duy  '}).displayName, 'Duy');
    });
  });
}
