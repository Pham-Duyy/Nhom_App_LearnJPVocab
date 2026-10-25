import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'chibi_mascot.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({
    Key? key,
    required this.name,
    this.mood = ChibiMood.neutral,
  }) : super(key: key);

  final String name;
  final ChibiMood mood;

  static const _subtitles = {
    ChibiMood.neutral: 'Hôm nay, cùng tiến thêm một bước.',
    ChibiMood.happy: 'Bạn đã đạt mục tiêu hôm nay, giỏi lắm!',
    ChibiMood.sleepy: 'Hết từ cần ôn rồi, Chibi đi ngủ một chút.',
    ChibiMood.celebrate: 'Hôm nay, cùng tiến thêm một bước.',
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào $name!', style: AppTextStyles.pageTitle),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _subtitles[mood]!,
                  key: ValueKey(mood),
                  style: palette.body.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.lavenderSurface,
            shape: BoxShape.circle,
          ),
          child: ChibiMascot(size: 56, mood: mood),
        ),
      ],
    );
  }
}
