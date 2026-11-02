import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/answer_option.dart';
import '../../widgets/question_prompt_card.dart';
import '../common/generic_screen.dart';
import 'exam_result_screen.dart';

/// Màn làm bài thi: đồng hồ đếm ngược, lưới số câu để nhảy qua lại, chọn và
/// đổi đáp án. Khi bài được nộp (bấm nút hoặc hết giờ) thì sang màn kết quả.
class ExamScreen extends StatefulWidget {
  const ExamScreen({Key? key}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends GenericScreenState<ExamScreen> {
  late final ExamProvider _exam = context.read<ExamProvider>();

  @override
  void initState() {
    super.initState();
    _exam.addListener(_openResultWhenFinished);
  }

  @override
  void dispose() {
    _exam.removeListener(_openResultWhenFinished);
    super.dispose();
  }

  void _openResultWhenFinished() {
    if (!_exam.isFinished || !mounted) return;
    _exam.removeListener(_openResultWhenFinished);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ExamResultScreen()),
    );
  }

  @override
  String getTitle(BuildContext context) => _exam.title;

  /// Chặn nút Back để hỏi lại trước khi bỏ dở bài thi.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: buildLayout(context),
    );
  }

  Future<void> _confirmExit() async {
    final leave = await _askConfirm(
      title: 'Thoát bài thi?',
      message: 'Bài làm sẽ không được chấm và không được lưu.',
      confirmLabel: 'Thoát',
    );
    if (leave && mounted) {
      _exam.cancel();
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmSubmit() async {
    final left = _exam.unansweredCount;
    final submit = await _askConfirm(
      title: 'Nộp bài?',
      message: left > 0
          ? 'Bạn còn $left câu chưa làm. Câu chưa làm tính là sai.'
          : 'Bạn đã làm hết các câu.',
      confirmLabel: 'Nộp bài',
    );
    if (submit) await _exam.submit();
  }

  Future<bool> _askConfirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final palette = context.palette;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(message, style: palette.body),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Làm tiếp'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final exam = context.watch<ExamProvider>();
    final question = exam.currentQuestion;
    if (question == null) return const SizedBox.shrink();
    final selected = exam.selectedAt(exam.currentIndex);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Câu ${exam.currentIndex + 1}/${exam.questions.length}',
                style: palette.sectionLabel,
              ),
            ),
            _TimerChip(remaining: exam.remaining),
          ],
        ),
        const SizedBox(height: 12),
        _QuestionGrid(
          count: exam.questions.length,
          current: exam.currentIndex,
          isAnswered: (index) => exam.selectedAt(index) != null,
          onTap: exam.goTo,
        ),
        const SizedBox(height: 20),
        QuestionPromptCard(question: question),
        const SizedBox(height: 20),
        for (var i = 0; i < question.options.length; i++)
          AnswerOption(
            letter: String.fromCharCode(65 + i),
            label: question.options[i],
            status: i == selected ? AnswerStatus.selected : AnswerStatus.idle,
            onSelected: () => exam.select(i),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: exam.isFirstQuestion ? null : exam.previous,
                child: const Text('Câu trước'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: exam.isLastQuestion ? _confirmSubmit : exam.next,
                child: Text(exam.isLastQuestion ? 'Nộp bài' : 'Câu sau'),
              ),
            ),
          ],
        ),
        if (!exam.isLastQuestion) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _confirmSubmit,
            child: Text(
              'Nộp bài sớm · đã làm '
              '${exam.answeredCount}/${exam.questions.length}',
            ),
          ),
        ],
      ],
    );
  }
}

/// Thời gian còn lại dạng mm:ss; dưới một phút thì chuyển màu đỏ son.
class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = remaining.inSeconds < 60 ? palette.stamp : palette.primary;
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            semanticsLabel: 'Còn $minutes phút $seconds giây',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lưới số câu: câu đã làm tô chàm, câu đang xem có viền; chạm để chuyển câu.
class _QuestionGrid extends StatelessWidget {
  const _QuestionGrid({
    required this.count,
    required this.current,
    required this.isAnswered,
    required this.onTap,
  });

  final int count;
  final int current;
  final bool Function(int index) isAnswered;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GridView.count(
      crossAxisCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: [
        for (var i = 0; i < count; i++)
          Semantics(
            button: true,
            selected: i == current,
            label: 'Câu ${i + 1}',
            excludeSemantics: true,
            child: InkWell(
              onTap: () => onTap(i),
              customBorder: const CircleBorder(),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAnswered(i) ? palette.primary : palette.card,
                  border: Border.all(
                    color: i == current ? palette.stamp : palette.cardBorder,
                    width: i == current ? 2 : 1,
                  ),
                ),
                child: FittedBox(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isAnswered(i)
                          ? palette.onPrimary
                          : palette.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
