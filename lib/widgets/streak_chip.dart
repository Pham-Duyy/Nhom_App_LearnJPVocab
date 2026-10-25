import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({Key? key, required this.days}) : super(key: key);

  final int days;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.lavenderSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.lavenderBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 18,
            color: palette.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$days ngày',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
        ],
      ),
    );
  }
}
