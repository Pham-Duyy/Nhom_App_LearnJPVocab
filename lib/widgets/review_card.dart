import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Thẻ nhắc ôn tập ở trang chủ. Chỉ nhận dữ liệu qua constructor — không tự
/// đọc Provider — để widget dễ test và tái sử dụng.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    Key? key,
    required this.dueCount,
    required this.estimatedMinutes,
    required this.onReview,
    this.isLoading = false,
  }) : super(key: key);

  final int dueCount;
  final int estimatedMinutes;
  final VoidCallback onReview;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasDueWords = dueCount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: palette.lavenderSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.lavenderBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ÔN TẬP HÔM NAY', style: palette.sectionLabel),
          const SizedBox(height: 14),
          Text(
            hasDueWords ? 'Đến giờ ôn tập' : 'Bạn đã ôn xong hôm nay!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasDueWords
                ? '$dueCount từ đến hạn · Khoảng $estimatedMinutes phút'
                : 'Quay lại vào ngày mai nhé.',
            style: palette.body.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: hasDueWords && !isLoading ? onReview : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.onPrimary,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_outlined),
                      SizedBox(width: 8),
                      Text('Bắt đầu ôn tập'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
