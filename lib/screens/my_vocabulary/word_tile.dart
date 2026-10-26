import 'package:flutter/material.dart';

import '../../models/vocabulary.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Một từ trong các danh sách của Kho từ: chữ lớn bên trái, nghĩa và cách
/// đọc ở giữa, [trailing] tùy màn (nút sửa/xóa, ô đánh dấu...).
class WordTile extends StatelessWidget {
  const WordTile({
    Key? key,
    required this.word,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  final Vocabulary word;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 12, right: 4),
        leading: SizedBox(
          width: 56,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word.name,
              style: AppTextStyles.japaneseDisplay.copyWith(
                fontSize: 24,
                color: palette.textPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          word.meaning,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            word.kana,
            if (word.romaji.isNotEmpty) word.romaji,
            if (word.isPersonal) 'Của tôi',
          ].join(' · '),
        ),
        trailing: trailing,
      ),
    );
  }
}
