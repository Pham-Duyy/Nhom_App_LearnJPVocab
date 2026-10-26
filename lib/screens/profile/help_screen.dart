import 'package:flutter/material.dart';

import '../../models/progress.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../common/generic_screen.dart';

/// Hướng dẫn sử dụng, mỗi mục mở/đóng được.
class HelpScreen extends GenericScreen {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Hướng dẫn sử dụng';

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const _HelpSection(
          icon: Icons.style_outlined,
          title: 'Học từ mới bằng flashcard',
          initiallyExpanded: true,
          body: 'Vào tab Học mới, chọn cấp độ, chủ đề rồi bài học. Chạm vào '
              'thẻ để lật xem nghĩa và câu ví dụ. Vuốt sang phải (hoặc bấm '
              'Đã nhớ) nếu bạn đã nhớ từ, vuốt sang trái (Chưa nhớ) nếu chưa.',
        ),
        _HelpSection(
          icon: Icons.alarm_outlined,
          title: 'Ôn tập đúng lúc sắp quên',
          body: 'Mỗi từ có 5 mức ghi nhớ. Nhớ thì lên một mức và được ôn lại '
              'thưa hơn; quên thì về mức 1 và ôn lại ngay hôm sau. Từ đến hạn '
              'ôn hiện ở tab Ôn tập.',
          footer: Table(
            border: TableBorder.all(color: palette.cardBorder),
            children: [
              const TableRow(
                children: [
                  _Cell('Mức', bold: true),
                  _Cell('Ôn lại sau', bold: true)
                ],
              ),
              for (final MapEntry(key: level, value: days)
                  in Progress.reviewIntervalDays.entries)
                TableRow(
                  children: [
                    _Cell('$level · ${Progress.levelLabels[level]}'),
                    _Cell('$days ngày'),
                  ],
                ),
            ],
          ),
        ),
        const _HelpSection(
          icon: Icons.quiz_outlined,
          title: 'Làm quiz',
          body: 'Bấm Quiz nhanh ở trang chủ hoặc Làm quiz bài này sau khi học '
              'xong. Mỗi câu chỉ chọn một lần; từ trả lời sai được đưa về lịch '
              'ôn. Đổi số câu mỗi lượt trong Cá nhân > Tùy chọn học.',
        ),
        const _HelpSection(
          icon: Icons.local_fire_department_outlined,
          title: 'Chuỗi ngày học và thành tích',
          body: 'Mỗi ngày trả lời ít nhất một thẻ hoặc một câu quiz là giữ '
              'được chuỗi. Bỏ lỡ một ngày thì chuỗi bắt đầu lại, nhưng thành '
              'tích đã đạt vẫn được giữ.',
        ),
        const _HelpSection(
          icon: Icons.bookmark_border_rounded,
          title: 'Sổ từ',
          body: 'Sổ từ chứa mọi từ bạn đã học. Tìm theo kanji, kana, romaji '
              'hoặc nghĩa; lọc các từ đến hạn hoặc yêu thích; chạm vào một từ '
              'để xem chi tiết.',
        ),
        const _HelpSection(
          icon: Icons.person_outline_rounded,
          title: 'Tài khoản khách',
          body: 'Bạn có thể học ngay mà không cần đăng ký. Để không mất tiến '
              'độ khi đổi máy, vào Cá nhân > Tài khoản và liên kết email hoặc '
              'Google; mọi từ đã học được giữ nguyên.',
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.icon,
    required this.title,
    required this.body,
    this.footer,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? footer;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: palette.primary),
        title: Text(title, style: AppTextStyles.cardTitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(body, style: palette.body),
          if (footer != null) ...[const SizedBox(height: 12), footer!],
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontWeight: bold ? FontWeight.w700 : null),
      ),
    );
  }
}
