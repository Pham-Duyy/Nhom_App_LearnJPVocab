import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../auth/firebase_auth_service.dart';
import '../repositories/category_repository.dart';
import '../repositories/combined_repository.dart';
import '../repositories/firestore/firestore_category_repository.dart';
import '../repositories/firestore/firestore_progress_repository.dart';
import '../repositories/firestore/firestore_quiz_attempt_repository.dart';
import '../repositories/firestore/firestore_user_topic_repository.dart';
import '../repositories/firestore/firestore_user_word_repository.dart';
import '../repositories/firestore/firestore_user_profile_repository.dart';
import '../repositories/firestore/firestore_vocabulary_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/quiz_attempt_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../repositories/user_topic_repository.dart';
import '../repositories/user_word_repository.dart';
import '../repositories/vocabulary_repository.dart';
import '../services/music_player.dart';
import '../services/speaker.dart';
import 'exam_provider.dart';
import 'lesson_provider.dart';
import 'library_provider.dart';
import 'main_navigation_provider.dart';
import 'my_vocabulary_provider.dart';
import 'progress_provider.dart';
import 'quiz_provider.dart';
import 'sound_provider.dart';
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
    this.userTopicRepository,
    this.userWordRepository,
    this.speaker,
    this.musicPlayer,
  }) : super(key: key);

  final Widget child;
  final AuthService? authService;
  final CategoryRepository? categoryRepository;
  final VocabularyRepository? vocabularyRepository;
  final ProgressRepository? progressRepository;
  final UserProfileRepository? userProfileRepository;
  final QuizAttemptRepository? quizAttemptRepository;
  final UserTopicRepository? userTopicRepository;
  final UserWordRepository? userWordRepository;
  final Speaker? speaker;
  final MusicPlayer? musicPlayer;

  @override
  Widget build(BuildContext context) {
    final categories = categoryRepository ?? FirestoreCategoryRepository();
    final topics = userTopicRepository ?? FirestoreUserTopicRepository();
    final myWords = userWordRepository ?? FirestoreUserWordRepository();
    // Từ của app cộng từ người học tự thêm: mọi nơi dùng từ vựng (flashcard,
    // quiz, ôn tập, Sổ từ) đều thấy cả hai.
    final vocabulary = CombinedVocabularyRepository(
      shared: vocabularyRepository ?? FirestoreVocabularyRepository(),
      personal: myWords,
    );
    final attempts = quizAttemptRepository ?? FirestoreQuizAttemptRepository();

    return MultiProvider(
      providers: [
        Provider<Speaker>(
          create: (_) => speaker ?? TtsSpeaker(),
          dispose: (_, speaker) => speaker.stop(),
        ),
        ChangeNotifierProvider(
          create: (context) => SoundProvider(
            context.read<Speaker>(),
            musicPlayer ?? AssetMusicPlayer(),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(authService ?? FirebaseAuthService())
            ..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => MainNavigationProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(
            userProfileRepository ?? FirestoreUserProfileRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LessonProvider(categories),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(categories, vocabulary),
        ),
        ChangeNotifierProvider(create: (_) => VocabularyProvider(vocabulary)),
        ChangeNotifierProvider(
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
              attempts,
              vocabulary,
              onAnswer: (vocabularyId, isCorrect) => isCorrect
                  ? profile.recordStudyActivity()
                  : progress.markWrong(vocabularyId),
            );
          },
        ),
        ChangeNotifierProvider(
          // Bài thi lưu vào cùng lịch sử với quiz: lưu xong thì tải lại để
          // trang Lịch sử và Thành tích thấy lượt thi mới.
          create: (context) => ExamProvider(
            attempts,
            onSaved: context.read<QuizProvider>().loadHistory,
          ),
        ),
        ChangeNotifierProvider(
          // Từ tự thêm thay đổi thì Sổ từ tải lại để thấy từ mới.
          create: (context) => MyVocabularyProvider(
            topics,
            myWords,
            vocabulary,
            onWordsChanged: context.read<LibraryProvider>().load,
          ),
        ),
      ],
      child: child,
    );
  }
}
