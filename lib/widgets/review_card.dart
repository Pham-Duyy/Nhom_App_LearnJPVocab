import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'seigaiha_pattern.dart';

/// Thẻ ôn tập hôm nay trên nền chàm: số từ đến hạn, tiến độ mục tiêu ngày
/// và nút bắt đầu. Chỉ nhận dữ liệu qua constructor, không tự đọc Provider,
/// để widget dễ test và tái sử dụng.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    Key? key,
    required this.dueCount,
    required this.estimatedMinutes,
    required this.onReview,
    this.isLoading = false,
    this.reviewedToday = 0,
    this.dailyGoal = 0,
  }) : super(key: key);

  final int dueCount;
  final int estimatedMinutes;
  final VoidCallback onReview;
  final bool isLoading;

  /// Số từ đã ôn hôm nay trên mục tiêu mỗi ngày; [dailyGoal] bằng 0 thì ẩn
  /// thanh mục tiêu.
  final int reviewedToday;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onCard = palette.onPrimary;
    final hasDueWords = dueCount > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      child: ColoredBox(
        color: palette.primary,
        child: Stack(
          children: [
            Positioned.fill(
              child: SeigaihaPattern(color: onCard.withValues(alpha: 0.07)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日の復習 · ÔN TẬP HÔM NAY',
                    style: palette.sectionLabel.copyWith(
                      color: onCard.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasDueWords
                                  ? 'Đến giờ ôn tập'
                                  : 'Bạn đã ôn xong hôm nay!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: onCard,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasDueWords
                                  ? '$dueCount từ đến hạn · '
                                      'Khoảng $estimatedMinutes phút'
                                  : 'Quay lại vào ngày mai nhé.',
                              style: TextStyle(
                                fontSize: 14,
                                color: onCard.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasDueWords)
                        Text(
                          '$dueCount',
                          style: AppTextStyles.japaneseDisplay.copyWith(
                            fontSize: 52,
                            height: 1,
                            color: onCard,
                          ),
                        ),
                    ],
                  ),
                  if (dailyGoal > 0) ...[
                    const SizedBox(height: 18),
                    _DailyGoalBar(
                      reviewed: reviewedToday,
                      goal: dailyGoal,
                      color: onCard,
                    ),
                  ],
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: hasDueWords && !isLoading ? onReview : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onCard,
                      foregroundColor: palette.primary,
                      disabledBackgroundColor: onCard.withValues(alpha: 0.18),
                      disabledForegroundColor: onCard.withValues(alpha: 0.7),
                    ),
                    child: isLoading
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.primary,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded),
                              SizedBox(width: 8),
                              Text('Bắt đầu ôn tập'),
                            ],
                          ),
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

/// Thanh mảnh "6 / 20 từ" cho mục tiêu hôm nay.
class _DailyGoalBar extends StatelessWidget {
  const _DailyGoalBar({
    required this.reviewed,
    required this.goal,
    required this.color,
  });

  final int reviewed;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = '$reviewed / $goal từ';
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (reviewed / goal).clamp(0, 1).toDouble(),
              minHeight: 5,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
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
            color: color,
          ),
        ),
      ],
    );
  }
}
