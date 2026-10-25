import 'package:chibakanji/auth/auth_controller.dart';
import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/providers/lesson_provider.dart';
import 'package:chibakanji/providers/library_provider.dart';
import 'package:chibakanji/providers/progress_provider.dart';
import 'package:chibakanji/providers/user_profile_provider.dart';
import 'package:chibakanji/repositories/mock/mock_category_repository.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:chibakanji/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_auth_service.dart';

Widget _buildGate(
  FakeAuthService authService,
  ProgressProvider progress, [
  LessonProvider? lessons,
]) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthController(authService)..initialize(),
      ),
      ChangeNotifierProvider.value(
        value: lessons ?? LessonProvider(MockCategoryRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => UserProfileProvider(MockUserProfileRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => LibraryProvider(
          MockCategoryRepository(),
          MockVocabularyRepository(),
        ),
      ),
      ChangeNotifierProvider.value(value: progress),
    ],
    child: const MaterialApp(
      home: AuthGate(child: Text('Nội dung chính')),
    ),
  );
}

void main() {
  testWidgets(
      'US02: đăng nhập ẩn danh xong thì hiện nội dung, tải chủ đề và tiến độ',
      (tester) async {
    final authService = FakeAuthService();
    final progress = ProgressProvider(MockProgressRepository(
      initialProgress: const [Progress(vocabularyId: 'v1', isLearned: true)],
    ));
    final lessons = LessonProvider(MockCategoryRepository());

    await tester.pumpWidget(_buildGate(authService, progress, lessons));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(lessons.categories, isEmpty);

    await tester.pumpAndSettle();

    expect(find.text('Nội dung chính'), findsOneWidget);
    expect(authService.signInCallCount, 1);
    expect(progress.totalLearned, 1);
    expect(lessons.categories, isNotEmpty);
  });

  testWidgets('8a: đăng nhập lỗi thì hiện thông báo, bấm Thử lại để vào app', (
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
