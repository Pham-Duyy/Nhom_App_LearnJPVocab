import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/progress.dart';
import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../../widgets/memory_level_chip.dart';
import '../common/generic_screen.dart';
import '../flashcard/flashcard_screen.dart';

class VocabularyHeroText extends StatelessWidget {
  const VocabularyHeroText({
    Key? key,
    required this.word,
    required this.fontSize,
    this.alignment = Alignment.centerLeft,
  }) : super(key: key);

  final Vocabulary word;
  final double fontSize;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'vocabulary-${word.id}',
      child: Material(
        type: MaterialType.transparency,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: Text(
            word.name,
            maxLines: 1,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontFamilyFallback: AppTextStyles.fontFamilyFallback,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class VocabularyDetailScreen extends GenericScreen {
  const VocabularyDetailScreen({Key? key, required this.word})
      : super(key: key);

  final Vocabulary word;

  @override
  String getTitle(BuildContext context) => 'Chi tiết từ';

  Future<void> _reviewThisWord(BuildContext context) async {
    final vocabularyProvider = context.read<VocabularyProvider>();
    await vocabularyProvider.loadReviewWords([word.id]);
    if (!context.mounted) return;

    if (vocabularyProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vocabularyProvider.errorMessage!)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FlashcardScreen(
          title: 'Ôn từ này',
          completionTitle: 'Đã ôn xong từ này!',
        ),
      ),
    );
  }

  String _nextReviewLabel(Progress progress) {
    final next = progress.nextReviewAt;
    if (next == null || progress.isDueForReview()) return 'Đến hạn ôn';
    return 'Ôn lại ngày ${next.day}/${next.month}';
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<ProgressProvider>();
    final progress = provider.progressList.firstWhere(
      (p) => p.vocabularyId == word.id,
      orElse: () => Progress(vocabularyId: word.id),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      children: [
        Center(
          child: VocabularyHeroText(
            word: word,
            fontSize: 52,
            alignment: Alignment.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${word.kana} · ${word.romaji}',
          textAlign: TextAlign.center,
          style: palette.body.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 18),
        Text(
          word.meaning,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Center(child: MemoryLevelChip(progress: progress)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.lavenderSurface,
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
            border: Border.all(color: palette.lavenderBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VÍ DỤ', style: palette.sectionLabel),
              const SizedBox(height: 12),
              Text(word.exampleJapanese, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              Text(word.exampleVietnamese, style: palette.body),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: palette.mutedSurface,
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _DetailStat(
                    value: '${progress.reviewCount}',
                    label: 'Lần ôn',
                  ),
                ),
                VerticalDivider(color: palette.lavenderBorder),
                Expanded(
                  child: _DetailStat(
                    value: '${progress.correctCount}/${progress.wrongCount}',
                    label: 'Nhớ / Quên',
                  ),
                ),
                VerticalDivider(color: palette.lavenderBorder),
                Expanded(
                  child: _DetailStat(
                    value: _nextReviewLabel(progress),
                    label: 'Lịch ôn',
                    small: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => _reviewThisWord(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.style_outlined),
              SizedBox(width: 10),
              Text('Ôn từ này'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final error = await provider.toggleFavorite(word.id);
            if (error != null && context.mounted) {
              showErrorSnackBar(context, error);
            }
          },
          icon: Icon(
            progress.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: palette.favorite,
          ),
          label: Text(
            progress.isFavorite ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích',
          ),
        ),
      ],
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.value,
    required this.label,
    this.small = false,
  });

  final String value;
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: small ? 14 : 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style:
                TextStyle(fontSize: 12, color: context.palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
