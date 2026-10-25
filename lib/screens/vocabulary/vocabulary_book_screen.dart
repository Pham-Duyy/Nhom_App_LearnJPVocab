import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock/mock_learning_data.dart';
import '../../models/progress.dart';
import '../../models/vocabulary.dart';
import '../../providers/main_navigation_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/memory_level_chip.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/tab_header.dart';
import '../common/generic_screen.dart';
import 'vocabulary_detail_screen.dart';

enum _WordFilter { all, due, favorite }

class VocabularyBookScreen extends StatefulWidget {
  const VocabularyBookScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyBookScreen> createState() => _VocabularyBookScreenState();
}

class _VocabularyBookScreenState
    extends GenericScreenState<VocabularyBookScreen> {
  final _searchController = TextEditingController();
  _WordFilter _filter = _WordFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) => 'Sổ từ';

  @override
  bool get showAppBar => false;

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final progressProvider = context.watch<ProgressProvider>();
    final progressById = {
      for (final progress in progressProvider.progressList)
        progress.vocabularyId: progress,
    };
    final learnedWords = MockLearningData.vocabulary
        .where((word) => progressById[word.id]?.isLearned == true)
        .where(_matchesSearch)
        .where((word) => _matchesFilter(progressById[word.id]!))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            16,
            AppSpacing.page,
            20,
          ),
          child: TabHeader(
            label: 'TỪ CỦA BẠN',
            title: 'Sổ từ',
            subtitle: '${progressProvider.totalLearned} từ đã học · '
                'Tìm kiếm và lưu yêu thích',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tìm kanji, kana hoặc nghĩa...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xoá tìm kiếm',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              fillColor: palette.mutedSurface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: palette.divider),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildFilters(palette, progressProvider.getDueForReview().length),
        const SizedBox(height: 8),
        Expanded(
          child: progressProvider.isLoading
              ? const SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: SkeletonList(itemCount: 4),
                )
              : learnedWords.isEmpty
                  ? _buildEmptyState(
                      palette,
                      progressProvider.totalLearned == 0,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        24,
                      ),
                      itemCount: learnedWords.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final word = learnedWords[index];
                        return _VocabularyTile(
                          word: word,
                          progress: progressById[word.id]!,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilters(AppPalette palette, int dueCount) {
    final labels = {
      _WordFilter.all: 'Tất cả',
      _WordFilter.due: 'Đến hạn · $dueCount',
      _WordFilter.favorite: 'Yêu thích',
    };
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: labels.entries.map((entry) {
          final selected = _filter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _filter = entry.key),
              selectedColor: palette.secondary,
              backgroundColor: palette.card,
              labelStyle: TextStyle(
                color: selected ? palette.primary : palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? palette.secondary : palette.cardBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(AppPalette palette, bool hasNoLearnedWords) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChibiMascot(
              size: 120,
              mood: hasNoLearnedWords ? ChibiMood.neutral : ChibiMood.sleepy,
            ),
            const SizedBox(height: 18),
            Text(
              hasNoLearnedWords
                  ? 'Bạn chưa học từ nào'
                  : 'Không tìm thấy từ phù hợp',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hasNoLearnedWords
                  ? 'Hãy bắt đầu một bài học để xây dựng sổ từ của riêng bạn.'
                  : 'Thử từ khóa khác hoặc thay đổi bộ lọc.',
              textAlign: TextAlign.center,
              style: palette.body,
            ),
            if (hasNoLearnedWords) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<MainNavigationProvider>().selectTab(1),
                icon: const Icon(Icons.import_contacts_outlined),
                label: const Text('Học từ mới'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _matchesSearch(Vocabulary word) {
    final keyword = _searchController.text.trim();
    return keyword.isEmpty || word.matches(keyword);
  }

  bool _matchesFilter(Progress progress) {
    switch (_filter) {
      case _WordFilter.all:
        return true;
      case _WordFilter.due:
        return progress.isDueForReview();
      case _WordFilter.favorite:
        return progress.isFavorite;
    }
  }
}

class _VocabularyTile extends StatelessWidget {
  const _VocabularyTile({required this.word, required this.progress});

  final Vocabulary word;
  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VocabularyDetailScreen(word: word),
        ),
      ),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VocabularyHeroText(word: word, fontSize: 28),
                  const SizedBox(height: 6),
                  Text(
                    word.romaji,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    word.meaning,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MemoryLevelChip(progress: progress),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: FavoriteButton(
                vocabularyId: word.id,
                isFavorite: progress.isFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
