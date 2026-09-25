import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson.dart';
import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import 'learning_result_screen.dart';

/// Học từ vựng bằng flashcard cho một bài học. Danh sách từ đã được
/// [VocabularyProvider.loadByLesson] tải trước khi màn hình này mở ra.
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({Key? key, required this.lesson}) : super(key: key);

  final Lesson lesson;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _showBack = false;

  // Đếm số lần đúng/sai của riêng phiên học này để hiển thị ở màn hình kết
  // quả. Đây là số liệu tạm thời của UI, khác với memoryLevel tích lũy lâu
  // dài mà ProgressProvider/ProgressRepository lưu trữ.
  int _correctCount = 0;
  int _wrongCount = 0;

  Future<void> _markWrong(Vocabulary word) async {
    await context.read<ProgressProvider>().markWrong(word.id);
    _wrongCount++;
    _advance();
  }

  Future<void> _markCorrect(Vocabulary word) async {
    await context.read<ProgressProvider>().markCorrect(word.id);
    _correctCount++;
    _advance();
  }

  void _advance() {
    if (!mounted) return;
    final vocabularyProvider = context.read<VocabularyProvider>();
    vocabularyProvider.nextCard();
    setState(() => _showBack = false);

    if (vocabularyProvider.sessionStatus == LearningSessionStatus.completed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LearningResultScreen(
            lesson: widget.lesson,
            correctCount: _correctCount,
            wrongCount: _wrongCount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        title: Text(widget.lesson.title),
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final word = provider.currentWord;
          if (word == null) {
            return const Center(
              child: Text('Bài học này chưa có từ vựng nào.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Từ ${provider.currentIndex + 1}/${provider.words.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (provider.currentIndex + 1) / provider.words.length,
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardBorder,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showBack = !_showBack),
                    child: _FlashcardFace(word: word, showBack: _showBack),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _markWrong(word),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Chưa nhớ'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _markCorrect(word),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Đã nhớ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    Key? key,
    required this.word,
    required this.showBack,
  }) : super(key: key);

  final Vocabulary word;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: showBack ? _buildBack() : _buildFront()),
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (word.kanji.isNotEmpty) ...[
          Text(
            word.kanji,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        Text(word.kana, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          word.romaji,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Text(
          'Chạm để xem nghĩa',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          word.meaning,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(word.exampleJapanese, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          word.exampleVietnamese,
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
