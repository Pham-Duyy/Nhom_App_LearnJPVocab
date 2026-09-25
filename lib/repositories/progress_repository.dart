import '../models/progress.dart';

abstract class ProgressRepository {
  Future<List<Progress>> getAll();

  Future<Progress?> getByVocabularyId(String vocabularyId);

  Future<List<Progress>> getDueForReview(DateTime now);

  Future<void> save(Progress progress);
}
