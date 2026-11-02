import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'japan_scenery.dart';
import 'section_heading.dart';

/// Thẻ ôn tập hôm nay: tranh cổng torii bên phải, số từ đến hạn, tiến độ
/// mục tiêu ngày và nút bắt đầu. Chỉ nhận dữ liệu qua constructor, không tự
/// đọc Provider, để widget dễ test và tái sử dụng.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    Key? key,
    required this.dueCount,
    required this.estimatedMinutes,
    required this.onReview,
    this.onLearnNew,
    this.isLoading = false,
    this.reviewedToday = 0,
    this.dailyGoal = 0,
  }) : super(key: key);

  final int dueCount;
  final int estimatedMinutes;
  final VoidCallback onReview;
  final VoidCallback? onLearnNew;
  final bool isLoading;

  /// Số từ đã ôn hôm nay trên mục tiêu mỗi ngày; [dailyGoal] bằng 0 thì ẩn
  /// thanh mục tiêu.
  final int reviewedToday;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasDueWords = dueCount > 0;
    final targetGoal = dailyGoal > 0 ? dailyGoal : 10;
    final isGoalMet = reviewedToday >= targetGoal;

    final VoidCallback? buttonAction;
    final String buttonLabel;
    final IconData buttonIcon;

    if (isGoalMet) {
      buttonAction = null;
      buttonLabel = 'Đã hoàn thành hôm nay';
      buttonIcon = Icons.check_circle_outline_rounded;
    } else if (hasDueWords) {
      buttonAction = onReview;
      buttonLabel = 'Bắt đầu ôn tập';
      buttonIcon = Icons.play_arrow_rounded;
    } else {
      buttonAction = onLearnNew ?? onReview;
      buttonLabel = 'Bắt đầu học mới';
      buttonIcon = Icons.play_arrow_rounded;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.card, palette.accentSurface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: palette.accentBorder),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 10,
            right: 0,
            width: 130,
            height: 112,
            child: ToriiScene(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  icon: Icons.auto_stories_outlined,
                  label: 'ÔN TẬP HÔM NAY',
                ),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.64,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasDueWords
                            ? 'Đến giờ ôn tập'
                            : 'Bạn đã ôn xong hôm nay!',
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: palette.primaryStrong,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasDueWords
                            ? '$dueCount từ đến hạn · '
                                'Khoảng $estimatedMinutes phút'
                            : 'Quay lại vào ngày mai nhé.',
                        style: palette.body,
                      ),
                    ],
                  ),
                ),
                if (dailyGoal > 0) ...[
                  const SizedBox(height: 12),
                  _DailyGoalBar(reviewed: reviewedToday, goal: dailyGoal),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isGoalMet || isLoading ? null : buttonAction,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  child: isLoading
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.onPrimary,
                          ),
                        )
                      : Row(
                          children: [
                            Icon(buttonIcon),
                            Expanded(
                              child: Text(
                                buttonLabel,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (!isGoalMet)
                              const Icon(Icons.arrow_forward_rounded, size: 20)
                            else
                              const SizedBox(width: 20),
                          ],
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

/// Thanh mảnh "6 / 20 từ" cho mục tiêu hôm nay.
class _DailyGoalBar extends StatelessWidget {
  const _DailyGoalBar({required this.reviewed, required this.goal});

  final int reviewed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = '$reviewed / $goal từ';
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (reviewed / goal).clamp(0, 1).toDouble(),
              minHeight: 5,
              color: palette.primary,
              backgroundColor: palette.progressTrack,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          semanticsLabel: 'Mục tiêu hôm nay: $label',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}
