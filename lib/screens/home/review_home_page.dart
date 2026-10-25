import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/main_navigation_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/error_view.dart';
import '../../widgets/greeting_section.dart';
import '../../widgets/memory_card.dart';
import '../../widgets/review_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/streak_chip.dart';
import '../common/generic_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../lesson/category_progress.dart';
import '../lesson/category_screen.dart';
import '../quiz/quiz_screen.dart';

class ReviewHomePage extends StatefulWidget {
  const ReviewHomePage({Key? key}) : super(key: key);

  @override
  State<ReviewHomePage> createState() => _ReviewHomePageState();
}

class _ReviewHomePageState extends GenericScreenState<ReviewHomePage> {
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

  ChibiMood _moodFor(ProgressProvider provider, int dailyGoal) {
    if (provider.isLoading) return ChibiMood.neutral;
    if (provider.getReviewedTodayCount() >= dailyGoal) {
      return ChibiMood.happy;
    }
    if (provider.getDueForReview().isEmpty) return ChibiMood.sleepy;
    return ChibiMood.neutral;
  }

  @override
  String getTitle(BuildContext context) => 'Ôn tập';

  @override
  bool get showAppBar => false;

  @override
  Widget buildBody(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final profile = context.watch<UserProfileProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        16,
        AppSpacing.page,
        28,
      ),
      children: [
        Row(
          children: [
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: BrandLogo(),
              ),
            ),
            const SizedBox(width: 12),
            StreakChip(days: profile.streak),
          ],
        ),
        const SizedBox(height: 36),
        GreetingSection(
          name: profile.displayName,
          mood: _moodFor(progressProvider, profile.dailyGoal),
        ),
        const SizedBox(height: 28),
        _buildProgressSection(progressProvider),
      ],
    );
  }

  Widget _buildProgressSection(ProgressProvider provider) {
    if (provider.isLoading) {
      return const Shimmer(
        child: Column(
          children: [
            SkeletonBox(height: 220, radius: 24),
            SizedBox(height: 20),
            SkeletonBox(height: 260, radius: 22),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.loadProgress,
      );
    }

    final dueCount = provider.getDueForReview().length;
    final estimatedMinutes = dueCount == 0 ? 0 : (dueCount / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReviewCard(
          dueCount: dueCount,
          estimatedMinutes: estimatedMinutes,
          isLoading: _isStartingReview,
          onReview: () => _startReview(provider),
        ),
        const SizedBox(height: 20),
        MemoryCard(
          totalLearned: provider.totalLearned,
          levelCounts: [
            provider.getCountForLevel(1),
            provider.getCountForLevel(2),
            provider.getCountForLevel(3),
            provider.getCountForLevel(4),
            provider.getCountForLevel(5),
          ],
          onViewAll: () => context.read<MainNavigationProvider>().selectTab(2),
        ),
        const SizedBox(height: 20),
        _QuickQuizTile(
          learnedCount: provider.totalLearned,
          onTap: () => openQuickQuiz(context),
        ),
        const SizedBox(height: 32),
        _buildDailyGoal(provider),
      ],
    );
  }

  Widget _buildDailyGoal(ProgressProvider provider) {
    final palette = context.palette;
    final lessonProvider = context.watch<LessonProvider>();
    final nextCategory = findNextCategory(
      lessonProvider.categories,
      provider.progressList,
      context.watch<LibraryProvider>(),
    );
    final reviewedToday = provider.getReviewedTodayCount();
    final dailyGoal = context.watch<UserProfileProvider>().dailyGoal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Mục tiêu hôm nay',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: palette.lavenderSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$reviewedToday / $dailyGoal từ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.primary,
                ),
              ),
            ),
          ],
        ),
        if (nextCategory != null) ...[
          const SizedBox(height: 14),
          _ContinueLearningTile(
            category: nextCategory,
            onTap: () => openCategory(context, nextCategory),
          ),
        ],
      ],
    );
  }
}

/// Lối vào quiz nhanh từ các từ đã học.
class _QuickQuizTile extends StatelessWidget {
  const _QuickQuizTile({required this.learnedCount, required this.onTap});

  final int learnedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        side: BorderSide(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: palette.lavenderSurface,
          child: Icon(Icons.quiz_outlined, color: palette.primary),
        ),
        title: const Text('Quiz nhanh', style: AppTextStyles.cardTitle),
        subtitle: Text('Kiểm tra $learnedCount từ bạn đã học'),
        trailing: Icon(Icons.chevron_right_rounded, color: palette.textMuted),
      ),
    );
  }
}

class _ContinueLearningTile extends StatelessWidget {
  const _ContinueLearningTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        side: BorderSide(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: palette.lavenderSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.spa_outlined, color: palette.label),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiếp tục học từ mới',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(category.name, style: palette.body),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
