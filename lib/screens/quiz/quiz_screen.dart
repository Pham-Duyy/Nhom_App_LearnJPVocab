import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/quiz_generator.dart';
import '../../models/question.dart';
import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/answer_option.dart';
import '../../widgets/question_prompt_card.dart';
import '../common/generic_screen.dart';
import 'quiz_result_screen.dart';

/// Bắt đầu quiz từ [words] rồi mở màn hình làm bài; báo lỗi nếu không đủ từ.
void openQuiz(
  BuildContext context, {
  required String quizId,
  required String title,
  required List<Vocabulary> words,
}) {
  final started = context.read<QuizProvider>().start(
        quizId: quizId,
        title: title,
        words: words,
        maxQuestions: _quizLength(context),
      );
  if (!started) {
    _showMessage(
      context,
      'Cần ít nhất ${QuizGenerator.minWords} từ khác nhau để làm quiz.',
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const QuizScreen()),
  );
}

/// Quiz nhanh từ tất cả các từ đã học.
Future<void> openQuickQuiz(BuildContext context) async {
  final learnedIds = context
      .read<ProgressProvider>()
      .progressList
      .where((progress) => progress.isLearned)
      .map((progress) => progress.vocabularyId)
      .toList();
  final error = await context.read<QuizProvider>().startWithWordIds(
        quizId: 'quick',
        title: 'Quiz nhanh',
        vocabularyIds: learnedIds,
        maxQuestions: _quizLength(context),
      );
  if (!context.mounted) return;
  if (error != null) {
    _showMessage(context, error);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const QuizScreen()),
  );
}

/// Số câu mỗi lượt theo Tùy chọn học của người dùng.
int _quizLength(BuildContext context) =>
    context.read<UserProfileProvider>().preferences.quizLength;

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Màn hình làm quiz: mỗi lần một câu, chọn đáp án rồi xem đúng/sai.
class QuizScreen extends GenericScreen {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => context.read<QuizProvider>().title;

  /// Chặn nút Back để hỏi lại trước khi bỏ dở quiz.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: buildLayout(context),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final palette = context.palette;
    final leave = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thoát quiz?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Kết quả của lượt này sẽ không được lưu.',
                style: palette.body,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Làm tiếp'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.danger,
                  side: BorderSide(color: palette.dangerBorder),
                ),
                child: const Text('Thoát quiz'),
              ),
            ],
          ),
        ),
      ),
    );
    if (leave == true && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _next(BuildContext context) async {
    final quiz = context.read<QuizProvider>();
    await quiz.next();
    if (quiz.isFinished && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const QuizResultScreen()),
      );
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final question = quiz.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final selected = quiz.selectedIndex;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        _QuizProgress(
          current: quiz.currentIndex + 1,
          results: [
            for (var i = 0; i < quiz.questions.length; i++) quiz.resultAt(i),
          ],
        ),
        const SizedBox(height: 20),
        QuestionPromptCard(question: question),
        const SizedBox(height: 20),
        for (var i = 0; i < question.options.length; i++)
          AnswerOption(
            letter: String.fromCharCode(65 + i),
            label: question.options[i],
            status: _statusOf(question, i, selected),
            onSelected: selected == null ? () => quiz.answer(i) : null,
          ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          _Explanation(
            isCorrect: question.isCorrect(selected),
            text: question.explanation ?? question.correctAnswer,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _next(context),
            child: Text(quiz.isLastQuestion ? 'Xem kết quả' : 'Câu tiếp theo'),
          ),
        ],
      ],
    );
  }

  static AnswerStatus _statusOf(Question question, int index, int? selected) {
    if (selected == null) return AnswerStatus.idle;
    if (index == question.correctIndex) return AnswerStatus.correct;
    if (index == selected) return AnswerStatus.wrong;
    return AnswerStatus.dimmed;
  }
}

/// "Câu 3/10" và một vạch cho mỗi câu: chàm là đúng, đỏ son là sai, xám là
/// chưa trả lời.
class _QuizProgress extends StatelessWidget {
  const _QuizProgress({required this.current, required this.results});

  final int current;
  final List<bool?> results;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Color colorOf(bool? result) => switch (result) {
          true => palette.primary,
          false => palette.stamp,
          null => palette.progressTrack,
        };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Câu $current/${results.length}', style: palette.sectionLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < results.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorOf(results[i]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.isCorrect, required this.text});

  final bool isCorrect;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.celebration_outlined : Icons.lightbulb_outline,
            color: isCorrect ? palette.primary : palette.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: isCorrect ? 'Chính xác! ' : 'Chưa đúng. ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: text),
                ],
              ),
              style: palette.body,
            ),
          ),
        ],
      ),
    );
  }
}
