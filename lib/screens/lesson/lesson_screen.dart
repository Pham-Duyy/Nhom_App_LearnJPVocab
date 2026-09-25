import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_card.dart';
import '../flashcard/flashcard_screen.dart';

/// Danh sách bài học thuộc chủ đề đã chọn ở [CategoryScreen]. Dữ liệu do
/// LessonProvider.selectCategory() tải sẵn trước khi màn hình này được mở.
class LessonScreen extends StatelessWidget {
  const LessonScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonProvider>();
    final category = provider.selectedCategory;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        title: Text(category?.name ?? 'Bài học'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(LessonProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final category = provider.selectedCategory;
                if (category != null) provider.selectCategory(category);
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (provider.lessons.isEmpty) {
      return const Center(child: Text('Chủ đề này chưa có bài học nào.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: provider.lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lesson = provider.lessons[index];
        return _LessonCard(
          lesson: lesson,
          onTap: () => _openLesson(context, lesson),
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({Key? key, required this.lesson, required this.onTap})
      : super(key: key);

  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(lesson.title, style: AppTextStyles.cardTitle),
        subtitle: Text(
          '${lesson.description}\n${lesson.vocabularyCount} từ · ${lesson.jlptLevel}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}
