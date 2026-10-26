import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/achievement.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/hanko_stamp.dart';
import '../common/generic_screen.dart';
import '../lesson/category_progress.dart';

/// Gom số liệu học tập từ các provider (và theo dõi thay đổi của chúng).
LearningStats watchLearningStats(BuildContext context) {
  final progress = context.watch<ProgressProvider>().progressList;
  final library = context.watch<LibraryProvider>();
  final categories = context.watch<LessonProvider>().categories;
  return LearningStats.from(
    progress: progress,
    quizzes: context.watch<QuizProvider>().history,
    longestStreak: context.watch<UserProfileProvider>().longestStreak,
    completedCategories: categories
        .where((c) => CategoryProgress.of(c, progress, library).isComplete)
        .length,
  );
}

/// Bảng huy hiệu: đã đạt thì sáng màu, chưa đạt thì hiện tiến độ.
class AchievementsScreen extends GenericScreen {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Thành tích';

  @override
  Widget buildBody(BuildContext context) {
    final stats = watchLearningStats(context);
    final unlocked = Achievement.all.where((a) => a.isUnlocked(stats)).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(
          'Đã đạt $unlocked/${Achievement.all.length} huy hiệu',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            for (final achievement in Achievement.all)
              _AchievementCard(achievement: achievement, stats: stats),
          ],
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.stats});

  final Achievement achievement;
  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUnlocked = achievement.isUnlocked(stats);
    final progress = achievement.progressOf(stats);
    final color = isUnlocked ? palette.stamp : palette.textMuted;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isUnlocked ? palette.accentSurface : palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: isUnlocked ? palette.accentBorder : palette.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            HankoStamp(
              text: achievement.stamp,
              size: 50,
              shape: HankoShape.circle,
              faded: !isUnlocked,
            ),
            const SizedBox(height: 10),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: palette.body.copyWith(fontSize: 12),
              ),
            ),
            if (isUnlocked)
              Text(
                'Đã đạt',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              )
            else ...[
              LinearProgressIndicator(value: progress / achievement.target),
              const SizedBox(height: 4),
              Text(
                '$progress/${achievement.target}',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
