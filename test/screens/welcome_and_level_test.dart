import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/data/mock/mock_learning_data.dart';
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
    testWidgets('mở app lần đầu thấy lời giới thiệu và hai lối vào', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildTestApp(showWelcome: true));
      await _pumpFrames(tester);

      expect(find.text('ChibaKanji'), findsWidgets);
      expect(find.textContaining('gần Nhật Bản hơn'), findsOneWidget);
      expect(find.text('Bắt đầu cùng Chibi →'), findsOneWidget);
      expect(find.textContaining('Đã có tài khoản?'), findsOneWidget);
    });

    testWidgets('bấm Bắt đầu thì sang màn đăng ký', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildTestApp(showWelcome: true));
      await _pumpFrames(tester);
      await tester.tap(find.text('Bắt đầu cùng Chibi →'));
      await _pumpFrames(tester);

      // Tiêu đề đầu trang của chế độ đăng ký.
      expect(find.text('MỘT KHỞI ĐẦU MỚI'), findsOneWidget);
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

      expect(find.text('Chủ đề N5'), findsOneWidget);
      expect(find.text('${MockLearningData.categories.length} chủ đề'),
          findsOneWidget);
      expect(find.text('Chào hỏi và giao tiếp'), findsOneWidget);
    });

    testWidgets('chọn cấp chưa có nội dung thì báo đang biên soạn', (
      tester,
    ) async {
      await pumpTestApp(tester);
      await tester.tap(find.text('Học mới'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('N4'));
      await tester.pumpAndSettle();

      expect(find.text('Chủ đề N4'), findsOneWidget);
      expect(find.text('0 chủ đề'), findsOneWidget);
      expect(find.text('Chào hỏi và giao tiếp'), findsNothing);
      expect(
        find.text('Chủ đề ở cấp độ này đang được biên soạn.'),
        findsOneWidget,
      );
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
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất').last);
    await _pumpFrames(tester);

    expect(auth.signOutCallCount, 1);
    expect(find.text('Bắt đầu cùng Chibi →'), findsOneWidget);
  });
}
