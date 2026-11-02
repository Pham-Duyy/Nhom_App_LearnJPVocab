import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_topic.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../common/generic_screen.dart';
import 'all_words_screen.dart';
import 'import_words_screen.dart';
import 'topic_actions.dart';
import 'topic_detail_screen.dart';
import 'word_form_screen.dart';

/// Kho từ của tôi: ba thao tác nhanh ở trên, bên dưới là các chủ đề tự tạo,
/// học ngay được bằng nút "Học" trên từng chủ đề.
class MyVocabularyScreen extends GenericScreen {
  const MyVocabularyScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Kho từ của tôi';

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<MyVocabularyProvider>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(
          '${provider.myWords.length} từ tự thêm · '
          '${provider.topics.length} chủ đề',
          style: palette.body,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.add_rounded,
                label: 'Từ mới',
                onTap: () => _open(context, const WordFormScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.upload_file_rounded,
                label: 'Import',
                onTap: () => _open(context, const ImportWordsScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.list_alt_rounded,
                label: 'Tất cả từ',
                onTap: () => _open(context, const AllWordsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('CHỦ ĐỀ CỦA TÔI', style: palette.sectionLabel),
        const SizedBox(height: 10),
        for (final topic in provider.topics)
          _TopicCard(
            topic: topic,
            onOpen: () => _open(context, TopicDetailScreen(topicId: topic.id)),
            onStudy: () => studyTopic(context, topic),
          ),
        _NewTopicCard(onTap: () => showCreateTopicSheet(context)),
      ],
    );
  }
}

/// Một nút thao tác nhanh: biểu tượng ở trên, chữ ở dưới.
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.accentSurface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: palette.primary),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: palette.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một chủ đề: bấm vào thẻ để xem và sửa, bấm "Học" để học ngay.
class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.onOpen,
    required this.onStudy,
  });

  final UserTopic topic;
  final VoidCallback onOpen;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
        title: Text(topic.name, style: AppTextStyles.cardTitle),
        subtitle: Text('${topic.wordCount} từ'),
        trailing: FilledButton.tonalIcon(
          onPressed: topic.wordCount == 0 ? null : onStudy,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Học'),
        ),
      ),
    );
  }
}

/// Ô cuối danh sách để tạo chủ đề mới.
class _NewTopicCard extends StatelessWidget {
  const _NewTopicCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tạo chủ đề mới'),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: palette.accentBorder, width: 1.5),
      ),
    );
  }
}
