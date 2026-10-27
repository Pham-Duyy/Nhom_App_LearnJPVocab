import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/models/study_preferences.dart';
import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_auth_service.dart';
import '../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Mở một mục ở màn Cá nhân (cuộn tới cho mục được dựng rồi mới bấm).
Future<void> _openProfileItem(WidgetTester tester, String title) async {
  await _tap(tester, find.text('Cá nhân'));
  await tester.scrollUntilVisible(find.text(title), 200);
  await _tap(tester, find.text(title));
}

Future<void> _pumpApp(
  WidgetTester tester, {
  StudyPreferences preferences = const StudyPreferences(),
  FakeAuthService? auth,
}) async {
  await tester.pumpWidget(buildTestApp(
    authService: auth,
    userProfileRepository: MockUserProfileRepository(
      initialProfile: UserProfile(displayName: 'Duy', preferences: preferences),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _openFirstLesson(WidgetTester tester) async {
  await _tap(tester, find.text('Học mới'));
  await _tap(tester, find.text('Chào hỏi và giao tiếp'));
  await _tap(tester, find.text('Chào hỏi cơ bản'));
}

void main() {
  group('Tùy chọn học', () {
    testWidgets('chọn Nghĩa làm mặt trước thì thẻ giấu chữ Nhật đến khi lật',
        (tester) async {
      await _pumpApp(tester);
      await _openProfileItem(tester, 'Tùy chọn học');
      await _tap(tester, find.text('Nghĩa'));
      await tester.pageBack();
      await tester.pumpAndSettle();

      await _openFirstLesson(tester);
      expect(find.text('Xin chào (ban ngày)'), findsOneWidget);
      expect(find.text('こんにちは'), findsNothing);

      await tester.tap(find.text('Xin chào (ban ngày)'));
      await tester.pumpAndSettle();
      expect(find.text('こんにちは'), findsOneWidget);
    });

    testWidgets('tắt romaji thì mặt trước không hiện cách đọc latinh', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        preferences: const StudyPreferences(showRomaji: false),
      );
      await _openFirstLesson(tester);

      expect(find.text('こんにちは'), findsOneWidget);
      expect(find.text('konnichiwa'), findsNothing);
    });

    testWidgets('chọn 5 câu mỗi lượt thì quiz nhanh có đúng 5 câu', (
      tester,
    ) async {
      await _pumpApp(tester,
          preferences: const StudyPreferences(quizLength: 5));

      await _tap(tester, find.text('Quiz nhanh'));

      expect(find.text('Câu 1/5'), findsOneWidget);
      final quiz =
          tester.element(find.byType(Scaffold).last).read<QuizProvider>();
      expect(quiz.questions, hasLength(5));
    });
  });

  group('Nhắc học mỗi ngày', () {
    testWidgets('hôm nay chưa học thì trang chủ có lời nhắc', (tester) async {
      await _pumpApp(tester);

      expect(find.textContaining('Hôm nay bạn chưa học'), findsOneWidget);
    });

    testWidgets('tắt nhắc học ở Cá nhân thì lời nhắc biến mất', (tester) async {
      await _pumpApp(tester);
      await _openProfileItem(tester, 'Nhắc học mỗi ngày');
      final reminderRow = find
          .ancestor(
              of: find.text('Nhắc học mỗi ngày'), matching: find.byType(Row))
          .first;
      expect(
        find.descendant(of: reminderRow, matching: find.text('Tắt')),
        findsOneWidget,
      );

      await _tap(tester, find.text('Ôn tập'));
      expect(find.textContaining('Hôm nay bạn chưa học'), findsNothing);
    });

    testWidgets('học một thẻ thì lời nhắc biến mất', (tester) async {
      await _pumpApp(tester);
      await _openFirstLesson(tester);
      await tester.tap(find.text('Đã nhớ'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Ôn tập'));

      expect(find.textContaining('Hôm nay bạn chưa học'), findsNothing);
    });
  });

  testWidgets('Thành tích: hiện số huy hiệu đã đạt và tiến độ từng huy hiệu', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openProfileItem(tester, 'Thành tích');

    // Dữ liệu mẫu đã học 9 từ: mới đạt "Bước đầu tiên", "Kho từ nhỏ" 9/10.
    expect(find.text('Đã đạt 1/9 huy hiệu'), findsOneWidget);
    expect(find.text('Bước đầu tiên'), findsOneWidget);
    expect(find.text('9/10'), findsOneWidget);
  });

  group('Tài khoản', () {
    testWidgets('khách thấy gợi ý liên kết; liên kết Google thì giữ uid', (
      tester,
    ) async {
      final auth = FakeAuthService(
        currentUser: const AppAuthUser(uid: 'guest-1', isAnonymous: true),
      );
      await _pumpApp(tester, auth: auth);
      await _openProfileItem(tester, 'Tài khoản');

      expect(find.text('Khách'), findsOneWidget);
      expect(find.text('Liên kết bằng email'), findsOneWidget);

      await _tap(tester, find.text('Liên kết Google'));

      expect(auth.currentUser!.uid, 'guest-1');
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Đã liên kết tài khoản Google.'), findsOneWidget);
    });

    testWidgets('tài khoản email đặt lại được mật khẩu', (tester) async {
      final auth = FakeAuthService(
        currentUser: const AppAuthUser(
          uid: 'duy',
          isAnonymous: false,
          email: 'duy@gmail.com',
          providers: [AppAuthUser.passwordProvider],
        ),
      );
      await _pumpApp(tester, auth: auth);
      await _openProfileItem(tester, 'Tài khoản');

      expect(find.text('Email và mật khẩu'), findsOneWidget);
      await _tap(tester, find.text('Đặt lại mật khẩu'));

      expect(auth.lastPasswordResetEmail, 'duy@gmail.com');
    });
  });

  testWidgets('Hướng dẫn: bảng lịch ôn lấy đúng từ thuật toán ôn tập', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openProfileItem(tester, 'Hướng dẫn sử dụng');

    await _tap(tester, find.text('Ôn tập đúng lúc sắp quên'));

    expect(find.text('1 · Mới học'), findsOneWidget);
    expect(find.text('30 ngày'), findsOneWidget);
  });

  testWidgets('mọi mục ở Cá nhân đều mở được, không còn "sẽ hoàn thiện"', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, find.text('Cá nhân'));

    // Theo thứ tự từ trên xuống để chỉ cần cuộn xuống.
    for (final title in [
      'Tùy chọn học',
      'Thành tích',
      'Lịch sử quiz',
      'Tài khoản',
      'Hướng dẫn sử dụng',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      await _tap(tester, find.text(title));
      expect(find.textContaining('sẽ được hoàn thiện'), findsNothing,
          reason: title);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
