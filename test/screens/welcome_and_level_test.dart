import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/widgets/chibi_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';
import '../helpers/test_app.dart';

/// Màn chào có animation lặp vô hạn nên không dùng pumpAndSettle được.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('US01: xem giới thiệu ứng dụng', () {
    testWidgets('mở app thấy Chibi chuyển động, 7 giây sau sang đăng ký', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildTestApp(showWelcome: true));
      await _pumpFrames(tester);

      expect(find.byType(ChibiMascot), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);

      const registerSubtitle = 'Lưu tiến độ học trên mọi thiết bị.';
      await tester.pump(const Duration(seconds: 6));
      expect(find.text(registerSubtitle), findsNothing);

      await passSplash(tester);
      expect(find.text(registerSubtitle), findsOneWidget);
    });

    testWidgets('chạm vào màn hình thì vào đăng ký ngay', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildTestApp(showWelcome: true));
      await _pumpFrames(tester);
      await tester.tap(find.byType(ChibiMascot));
      await _pumpFrames(tester);

      expect(find.text('Lưu tiến độ học trên mọi thiết bị.'), findsOneWidget);
    });
  });

  testWidgets('US02: khách vào thẳng trang chủ, không cần tạo tài khoản', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(buildTestApp(authService: auth));
    await tester.pumpAndSettle();

    expect(auth.currentUser!.isAnonymous, isTrue);
    expect(find.text('Quiz nhanh'), findsOneWidget);
  });

  group('US06: chủ đề theo cấp độ JLPT', () {
    testWidgets('mặc định là N5 với đủ các chủ đề mẫu', (tester) async {
      await pumpTestApp(tester);
      await tester.tap(find.text('Học mới'));
      await tester.pumpAndSettle();

      final n5Count = MockLearningData.categories
          .where((category) => category.jlptLevel == 'N5')
          .length;
      expect(find.text('$n5Count chủ đề'), findsOneWidget);
      expect(find.text('Chào hỏi và giao tiếp'), findsOneWidget);
    });

    testWidgets('chọn "Ngành" thì hiện các chủ đề từ vựng chuyên ngành', (
      tester,
    ) async {
      await pumpTestApp(tester);
      await tester.tap(find.text('Học mới'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ngành'));
      await tester.pumpAndSettle();

      expect(find.text('3 chủ đề'), findsOneWidget);
      expect(find.text('Chế biến thực phẩm'), findsOneWidget);
      expect(find.text('Chào hỏi và giao tiếp'), findsNothing);
    });

    testWidgets('chọn N4 và N3 thì hiện đúng chủ đề của từng cấp', (
      tester,
    ) async {
      await pumpTestApp(tester);
      await tester.tap(find.text('Học mới'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('N4'));
      await tester.pumpAndSettle();
      expect(find.text('3 chủ đề'), findsOneWidget);
      expect(find.text('Công việc và công ty'), findsOneWidget);
      expect(find.text('Chào hỏi và giao tiếp'), findsNothing);

      await tester.tap(find.text('N3'));
      await tester.pumpAndSettle();
      expect(find.text('3 chủ đề'), findsOneWidget);
      expect(find.text('Xã hội và tin tức'), findsOneWidget);
      expect(find.text('Công việc và công ty'), findsNothing);
    });
  });

  testWidgets('US05: khách đăng xuất thì về màn chào', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final auth = FakeAuthService(
      currentUser: const AppAuthUser(uid: 'guest', isAnonymous: true),
    );
    await tester.pumpWidget(buildTestApp(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Đăng xuất'), 200);
    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất').last);
    await _pumpFrames(tester);

    expect(auth.signOutCallCount, 1);
    expect(find.byType(ChibiMascot), findsOneWidget);
  });
}
