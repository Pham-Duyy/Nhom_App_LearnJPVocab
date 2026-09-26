import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock/mock_learning_data.dart';
import '../../models/progress.dart';
import '../../models/vocabulary.dart';
import '../../providers/main_navigation_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';

enum _WordFilter { all, due, favorite }

class VocabularyBookScreen extends StatefulWidget {
  const VocabularyBookScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyBookScreen> createState() => _VocabularyBookScreenState();
}

class _VocabularyBookScreenState extends State<VocabularyBookScreen> {
  final _searchController = TextEditingController();
  _WordFilter _filter = _WordFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(progressProvider.totalLearned),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kanji, kana hoặc nghĩa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),
          _buildFilters(),
          const SizedBox(height: 12),
          Expanded(
            child: progressProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : learnedWords.isEmpty
                    ? _buildEmptyState(progressProvider.totalLearned == 0)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: learnedWords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      ),
    );
  }

  Widget _buildHeader(int totalLearned) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.avatarBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.bookmarks_rounded,
                color: AppColors.primary, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sổ từ của bạn',
                    style:
                        TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                Text('$totalLearned từ đã học',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const labels = {
      _WordFilter.all: 'Tất cả',
      _WordFilter.due: 'Đến hạn',
      _WordFilter.favorite: 'Yêu thích',
    };
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: labels.entries.map((entry) {
          final selected = _filter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _filter = entry.key),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.cardBorder,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool hasNoLearnedWords) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.avatarBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_outlined,
                  size: 43, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              hasNoLearnedWords
                  ? 'Bạn chưa học từ nào'
                  : 'Không tìm thấy từ phù hợp',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasNoLearnedWords
                  ? 'Hãy bắt đầu một bài học để xây dựng sổ từ của riêng bạn.'
                  : 'Thử từ khóa khác hoặc thay đổi bộ lọc.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            if (hasNoLearnedWords) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<MainNavigationProvider>().selectTab(1),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Học từ mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
    final levelColor = AppColors.memoryLevelColors[progress.memoryLevel - 1];
    final title = word.kanji.isEmpty ? word.kana : word.kanji;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showWordDetails(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 57,
                height: 57,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word.meaning,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${word.kana}  ·  ${word.romaji}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Mức ${progress.memoryLevel}',
                        style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    progress.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: progress.isFavorite ? Colors.redAccent : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWordDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              Text(word.kanji.isEmpty ? word.kana : word.kanji,
                  style: const TextStyle(
                      fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${word.kana} · ${word.romaji}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 16),
              Text(word.meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ví dụ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(word.exampleJapanese,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(word.exampleVietnamese,
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await sheetContext
                        .read<ProgressProvider>()
                        .toggleFavorite(word.id);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: Icon(progress.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  label: Text(progress.isFavorite
                      ? 'Bỏ khỏi yêu thích'
                      : 'Thêm vào yêu thích'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
