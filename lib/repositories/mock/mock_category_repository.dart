import '../../data/mock/mock_learning_data.dart';
import '../../models/category.dart';
import '../../models/lesson.dart';
import '../category_repository.dart';

/// Đọc category/lesson từ dữ liệu mock trong bộ nhớ. Sẽ được thay bằng một
/// implementation đọc Cloud Firestore ở giai đoạn sau, giữ nguyên interface.
class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async {
    final result = MockLearningData.categories.toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  @override
  Future<List<Lesson>> getLessonsByCategory(String categoryId) async {
    final result = MockLearningData.lessons
        .where((lesson) => lesson.categoryId == categoryId)
        .toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    for (final lesson in MockLearningData.lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }
}
