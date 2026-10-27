import 'dart:async';

import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/providers/user_profile_provider.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:chibakanji/repositories/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository có thể bật lỗi khi lưu/tải, để kiểm tra nhánh xử lý lỗi.
class _FailingRepository implements UserProfileRepository {
  bool failLoad = false;
  bool failSave = false;

  @override
  Future<UserProfile?> load() async {
    if (failLoad) throw Exception('mất mạng');
    return null;
  }

  @override
  Future<void> save(UserProfile profile) async {
    if (failSave) throw Exception('mất mạng');
  }
}

/// Repository mà mỗi lần tải chỉ xong khi test cho phép.
class _ControlledRepository implements UserProfileRepository {
  final pending = <Completer<UserProfile?>>[];

  @override
  Future<UserProfile?> load() {
    final completer = Completer<UserProfile?>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<void> save(UserProfile profile) async {}
}

void main() {
  group('tải hồ sơ', () {
    test('người dùng mới (chưa có document) dùng hồ sơ mặc định', () async {
      final provider = UserProfileProvider(MockUserProfileRepository());

      await provider.load();

      expect(provider.profile, const UserProfile());
      expect(provider.displayName, UserProfile.defaultDisplayName);
      expect(provider.isLoading, isFalse);
    });

    test('đọc đúng hồ sơ đã lưu', () async {
      final provider = UserProfileProvider(MockUserProfileRepository(
        initialProfile: const UserProfile(displayName: 'Duy', dailyGoal: 15),
      ));

      await provider.load();

      expect(provider.displayName, 'Duy');
      expect(provider.dailyGoal, 15);
    });

    test('lỗi khi tải thì báo lỗi và vẫn dùng được hồ sơ mặc định', () async {
      final provider =
          UserProfileProvider(_FailingRepository()..failLoad = true);

      await provider.load();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
      expect(provider.profile, const UserProfile());
    });

    test('kết quả của lần tải cũ bị bỏ qua khi đã có lần tải mới hơn',
        () async {
      final repository = _ControlledRepository();
      final provider = UserProfileProvider(repository);

      final firstLoad = provider.load();
      final secondLoad = provider.load();
      repository.pending[1].complete(const UserProfile(displayName: 'Mới'));
      await secondLoad;
      repository.pending[0].complete(const UserProfile(displayName: 'Cũ'));
      await firstLoad;

      expect(provider.displayName, 'Mới');
      expect(provider.isLoading, isFalse);
    });
  });

  group('US20: đổi tên và giao diện', () {
    test('đổi tên hợp lệ thì cập nhật và lưu (đã cắt khoảng trắng)', () async {
      final repository = MockUserProfileRepository();
      final provider = UserProfileProvider(repository);

      final error = await provider.updateDisplayName('  Sơn  ');

      expect(error, isNull);
      expect(provider.displayName, 'Sơn');
      expect((await repository.load())!.displayName, 'Sơn');
    });

    test('tên không hợp lệ trả về lỗi và không lưu gì', () async {
      final repository = MockUserProfileRepository();
      final provider = UserProfileProvider(repository);

      final error = await provider.updateDisplayName('   ');

      expect(error, isNotNull);
      expect(provider.displayName, UserProfile.defaultDisplayName);
      expect(repository.saveCount, 0);
    });

    test('đổi giao diện tối được lưu lại', () async {
      final repository = MockUserProfileRepository();
      final provider = UserProfileProvider(repository);

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect((await repository.load())!.themeMode, ThemeMode.dark);
    });

    test('chọn lại đúng giá trị đang có thì không ghi thừa', () async {
      final repository = MockUserProfileRepository();
      final provider = UserProfileProvider(repository);

      await provider.setThemeMode(ThemeMode.light);
      await provider.updateDisplayName(UserProfile.defaultDisplayName);

      expect(repository.saveCount, 0);
    });

    test('lưu thất bại thì trả lại giá trị cũ và báo lỗi', () async {
      final repository = _FailingRepository()..failSave = true;
      final provider = UserProfileProvider(repository);

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.light);
      expect(provider.errorMessage, isNotNull);

      provider.clearError();
      expect(provider.errorMessage, isNull);
    });
  });

  group('US18: mục tiêu mỗi ngày', () {
    test('mặc định là 10 từ', () {
      final provider = UserProfileProvider(MockUserProfileRepository());

      expect(provider.dailyGoal, 10);
    });

    test('chọn mục tiêu trong danh sách thì được lưu', () async {
      final repository = MockUserProfileRepository();
      final provider = UserProfileProvider(repository);

      await provider.setDailyGoal(20);

      expect(provider.dailyGoal, 20);
      expect((await repository.load())!.dailyGoal, 20);
    });

    test('mục tiêu ngoài danh sách bị từ chối', () async {
      final provider = UserProfileProvider(MockUserProfileRepository());

      await expectLater(provider.setDailyGoal(7), throwsArgumentError);
      expect(provider.dailyGoal, 10);
    });
  });

  group('US19: ghi nhận ngày học', () {
    test('học nhiều thẻ trong cùng ngày chỉ lưu đúng một lần', () async {
      final repository = MockUserProfileRepository();
      final provider = UserProfileProvider(
        repository,
        clock: () => DateTime(2026, 10, 25, 9),
      );

      await provider.recordStudyActivity();
      await provider.recordStudyActivity();
      await provider.recordStudyActivity();

      expect(provider.streak, 1);
      expect(repository.saveCount, 1);
    });

    test('học hai ngày liền thì chuỗi là 2', () async {
      var now = DateTime(2026, 10, 25, 20);
      final provider = UserProfileProvider(
        MockUserProfileRepository(),
        clock: () => now,
      );

      await provider.recordStudyActivity();
      now = DateTime(2026, 10, 26, 7);
      await provider.recordStudyActivity();

      expect(provider.streak, 2);
    });

    test('chuỗi hiển thị về 0 khi đã bỏ lỡ một ngày', () async {
      var now = DateTime(2026, 10, 25);
      final provider = UserProfileProvider(
        MockUserProfileRepository(),
        clock: () => now,
      );

      await provider.recordStudyActivity();
      now = DateTime(2026, 10, 27);

      expect(provider.streak, 0);
    });
  });
}
