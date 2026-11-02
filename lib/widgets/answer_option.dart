import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'hanko_stamp.dart';

/// Trạng thái hiển thị của một đáp án: [selected] dùng khi làm bài thi (chưa
/// biết đúng sai), [correct]/[wrong]/[dimmed] khi đã chấm.
enum AnswerStatus { idle, selected, correct, wrong, dimmed }

/// Một đáp án; [onSelected] là callback báo lựa chọn lên Provider, null
/// thì đáp án bị khóa.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    Key? key,
    required this.letter,
    required this.label,
    required this.status,
    required this.onSelected,
  }) : super(key: key);

  final String letter;
  final String label;
  final AnswerStatus status;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final highlighted =
        status == AnswerStatus.correct || status == AnswerStatus.selected;
    final (Color border, Color background, IconData? icon) = switch (status) {
      AnswerStatus.correct => (palette.primary, palette.secondary, null),
      AnswerStatus.selected => (palette.primary, palette.accentSurface, null),
      AnswerStatus.wrong => (
          palette.danger,
          palette.dangerSurface,
          Icons.cancel_rounded,
        ),
      _ => (palette.cardBorder, palette.card, null),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: status == AnswerStatus.dimmed ? 0.55 : 1,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: border, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onSelected,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        highlighted ? palette.primary : palette.mutedSurface,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: highlighted ? palette.onPrimary : palette.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (status == AnswerStatus.correct)
                    const HankoStamp(text: '正', size: 34)
                  else if (icon != null)
                    Icon(icon, color: border),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
