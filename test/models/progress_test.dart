import 'package:chibakanji/models/progress.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 1, 15, 9);

void main() {
  group('US09: Progress.markCorrect', () {
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

  group('US09: Progress.markWrong', () {
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

  group('US11: nextReviewAt được tính theo mức ghi nhớ', () {
    test('lịch ôn tính từ thời điểm trả lời được truyền vào', () {
      const progress = Progress(vocabularyId: 'v1', memoryLevel: 2);

      final correct = progress.markCorrect(_now);
      final wrong = progress.markWrong(_now);

      expect(correct.lastReviewedAt, _now);
      expect(correct.nextReviewAt, DateTime(2026, 1, 22, 9));
      expect(wrong.nextReviewAt, DateTime(2026, 1, 16, 9));
    });

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

  group('US11: Progress.isDueForReview', () {
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
