import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Thanh chọn một trong vài lựa chọn kiểu [T]: cấp độ JLPT (`String`), mặt
/// trước thẻ (`CardFront`), số câu quiz (`int`), phạm vi trong Kho từ (enum),
/// chủ đề mới hay có sẵn khi import (`bool`).
/// [labelOf] đổi một lựa chọn thành chữ; [onChanged] báo lựa chọn mới lên
/// màn hình cha.
class ChoiceSegments<T> extends StatelessWidget {
  const ChoiceSegments({
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.mutedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: labelOf?.call(option) ?? '$option',
                selected: option == selected,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? palette.onPrimary : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
