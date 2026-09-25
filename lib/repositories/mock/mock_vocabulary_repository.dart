import '../../data/mock/mock_learning_data.dart';
import '../../models/vocabulary.dart';
import '../vocabulary_repository.dart';

/// Đọc từ vựng từ dữ liệu mock trong bộ nhớ. Sẽ được thay bằng một
/// implementation đọc Cloud Firestore ở giai đoạn sau, giữ nguyên interface.
class MockVocabularyRepository implements VocabularyRepository {
  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) async {
    final result = MockLearningData.vocabulary
        .where((word) => word.lessonId == lessonId)
        .toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  @override
  Future<Vocabulary?> getById(String vocabularyId) async {
    for (final word in MockLearningData.vocabulary) {
      if (word.id == vocabularyId) return word;
    }
    return null;
  }

  @override
  Future<List<Vocabulary>> search(String keyword) async {
    return MockLearningData.vocabulary
        .where((word) => word.matches(keyword))
        .toList();
  }
}
