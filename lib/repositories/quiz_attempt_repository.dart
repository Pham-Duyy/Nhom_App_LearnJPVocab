import '../models/quiz_attempt.dart';
import 'repository.dart';

/// Lịch sử các lần làm quiz của người dùng, khóa là [QuizAttempt.id].
abstract class QuizAttemptRepository
    implements Repository<QuizAttempt, String> {}
