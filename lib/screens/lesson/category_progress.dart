import '../../data/mock/mock_learning_data.dart';
import '../../models/category.dart';
import '../../models/progress.dart';

class CategoryProgress {
  const CategoryProgress({required this.learned, required this.total});

  factory CategoryProgress.of(Category category, List<Progress> progressList) {
    final lessonIds = MockLearningData.lessons
        .where((lesson) => lesson.categoryId == category.id)
        .map((lesson) => lesson.id)
        .toSet();
    final wordIds = MockLearningData.vocabulary
        .where((word) => lessonIds.contains(word.lessonId))
        .map((word) => word.id)
        .toSet();
    final learned = progressList
        .where((p) => p.isLearned && wordIds.contains(p.vocabularyId))
        .length;
    return CategoryProgress(learned: learned, total: wordIds.length);
  }

  final int learned;
  final int total;

  double get ratio => total == 0 ? 0 : learned / total;

  bool get isComplete => total > 0 && learned >= total;
}

Category? findNextCategory(
  List<Category> categories,
  List<Progress> progressList,
) {
  for (final category in categories) {
    if (!CategoryProgress.of(category, progressList).isComplete) {
      return category;
    }
  }
  return null;
}
