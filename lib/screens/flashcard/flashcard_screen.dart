import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/flashcard_widget.dart';
import 'learning_result_screen.dart';

/// Học từ vựng bằng flashcard. Dùng chung cho phiên học theo bài
/// ([VocabularyProvider.loadByLesson]) lẫn phiên ôn tập gồm từ của nhiều bài
/// khác nhau ([VocabularyProvider.loadReviewWords]) — màn hình không cần
/// biết dữ liệu đến từ đâu, chỉ hiển thị [VocabularyProvider.words] hiện có.
/// [title] hiển thị trên AppBar, [completionTitle] hiển thị ở màn hình kết
/// quả khi học xong.
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({
    Key? key,
    required this.title,
    required this.completionTitle,
  }) : super(key: key);

  final String title;
  final String completionTitle;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  // Chặn bấm đúp trong lúc markCorrect()/markWrong() đang chờ lưu — nếu
  // không, một cú bấm kép có thể lưu một từ hai lần, nhảy qua từ tiếp theo,
  // sai số liệu phiên, hoặc mở màn hình kết quả nhiều lần.
  bool _isSubmitting = false;

  // Đếm số lần đúng/sai của riêng phiên học này để hiển thị ở màn hình kết
  // quả. Đây là số liệu tạm thời của UI, khác với memoryLevel tích lũy lâu
  // dài mà ProgressProvider/ProgressRepository lưu trữ.
  int _correctCount = 0;
  int _wrongCount = 0;

  Future<void> _markWrong(Vocabulary word) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await context.read<ProgressProvider>().markWrong(word.id);
      _wrongCount++;
      _advance();
    } catch (_) {
      _handleSaveError();
    }
  }

  Future<void> _markCorrect(Vocabulary word) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await context.read<ProgressProvider>().markCorrect(word.id);
      _correctCount++;
      _advance();
    } catch (_) {
      _handleSaveError();
    }
  }

  void _handleSaveError() {
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể lưu tiến độ. Vui lòng thử lại.')),
    );
  }

  void _advance() {
    if (!mounted) return;
    final vocabularyProvider = context.read<VocabularyProvider>();
    vocabularyProvider.nextCard();
    setState(() {
      _isSubmitting = false;
    });

    if (vocabularyProvider.sessionStatus == LearningSessionStatus.completed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LearningResultScreen(
            title: widget.title,
            completionTitle: widget.completionTitle,
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
        title: Text(widget.title),
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
            padding: const EdgeInsets.all(AppSpacing.page),
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
                  child: FlashcardWidget(
                    key: ValueKey(word.id),
                    word: word,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSubmitting ? null : () => _markWrong(word),
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
                        onPressed:
                            _isSubmitting ? null : () => _markCorrect(word),
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

