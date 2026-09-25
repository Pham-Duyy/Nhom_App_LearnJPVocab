import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Card nền trắng, không đổ bóng, viền nhạt — kiểu card dùng chung cho
/// danh sách chủ đề/bài học, thống kê ghi nhớ và mặt thẻ flashcard.
class AppCard extends StatelessWidget {
  const AppCard({
    Key? key,
    required this.child,
    this.radius = AppRadius.card,
  }) : super(key: key);

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
