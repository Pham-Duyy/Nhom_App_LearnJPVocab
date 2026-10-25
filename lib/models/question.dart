/// Một câu hỏi trắc nghiệm thuộc [Quiz]: một đề bài, danh sách đáp án và vị
/// trí (index) của đáp án đúng trong danh sách đó.
class Question {
  final String id;
  final String quizId;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final int order;

  /// Hướng dẫn hiện trên đề bài, vd. "Chọn nghĩa đúng".
  final String? instruction;

  /// Từ vựng mà câu hỏi kiểm tra; trả lời sai thì từ này được đưa về lịch ôn.
  final String? vocabularyId;

  const Question({
    required this.id,
    required this.quizId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.order,
    this.instruction,
    this.vocabularyId,
  });

  String get correctAnswer => options[correctIndex];

  /// `correctIndex` có trỏ tới một đáp án thật trong [options] hay không.
  /// Không dùng assert vì `options.length` không hợp lệ trong constructor
  /// const, mà model này cần giữ const để dùng cho dữ liệu mock.
  bool get isValid => correctIndex >= 0 && correctIndex < options.length;

  Question copyWith({
    String? id,
    String? quizId,
    String? prompt,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    int? order,
    String? instruction,
    String? vocabularyId,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      prompt: prompt ?? this.prompt,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      order: order ?? this.order,
      instruction: instruction ?? this.instruction,
      vocabularyId: vocabularyId ?? this.vocabularyId,
    );
  }

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  Map<String, dynamic> toMap() => {
        'id': id,
        'quizId': quizId,
        'prompt': prompt,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'order': order,
        'instruction': instruction,
        'vocabularyId': vocabularyId,
      };

  factory Question.fromMap(Map<String, dynamic> map) => Question(
        id: map['id'] as String,
        quizId: map['quizId'] as String,
        prompt: map['prompt'] as String,
        options: List<String>.from(map['options'] as List),
        correctIndex: map['correctIndex'] as int,
        explanation: map['explanation'] as String?,
        order: map['order'] as int,
        instruction: map['instruction'] as String?,
        vocabularyId: map['vocabularyId'] as String?,
      );

  @override
  String toString() => 'Question($prompt)';
}
