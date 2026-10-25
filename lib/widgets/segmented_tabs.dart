import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    Key? key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.showCheck = false,
  }) : super(key: key);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: palette.lavenderSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(child: _buildSegment(palette, i)),
        ],
      ),
    );
  }

  Widget _buildSegment(AppPalette palette, int index) {
    final selected = index == selectedIndex;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? palette.raised : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            selected && showCheck ? '✓ ${labels[index]}' : labels[index],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? palette.primary : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
