import '../models/vocabulary.dart';

abstract class VocabularyRepository {
  Future<List<Vocabulary>> getByLesson(String lessonId);

  Future<Vocabulary?> getById(String vocabularyId);

  /// Trả về các từ có id nằm trong [vocabularyIds], theo đúng thứ tự của
  /// [vocabularyIds] (không phải thứ tự lưu trữ). Id không tồn tại bị bỏ
  /// qua thay vì gây lỗi.
  Future<List<Vocabulary>> getByIds(List<String> vocabularyIds);

  Future<List<Vocabulary>> search(String keyword);
}
