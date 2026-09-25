import 'package:chibakanji/models/question.dart';
import 'package:chibakanji/models/quiz_attempt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Question', () {
    const question = Question(
      id: 'q1',
      quizId: 'quiz1',
      prompt: '"学校" đọc là gì?',
      options: ['がっこう', 'がくせい', 'せんせい'],
      correctIndex: 0,
      explanation: '学校 = trường học.',
      order: 1,
    );

    test('isCorrect chỉ đúng với đúng index của đáp án đúng', () {
      expect(question.isCorrect(0), isTrue);
      expect(question.isCorrect(1), isFalse);
    });

    test('isValid phát hiện correctIndex ngoài phạm vi options', () {
      final outOfRange = question.copyWith(correctIndex: 3);

      expect(question.isValid, isTrue);
      expect(outOfRange.isValid, isFalse);
    });

    test('fromMap(toMap()) giữ nguyên danh sách đáp án và explanation', () {
      final restored = Question.fromMap(question.toMap());

      expect(restored.options, question.options);
      expect(restored.correctIndex, question.correctIndex);
      expect(restored.explanation, question.explanation);
    });
  });

  group('QuizAttempt', () {
    final startedAt = DateTime(2026, 1, 15, 9);

    test('scorePercent tính đúng phần trăm số câu đúng', () {
      final attempt = QuizAttempt(
        id: 'a1',
        quizId: 'quiz1',
        totalQuestions: 4,
        correctCount: 3,
        startedAt: startedAt,
      );

      expect(attempt.scorePercent, 75);
    });

    test('quiz không có câu hỏi có điểm 0 thay vì chia cho 0', () {
      final attempt = QuizAttempt(
        id: 'a2',
        quizId: 'quiz1',
        totalQuestions: 0,
        startedAt: startedAt,
      );

      expect(attempt.scorePercent, 0);
    });

    test('isCompleted chỉ true khi đã có completedAt', () {
      final inProgress = QuizAttempt(
        id: 'a3',
        quizId: 'quiz1',
        totalQuestions: 2,
        startedAt: startedAt,
      );
      final done = inProgress.copyWith(
        completedAt: startedAt.add(const Duration(minutes: 3)),
      );

      expect(inProgress.isCompleted, isFalse);
      expect(done.isCompleted, isTrue);
    });

    test('fromMap(toMap()) giữ nguyên thời gian và đáp án đã chọn', () {
      final attempt = QuizAttempt(
        id: 'a4',
        quizId: 'quiz1',
        totalQuestions: 2,
        correctCount: 1,
        selectedAnswers: const {'q1': 0, 'q2': 2},
        startedAt: startedAt,
        completedAt: startedAt.add(const Duration(minutes: 3)),
      );

      final restored = QuizAttempt.fromMap(attempt.toMap());

      expect(restored.startedAt, attempt.startedAt);
      expect(restored.completedAt, attempt.completedAt);
      expect(restored.selectedAnswers, attempt.selectedAnswers);
    });
  });
}
