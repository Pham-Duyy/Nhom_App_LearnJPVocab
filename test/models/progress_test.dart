import 'package:chibakanji/models/progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Progress.markCorrect', () {
    test('tăng memoryLevel lên 1 mỗi lần trả lời đúng', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 2);
      final updated = progress.markCorrect();

      expect(updated.memoryLevel, 3);
      expect(updated.correctCount, 1);
      expect(updated.reviewCount, 1);
      expect(updated.isLearned, isTrue);
    });

    test('không vượt quá mức 5', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 5);
      final updated = progress.markCorrect();

      expect(updated.memoryLevel, 5);
    });
  });

  group('Progress.markWrong', () {
    test('đưa memoryLevel về 1 dù đang ở mức cao', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 4);
      final updated = progress.markWrong();

      expect(updated.memoryLevel, 1);
      expect(updated.wrongCount, 1);
      expect(updated.reviewCount, 1);
    });

    test('trả lời sai vẫn đánh dấu từ đã học', () {
      const progress = Progress(vocabularyId: 'v1');
      final updated = progress.markWrong();

      expect(updated.isLearned, isTrue);
    });
  });

  group('nextReviewAt được tính theo mức ghi nhớ', () {
    test('mức 1: ôn lại sau 1 ngày', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 3);
      final updated = progress.markWrong();
      final days =
          updated.nextReviewAt!.difference(updated.lastReviewedAt!).inDays;

      expect(days, 1);
    });

    test('mức 2 (đúng từ mức 1): ôn lại sau 3 ngày', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 1);
      final updated = progress.markCorrect();
      final days =
          updated.nextReviewAt!.difference(updated.lastReviewedAt!).inDays;

      expect(updated.memoryLevel, 2);
      expect(days, 3);
    });

    test('mức 5 (đúng từ mức 4): ôn lại sau 30 ngày', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 4);
      final updated = progress.markCorrect();
      final days =
          updated.nextReviewAt!.difference(updated.lastReviewedAt!).inDays;

      expect(updated.memoryLevel, 5);
      expect(days, 30);
    });
  });

  group('Progress.isDueForReview', () {
    test('true khi chưa từng được ôn (nextReviewAt null)', () {
      const progress = Progress(vocabularyId: 'v1');

      expect(progress.isDueForReview(), isTrue);
    });

    test('true khi nextReviewAt đã qua', () {
      final progress = Progress(
        vocabularyId: 'v1',
        nextReviewAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(progress.isDueForReview(), isTrue);
    });

    test('false khi nextReviewAt còn trong tương lai', () {
      final progress = Progress(
        vocabularyId: 'v1',
        nextReviewAt: DateTime.now().add(const Duration(days: 5)),
      );

      expect(progress.isDueForReview(), isFalse);
    });
  });
}
