import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/study_preferences.dart';
import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/speak_button.dart';
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

  bool _isSubmitting = false;

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
          return ErrorView(
            message: provider.errorMessage!,
            onRetry: provider.retry,
          );
        }

        final word = provider.currentWord;
        if (word == null) {
          return const Center(
            child: Text('Bài học này chưa có từ vựng nào.'),
          );
        }

        final preferences = context.watch<UserProfileProvider>().preferences;
        final japaneseFirst = preferences.cardFront == CardFront.japanese;
        const tapHint =
            _CardHint('Chạm để lật thẻ · vuốt trái/phải để trả lời');
        const swipeHint = _CardHint('Vuốt phải nếu đã nhớ, trái nếu chưa');
        Widget japanese(_CardHint hint) => _JapaneseFace(
              word: word,
              showRomaji: preferences.showRomaji,
              hint: hint,
            );
        Widget meaning(_CardHint hint) => _MeaningFace(
              word: word,
              revealJapanese: japaneseFirst,
              hint: hint,
            );

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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _DeckLayer(
                          angle: 0.05,
                          color: palette.mutedSurface,
                        ),
                      ),
                      Positioned.fill(
                        child: _DeckLayer(
                          angle: 0.024,
                          color: palette.backgroundTinted,
                        ),
                      ),
                      Positioned.fill(
                        child: SwipeFlashcard(
                          key: _cardKey,
                          cardId: word.id,
                          enabled: !_isSubmitting,
                          front: japaneseFirst
                              ? japanese(tapHint)
                              : meaning(tapHint),
                          back: japaneseFirst
                              ? meaning(swipeHint)
                              : japanese(swipeHint),
                          onSwiped: (remembered) => remembered
                              ? _markCorrect(word)
                              : _markWrong(word),
                        ),
                      ),
                    ],
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
                        backgroundColor: palette.card,
                        side: BorderSide(color: palette.stamp, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Chưa nhớ',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                          Flexible(
                            child: Text(
                              'Đã nhớ',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

/// Dòng gợi ý thao tác ở cuối mỗi mặt thẻ.
class _CardHint extends StatelessWidget {
  const _CardHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: context.palette.textMuted),
    );
  }
}

/// Một lớp giấy nằm dưới thẻ đang học, để thẻ trông như một xấp thẻ.
class _DeckLayer extends StatelessWidget {
  const _DeckLayer({required this.angle, required this.color});

  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          border: Border.all(color: context.palette.cardBorder),
        ),
      ),
    );
  }
}

/// Nhãn cấp độ viền đỏ son ở góc thẻ, vd. "N5".
class _LevelBadge extends StatelessWidget {
  const _LevelBadge(this.level);

  final String level;

  @override
  Widget build(BuildContext context) {
    final stamp = context.palette.stamp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: stamp, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: stamp,
        ),
      ),
    );
  }
}

/// Mặt chữ Nhật của thẻ: kanji (nếu có), kana, romaji (tùy chọn học) và nút
/// nghe phát âm.
class _JapaneseFace extends StatelessWidget {
  const _JapaneseFace({
    required this.word,
    required this.showRomaji,
    required this.hint,
  });

  final Vocabulary word;
  final bool showRomaji;
  final _CardHint hint;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasKanji = word.kanji.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _LevelBadge(word.jlptLevel),
          ),
          const Spacer(),
          if (hasKanji)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word.kanji,
                style: AppTextStyles.japaneseDisplay.copyWith(
                  fontSize: 96,
                  color: palette.textPrimary,
                ),
              ),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word.kana,
              style: AppTextStyles.japaneseDisplay.copyWith(
                fontSize: hasKanji ? 22 : 48,
                letterSpacing: hasKanji ? 6 : 2,
                color: hasKanji ? palette.primary : palette.textPrimary,
              ),
            ),
          ),
          if (showRomaji) ...[
            const SizedBox(height: 4),
            Text(
              word.romaji,
              style: TextStyle(fontSize: 15, color: palette.textMuted),
            ),
          ],
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.primary, width: 1.5),
            ),
            child: SpeakButton(text: word.kana, size: 22),
          ),
          const Spacer(),
          hint,
        ],
      ),
    );
  }
}

/// Mặt nghĩa của thẻ. [revealJapanese] thì kèm cách viết và câu ví dụ; tắt
/// khi mặt này nằm trước để không lộ đáp án.
class _MeaningFace extends StatelessWidget {
  const _MeaningFace({
    required this.word,
    required this.revealJapanese,
    required this.hint,
  });

  final Vocabulary word;
  final bool revealJapanese;
  final _CardHint hint;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.accentSurface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: palette.accentBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('NGHĨA', style: palette.sectionLabel),
          const Spacer(),
          if (revealJapanese) ...[
            Text(
              word.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: palette.textSecondary),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            word.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          if (revealJapanese) ...[
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
                  Text(
                    word.exampleJapanese,
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(word.exampleVietnamese, style: palette.body),
                ],
              ),
            ),
          ],
          const Spacer(),
          hint,
        ],
      ),
    );
  }
}
