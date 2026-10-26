import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../common/generic_screen.dart';
import 'topic_detail_screen.dart';
import 'topic_form_screen.dart';

/// Quản lý chủ đề: danh sách chủ đề tự tạo, chạm để xem và học.
class MyTopicsScreen extends GenericScreen {
  const MyTopicsScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Chủ đề của tôi';

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final topics = context.watch<MyVocabularyProvider>().topics;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        OutlinedButton.icon(
          onPressed: () => _open(context, const TopicFormScreen()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tạo chủ đề mới'),
        ),
        const SizedBox(height: 16),
        if (topics.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'Chưa có chủ đề nào. Tạo chủ đề để gom các từ bạn muốn học.',
              textAlign: TextAlign.center,
              style: palette.body,
            ),
          ),
        for (final topic in topics)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            color: palette.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: palette.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () => _open(context, TopicDetailScreen(topicId: topic.id)),
              leading: CircleAvatar(
                backgroundColor: palette.accentSurface,
                child: Text(
                  topic.name.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: palette.primary,
                  ),
                ),
              ),
              title: Text(topic.name, style: AppTextStyles.cardTitle),
              subtitle: Text(
                topic.description.isEmpty
                    ? '${topic.wordCount} từ'
                    : '${topic.wordCount} từ · ${topic.description}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: palette.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
