import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/vocabulary.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/pill_choices.dart';
import '../common/generic_list_screen.dart';
import '../my_vocabulary/my_vocabulary_screen.dart';
import '../my_vocabulary/topic_actions.dart';
import 'category_progress.dart';
import 'lesson_screen.dart';

Future<void> openCategory(BuildContext context, Category category) async {
  await context.read<LessonProvider>().selectCategory(category);
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const LessonScreen()),
  );
}

/// Tab Học mới: chọn cấp độ rồi chọn chủ đề. Mục "Của tôi" hiện các chủ đề
/// tự tạo trong Kho từ, học được như chủ đề có sẵn.
class CategoryScreen extends GenericListScreen<Category> {
  const CategoryScreen({Key? key}) : super(key: key);

  /// Chữ Hán đại diện cho từng chủ đề; chủ đề mới chưa có thì lấy chữ đầu
  /// của tên.
  static const _topicKanji = {
    'cat_greetings': '話',
    'cat_family': '家',
    'cat_school': '学',
    'cat_food': '食',
    'cat_time': '時',
    'cat_shopping': '買',
    'cat_places': '駅',
    'cat_home': '部',
    'cat_nature': '山',
    'cat_ind_food': '製',
    'cat_ind_build': '建',
    'cat_ind_care': '介',
  };

  @override
  String getTitle(BuildContext context) => 'Học mới';

  @override
  bool get showAppBar => false;

  @override
  List<Category> getItems(BuildContext context) =>
      context.watch<LessonProvider>().categoriesForSelectedLevel;

  @override
  bool isLoading(BuildContext context) =>
      context.watch<LessonProvider>().isLoading;

  @override
  String? getErrorMessage(BuildContext context) =>
      context.watch<LessonProvider>().errorMessage;

  @override
  String get emptyMessage => 'Chủ đề ở cấp độ này đang được biên soạn.';

  @override
  void onRetry(BuildContext context) {
    context.read<LessonProvider>().loadCategories();
  }

  @override
  Future<void> onItemTap(BuildContext context, Category item) =>
      openCategory(context, item);

  bool _isPersonal(BuildContext context) =>
      context.watch<LessonProvider>().selectedLevel == Vocabulary.personalLevel;

  @override
  Widget buildHeader(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<LessonProvider>();
    final topicCount = _isPersonal(context)
        ? context.watch<MyVocabularyProvider>().topics.length
        : provider.categoriesForSelectedLevel.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Học mới', style: AppTextStyles.pageTitle),
        const SizedBox(height: 18),
        PillChoices<String>(
          options: LessonProvider.levels,
          selected: provider.selectedLevel,
          onChanged: provider.selectLevel,
        ),
        const SizedBox(height: 14),
        Text('$topicCount chủ đề', style: palette.body),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget buildEmptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ChibiMascot(size: 120, mood: ChibiMood.sleepy),
        const SizedBox(height: 16),
        Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: context.palette.body,
        ),
      ],
    );
  }

  @override
  Widget buildSeparator(BuildContext context) => const SizedBox(height: 10);

  /// Mục "Của tôi": các chủ đề tự tạo trong Kho từ.
  @override
  Widget buildBody(BuildContext context) {
    if (!_isPersonal(context)) return super.buildBody(context);
    final palette = context.palette;
    final myVocabulary = context.watch<MyVocabularyProvider>();
    final learnedIds = {
      for (final p in context.watch<ProgressProvider>().progressList)
        if (p.isLearned) p.vocabularyId,
    };
    void openStore() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyVocabularyScreen()),
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        buildHeader(context),
        if (myVocabulary.topics.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  'Bạn chưa có chủ đề riêng. Tạo chủ đề hoặc import file từ '
                  'vựng trong Kho từ.',
                  textAlign: TextAlign.center,
                  style: palette.body,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: openStore,
                  child: const Text('Mở Kho từ'),
                ),
              ],
            ),
          )
        else ...[
          for (final (i, topic) in myVocabulary.topics.indexed) ...[
            if (i > 0) buildSeparator(context),
            _TopicRow(
              symbol: topic.name.characters.first.toUpperCase(),
              name: topic.name,
              learned: myVocabulary
                  .wordsOf(topic)
                  .where((w) => learnedIds.contains(w.id))
                  .length,
              total: topic.wordCount,
              colorIndex: i % palette.topicBackgrounds.length,
              onTap: () => studyTopic(context, topic),
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: openStore,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Quản lý trong Kho từ'),
          ),
        ],
      ],
    );
  }

  @override
  Widget buildItem(BuildContext context, Category item) {
    final palette = context.palette;
    final progressList = context.watch<ProgressProvider>().progressList;
    final library = context.watch<LibraryProvider>();
    final categories = getItems(context);
    final progress = CategoryProgress.of(item, progressList, library);
    final isNext =
        findNextCategory(categories, progressList, library)?.id == item.id;

    return _TopicRow(
      symbol: _topicKanji[item.id] ?? item.name.characters.first,
      name: item.name,
      learned: progress.learned,
      total: progress.total,
      colorIndex: categories.indexOf(item) % palette.topicBackgrounds.length,
      highlight: isNext && progress.learned > 0,
      onTap: () => onItemTap(context, item),
    );
  }
}

/// Một chủ đề trên một thẻ gọn: chữ đại diện, tên, thanh tiến độ mảnh và số
/// từ đã học. [highlight] đánh dấu chủ đề đang học dở.
class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.symbol,
    required this.name,
    required this.learned,
    required this.total,
    required this.colorIndex,
    required this.onTap,
    this.highlight = false,
  });

  final String symbol;
  final String name;
  final int learned;
  final int total;
  final int colorIndex;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: highlight ? palette.primary : palette.cardBorder,
          width: highlight ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.topicBackgrounds[colorIndex],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  symbol,
                  style: AppTextStyles.japaneseDisplay.copyWith(
                    fontSize: 22,
                    color: palette.topicForegrounds[colorIndex],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        if (highlight)
                          Text(
                            'Tiếp tục',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: palette.primary,
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            color: palette.textMuted,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedProgressBar(
                            value: total == 0 ? 0 : learned / total,
                            color: palette.primarySoft,
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$learned/$total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: palette.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
