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
import '../../widgets/speak_button.dart';
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
          total: quiz.questions.length,
        ),
        const SizedBox(height: 20),
        _PromptCard(question: question),
        const SizedBox(height: 20),
        for (var i = 0; i < question.options.length; i++)
          _AnswerOption(
            letter: String.fromCharCode(65 + i),
            label: question.options[i],
            status: _statusOf(question, i, selected),
            // Đã chọn thì khóa lại: mỗi câu chỉ được trả lời một lần.
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

  static _OptionStatus _statusOf(Question question, int index, int? selected) {
    if (selected == null) return _OptionStatus.idle;
    if (index == question.correctIndex) return _OptionStatus.correct;
    if (index == selected) return _OptionStatus.wrong;
    return _OptionStatus.dimmed;
  }
}

class _QuizProgress extends StatelessWidget {
  const _QuizProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Câu $current/$total', style: palette.sectionLabel),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: current / total, minHeight: 8),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      color: palette.lavenderSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        side: BorderSide(color: palette.lavenderBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Text(question.instruction ?? '', style: palette.body),
            const SizedBox(height: 12),
            if (question.isListening)
              // ObjectKey: mỗi câu mới là một State mới, nên tự đọc lại.
              _ListeningPrompt(
                key: ObjectKey(question),
                text: question.pronunciation!,
              )
            else ...[
              Text(
                question.prompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: palette.primaryStrong,
                ),
              ),
              if (question.pronunciation != null) ...[
                const SizedBox(height: 4),
                SpeakButton(text: question.pronunciation!),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Đề bài câu hỏi nghe: không hiện chữ (chữ chính là đáp án), tự đọc một lần
/// khi câu hiện ra và có nút loa lớn để nghe lại.
class _ListeningPrompt extends StatefulWidget {
  const _ListeningPrompt({super.key, required this.text});

  final String text;

  @override
  State<_ListeningPrompt> createState() => _ListeningPromptState();
}

class _ListeningPromptState extends State<_ListeningPrompt> {
  @override
  void initState() {
    super.initState();
    // Đợi khung hình đầu vẽ xong để context hiện được SnackBar nếu lỗi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speak();
    });
  }

  void _speak() => SpeakButton.speak(context, widget.text);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        IconButton.filled(
          tooltip: 'Nghe lại',
          iconSize: 44,
          padding: const EdgeInsets.all(18),
          onPressed: _speak,
          icon: const Icon(Icons.volume_up_rounded),
        ),
        const SizedBox(height: 8),
        Text('Nhấn loa để nghe lại', style: palette.body),
      ],
    );
  }
}

enum _OptionStatus { idle, correct, wrong, dimmed }

/// Một đáp án; [onSelected] là callback báo lựa chọn lên QuizProvider, null
/// thì đáp án bị khóa.
class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.letter,
    required this.label,
    required this.status,
    required this.onSelected,
  });

  final String letter;
  final String label;
  final _OptionStatus status;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final success = palette.memoryLevelColors.last;
    final (Color border, Color background, IconData? icon) = switch (status) {
      _OptionStatus.correct => (
          success,
          success.withValues(alpha: 0.12),
          Icons.check_circle_rounded,
        ),
      _OptionStatus.wrong => (
          palette.danger,
          palette.dangerSurface,
          Icons.cancel_rounded,
        ),
      _ => (palette.cardBorder, palette.card, null),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: status == _OptionStatus.dimmed ? 0.55 : 1,
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
                    backgroundColor: palette.mutedSurface,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (icon != null) Icon(icon, color: border),
                ],
              ),
            ),
          ),
        ),
      ),
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
