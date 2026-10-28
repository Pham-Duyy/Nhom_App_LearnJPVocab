import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/models/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 15, 12);

  test('tạo đúng 9 Progress mẫu, tất cả đã học', () {
    final progress = MockLearningData.createInitialProgress(now: fixedNow);

    expect(progress.length, 9);
    expect(progress.every((p) => p.isLearned), isTrue);
  });

  test('phân bố mức ghi nhớ đúng 3-3-1-1-1', () {
    final progress = MockLearningData.createInitialProgress(now: fixedNow);

    final countByLevel = <int, int>{};
    for (final p in progress) {
      countByLevel[p.memoryLevel] = (countByLevel[p.memoryLevel] ?? 0) + 1;
    }

    expect(countByLevel, {1: 3, 2: 3, 3: 1, 4: 1, 5: 1});
  });

  test(
      'đúng 3 từ đến hạn ôn tại thời điểm cố định, 6 từ còn lại trong tương lai',
      () {
    final progress = MockLearningData.createInitialProgress(now: fixedNow);

    final dueCount = progress.where((p) => p.isDueForReview(fixedNow)).length;

    expect(dueCount, 3);
    expect(progress.length - dueCount, 6);
  });

  group('nội dung học mẫu', () {
    const categories = MockLearningData.categories;
    const lessons = MockLearningData.lessons;
    final words = MockLearningData.vocabulary;

    test(
        '9 chủ đề N5, 3 chủ đề ngành, 3 chủ đề N4, 3 chủ đề N3: 36 bài, 330 từ',
        () {
      final industry =
          categories.where((c) => c.jlptLevel == Category.industryLevel).length;
      expect(industry, 3);
      expect(categories.where((c) => c.jlptLevel == 'N4'), hasLength(3));
      expect(categories.where((c) => c.jlptLevel == 'N3'), hasLength(3));
      expect(categories, hasLength(18));
      expect(lessons, hasLength(36));
      expect(words, hasLength(330));
    });

    test('id không trùng, mỗi bài và mỗi từ đều thuộc về một mục có thật', () {
      final categoryIds = categories.map((c) => c.id).toSet();
      final lessonIds = lessons.map((l) => l.id).toSet();

      expect(categoryIds, hasLength(categories.length));
      expect(lessonIds, hasLength(lessons.length));
      expect(words.map((w) => w.id).toSet(), hasLength(words.length));
      for (final lesson in lessons) {
        expect(categoryIds, contains(lesson.categoryId), reason: lesson.id);
      }
      for (final word in words) {
        expect(lessonIds, contains(word.lessonId), reason: word.id);
      }
    });

    test('vocabularyCount của mỗi bài khớp số từ thật', () {
      for (final lesson in lessons) {
        final count = words.where((w) => w.lessonId == lesson.id).length;
        expect(count, lesson.vocabularyCount, reason: lesson.id);
      }
    });

    // Quiz cần đáp án khác nhau: hai từ trùng cách đọc hoặc trùng nghĩa sẽ
    // khiến một câu có hai đáp án đúng.
    test('không có hai từ trùng cách đọc hoặc trùng nghĩa', () {
      expect(words.map((w) => w.kana).toSet(), hasLength(words.length));
      expect(words.map((w) => w.meaning).toSet(), hasLength(words.length));
    });

    test('từ nào cũng có đủ cách đọc, nghĩa và câu ví dụ', () {
      for (final word in words) {
        expect(
          [
            word.kana,
            word.romaji,
            word.meaning,
            word.exampleJapanese,
            word.exampleVietnamese,
          ],
          everyElement(isNotEmpty),
          reason: word.id,
        );
        final lesson = lessons.firstWhere((l) => l.id == word.lessonId);
        expect(word.jlptLevel, lesson.jlptLevel, reason: word.id);
      }
    });
  });

  test('mọi vocabularyId đều tồn tại trong danh sách từ mẫu', () {
    final progress = MockLearningData.createInitialProgress(now: fixedNow);
    final knownIds = MockLearningData.vocabulary.map((v) => v.id).toSet();

    for (final p in progress) {
      expect(
        knownIds.contains(p.vocabularyId),
        isTrue,
        reason:
            '${p.vocabularyId} phải tồn tại trong MockLearningData.vocabulary',
      );
    }
  });
}
