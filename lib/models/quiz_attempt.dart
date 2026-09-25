/// Kết quả một lần làm [Quiz]. `startedAt`/`completedAt` lưu dưới dạng
/// ISO-8601 String trong [toMap]/[fromMap], cùng cách với Progress, để sau
/// này chỉ cần đổi sang Timestamp khi nối Firestore.
class QuizAttempt {
  final String id;
  final String quizId;
  final int totalQuestions;
  final int correctCount;

  /// Đáp án đã chọn theo từng câu: key là Question.id, value là index đáp án.
  final Map<String, int> selectedAnswers;
  final DateTime startedAt;
  final DateTime? completedAt;

  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.totalQuestions,
    this.correctCount = 0,
    this.selectedAnswers = const {},
    required this.startedAt,
    this.completedAt,
  }) : assert(correctCount >= 0 && correctCount <= totalQuestions);

  bool get isCompleted => completedAt != null;

  /// Điểm theo phần trăm (0-100); quiz không có câu hỏi nào tính là 0.
  double get scorePercent =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions * 100;

  QuizAttempt copyWith({
    String? id,
    String? quizId,
    int? totalQuestions,
    int? correctCount,
    Map<String, int>? selectedAnswers,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'quizId': quizId,
        'totalQuestions': totalQuestions,
        'correctCount': correctCount,
        'selectedAnswers': selectedAnswers,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory QuizAttempt.fromMap(Map<String, dynamic> map) => QuizAttempt(
        id: map['id'] as String,
        quizId: map['quizId'] as String,
        totalQuestions: map['totalQuestions'] as int,
        correctCount: map['correctCount'] as int? ?? 0,
        selectedAnswers: Map<String, int>.from(
          map['selectedAnswers'] as Map? ?? const {},
        ),
        startedAt: DateTime.parse(map['startedAt'] as String),
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : null,
      );

  @override
  String toString() => 'QuizAttempt($quizId, $correctCount/$totalQuestions)';
}
