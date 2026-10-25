import '../models/vocabulary.dart';
import 'repository.dart';

abstract class VocabularyRepository implements Repository<Vocabulary, String> {
  /// Các từ của một bài học, theo thứ tự trong bài.
  Future<List<Vocabulary>> getByLesson(String lessonId);

  Future<List<Vocabulary>> search(String keyword);
}
