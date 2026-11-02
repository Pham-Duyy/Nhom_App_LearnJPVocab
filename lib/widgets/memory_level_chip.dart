import 'package:flutter/material.dart';

import '../models/progress.dart';
import '../theme/app_colors.dart';

class MemoryLevelChip extends StatelessWidget {
  const MemoryLevelChip({Key? key, required this.progress}) : super(key: key);

  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.memoryLevelColors[progress.memoryLevel - 1]
            .withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        progress.levelLabel,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: palette.primaryStrong,
        ),
      ),
    );
  }
}
