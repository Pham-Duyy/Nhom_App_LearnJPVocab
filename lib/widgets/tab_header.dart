import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

class TabHeader extends StatelessWidget {
  const TabHeader({
    Key? key,
    required this.label,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  final String label;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ChibaKanji',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.textMuted,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: palette.sectionLabel.copyWith(
                color: palette.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.pageTitle)),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: palette.body),
        ],
      ],
    );
  }
}
