import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Lời chào ở đầu trang chủ: "Chào [name]!" cỡ lớn và một câu [message]
/// ngắn. Câu chào tiếng Nhật được đọc thành tiếng (SoundProvider), không
/// hiện chữ.
class GreetingSection extends StatelessWidget {
  const GreetingSection({Key? key, required this.name, this.message})
      : super(key: key);

  final String name;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào $name!',
          style: AppTextStyles.pageTitle.copyWith(
            fontSize: 28,
            color: palette.primaryStrong,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 4),
          Text(message!, style: palette.body.copyWith(fontSize: 14)),
        ],
      ],
    );
  }
}
