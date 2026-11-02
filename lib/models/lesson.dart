import 'learning_content.dart';

class Lesson extends LearningContent {
  final String categoryId;
  final String jlptLevel;
  final int vocabularyCount;

  const Lesson({
    required String id,
    required this.categoryId,
    required String title,
    required String description,
    required this.jlptLevel,
    required int order,
    this.vocabularyCount = 0,
    bool isPublished = true,
  }) : super(
          id: id,
          name: title,
          description: description,
          order: order,
          isPublished: isPublished,
        );

  String get title => name;

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

  @override
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
}
