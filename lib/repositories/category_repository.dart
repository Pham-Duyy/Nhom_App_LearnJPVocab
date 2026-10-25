import '../models/category.dart';
import '../models/lesson.dart';

abstract class CategoryRepository {
  /// Các chủ đề, theo thứ tự hiển thị.
  Future<List<Category>> getCategories();

  /// Các bài học của một chủ đề, theo thứ tự trong chủ đề.
  Future<List<Lesson>> getLessonsByCategory(String categoryId);
}
