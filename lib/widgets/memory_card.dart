import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Tổng số từ đã học và biểu đồ cột theo 3 giai đoạn ghi nhớ: Mới học (mức
/// 1), Đang nhớ (mức 2) và Đã nhớ (mức 3 trở lên). Chỉ nhận dữ liệu qua
/// constructor, không tự đọc Provider, để widget dễ test và tái sử dụng.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    Key? key,
    required this.totalLearned,
    required this.levelCounts,
    this.onViewAll,
  }) : super(key: key);

  static const _chartHeight = 110.0;

  final int totalLearned;

  /// Số từ ở mỗi mức ghi nhớ 1–5, index 0 ứng với mức 1. Thiếu phần tử thì
  /// mức đó coi là 0 thay vì gây lỗi.
  final List<int> levelCounts;

  final VoidCallback? onViewAll;

  int _count(int level) {
    final index = level - 1;
    return index >= 0 && index < levelCounts.length ? levelCounts[index] : 0;
  }

  /// (tên giai đoạn, số từ): mức 3, 4, 5 gộp chung thành "Đã nhớ".
  List<(String, int)> get _stages => [
        ('Mới học', _count(1)),
        ('Đang nhớ', _count(2)),
        ('Đã nhớ', _count(3) + _count(4) + _count(5)),
      ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final stages = _stages;
    final maxCount = stages.fold<int>(1, (max, s) => s.$2 > max ? s.$2 : max);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GHI NHỚ', style: palette.sectionLabel),
                    const SizedBox(height: 4),
                    Text(
                      '$totalLearned từ vựng',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Xem tất cả ›'),
                ),
            ],
          ),
          const SizedBox(height: 18),
          // Cột: số ở trên, cột đứng trên đường nền, tên ở dưới.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, (label, count)) in stages.indexed)
                Expanded(
                  child: MemoryBar(
                    label: label,
                    count: count,
                    height: _chartHeight * count / maxCount,
                    maxHeight: _chartHeight,
                    color: palette.chartColors[index],
                  ),
                ),
            ],
          ),
          Divider(height: 1, thickness: 1, color: palette.divider),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (label, _) in stages)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Một cột: số từ ở trên; cột màu chuyển nhẹ từ trên xuống, đứng trước một
/// cột nền nhạt cùng màu cao bằng cả biểu đồ; lớn dần lên khi hiện ra.
class MemoryBar extends StatelessWidget {
  const MemoryBar({
    Key? key,
    required this.label,
    required this.count,
    required this.height,
    required this.maxHeight,
    required this.color,
  }) : super(key: key);

  final String label;
  final int count;
  final double height;
  final double maxHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $count từ',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: AppTextStyles.cardTitle.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: maxHeight,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: count == 0 ? 0 : height.clamp(8, maxHeight),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Container(
                height: value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(color, Colors.white, 0.2)!,
                      color,
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
