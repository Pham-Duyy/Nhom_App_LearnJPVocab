/// Một bài kiểm tra gắn với một [Lesson]. Danh sách câu hỏi nằm ở [Question]
/// (theo quizId), không nhúng trong Quiz, để khớp cách tổ chức collection
/// riêng trên Firestore sau này.
class Quiz {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final int questionCount;
  final int order;
  final bool isPublished;

  const Quiz({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    this.questionCount = 0,
    required this.order,
    this.isPublished = true,
  });

  Quiz copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    int? questionCount,
    int? order,
    bool? isPublished,
  }) {
    return Quiz(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      questionCount: questionCount ?? this.questionCount,
      order: order ?? this.order,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'lessonId': lessonId,
        'title': title,
        'description': description,
        'questionCount': questionCount,
        'order': order,
        'isPublished': isPublished,
      };

  factory Quiz.fromMap(Map<String, dynamic> map) => Quiz(
        id: map['id'] as String,
        lessonId: map['lessonId'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        questionCount: map['questionCount'] as int? ?? 0,
        order: map['order'] as int,
        isPublished: map['isPublished'] as bool? ?? true,
      );

  @override
  String toString() => 'Quiz($title)';
}
