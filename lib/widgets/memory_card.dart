import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'app_card.dart';

/// Hiển thị tổng số từ đã học và phân bố theo 5 mức ghi nhớ. Chỉ nhận dữ
/// liệu qua constructor — không tự đọc Provider — để widget dễ test và tái
/// sử dụng.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    Key? key,
    required this.totalLearned,
    required this.levelCounts,
    this.onViewAll,
  }) : super(key: key);

  final int totalLearned;

  /// Số từ ở mỗi mức ghi nhớ, index 0 ứng với mức 1. Nếu thiếu phần tử,
  /// mức tương ứng được coi là 0 thay vì gây lỗi.
  final List<int> levelCounts;

  final VoidCallback? onViewAll;

  int _countForLevel(int level) {
    final index = level - 1;
    if (index < 0 || index >= levelCounts.length) return 0;
    return levelCounts[index];
  }

  double _barHeight(int count) {
    final maxCount = levelCounts.fold<int>(0, math.max);
    if (maxCount == 0) return 24;
    return 24 + 44 * count / maxCount;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      radius: AppRadius.cardLarge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TIẾN ĐỘ GHI NHỚ', style: palette.sectionLabel),
                      const SizedBox(height: 12),
                      Text(
                        '$totalLearned từ vựng',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text(
                      'Xem tất cả →',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var level = 1; level <= 5; level++)
                  MemoryBar(
                    level: level,
                    count: _countForLevel(level),
                    height: _barHeight(_countForLevel(level)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Từ mới học đến nhớ vững qua từng lần ôn.',
              style: palette.body.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryBar extends StatelessWidget {
  const MemoryBar({
    Key? key,
    required this.level,
    required this.count,
    required this.height,
  }) : super(key: key);

  final int level;
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$count', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: height),
            duration: Duration(milliseconds: 500 + level * 80),
            curve: Curves.easeOutBack,
            builder: (context, animatedHeight, _) => Container(
              height: math.max(0, animatedHeight),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: palette.memoryLevelColors[level - 1],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Progress.levelLabels[level]!,
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
