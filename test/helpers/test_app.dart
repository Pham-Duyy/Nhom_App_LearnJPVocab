import 'package:chibakanji/app.dart';
import 'package:chibakanji/auth/app_auth_user.dart';
import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/providers/app_providers.dart';
import 'package:chibakanji/repositories/mock/mock_category_repository.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_service.dart';

/// Toàn bộ ứng dụng chạy trên dữ liệu mock và một người dùng ẩn danh giả,
/// không cần Firebase.
Widget buildTestApp({
  bool showWelcome = false,
  FakeAuthService? authService,
  MockUserProfileRepository? userProfileRepository,
}) {
  return AppProviders(
    authService: authService ??
        FakeAuthService(
          currentUser: const AppAuthUser(uid: 'test-user', isAnonymous: true),
        ),
    categoryRepository: MockCategoryRepository(),
    vocabularyRepository: MockVocabularyRepository(),
    progressRepository: MockProgressRepository(
      initialProgress: MockLearningData.createInitialProgress(),
    ),
    userProfileRepository: userProfileRepository ??
        MockUserProfileRepository(
          initialProfile: const UserProfile(displayName: 'Duy'),
        ),
    quizAttemptRepository: MockQuizAttemptRepository(),
    child: ChibaKanjiApp(showWelcome: showWelcome),
  );
}

/// Dựng ứng dụng và chờ qua bước đăng nhập + tải tiến độ.
Future<void> pumpTestApp(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();
}
