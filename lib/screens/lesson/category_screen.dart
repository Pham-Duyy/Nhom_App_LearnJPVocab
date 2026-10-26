import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/choice_segments.dart';
import '../../widgets/tab_header.dart';
import '../common/generic_list_screen.dart';
import 'category_progress.dart';
import 'lesson_screen.dart';

Future<void> openCategory(BuildContext context, Category category) async {
  await context.read<LessonProvider>().selectCategory(category);
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const LessonScreen()),
  );
}

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

  @override
  Widget buildHeader(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<LessonProvider>();
    final topicCount = provider.categoriesForSelectedLevel.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TabHeader(
          label: 'HỌC TỪ VỰNG',
          title: 'Học mới',
          subtitle: 'Chọn cấp độ và chủ đề để bắt đầu.',
        ),
        const SizedBox(height: 24),
        ChoiceSegments<String>(
          options: LessonProvider.jlptLevels,
          selected: provider.selectedLevel,
          onChanged: provider.selectLevel,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Chủ đề ${provider.selectedLevel}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$topicCount chủ đề',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
  Widget buildSeparator(BuildContext context) => const Divider();

  @override
  Widget buildItem(BuildContext context, Category item) {
    final palette = context.palette;
    final progressList = context.watch<ProgressProvider>().progressList;
    final library = context.watch<LibraryProvider>();
    final categories = getItems(context);
    final progress = CategoryProgress.of(item, progressList, library);
    final isNext =
        findNextCategory(categories, progressList, library)?.id == item.id;
    final paletteIndex =
        categories.indexOf(item) % palette.topicBackgrounds.length;

    return InkWell(
      onTap: () => onItemTap(context, item),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: palette.topicBackgrounds[paletteIndex],
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                _topicKanji[item.id] ?? item.name.characters.first,
                style: AppTextStyles.japaneseDisplay.copyWith(
                  fontSize: 26,
                  color: palette.topicForegrounds[paletteIndex],
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(item.description, style: palette.body),
                  const SizedBox(height: 14),
                  AnimatedProgressBar(
                    value: progress.ratio,
                    color: palette.primarySoft,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${progress.learned} / ${progress.total} từ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        progress.isComplete
                            ? 'Ôn lại →'
                            : isNext
                                ? 'Tiếp tục học →'
                                : 'Khám phá →',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isNext ? palette.primary : palette.textSecondary,
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
    );
  }
}
