import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/main_navigation_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/japan_scenery.dart';
import '../../widgets/error_view.dart';
import '../../widgets/greeting_section.dart';
import '../../widgets/memory_card.dart';
import '../../widgets/review_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/streak_chip.dart';
import '../common/generic_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../quiz/quiz_screen.dart';

class ReviewHomePage extends StatefulWidget {
  const ReviewHomePage({Key? key}) : super(key: key);

  @override
  State<ReviewHomePage> createState() => _ReviewHomePageState();
}

class _ReviewHomePageState extends GenericScreenState<ReviewHomePage> {
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
  String getTitle(BuildContext context) => 'Ôn tập';

  @override
  bool get showAppBar => false;

  @override
  Widget buildBody(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final profile = context.watch<UserProfileProvider>();

    final dueCount = progressProvider.isLoading
        ? 0
        : progressProvider.getDueForReview().length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        _HomeHeader(
          name: profile.displayName,
          streak: profile.streak,
          dueCount: dueCount,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: _buildProgressSection(progressProvider),
        ),
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
    final profile = context.watch<UserProfileProvider>();
    final showReminder =
        profile.preferences.dailyReminder && !profile.hasStudiedToday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showReminder) ...[
          _StudyReminder(
            streak: profile.streak,
            onTap: () => context
                .read<MainNavigationProvider>()
                .selectTab(MainNavigationProvider.learnTab),
          ),
          const SizedBox(height: 12),
        ],
        ReviewCard(
          dueCount: dueCount,
          estimatedMinutes: estimatedMinutes,
          isLoading: _isStartingReview,
          reviewedToday: provider.getReviewedTodayCount(),
          dailyGoal: profile.dailyGoal,
          onReview: () => _startReview(provider),
        ),
        const SizedBox(height: 12),
        MemoryCard(
          totalLearned: provider.totalLearned,
          levelCounts: [
            provider.getCountForLevel(1),
            provider.getCountForLevel(2),
            provider.getCountForLevel(3),
            provider.getCountForLevel(4),
            provider.getCountForLevel(5),
          ],
          onViewAll: () => context
              .read<MainNavigationProvider>()
              .selectTab(MainNavigationProvider.wordsTab),
        ),
        const SizedBox(height: 12),
        _ActionTile(
          kanji: '問',
          title: 'Quiz nhanh',
          subtitle: 'Kiểm tra ${provider.totalLearned} từ bạn đã học',
          onTap: () => openQuickQuiz(context),
        ),
      ],
    );
  }
}

/// Đầu trang chủ tràn hết chiều ngang: tranh hoa anh đào và núi Phú Sĩ,
/// logo, dấu chuỗi ngày, lời chào và Chibi (ngủ khi đã hết từ cần ôn).
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.streak,
    required this.dueCount,
  });

  final String name;
  final int streak;
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final resting = dueCount == 0;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 196),
      child: Stack(
        children: [
          const Positioned.fill(child: HomeScenery()),
          Positioned(
            right: 8,
            bottom: 4,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Đệm ngồi zabuton màu chàm, nằm sau Chibi.
                Container(
                  width: 92,
                  height: 22,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.all(
                      Radius.elliptical(46, 11),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: ChibiMascot(
                    size: 96,
                    mood: resting ? ChibiMood.sleepy : ChibiMood.happy,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              10,
              AppSpacing.page,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandLogo(size: 34),
                      ),
                    ),
                    StreakChip(days: streak),
                  ],
                ),
                const SizedBox(height: 2),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: GreetingSection(
                    name: name,
                    message: resting
                        ? 'Hết từ cần ôn rồi, Chibi đi ngủ một chút.'
                        : 'Có $dueCount từ đang chờ, ôn cùng Chibi nhé!',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lời nhắc khi hôm nay chưa học (tắt được trong Tùy chọn học); chạm để
/// sang Học mới.
class _StudyReminder extends StatelessWidget {
  const _StudyReminder({required this.streak, required this.onTap});

  final int streak;
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
        side: BorderSide(color: palette.accentBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: IntrinsicHeight(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: palette.accentSurface,
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 20,
                    color: palette.primary,
                  ),
                ),
                VerticalDivider(
                  width: 24,
                  indent: 4,
                  endIndent: 4,
                  color: palette.accentBorder,
                ),
                Expanded(
                  child: Text(
                    streak > 0
                        ? 'Hôm nay bạn chưa học. Ôn vài thẻ để giữ chuỗi '
                            '$streak ngày nhé!'
                        : 'Hôm nay bạn chưa học. Chỉ cần vài thẻ là bắt đầu '
                            'một chuỗi ngày mới!',
                    style: palette.body.copyWith(fontSize: 13),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: palette.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Một lối vào trên trang chủ (vd. Quiz nhanh): chữ Hán đại diện, tên
/// và mô tả ngắn.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.kanji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String kanji;
  final String title;
  final String subtitle;
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
          backgroundColor: palette.accentSurface,
          child: Text(
            kanji,
            style: AppTextStyles.japaneseDisplay.copyWith(
              fontSize: 20,
              color: palette.primary,
            ),
          ),
        ),
        title: Text(title, style: AppTextStyles.cardTitle),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right_rounded, color: palette.textMuted),
      ),
    );
  }
}
