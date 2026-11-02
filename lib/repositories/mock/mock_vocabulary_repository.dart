import '../../data/mock/mock_learning_data.dart';
import '../../models/vocabulary.dart';
import '../repository.dart';
import '../vocabulary_repository.dart';
import 'in_memory_repository.dart';

/// Từ vựng mẫu trong bộ nhớ, dùng cho test và chạy không cần Firebase.
class MockVocabularyRepository extends InMemoryRepository<Vocabulary>
    implements VocabularyRepository {
  MockVocabularyRepository()
      : super(
          idOf: (word) => word.id,
          initialItems: MockLearningData.vocabulary,
        );

  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) async => sortByOrder(
        (await getAll()).where((word) => word.lessonId == lessonId).toList(),
      );

  @override
  Future<List<Vocabulary>> search(String keyword) async =>
      (await getAll()).where((word) => word.matches(keyword)).toList();
}
