import 'progress.dart';
import 'quiz_attempt.dart';

/// Số liệu học tập dùng để xét thành tích, tính từ dữ liệu đã có (tiến độ,
/// hồ sơ, lịch sử quiz) nên không cần lưu riêng.
class LearningStats {
  const LearningStats({
    this.learnedWords = 0,
    this.masteredWords = 0,
    this.longestStreak = 0,
    this.completedCategories = 0,
    this.quizzesTaken = 0,
    this.perfectQuizzes = 0,
  });

  factory LearningStats.from({
    required List<Progress> progress,
    required List<QuizAttempt> quizzes,
    required int longestStreak,
    required int completedCategories,
  }) {
    return LearningStats(
      learnedWords: progress.where((p) => p.isLearned).length,
      masteredWords: progress.where((p) => p.memoryLevel == 5).length,
      longestStreak: longestStreak,
      completedCategories: completedCategories,
      quizzesTaken: quizzes.length,
      perfectQuizzes: quizzes
          .where((q) => q.totalQuestions > 0 && q.scorePercent == 100)
          .length,
    );
  }

  final int learnedWords;

  /// Số từ ở mức ghi nhớ cao nhất (mức 5, "Nhớ vững").
  final int masteredWords;
  final int longestStreak;
  final int completedCategories;
  final int quizzesTaken;
  final int perfectQuizzes;
}

/// Một huy hiệu: đạt được khi [measure] của số liệu học tập chạm [target].
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.stamp,
    required this.target,
    required this.measure,
  });

  final String id;
  final String title;
  final String description;

  /// Chữ Hán in trên dấu triện của huy hiệu.
  final String stamp;
  final int target;
  final int Function(LearningStats stats) measure;

  /// Tiến độ hiện tại, không vượt quá [target].
  int progressOf(LearningStats stats) {
    final value = measure(stats);
    return value > target ? target : value;
  }

  bool isUnlocked(LearningStats stats) => measure(stats) >= target;

  static final all = <Achievement>[
    Achievement(
      id: 'first_word',
      title: 'Bước đầu tiên',
      description: 'Học từ vựng đầu tiên',
      stamp: '初',
      target: 1,
      measure: (s) => s.learnedWords,
    ),
    Achievement(
      id: 'words_10',
      title: 'Kho từ nhỏ',
      description: 'Học 10 từ vựng',
      stamp: '十',
      target: 10,
      measure: (s) => s.learnedWords,
    ),
    Achievement(
      id: 'words_30',
      title: 'Chăm chỉ tích lũy',
      description: 'Học 30 từ vựng',
      stamp: '積',
      target: 30,
      measure: (s) => s.learnedWords,
    ),
    Achievement(
      id: 'streak_3',
      title: 'Ba ngày liền',
      description: 'Học 3 ngày liên tiếp',
      stamp: '三',
      target: 3,
      measure: (s) => s.longestStreak,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Một tuần bền bỉ',
      description: 'Học 7 ngày liên tiếp',
      stamp: '週',
      target: 7,
      measure: (s) => s.longestStreak,
    ),
    Achievement(
      id: 'mastered_5',
      title: 'Nhớ vững',
      description: 'Có 5 từ đạt mức Nhớ vững',
      stamp: '憶',
      target: 5,
      measure: (s) => s.masteredWords,
    ),
    Achievement(
      id: 'category_1',
      title: 'Trọn một chủ đề',
      description: 'Học hết các từ của một chủ đề',
      stamp: '完',
      target: 1,
      measure: (s) => s.completedCategories,
    ),
    Achievement(
      id: 'quiz_1',
      title: 'Thử sức',
      description: 'Làm quiz lần đầu',
      stamp: '試',
      target: 1,
      measure: (s) => s.quizzesTaken,
    ),
    Achievement(
      id: 'quiz_perfect',
      title: 'Điểm tuyệt đối',
      description: 'Đúng hết một lượt quiz',
      stamp: '満',
      target: 1,
      measure: (s) => s.perfectQuizzes,
    ),
  ];
}
