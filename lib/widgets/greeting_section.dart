import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Lời chào ở đầu trang chủ: câu chào tiếng Nhật theo giờ trong ngày, rồi
/// "Chào [name]!".
class GreetingSection extends StatelessWidget {
  const GreetingSection({Key? key, required this.name, this.now})
      : super(key: key);

  final String name;

  /// Thời điểm để chọn câu chào; mặc định là bây giờ (test truyền giờ cố
  /// định).
  final DateTime? now;

  /// おはよう trước 11 giờ, こんにちは tới 18 giờ, sau đó こんばんは.
  static String japaneseGreeting(DateTime time) {
    if (time.hour < 11) return 'おはよう';
    if (time.hour < 18) return 'こんにちは';
    return 'こんばんは';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          japaneseGreeting(now ?? DateTime.now()),
          style: AppTextStyles.japaneseDisplay.copyWith(
            fontSize: 16,
            letterSpacing: 2,
            color: palette.stamp,
          ),
        ),
        const SizedBox(height: 4),
        Text('Chào $name!', style: AppTextStyles.pageTitle),
      ],
    );
  }
}
