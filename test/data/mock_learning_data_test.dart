import 'package:chibakanji/data/mock/mock_learning_data.dart';
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

  test('mọi vocabularyId đều tồn tại trong danh sách 30 từ mẫu', () {
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
