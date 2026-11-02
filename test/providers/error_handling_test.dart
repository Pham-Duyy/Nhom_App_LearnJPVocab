import 'dart:async';

import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/models/category.dart';
import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/providers/lesson_provider.dart';
import 'package:chibakanji/providers/progress_provider.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/providers/vocabulary_provider.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/flaky_repositories.dart';

void main() {
  group('8a: lỗi khi tải dữ liệu', () {
    test('mất mạng khi tải chủ đề: báo dễ hiểu, thử lại khi có mạng là được',
        () async {
      final repository = FlakyCategoryRepository()..failure = offlineError;
      final provider = LessonProvider(repository);

      await provider.loadCategories();
      expect(provider.errorMessage, startsWith('Không có kết nối mạng'));
      expect(provider.errorMessage, isNot(contains('abc123')));
      expect(provider.isLoading, isFalse);

      repository.failure = null;
      await provider.loadCategories();
      expect(provider.errorMessage, isNull);
      expect(provider.categories, isNotEmpty);
    });

    test('lỗi khi tải bài học của một chủ đề cũng được báo', () async {
      final repository = FlakyCategoryRepository()..failure = offlineError;
      final provider = LessonProvider(repository);
      const category =
          Category(id: 'cat_greetings', name: 'C', description: '', order: 1);

      await provider.selectCategory(category);

      expect(provider.errorMessage, contains('tải danh sách bài học'));
      expect(provider.lessons, isEmpty);
    });

    test('flashcard tải từ lỗi thì retry() tải lại đúng bài đó', () async {
      final repository = FlakyVocabularyRepository()..failure = offlineError;
      final provider = VocabularyProvider(repository);

      await provider.loadByLesson('les_greetings_1');
      expect(provider.errorMessage, isNotNull);
      expect(provider.words, isEmpty);

      repository.failure = null;
      await provider.retry();
      expect(provider.errorMessage, isNull);
      expect(provider.words, hasLength(5));
    });

    test('lỗi khi tải tiến độ học không lộ chi tiết kỹ thuật', () async {
      final provider = ProgressProvider(
        FlakyProgressRepository()..failure = StateError('token=abc123'),
      );

      await provider.loadProgress();

      expect(provider.errorMessage,
          'Không thể tải tiến độ học. Vui lòng thử lại.');
    });
  });

  group('8a: lỗi khi lưu dữ liệu', () {
    test('đánh dấu yêu thích lỗi thì báo lỗi và giữ nguyên trạng thái cũ',
        () async {
      final repository = FlakyProgressRepository(
        initialProgress: const [Progress(vocabularyId: 'v1')],
      );
      final provider = ProgressProvider(repository);
      await provider.loadProgress();

      repository.failure = offlineError;
      final error = await provider.toggleFavorite('v1');

      expect(error, contains('lưu từ yêu thích'));
      expect(provider.favoriteCount, 0);
    });

    test('đánh dấu yêu thích thành công thì không có lỗi', () async {
      final provider = ProgressProvider(FlakyProgressRepository());

      expect(await provider.toggleFavorite('v1'), isNull);
      expect(provider.favoriteCount, 1);
    });

    test('lưu tiến độ thẻ lỗi thì ném lỗi để màn flashcard cho thử lại',
        () async {
      final provider = ProgressProvider(
        FlakyProgressRepository()..failure = offlineError,
      );

      await expectLater(provider.markCorrect('v1'), throwsA(offlineError));
      expect(provider.totalLearned, 0);
    });

    test('quiz vẫn chạy tiếp khi lưu kết quả từng câu bị lỗi', () async {
      final quiz = QuizProvider(
        MockQuizAttemptRepository(),
        MockVocabularyRepository(),
        onAnswer: (_, __) => Future.error(offlineError),
      );
      quiz.start(
        quizId: 'q',
        title: 'T',
        words: MockLearningData.vocabulary.take(5).toList(),
      );

      // Lỗi của callback được bắt bên trong, không lọt ra ngoài zone.
      await runZonedGuarded(
        () async {
          quiz.answer(0);
          await Future<void>.delayed(Duration.zero);
        },
        (error, _) => fail('Lỗi lọt ra ngoài: $error'),
      );

      expect(quiz.isAnswered, isTrue);
      await quiz.next();
      expect(quiz.currentIndex, 1);
    });
  });
}
