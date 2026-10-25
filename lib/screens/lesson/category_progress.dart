import '../../models/category.dart';
import '../../models/progress.dart';
import '../../providers/library_provider.dart';

/// Số từ đã học trên tổng số từ của một chủ đề.
class CategoryProgress {
  const CategoryProgress({required this.learned, required this.total});

  factory CategoryProgress.of(
    Category category,
    List<Progress> progressList,
    LibraryProvider library,
  ) {
    final wordIds = library.wordIdsOf(category.id);
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

/// Chủ đề đầu tiên chưa học xong, để gợi ý "Học tiếp".
Category? findNextCategory(
  List<Category> categories,
  List<Progress> progressList,
  LibraryProvider library,
) {
  for (final category in categories) {
    if (!CategoryProgress.of(category, progressList, library).isComplete) {
      return category;
    }
  }
  return null;
}
