import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Dãy nút dạng viên thuốc để chọn một trong các lựa chọn kiểu [T], vuốt
/// ngang được khi không đủ chỗ. Gọn hơn ChoiceSegments khi có nhiều lựa chọn.
class PillChoices<T> extends StatelessWidget {
  const PillChoices({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.labelOf,
  }) : super(key: key);

  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T option)? labelOf;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(labelOf?.call(option) ?? '$option'),
              selected: option == selected,
              onSelected: (_) => onChanged(option),
              showCheckmark: false,
              selectedColor: palette.primary,
              backgroundColor: palette.card,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: option == selected
                    ? palette.onPrimary
                    : palette.textSecondary,
              ),
              side: BorderSide(
                color:
                    option == selected ? palette.primary : palette.cardBorder,
              ),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
