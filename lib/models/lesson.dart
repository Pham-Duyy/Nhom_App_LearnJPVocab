class Lesson {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String jlptLevel;
  final int order;
  final int vocabularyCount;
  final bool isPublished;

  const Lesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.jlptLevel,
    required this.order,
    this.vocabularyCount = 0,
    this.isPublished = true,
  });

  Lesson copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    String? jlptLevel,
    int? order,
    int? vocabularyCount,
    bool? isPublished,
  }) {
    return Lesson(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      order: order ?? this.order,
      vocabularyCount: vocabularyCount ?? this.vocabularyCount,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'jlptLevel': jlptLevel,
        'order': order,
        'vocabularyCount': vocabularyCount,
        'isPublished': isPublished,
      };

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id: map['id'] as String,
        categoryId: map['categoryId'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        jlptLevel: map['jlptLevel'] as String,
        order: map['order'] as int,
        vocabularyCount: map['vocabularyCount'] as int? ?? 0,
        isPublished: map['isPublished'] as bool? ?? true,
      );

  @override
  String toString() => 'Lesson($title)';
}
