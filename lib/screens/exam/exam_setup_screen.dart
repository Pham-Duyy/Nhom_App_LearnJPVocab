import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/choice_segments.dart';
import '../../widgets/error_view.dart';
import '../../widgets/hanko_stamp.dart';
import '../common/generic_screen.dart';
import 'exam_screen.dart';

/// Tab Thi thử: chọn phạm vi và số câu rồi bắt đầu làm bài.
class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({Key? key}) : super(key: key);

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends GenericScreenState<ExamSetupScreen> {
  String? _level;
  int _questionCount = ExamProvider.defaultQuestionCount;

  @override
  String getTitle(BuildContext context) => 'Thi thử';

  @override
  bool get showAppBar => false;

  void _start(LibraryProvider library, String level) {
    final words =
        library.words.where((word) => word.jlptLevel == level).toList();
    final started = context.read<ExamProvider>().start(
          level: level,
          words: words,
          questionCount: _questionCount,
        );
    if (!started) {
      showErrorSnackBar(context, 'Phạm vi này chưa đủ từ để ra đề.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExamScreen()),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final library = context.watch<LibraryProvider>();
    if (library.words.isEmpty) {
      if (library.errorMessage != null) {
        return ErrorView(message: library.errorMessage!, onRetry: library.load);
      }
      return const Center(child: CircularProgressIndicator());
    }

    // Chỉ cho chọn phạm vi đã có từ vựng (N4, N3 chưa có nội dung).
    final levels = LessonProvider.levels
        .where((level) => library.words.any((w) => w.jlptLevel == level))
        .toList();
    final level = levels.contains(_level) ? _level! : levels.first;
    final minutes = ExamProvider.durationFor(_questionCount).inMinutes;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Row(
          children: [
            const HankoStamp(text: '模試', size: 68),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thi thử như đề JLPT',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Làm bài có giờ, nộp xong mới biết điểm.',
                    style: palette.body,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('PHẠM VI', style: palette.sectionLabel),
        const SizedBox(height: 8),
        ChoiceSegments<String>(
          options: levels,
          selected: level,
          onChanged: (value) => setState(() => _level = value),
        ),
        const SizedBox(height: 20),
        Text('SỐ CÂU', style: palette.sectionLabel),
        const SizedBox(height: 8),
        ChoiceSegments<int>(
          options: ExamProvider.questionCountOptions,
          selected: _questionCount,
          labelOf: (count) => '$count câu',
          onChanged: (value) => setState(() => _questionCount = value),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: palette.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _Rule(
                  icon: Icons.timer_outlined,
                  text: '$minutes phút cho cả bài, hết giờ tự nộp',
                ),
                const _Rule(
                  icon: Icons.edit_note_rounded,
                  text: 'Được quay lại đổi đáp án trước khi nộp',
                ),
                const _Rule(
                  icon: Icons.visibility_off_outlined,
                  text: 'Nộp bài xong mới biết câu nào đúng, sai',
                ),
                const _Rule(
                  icon: Icons.verified_outlined,
                  text: 'Đúng từ ${ExamProvider.passPercent}% số câu là đạt',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => _start(library, level),
          child: const Text('Bắt đầu làm bài'),
        ),
      ],
    );
  }
}

/// Một dòng luật thi.
class _Rule extends StatelessWidget {
  const _Rule({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: context.palette.primary),
      title: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
