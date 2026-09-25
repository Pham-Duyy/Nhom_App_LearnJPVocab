import '../models/vocabulary.dart';

abstract class VocabularyRepository {
  Future<List<Vocabulary>> getByLesson(String lessonId);

  Future<Vocabulary?> getById(String vocabularyId);

  Future<List<Vocabulary>> search(String keyword);
}
