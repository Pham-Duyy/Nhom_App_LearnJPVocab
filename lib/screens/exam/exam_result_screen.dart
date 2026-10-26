import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question.dart';
import '../../providers/exam_provider.dart';
import '../../providers/main_navigation_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/hanko_stamp.dart';
import '../common/generic_screen.dart';
import 'exam_screen.dart';

/// Kết quả thi thử: dấu 合格 (đạt) hoặc 不合格 (chưa đạt), điểm, thời gian
/// làm bài và xem lại từng câu.
class ExamResultScreen extends GenericScreen {
  const ExamResultScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Kết quả thi thử';

  @override
  bool get showBackButton => false;

  void _retake(BuildContext context) {
    if (!context.read<ExamProvider>().restart()) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ExamScreen()),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final exam = context.watch<ExamProvider>();
    final result = exam.result;
    if (result == null) return const SizedBox.shrink();

    final used = result.completedAt!.difference(result.startedAt);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const SizedBox(height: 8),
        Center(
          child: HankoStamp(
            text: exam.passed ? '合格' : '不合格',
            caption: exam.passed ? 'Đạt' : 'Chưa đạt',
            size: 132,
            shape: HankoShape.circle,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${result.correctCount}/${result.totalQuestions} câu đúng',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '${result.scorePercent.round()}% · cần '
          '${ExamProvider.passPercent}% để đạt · làm trong '
          '${used.inMinutes} phút ${used.inSeconds % 60} giây',
          textAlign: TextAlign.center,
          style: palette.body,
        ),
        if (exam.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            exam.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.danger),
          ),
        ],
        const SizedBox(height: 28),
        Text('XEM LẠI BÀI LÀM', style: palette.sectionLabel),
        const SizedBox(height: 10),
        for (var i = 0; i < exam.questions.length; i++)
          _ReviewTile(
            number: i + 1,
            question: exam.questions[i],
            selected: exam.selectedAt(i),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _retake(context),
          child: const Text('Thi lại'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            context.read<MainNavigationProvider>().goHome();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('Về trang chủ'),
        ),
      ],
    );
  }
}

/// Một câu khi xem lại: đề, đáp án đã chọn và đáp án đúng nếu chọn sai.
class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.number,
    required this.question,
    required this.selected,
  });

  final int number;
  final Question question;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final answer = selected;
    final isCorrect = answer != null && question.isCorrect(answer);
    final color = isCorrect ? palette.primary : palette.stamp;
    // Câu nghe: giờ mới hiện chữ của từ đã nghe.
    final prompt = question.isListening
        ? 'Nghe: ${question.pronunciation}'
        : question.prompt;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: palette.cardBorder),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: palette.onPrimary,
            ),
          ),
        ),
        title:
            Text(prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            answer == null
                ? 'Chưa làm'
                : 'Bạn chọn: ${question.options[answer]}',
            if (!isCorrect) 'Đáp án: ${question.correctAnswer}',
          ].join('\n'),
        ),
        trailing: Icon(
          isCorrect ? Icons.check_rounded : Icons.close_rounded,
          color: color,
        ),
      ),
    );
  }
}
