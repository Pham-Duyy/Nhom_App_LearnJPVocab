import '../../models/quiz_attempt.dart';
import '../quiz_attempt_repository.dart';
import 'in_memory_repository.dart';

/// Lịch sử quiz trong bộ nhớ, dùng cho test và chạy không cần Firebase.
class MockQuizAttemptRepository extends InMemoryRepository<QuizAttempt>
    implements QuizAttemptRepository {
  MockQuizAttemptRepository({List<QuizAttempt> initialAttempts = const []})
      : super(idOf: (attempt) => attempt.id, initialItems: initialAttempts);
}
