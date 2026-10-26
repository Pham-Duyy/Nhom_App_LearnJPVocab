import 'dart:math';

import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/data/quiz_generator.dart';
import 'package:chibakanji/providers/exam_provider.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/flaky_repositories.dart';

final _n5Words =
    MockLearningData.vocabulary.where((w) => w.jlptLevel == 'N5').toList();

ExamProvider _exam(
  MockQuizAttemptRepository attempts, {
  Future<void> Function()? onSaved,
}) {
  final exam = ExamProvider(
    attempts,
    generator: QuizGenerator(random: Random(7)),
    clock: () => DateTime(2026, 1, 15, 9),
    onSaved: onSaved,
  );
  addTearDown(exam.dispose);
  return exam;
}

/// Chọn đáp án cho mọi câu: đúng ở [correct] câu đầu, sai ở các câu còn lại.
void _answerAll(ExamProvider exam, {required int correct}) {
  for (var i = 0; i < exam.questions.length; i++) {
    exam.goTo(i);
    final question = exam.questions[i];
    exam.select(
      i < correct
          ? question.correctIndex
          : (question.correctIndex + 1) % question.options.length,
    );
  }
}

void main() {
  group('US21: bắt đầu thi thử', () {
    test('ra đúng số câu và tính giờ 30 giây mỗi câu', () {
      final exam = _exam(MockQuizAttemptRepository());

      final started = exam.start(level: 'N5', words: _n5Words);

      expect(started, isTrue);
      expect(exam.questions, hasLength(ExamProvider.defaultQuestionCount));
      expect(exam.remaining, const Duration(minutes: 10));
      expect(exam.title, 'Thi thử N5');
      expect(exam.answeredCount, 0);
    });

    test('không đủ từ thì không bắt đầu được', () {
      final exam = _exam(MockQuizAttemptRepository());

      expect(
          exam.start(level: 'N5', words: _n5Words.take(3).toList()), isFalse);
      expect(exam.questions, isEmpty);
    });
  });

  group('US21: làm bài', () {
    test('đổi được đáp án và nhảy qua lại giữa các câu', () {
      final exam = _exam(MockQuizAttemptRepository())
        ..start(level: 'N5', words: _n5Words, questionCount: 10);

      exam.select(0);
      exam.select(2);
      exam.next();
      exam.previous();

      expect(exam.currentIndex, 0);
      expect(exam.selectedAt(0), 2);
      expect(exam.answeredCount, 1);
      expect(exam.unansweredCount, 9);
    });

    test('không đi quá câu đầu hoặc câu cuối', () {
      final exam = _exam(MockQuizAttemptRepository())
        ..start(level: 'N5', words: _n5Words, questionCount: 10);

      exam.previous();
      expect(exam.currentIndex, 0);
      exam.goTo(9);
      exam.next();
      expect(exam.currentIndex, 9);
      expect(exam.isLastQuestion, isTrue);
    });
  });

  group('US21: nộp bài và chấm điểm', () {
    test('đúng 6/10 là đạt; kết quả được lưu vào lịch sử', () async {
      final attempts = MockQuizAttemptRepository();
      var savedCalls = 0;
      final exam = _exam(attempts, onSaved: () async => savedCalls++)
        ..start(level: 'N5', words: _n5Words, questionCount: 10);
      _answerAll(exam, correct: 6);

      await exam.submit();

      expect(exam.result!.correctCount, 6);
      expect(exam.passed, isTrue);
      expect(await attempts.getAll(), [exam.result]);
      expect(exam.result!.quizId, 'exam-N5');
      expect(savedCalls, 1);
    });

    test('đúng 5/10 là chưa đạt', () async {
      final exam = _exam(MockQuizAttemptRepository())
        ..start(level: 'N5', words: _n5Words, questionCount: 10);
      _answerAll(exam, correct: 5);

      await exam.submit();

      expect(exam.result!.correctCount, 5);
      expect(exam.passed, isFalse);
    });

    test('câu chưa làm tính là sai', () async {
      final exam = _exam(MockQuizAttemptRepository())
        ..start(level: 'N5', words: _n5Words, questionCount: 10);

      await exam.submit();

      expect(exam.result!.correctCount, 0);
      expect(exam.passed, isFalse);
    });

    test('đã nộp thì không đổi được đáp án nữa', () async {
      final exam = _exam(MockQuizAttemptRepository())
        ..start(level: 'N5', words: _n5Words, questionCount: 10);
      await exam.submit();

      exam.select(1);

      expect(exam.selectedAt(0), isNull);
    });

    test('8a: lưu thất bại vẫn có kết quả và báo lỗi dễ hiểu', () async {
      final attempts = FlakyQuizAttemptRepository()..failure = offlineError;
      final exam = _exam(attempts)
        ..start(level: 'N5', words: _n5Words, questionCount: 10);

      await exam.submit();

      expect(exam.isFinished, isTrue);
      expect(exam.errorMessage, contains('lưu kết quả bài thi'));
      expect(exam.errorMessage, isNot(contains('abc123')));
    });
  });

  group('US21: hết giờ', () {
    test('mỗi tick trừ một giây, hết giờ thì tự nộp bài', () {
      final exam = _exam(MockQuizAttemptRepository())
        ..start(level: 'N5', words: _n5Words, questionCount: 10);

      exam.tick();
      expect(exam.remaining, const Duration(minutes: 4, seconds: 59));

      for (var i = 0; i < 299; i++) {
        exam.tick();
      }

      expect(exam.remaining, Duration.zero);
      expect(exam.isFinished, isTrue);
    });

    test('thoát giữa chừng thì không chấm, không lưu', () async {
      final attempts = MockQuizAttemptRepository();
      final exam = _exam(attempts)
        ..start(level: 'N5', words: _n5Words, questionCount: 10);

      exam.cancel();

      expect(exam.questions, isEmpty);
      expect(exam.isFinished, isFalse);
      expect(await attempts.getAll(), isEmpty);
    });
  });
}
