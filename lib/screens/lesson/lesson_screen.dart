import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../common/generic_list_screen.dart';
import '../flashcard/flashcard_screen.dart';

/// Danh sách bài học thuộc chủ đề đã chọn ở [CategoryScreen]. Dữ liệu do
/// LessonProvider.selectCategory() tải sẵn trước khi màn hình này được mở.
class LessonScreen extends GenericListScreen<Lesson> {
  const LessonScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) =>
      context.watch<LessonProvider>().selectedCategory?.name ?? 'Bài học';

  @override
  List<Lesson> getItems(BuildContext context) =>
      context.watch<LessonProvider>().lessons;

  @override
  bool isLoading(BuildContext context) =>
      context.watch<LessonProvider>().isLoading;

  @override
  String? getErrorMessage(BuildContext context) =>
      context.watch<LessonProvider>().errorMessage;

  @override
  String get emptyMessage => 'Chủ đề này chưa có bài học nào.';

  @override
  String getSubtitle(Lesson item) =>
      '${item.description}\n${item.vocabularyCount} từ · ${item.jlptLevel}';

  @override
  void onRetry(BuildContext context) {
    final provider = context.read<LessonProvider>();
    final category = provider.selectedCategory;
    if (category != null) provider.selectCategory(category);
  }

  @override
  Future<void> onItemTap(BuildContext context, Lesson item) async {
    context.read<LessonProvider>().selectLesson(item);
    final vocabularyProvider = context.read<VocabularyProvider>();
    await vocabularyProvider.loadByLesson(item.id);
    if (!context.mounted) return;

    // Tải thất bại thì ở lại danh sách bài học thay vì mở flashcard rỗng/lỗi.
    if (vocabularyProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vocabularyProvider.errorMessage!)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          title: item.title,
          completionTitle: 'Hoàn thành bài học!',
        ),
      ),
    );
  }
}
