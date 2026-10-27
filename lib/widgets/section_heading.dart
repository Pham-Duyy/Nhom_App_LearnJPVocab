import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Đầu mục của một thẻ trên trang chủ: icon trong vòng tròn, nhãn chữ in
/// hoa và gạch ngắn bên dưới. [color] mặc định là màu chính.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    Key? key,
    required this.icon,
    required this.label,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = color ?? palette.primary;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: tint),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: palette.sectionLabel.copyWith(color: palette.primary),
              ),
              const SizedBox(height: 6),
              Container(
                width: 26,
                height: 3,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
