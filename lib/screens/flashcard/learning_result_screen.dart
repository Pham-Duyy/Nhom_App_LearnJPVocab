import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import 'flashcard_screen.dart';

/// Tổng kết sau khi học hết một bài flashcard.
class LearningResultScreen extends StatelessWidget {
  const LearningResultScreen({
    Key? key,
    required this.lesson,
    required this.correctCount,
    required this.wrongCount,
  }) : super(key: key);

  final Lesson lesson;
  final int correctCount;
  final int wrongCount;

  int get _totalReviewed => correctCount + wrongCount;

  void _learnAgain(BuildContext context) {
    context.read<VocabularyProvider>().resetSession();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => FlashcardScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        title: const Text('Kết quả buổi học'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Hoàn thành bài "${lesson.title}"!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text('Đã ôn $_totalReviewed từ',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Đã nhớ: $correctCount · Chưa nhớ: $wrongCount'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _learnAgain(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Học lại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Về trang chủ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
