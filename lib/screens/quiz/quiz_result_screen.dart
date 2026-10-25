import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question.dart';
import '../../providers/main_navigation_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../common/generic_screen.dart';
import 'quiz_screen.dart';

/// Điểm của lượt vừa làm và các câu trả lời sai để xem lại.
class QuizResultScreen extends GenericScreen {
  const QuizResultScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Kết quả quiz';

  @override
  bool get showBackButton => false;

  static String _messageFor(double percent) {
    if (percent >= 90) return 'Xuất sắc! Bạn nhớ rất chắc.';
    if (percent >= 70) return 'Tốt lắm! Chỉ còn vài từ cần ôn.';
    if (percent >= 50) return 'Khá ổn, ôn thêm một chút nhé.';
    return 'Đừng nản, các từ sai đã được đưa vào lịch ôn.';
  }

  void _retry(BuildContext context) {
    if (!context.read<QuizProvider>().restart()) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }

  void _goHome(BuildContext context) {
    context.read<MainNavigationProvider>().goHome();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final quiz = context.watch<QuizProvider>();
    final result = quiz.result;
    if (result == null) return const SizedBox.shrink();

    final wrong = quiz.wrongQuestions;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Center(
          child: Text(
            '${result.correctCount}/${result.totalQuestions}',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: palette.primary,
            ),
          ),
        ),
        Center(
          child: Text(
            '${result.scorePercent.round()}% · ${_messageFor(result.scorePercent)}',
            textAlign: TextAlign.center,
            style: palette.body.copyWith(fontSize: 15),
          ),
        ),
        if (quiz.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            quiz.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.danger),
          ),
        ],
        const SizedBox(height: 28),
        if (wrong.isNotEmpty) ...[
          Text('CẦN ÔN LẠI (${wrong.length})', style: palette.sectionLabel),
          const SizedBox(height: 8),
          for (final question in wrong) _WrongAnswerTile(question: question),
          const SizedBox(height: 20),
        ],
        ElevatedButton.icon(
          onPressed: () => _retry(context),
          icon: const Icon(Icons.replay_rounded, size: 20),
          label: const Text('Làm lại'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _goHome(context),
          child: const Text('Về trang chủ'),
        ),
      ],
    );
  }
}

class _WrongAnswerTile extends StatelessWidget {
  const _WrongAnswerTile({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      color: palette.card,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: palette.cardBorder),
      ),
      child: ListTile(
        leading: Icon(Icons.close_rounded, color: palette.danger),
        title: Text(
          question.prompt,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('Đáp án: ${question.correctAnswer}'),
      ),
    );
  }
}
