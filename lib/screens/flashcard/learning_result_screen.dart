import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/main_navigation_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/chibi_mascot.dart';
import '../common/generic_screen.dart';
import '../quiz/quiz_screen.dart';
import 'flashcard_screen.dart';

/// Tổng kết sau khi học hết một phiên flashcard — dùng chung cho phiên học
/// theo bài lẫn phiên ôn tập, không phụ thuộc vào Lesson.
class LearningResultScreen extends GenericScreen {
  const LearningResultScreen({
    Key? key,
    required this.title,
    required this.completionTitle,
    required this.correctCount,
    required this.wrongCount,
  }) : super(key: key);

  final String title;
  final String completionTitle;
  final int correctCount;
  final int wrongCount;

  int get _totalReviewed => correctCount + wrongCount;

  double get _accuracy =>
      _totalReviewed == 0 ? 0 : correctCount / _totalReviewed;

  void _learnAgain(BuildContext context) {
    context.read<VocabularyProvider>().resetSession();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            FlashcardScreen(title: title, completionTitle: completionTitle),
      ),
    );
  }

  /// Kiểm tra lại ngay bộ từ vừa học.
  void _takeQuiz(BuildContext context) {
    final words = context.read<VocabularyProvider>().words;
    final lessonIds = words.map((word) => word.lessonId).toSet();
    openQuiz(
      context,
      quizId: lessonIds.length == 1 ? 'lesson-${lessonIds.first}' : 'review',
      title: title,
      words: words,
    );
  }

  @override
  String getTitle(BuildContext context) => 'Kết quả buổi học';

  @override
  bool get showBackButton => false;

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      children: [
        const Center(
          child: ChibiMascot(size: 140, mood: ChibiMood.celebrate),
        ),
        const SizedBox(height: 10),
        Text(
          completionTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Đã ôn $_totalReviewed từ',
          textAlign: TextAlign.center,
          style: palette.body.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: palette.lavenderSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.lavenderBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: (_accuracy * 100).round()),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Text(
                      '$value%',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: palette.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Độ chính xác',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đã nhớ: $correctCount · Chưa nhớ: $wrongCount',
                          style: palette.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedProgressBar(
                value: _accuracy,
                minHeight: 8,
                color: palette.primary,
                backgroundColor: palette.card,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => _learnAgain(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.replay_rounded, size: 20),
              SizedBox(width: 8),
              Text('Học lại'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _takeQuiz(context),
          icon: const Icon(Icons.quiz_outlined, size: 20),
          label: const Text('Làm quiz bài này'),
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
