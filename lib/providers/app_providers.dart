import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../auth/firebase_auth_service.dart';
import '../repositories/category_repository.dart';
import '../repositories/firestore/firestore_category_repository.dart';
import '../repositories/firestore/firestore_progress_repository.dart';
import '../repositories/firestore/firestore_vocabulary_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/vocabulary_repository.dart';
import 'app_settings_provider.dart';
import 'lesson_provider.dart';
import 'main_navigation_provider.dart';
import 'progress_provider.dart';
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
  }) : super(key: key);

  final Widget child;
  final AuthService? authService;
  final CategoryRepository? categoryRepository;
  final VocabularyRepository? vocabularyRepository;
  final ProgressRepository? progressRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(
          // initialize() an toàn khi gọi ở đây vì chưa có widget nào lắng
          // nghe, nên notifyListeners() bên trong không chạm vào build nào.
          create: (_) => AuthController(authService ?? FirebaseAuthService())
            ..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => MainNavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(
          // Không tải ngay: Firestore chỉ cho đọc chủ đề khi đã đăng nhập,
          // nên AuthGate gọi loadCategories() sau khi đã có người dùng.
          create: (_) => LessonProvider(
            categoryRepository ?? FirestoreCategoryRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VocabularyProvider(
            vocabularyRepository ?? FirestoreVocabularyRepository(),
          ),
        ),
        ChangeNotifierProvider(
          // Không tải ngay: tiến độ nằm dưới users/{uid}, nên AuthGate gọi
          // loadProgress() sau khi đã có người dùng.
          create: (_) => ProgressProvider(
            progressRepository ?? FirestoreProgressRepository(),
          ),
        ),
      ],
      child: child,
    );
  }
}
