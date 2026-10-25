import '../../data/mock/mock_learning_data.dart';
import '../../models/category.dart';
import '../../models/lesson.dart';
import '../category_repository.dart';
import '../repository.dart';

/// Chủ đề và bài học mẫu trong bộ nhớ, dùng cho test và chạy không cần
/// Firebase.
class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async =>
      sortByOrder(MockLearningData.categories.toList());

  @override
  Future<List<Lesson>> getLessonsByCategory(String categoryId) async =>
      sortByOrder(MockLearningData.lessons
          .where((lesson) => lesson.categoryId == categoryId)
          .toList());
}
