import '../../models/progress.dart';
import '../progress_repository.dart';
import 'in_memory_repository.dart';

/// Tiến độ lưu trong bộ nhớ, dùng cho test và chạy không cần Firebase.
class MockProgressRepository extends InMemoryRepository<Progress>
    implements ProgressRepository {
  MockProgressRepository({List<Progress> initialProgress = const []})
      : super(
          idOf: (progress) => progress.vocabularyId,
          initialItems: initialProgress,
        );
}
