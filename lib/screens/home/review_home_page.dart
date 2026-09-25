import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/greeting_section.dart';
import '../../widgets/memory_card.dart';
import '../../widgets/review_card.dart';
import '../flashcard/flashcard_screen.dart';

class ReviewHomePage extends StatefulWidget {
  const ReviewHomePage({Key? key}) : super(key: key);

  @override
  State<ReviewHomePage> createState() => _ReviewHomePageState();
}

class _ReviewHomePageState extends State<ReviewHomePage> {
  // Khoá nút "Ôn ngay" trong lúc loadReviewWords() đang chờ, để tránh bấm
  // nhiều lần mở nhiều phiên ôn tập chồng lên nhau.
  bool _isStartingReview = false;

  Future<void> _startReview(ProgressProvider progressProvider) async {
    if (_isStartingReview) return;
    setState(() => _isStartingReview = true);

    final dueIds = progressProvider
        .getDueForReview()
        .map((progress) => progress.vocabularyId)
        .toList();

    final vocabularyProvider = context.read<VocabularyProvider>();
    await vocabularyProvider.loadReviewWords(dueIds);
    if (!mounted) return;

    if (vocabularyProvider.errorMessage != null) {
      setState(() => _isStartingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vocabularyProvider.errorMessage!)),
      );
      return;
    }

    if (vocabularyProvider.words.isEmpty) {
      setState(() => _isStartingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy từ vựng cần ôn tập.')),
      );
      return;
    }

    setState(() => _isStartingReview = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FlashcardScreen(
          title: 'Ôn tập hôm nay',
          completionTitle: 'Hoàn thành phiên ôn tập!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const GreetingSection(),
        const SizedBox(height: 24),
        _buildProgressSection(progressProvider),
      ],
    );
  }

  Widget _buildProgressSection(ProgressProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.loadProgress(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final dueCount = provider.getDueForReview().length;
    final estimatedMinutes = dueCount == 0 ? 0 : (dueCount / 2).ceil();

    return Column(
      children: [
        MemoryCard(
          totalLearned: provider.totalLearned,
          levelCounts: [
            provider.getCountForLevel(1),
            provider.getCountForLevel(2),
            provider.getCountForLevel(3),
            provider.getCountForLevel(4),
            provider.getCountForLevel(5),
          ],
        ),
        const SizedBox(height: 16),
        ReviewCard(
          dueCount: dueCount,
          estimatedMinutes: estimatedMinutes,
          isLoading: _isStartingReview,
          onReview: () => _startReview(provider),
        ),
      ],
    );
  }
}
