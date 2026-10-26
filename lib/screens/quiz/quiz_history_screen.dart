import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_attempt.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import 'quiz_screen.dart';

/// Lịch sử các lần làm quiz, mới nhất ở trên.
class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends GenericScreenState<QuizHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<QuizProvider>().loadHistory();
    });
  }

  @override
  String getTitle(BuildContext context) => 'Lịch sử quiz';

  @override
  Widget buildBody(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    if (quiz.isLoadingHistory && quiz.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (quiz.errorMessage != null && quiz.history.isEmpty) {
      return ErrorView(message: quiz.errorMessage!, onRetry: quiz.loadHistory);
    }
    if (quiz.history.isEmpty) {
      return ErrorView(
        icon: Icons.quiz_outlined,
        message: 'Bạn chưa làm quiz nào.',
        actionLabel: 'Làm quiz nhanh',
        onRetry: () => openQuickQuiz(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: quiz.history.length,
      itemBuilder: (context, index) =>
          _AttemptTile(attempt: quiz.history[index]),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.attempt});

  final QuizAttempt attempt;

  /// Vd. 25/10/2026 · 20:05
  static String _formatDate(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.day)}/${two(time.month)}/${time.year} · '
        '${two(time.hour)}:${two(time.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final percent = attempt.scorePercent.round();
    return Card(
      elevation: 0,
      color: palette.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: palette.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: palette.lavenderSurface,
          child: Text(
            '$percent%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
        ),
        title: Text(
          attempt.title.isEmpty ? 'Quiz' : attempt.title,
          style: AppTextStyles.cardTitle,
        ),
        subtitle: Text(_formatDate(attempt.startedAt)),
        trailing: Text(
          '${attempt.correctCount}/${attempt.totalQuestions}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
