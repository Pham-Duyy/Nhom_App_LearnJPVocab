import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../repositories/mock/mock_category_repository.dart';
import '../repositories/mock/mock_progress_repository.dart';
import '../repositories/mock/mock_vocabulary_repository.dart';
import 'lesson_provider.dart';
import 'progress_provider.dart';
import 'vocabulary_provider.dart';

/// Khởi tạo repository (hiện là bản mock) và các Provider dùng chung cho
/// toàn bộ ứng dụng. Mỗi repository chỉ được tạo một lần, không phụ thuộc
/// vào rebuild của widget.
class AppProviders extends StatelessWidget {
  const AppProviders({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LessonProvider(MockCategoryRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => VocabularyProvider(MockVocabularyRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(MockProgressRepository()),
        ),
      ],
      child: child,
    );
  }
}
