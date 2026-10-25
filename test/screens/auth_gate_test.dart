import 'package:chibakanji/auth/auth_controller.dart';
import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/providers/progress_provider.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:chibakanji/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_auth_service.dart';

Widget _buildGate(FakeAuthService authService, ProgressProvider progress) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthController(authService)..initialize(),
      ),
      ChangeNotifierProvider.value(value: progress),
    ],
    child: const MaterialApp(
      home: AuthGate(child: Text('Nội dung chính')),
    ),
  );
}

void main() {
  testWidgets('đăng nhập ẩn danh xong thì hiện nội dung và tải tiến độ', (
    tester,
  ) async {
    final authService = FakeAuthService();
    final progress = ProgressProvider(MockProgressRepository(
      initialProgress: const [Progress(vocabularyId: 'v1', isLearned: true)],
    ));

    await tester.pumpWidget(_buildGate(authService, progress));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Nội dung chính'), findsOneWidget);
    expect(authService.signInCallCount, 1);
    expect(progress.totalLearned, 1);
  });

  testWidgets('đăng nhập lỗi thì hiện thông báo, bấm Thử lại để vào app', (
    tester,
  ) async {
    final authService = FakeAuthService(shouldFailSignIn: true);
    final progress = ProgressProvider(MockProgressRepository());

    await tester.pumpWidget(_buildGate(authService, progress));
    await tester.pumpAndSettle();

    expect(find.textContaining('Không thể kết nối mạng'), findsOneWidget);
    expect(find.text('Nội dung chính'), findsNothing);

    authService.shouldFailSignIn = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();

    expect(find.text('Nội dung chính'), findsOneWidget);
  });
}
