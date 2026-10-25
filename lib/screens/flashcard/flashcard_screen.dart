import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/swipe_flashcard.dart';
import '../common/generic_screen.dart';
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

class _FlashcardScreenState extends GenericScreenState<FlashcardScreen> {
  final _cardKey = GlobalKey<SwipeFlashcardState>();

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
    _cardKey.currentState?.reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể lưu tiến độ. Vui lòng thử lại.')),
    );
  }

  void _advance() {
    if (!mounted) return;
    final vocabularyProvider = context.read<VocabularyProvider>();
    vocabularyProvider.nextCard();
    setState(() => _isSubmitting = false);

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
  String getTitle(BuildContext context) => widget.title;

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    return Consumer<VocabularyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return _buildSkeleton();

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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            AppSpacing.page,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Từ ${provider.currentIndex + 1}/${provider.words.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '$_correctCount nhớ · $_wrongCount cần ôn',
                    style: TextStyle(fontSize: 13, color: palette.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedProgressBar(
                value: (provider.currentIndex + 1) / provider.words.length,
                color: palette.primary,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SwipeFlashcard(
                    key: _cardKey,
                    cardId: word.id,
                    enabled: !_isSubmitting,
                    front: _FlashcardFront(word: word),
                    back: _FlashcardBack(word: word),
                    onSwiped: (remembered) =>
                        remembered ? _markCorrect(word) : _markWrong(word),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _cardKey.currentState?.swipe(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        foregroundColor: palette.danger,
                        backgroundColor: palette.dangerSurface,
                        side: BorderSide(color: palette.dangerBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.replay_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Chưa nhớ'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _cardKey.currentState?.swipe(true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Đã nhớ'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.page),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 90),
            SizedBox(height: 14),
            SkeletonBox(height: 6),
            SizedBox(height: 24),
            Expanded(child: SkeletonBox(height: double.infinity, radius: 28)),
            SizedBox(height: 34),
            SkeletonBox(height: 58, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _FlashcardFront extends StatelessWidget {
  const _FlashcardFront({required this.word});

  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasKanji = word.kanji.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: palette.lavenderSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.jlptLevel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.primary,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (hasKanji) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word.kanji,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word.kana,
              style: TextStyle(
                fontSize: hasKanji ? 26 : 40,
                fontWeight: hasKanji ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.romaji,
            style: TextStyle(fontSize: 16, color: palette.textMuted),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined,
                  size: 18, color: palette.textMuted),
              const SizedBox(width: 6),
              Text(
                'Chạm để xem nghĩa',
                style: TextStyle(fontSize: 13, color: palette.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashcardBack extends StatelessWidget {
  const _FlashcardBack({required this.word});

  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.lavenderSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.lavenderBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('NGHĨA', style: palette.sectionLabel),
          const Spacer(),
          Text(
            word.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: palette.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            word.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.exampleJapanese,
                    style: const TextStyle(fontSize: 17)),
                const SizedBox(height: 6),
                Text(word.exampleVietnamese, style: palette.body),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_outlined, size: 18, color: palette.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Vuốt phải nếu đã nhớ, trái nếu chưa',
                  style: TextStyle(fontSize: 13, color: palette.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
