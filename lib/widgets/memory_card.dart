import 'package:flutter/material.dart';

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
  }) : super(key: key);

  final int totalLearned;

  /// Số từ ở mỗi mức ghi nhớ, index 0 ứng với mức 1. Nếu thiếu phần tử,
  /// mức tương ứng được coi là 0 thay vì gây lỗi.
  final List<int> levelCounts;

  int _countForLevel(int level) {
    final index = level - 1;
    if (index < 0 || index >= levelCounts.length) return 0;
    return levelCounts[index];
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.cardLarge,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BẠN ĐÃ HỌC'),
            Text(
              '$totalLearned từ vựng',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MemoryBar(level: 1, count: _countForLevel(1), height: 55),
                MemoryBar(level: 2, count: _countForLevel(2), height: 75),
                MemoryBar(level: 3, count: _countForLevel(3), height: 35),
                MemoryBar(level: 4, count: _countForLevel(4), height: 42),
                MemoryBar(level: 5, count: _countForLevel(5), height: 48),
              ],
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
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$count'),
          const SizedBox(height: 5),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.memoryLevelColors[level - 1],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text('Mức $level', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
