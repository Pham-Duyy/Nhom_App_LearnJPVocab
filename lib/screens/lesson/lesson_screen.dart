import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/entity_card.dart';
import '../base/generic_list_screen.dart';
import '../flashcard/flashcard_screen.dart';

/// Danh sách bài học thuộc chủ đề đã chọn ở CategoryScreen. Dữ liệu do
/// LessonProvider.selectCategory() tải sẵn trước khi màn hình này được mở.
/// Kế thừa bố cục chung [GenericListScreen] với T = Lesson.
class LessonScreen extends GenericListScreen<Lesson> {
  const LessonScreen({Key? key}) : super(key: key);

  @override
  String? appBarTitle(BuildContext context) =>
      context.watch<LessonProvider>().selectedCategory?.name ?? 'Bài học';

  @override
  bool isLoading(BuildContext context) =>
      context.watch<LessonProvider>().isLoading;

  @override
  String? errorMessage(BuildContext context) =>
      context.watch<LessonProvider>().errorMessage;

  @override
  List<Lesson> items(BuildContext context) =>
      context.watch<LessonProvider>().lessons;

  @override
  void onRetry(BuildContext context) {
    final provider = context.read<LessonProvider>();
    final category = provider.selectedCategory;
    if (category != null) provider.selectCategory(category);
  }

  @override
  String get emptyMessage => 'Chủ đề này chưa có bài học nào.';

  @override
  Widget buildItem(BuildContext context, Lesson item) {
    return EntityCard(
      entity: item,
      subtitle:
          '${item.description}\n${item.vocabularyCount} từ · ${item.jlptLevel}',
      isThreeLine: true,
      onTap: () => _openLesson(context, item),
    );
  }

  Future<void> _openLesson(BuildContext context, Lesson lesson) async {
    context.read<LessonProvider>().selectLesson(lesson);
    final vocabularyProvider = context.read<VocabularyProvider>();
    await vocabularyProvider.loadByLesson(lesson.id);
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
          title: lesson.title,
          completionTitle: 'Hoàn thành bài học!',
        ),
      ),
    );
  }
}
