import 'dart:math';

import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/data/quiz_generator.dart';
import 'package:chibakanji/models/quiz_attempt.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository lịch sử luôn lỗi khi lưu, để kiểm tra nhánh xử lý lỗi.
class _FailingAttemptRepository extends MockQuizAttemptRepository {
  @override
  Future<void> save(QuizAttempt item) async => throw Exception('mất mạng');
}

void main() {
  final words = MockLearningData.vocabulary.take(6).toList();
  late MockQuizAttemptRepository attempts;
  late List<(String, bool)> answered;

  QuizProvider createProvider({MockQuizAttemptRepository? repository}) {
    return QuizProvider(
      repository ?? attempts,
      MockVocabularyRepository(),
      generator: QuizGenerator(random: Random(7)),
      onAnswer: (id, isCorrect) async => answered.add((id, isCorrect)),
      clock: () => DateTime(2026, 10, 26, 9),
    );
  }

  /// Trả lời hết các câu; [correct] quyết định chọn đáp án đúng hay sai.
  Future<void> answerAll(QuizProvider quiz, {required bool correct}) async {
    while (!quiz.isFinished) {
      final question = quiz.currentQuestion!;
      quiz.answer(correct
          ? question.correctIndex
          : (question.correctIndex + 1) % question.options.length);
      await quiz.next();
    }
  }

  setUp(() {
    attempts = MockQuizAttemptRepository();
    answered = [];
  });

  group('US16: làm quiz', () {
    test('không đủ từ thì không bắt đầu được', () {
      final quiz = createProvider();

      expect(quiz.start(quizId: 'q', title: 'T', words: words.take(3).toList()),
          isFalse);
      expect(quiz.currentQuestion, isNull);
    });

    test('mỗi câu chỉ được chọn đáp án một lần', () {
      final quiz = createProvider()
        ..start(quizId: 'q', title: 'T', words: words);
      final question = quiz.currentQuestion!;

      quiz.answer(question.correctIndex);
      quiz.answer((question.correctIndex + 1) % 4);

      expect(quiz.selectedIndex, question.correctIndex);
      expect(quiz.correctCount, 1);
      expect(answered, hasLength(1));
    });

    test('chưa chọn đáp án thì không sang câu tiếp theo được', () async {
      final quiz = createProvider()
        ..start(quizId: 'q', title: 'T', words: words);

      await quiz.next();

      expect(quiz.currentIndex, 0);
    });

    test('báo đúng/sai của từng từ ra ngoài qua onAnswer', () async {
      final quiz = createProvider()
        ..start(quizId: 'q', title: 'T', words: words);
      final first = quiz.currentQuestion!;

      quiz.answer((first.correctIndex + 1) % 4);

      expect(answered.single, (first.vocabularyId, false));
    });

    test('trả lời sai thì câu đó có trong danh sách cần ôn lại', () async {
      final quiz = createProvider()
        ..start(quizId: 'q', title: 'T', words: words);

      await answerAll(quiz, correct: false);

      expect(quiz.correctCount, 0);
      expect(quiz.wrongQuestions, hasLength(quiz.questions.length));
    });
  });

  group('US17: lưu và xem lịch sử', () {
    test('làm xong thì lưu một lượt với đúng điểm và tên', () async {
      final quiz = createProvider()
        ..start(quizId: 'lesson-1', title: 'Chào hỏi', words: words);

      await answerAll(quiz, correct: true);

      final saved = await attempts.getAll();
      expect(saved, hasLength(1));
      expect(saved.single.title, 'Chào hỏi');
      expect(saved.single.correctCount, quiz.questions.length);
      expect(saved.single.scorePercent, 100);
      expect(quiz.history.first, saved.single);
    });

    test('lịch sử xếp lần làm mới nhất lên đầu', () async {
      attempts = MockQuizAttemptRepository(initialAttempts: [
        QuizAttempt(
          id: 'old',
          quizId: 'q',
          totalQuestions: 5,
          startedAt: DateTime(2026, 10, 1),
        ),
        QuizAttempt(
          id: 'new',
          quizId: 'q',
          totalQuestions: 5,
          startedAt: DateTime(2026, 10, 20),
        ),
      ]);
      final quiz = createProvider();

      await quiz.loadHistory();

      expect(quiz.history.map((a) => a.id), ['new', 'old']);
    });

    test('lưu lỗi thì vẫn hiện kết quả và báo lỗi', () async {
      final quiz = createProvider(repository: _FailingAttemptRepository())
        ..start(quizId: 'q', title: 'T', words: words);

      await answerAll(quiz, correct: true);

      expect(quiz.isFinished, isTrue);
      expect(quiz.errorMessage, isNotNull);
    });

    test('làm lại tạo lượt mới với cùng bộ từ', () async {
      final quiz = createProvider()
        ..start(quizId: 'q', title: 'T', words: words);
      await answerAll(quiz, correct: true);

      expect(quiz.restart(), isTrue);
      expect(quiz.isFinished, isFalse);
      expect(quiz.currentIndex, 0);
      expect(quiz.selectedIndex, isNull);
    });
  });

  group('US16: quiz nhanh từ các từ đã học', () {
    test('đủ từ thì bắt đầu được', () async {
      final quiz = createProvider();

      final error = await quiz.startWithWordIds(
        quizId: 'quick',
        title: 'Quiz nhanh',
        vocabularyIds: words.map((w) => w.id).toList(),
      );

      expect(error, isNull);
      expect(quiz.questions, isNotEmpty);
    });

    test('học chưa đủ 4 từ thì báo cần học thêm', () async {
      final quiz = createProvider();

      final error = await quiz.startWithWordIds(
        quizId: 'quick',
        title: 'Quiz nhanh',
        vocabularyIds: [words.first.id],
      );

      expect(error, contains('ít nhất'));
    });
  });
}
