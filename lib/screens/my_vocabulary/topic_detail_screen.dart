import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_topic.dart';
import '../../models/vocabulary.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../quiz/quiz_screen.dart';
import '../vocabulary/vocabulary_detail_screen.dart';
import 'add_to_topic_screen.dart';
import 'topic_form_screen.dart';
import 'word_form_screen.dart';
import 'word_tile.dart';

/// Một chủ đề tự tạo: học bằng flashcard hoặc quiz, thêm/bỏ từ, sửa hoặc
/// xóa chủ đề.
class TopicDetailScreen extends GenericScreen {
  const TopicDetailScreen({Key? key, required this.topicId}) : super(key: key);

  final String topicId;

  @override
  String getTitle(BuildContext context) =>
      context.watch<MyVocabularyProvider>().topicById(topicId)?.name ??
      'Chủ đề';

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _study(
    BuildContext context,
    UserTopic topic,
    List<Vocabulary> words,
  ) async {
    await context.read<VocabularyProvider>().loadWords(words);
    if (!context.mounted) return;
    _open(
      context,
      FlashcardScreen(
        title: topic.name,
        completionTitle: 'Đã học xong "${topic.name}"!',
      ),
    );
  }

  Future<void> _delete(BuildContext context, UserTopic topic) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Xóa chủ đề "${topic.name}"?',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Các từ vẫn còn trong kho, chỉ chủ đề bị xóa.',
                style: sheetContext.palette.body,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Giữ lại'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Xóa chủ đề'),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error =
        await context.read<MyVocabularyProvider>().deleteTopic(topic.id);
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<MyVocabularyProvider>();
    final topic = provider.topicById(topicId);
    if (topic == null) return const SizedBox.shrink();
    final words = provider.wordsOf(topic);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        if (topic.description.isNotEmpty) ...[
          Text(topic.description, style: palette.body),
          const SizedBox(height: 12),
        ],
        Text('${words.length} từ', style: palette.sectionLabel),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    words.isEmpty ? null : () => _study(context, topic, words),
                child: const Text('Học'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: words.isEmpty
                    ? null
                    : () => openQuiz(
                          context,
                          quizId: 'topic-${topic.id}',
                          title: topic.name,
                          words: words,
                        ),
                child: const Text('Quiz'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: () =>
                  _open(context, WordFormScreen(topicId: topic.id)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Từ mới'),
            ),
            TextButton.icon(
              onPressed: () =>
                  _open(context, AddToTopicScreen(topicId: topic.id)),
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Từ có sẵn'),
            ),
            TextButton.icon(
              onPressed: () => _open(context, TopicFormScreen(topic: topic)),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Sửa'),
            ),
            TextButton.icon(
              onPressed: () => _delete(context, topic),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Xóa'),
              style: TextButton.styleFrom(foregroundColor: palette.danger),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (words.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              'Chủ đề chưa có từ nào. Thêm từ mới hoặc chọn từ có sẵn.',
              textAlign: TextAlign.center,
              style: palette.body,
            ),
          ),
        for (final word in words)
          WordTile(
            word: word,
            onTap: () => _open(context, VocabularyDetailScreen(word: word)),
            trailing: IconButton(
              tooltip: 'Bỏ khỏi chủ đề',
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: () => provider.removeWordFromTopic(topic.id, word.id),
            ),
          ),
      ],
    );
  }
}
