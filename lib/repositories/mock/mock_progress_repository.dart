import '../../models/progress.dart';
import '../progress_repository.dart';

/// Lưu tiến độ trong bộ nhớ trong suốt thời gian ứng dụng chạy. Sẽ được
/// thay bằng một implementation đọc/ghi Cloud Firestore ở giai đoạn sau,
/// giữ nguyên interface [ProgressRepository].
class MockProgressRepository implements ProgressRepository {
  MockProgressRepository({List<Progress> initialProgress = const []}) {
    for (final progress in initialProgress) {
      _store[progress.vocabularyId] = progress;
    }
  }

  final Map<String, Progress> _store = {};

  @override
  Future<List<Progress>> getAll() async {
    return _store.values.toList();
  }

  @override
  Future<Progress?> getByVocabularyId(String vocabularyId) async {
    return _store[vocabularyId];
  }

  @override
  Future<List<Progress>> getDueForReview(DateTime now) async {
    return _store.values
        .where((progress) => progress.isDueForReview(now))
        .toList();
  }

  @override
  Future<void> save(Progress progress) async {
    _store[progress.vocabularyId] = progress;
  }
}
