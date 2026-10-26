import 'package:chibakanji/models/achievement.dart';
import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/models/quiz_attempt.dart';
import 'package:flutter_test/flutter_test.dart';

Achievement _byId(String id) => Achievement.all.firstWhere((a) => a.id == id);

QuizAttempt _quiz(int correct, int total) => QuizAttempt(
      id: 'q$correct-$total',
      quizId: 'q',
      totalQuestions: total,
      correctCount: correct,
      startedAt: DateTime(2026, 10, 26),
    );

void main() {
  test('LearningStats đếm đúng từ đã học, từ nhớ vững và quiz điểm tuyệt đối',
      () {
    final stats = LearningStats.from(
      progress: const [
        Progress(vocabularyId: 'a', isLearned: true, memoryLevel: 5),
        Progress(vocabularyId: 'b', isLearned: true, memoryLevel: 2),
        Progress(vocabularyId: 'c'),
      ],
      quizzes: [_quiz(5, 5), _quiz(3, 5)],
      longestStreak: 4,
      completedCategories: 1,
    );

    expect(stats.learnedWords, 2);
    expect(stats.masteredWords, 1);
    expect(stats.quizzesTaken, 2);
    expect(stats.perfectQuizzes, 1);
  });

  test('chưa học gì thì chưa đạt huy hiệu nào', () {
    const stats = LearningStats();

    expect(Achievement.all.where((a) => a.isUnlocked(stats)), isEmpty);
  });

  test('đủ mục tiêu thì đạt, tiến độ không vượt quá mục tiêu', () {
    const stats = LearningStats(learnedWords: 25);

    expect(_byId('first_word').isUnlocked(stats), isTrue);
    expect(_byId('words_10').isUnlocked(stats), isTrue);
    expect(_byId('words_10').progressOf(stats), 10);
    expect(_byId('words_30').isUnlocked(stats), isFalse);
    expect(_byId('words_30').progressOf(stats), 25);
  });

  test('huy hiệu chuỗi ngày xét theo chuỗi dài nhất, không mất khi chuỗi đứt',
      () {
    const stats = LearningStats(longestStreak: 7);

    expect(_byId('streak_3').isUnlocked(stats), isTrue);
    expect(_byId('streak_7').isUnlocked(stats), isTrue);
  });

  test('mọi huy hiệu có id riêng và mục tiêu dương', () {
    final ids = Achievement.all.map((a) => a.id).toSet();

    expect(ids, hasLength(Achievement.all.length));
    expect(Achievement.all.every((a) => a.target > 0), isTrue);
  });
}
