import 'package:chibakanji/models/category.dart';
import 'package:chibakanji/models/lesson.dart';
import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/models/quiz_attempt.dart';
import 'package:chibakanji/models/vocabulary.dart';
import 'package:chibakanji/repositories/mock/mock_category_repository.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:firebase_core/firebase_core.dart';

/// Lỗi Firestore khi mất mạng, giống hệt lỗi thật mà SDK ném ra.
final offlineError = FirebaseException(
  plugin: 'cloud_firestore',
  code: 'unavailable',
  message: 'The service is currently unavailable. token=abc123',
);

/// Các repository mock có thể bật lỗi: gán [failure] khác null thì mọi lần
/// gọi đều ném lỗi đó; gán lại null để giả lập mạng đã có lại.
class FlakyCategoryRepository extends MockCategoryRepository {
  Object? failure;

  @override
  Future<List<Category>> getCategories() async {
    if (failure != null) throw failure!;
    return super.getCategories();
  }

  @override
  Future<List<Lesson>> getLessonsByCategory(String categoryId) async {
    if (failure != null) throw failure!;
    return super.getLessonsByCategory(categoryId);
  }
}

class FlakyProgressRepository extends MockProgressRepository {
  FlakyProgressRepository({super.initialProgress});

  Object? failure;

  @override
  Future<List<Progress>> getAll() async {
    if (failure != null) throw failure!;
    return super.getAll();
  }

  @override
  Future<void> save(Progress item) async {
    if (failure != null) throw failure!;
    return super.save(item);
  }
}

class FlakyVocabularyRepository extends MockVocabularyRepository {
  Object? failure;

  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) async {
    if (failure != null) throw failure!;
    return super.getByLesson(lessonId);
  }
}

class FlakyQuizAttemptRepository extends MockQuizAttemptRepository {
  Object? failure;

  @override
  Future<void> save(QuizAttempt item) async {
    if (failure != null) throw failure!;
    return super.save(item);
  }
}
