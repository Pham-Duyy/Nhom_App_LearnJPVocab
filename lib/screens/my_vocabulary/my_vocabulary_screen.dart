import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/hanko_stamp.dart';
import '../common/generic_screen.dart';
import 'add_to_topic_screen.dart';
import 'all_words_screen.dart';
import 'import_words_screen.dart';
import 'my_topics_screen.dart';
import 'topic_form_screen.dart';
import 'word_form_screen.dart';

/// Một mục trong danh sách chức năng của Kho từ.
typedef _MenuEntry = ({
  String kanji,
  String title,
  String subtitle,
  Widget page,
});

/// Kho từ của tôi: người học tự tạo chủ đề, thêm và import từ vựng để học.
class MyVocabularyScreen extends GenericScreen {
  const MyVocabularyScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Kho từ của tôi';

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<MyVocabularyProvider>();
    final entries = <_MenuEntry>[
      (
        kanji: '覧',
        title: 'Xem tất cả từ vựng',
        subtitle: '${provider.allWords.length} từ, trong đó '
            '${provider.myWords.length} từ bạn tự thêm',
        page: const AllWordsScreen(),
      ),
      (
        kanji: '類',
        title: 'Quản lý chủ đề',
        subtitle: '${provider.topics.length} chủ đề của bạn',
        page: const MyTopicsScreen(),
      ),
      (
        kanji: '作',
        title: 'Tạo chủ đề',
        subtitle: 'Gom các từ muốn học vào một chủ đề',
        page: const TopicFormScreen(),
      ),
      (
        kanji: '新',
        title: 'Thêm từ vựng mới',
        subtitle: 'Nhập chữ Hán, kana, nghĩa và câu ví dụ',
        page: const WordFormScreen(),
      ),
      (
        kanji: '加',
        title: 'Thêm từ vào chủ đề',
        subtitle: 'Chọn từ có sẵn cho chủ đề của bạn',
        page: const AddToTopicScreen(),
      ),
      (
        kanji: '入',
        title: 'Import từ vựng',
        subtitle: 'Dán danh sách từ Excel hoặc Google Sheets',
        page: const ImportWordsScreen(),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Row(
          children: [
            const HankoStamp(text: '蔵', size: 58),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Tự thêm từ và chủ đề của riêng bạn, rồi học bằng flashcard '
                'và quiz như các bài có sẵn.',
                style: palette.body,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final entry in entries)
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
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => entry.page),
              ),
              leading: CircleAvatar(
                backgroundColor: palette.accentSurface,
                child: Text(
                  entry.kanji,
                  style: AppTextStyles.japaneseDisplay.copyWith(
                    fontSize: 20,
                    color: palette.primary,
                  ),
                ),
              ),
              title: Text(entry.title, style: AppTextStyles.cardTitle),
              subtitle: Text(entry.subtitle),
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
