import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../auth/firebase_auth_service.dart';
import '../repositories/category_repository.dart';
import '../repositories/firestore/firestore_category_repository.dart';
import '../repositories/firestore/firestore_progress_repository.dart';
import '../repositories/firestore/firestore_quiz_attempt_repository.dart';
import '../repositories/firestore/firestore_user_profile_repository.dart';
import '../repositories/firestore/firestore_vocabulary_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/quiz_attempt_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../repositories/vocabulary_repository.dart';
import 'lesson_provider.dart';
import 'library_provider.dart';
import 'main_navigation_provider.dart';
import 'progress_provider.dart';
import 'quiz_provider.dart';
import 'user_profile_provider.dart';
import 'vocabulary_provider.dart';

/// Khởi tạo xác thực, repository và các Provider dùng chung cho toàn bộ
/// ứng dụng. Mặc định dùng Firebase (Auth + Firestore); test truyền bản mock
/// qua constructor để không cần mạng.
class AppProviders extends StatelessWidget {
  const AppProviders({
    Key? key,
    required this.child,
    this.authService,
    this.categoryRepository,
    this.vocabularyRepository,
    this.progressRepository,
    this.userProfileRepository,
    this.quizAttemptRepository,
  }) : super(key: key);

  final Widget child;
  final AuthService? authService;
  final CategoryRepository? categoryRepository;
  final VocabularyRepository? vocabularyRepository;
  final ProgressRepository? progressRepository;
  final UserProfileRepository? userProfileRepository;
  final QuizAttemptRepository? quizAttemptRepository;

  @override
  Widget build(BuildContext context) {
    // Dùng chung một repository cho các provider cùng đọc một loại dữ liệu.
    final categories = categoryRepository ?? FirestoreCategoryRepository();
    final vocabulary = vocabularyRepository ?? FirestoreVocabularyRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // initialize() an toàn khi gọi ở đây vì chưa có widget nào lắng
          // nghe, nên notifyListeners() bên trong không chạm vào build nào.
          create: (_) => AuthController(authService ?? FirebaseAuthService())
            ..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => MainNavigationProvider()),
        ChangeNotifierProvider(
          // Không tải ngay: hồ sơ nằm ở users/{uid}, nên AuthGate gọi load()
          // sau khi đã có người dùng.
          create: (_) => UserProfileProvider(
            userProfileRepository ?? FirestoreUserProfileRepository(),
          ),
        ),
        ChangeNotifierProvider(
          // Không tải ngay: Firestore chỉ cho đọc chủ đề khi đã đăng nhập,
          // nên AuthGate gọi loadCategories() sau khi đã có người dùng.
          create: (_) => LessonProvider(categories),
        ),
        // Không tải ngay, cùng lý do với LessonProvider.
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(categories, vocabulary),
        ),
        ChangeNotifierProvider(create: (_) => VocabularyProvider(vocabulary)),
        ChangeNotifierProvider(
          // Không tải ngay: tiến độ nằm dưới users/{uid}, nên AuthGate gọi
          // loadProgress() sau khi đã có người dùng. Mỗi lần trả lời một thẻ
          // được tính là một ngày học trong chuỗi ngày liên tiếp.
          create: (context) => ProgressProvider(
            progressRepository ?? FirestoreProgressRepository(),
            onStudyActivity:
                context.read<UserProfileProvider>().recordStudyActivity,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final progress = context.read<ProgressProvider>();
            final profile = context.read<UserProfileProvider>();
            return QuizProvider(
              quizAttemptRepository ?? FirestoreQuizAttemptRepository(),
              vocabulary,
              // Sai thì đưa từ về mức 1 để ôn lại; đúng thì vẫn tính là một
              // ngày học trong chuỗi ngày liên tiếp.
              onAnswer: (vocabularyId, isCorrect) => isCorrect
                  ? profile.recordStudyActivity()
                  : progress.markWrong(vocabularyId),
            );
          },
        ),
      ],
      child: child,
    );
  }
}
