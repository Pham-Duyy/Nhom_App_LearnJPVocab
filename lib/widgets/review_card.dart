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
    final hasDueWords = dueCount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.reviewCardBackground,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            hasDueWords ? 'Đến giờ ôn rồi!' : 'Bạn đã ôn xong hôm nay!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            hasDueWords
                ? '$dueCount từ đang chờ bạn · khoảng $estimatedMinutes phút'
                : 'Quay lại vào ngày mai nhé.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: hasDueWords && !isLoading ? onReview : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Ôn ngay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
