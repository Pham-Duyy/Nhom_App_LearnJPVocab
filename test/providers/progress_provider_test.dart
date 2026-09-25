import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/providers/progress_provider.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tính đúng tổng số từ đã học và số lượng theo từng mức', () async {
    final repository = MockProgressRepository();
    await repository.save(const Progress(
      vocabularyId: 'v1',
      memoryLevel: 2,
      isLearned: true,
    ));
    await repository.save(const Progress(
      vocabularyId: 'v2',
      memoryLevel: 2,
      isLearned: true,
    ));
    await repository.save(const Progress(
      vocabularyId: 'v3',
      memoryLevel: 1,
      isLearned: false,
    ));

    final provider = ProgressProvider(repository);
    await provider.loadProgress();

    expect(provider.totalLearned, 2);
    expect(provider.getCountForLevel(2), 2);
    expect(provider.getCountForLevel(1), 1);
  });

  test('markCorrect cập nhật provider và lưu vào repository', () async {
    final repository = MockProgressRepository();
    final provider = ProgressProvider(repository);
    await provider.loadProgress();

    await provider.markCorrect('v1');

    expect(provider.getCountForLevel(2), 1);
    expect(provider.totalLearned, 1);

    final saved = await repository.getByVocabularyId('v1');
    expect(saved, isNotNull);
    expect(saved!.memoryLevel, 2);
  });

  test('markWrong đưa từ về mức 1 và phản ánh ngay trong thống kê', () async {
    final repository = MockProgressRepository();
    await repository.save(const Progress(vocabularyId: 'v1', memoryLevel: 4));
    final provider = ProgressProvider(repository);
    await provider.loadProgress();

    await provider.markWrong('v1');

    expect(provider.getCountForLevel(1), 1);
    expect(provider.getCountForLevel(4), 0);
  });
}
