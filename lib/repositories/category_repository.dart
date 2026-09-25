import '../models/category.dart';
import '../models/lesson.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();

  Future<List<Lesson>> getLessonsByCategory(String categoryId);

  Future<Lesson?> getLessonById(String lessonId);
}
