import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/providers/progress_provider.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lưu và đọc lại đúng tiến độ theo vocabularyId', () async {
    final repository = MockProgressRepository();
    const progress = Progress(
      vocabularyId: 'v1',
      memoryLevel: 3,
      correctCount: 2,
    );

    await repository.save(progress);
    final loaded = await repository.getById('v1');

    expect(loaded, isNotNull);
    expect(loaded!.memoryLevel, 3);
    expect(loaded.correctCount, 2);
  });

  test('save() ghi đè tiến độ cũ của cùng một từ thay vì cộng dồn', () async {
    final repository = MockProgressRepository();
    await repository.save(const Progress(vocabularyId: 'v1', memoryLevel: 1));
    await repository.save(const Progress(vocabularyId: 'v1', memoryLevel: 4));

    final all = await repository.getAll();

    expect(all.length, 1);
    expect(all.first.memoryLevel, 4);
  });

  test('getById trả về null với từ chưa có tiến độ', () async {
    expect(await MockProgressRepository().getById('chua-hoc'), isNull);
  });

  test('provider chỉ đưa vào danh sách ôn các từ đã đến hạn', () async {
    final now = DateTime.now();
    final provider = ProgressProvider(MockProgressRepository(initialProgress: [
      Progress(
        vocabularyId: 'due',
        nextReviewAt: now.subtract(const Duration(days: 1)),
      ),
      Progress(
        vocabularyId: 'not_due',
        nextReviewAt: now.add(const Duration(days: 5)),
      ),
    ]));
    await provider.loadProgress();

    final due = provider.getDueForReview(now);

    expect(due.map((p) => p.vocabularyId), ['due']);
  });
}
