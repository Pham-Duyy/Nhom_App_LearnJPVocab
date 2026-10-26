import 'learning_content.dart';

/// Chủ đề học. id, name, description, order, isPublished và các phương thức
/// chung (getName, matches, toString...) kế thừa từ [LearningContent].
class Category extends LearningContent {
  /// "Cấp độ" của các chủ đề từ vựng chuyên ngành (thực phẩm, xây dựng...),
  /// hiện cạnh N5, N4, N3.
  static const industryLevel = 'Ngành';

  final String? imageUrl;
  final String jlptLevel;

  const Category({
    required String id,
    required String name,
    required String description,
    this.imageUrl,
    this.jlptLevel = 'N5',
    required int order,
    bool isPublished = true,
  }) : super(
          id: id,
          name: name,
          description: description,
          order: order,
          isPublished: isPublished,
        );

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? jlptLevel,
    int? order,
    bool? isPublished,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      order: order ?? this.order,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'jlptLevel': jlptLevel,
        'order': order,
        'isPublished': isPublished,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        imageUrl: map['imageUrl'] as String?,
        jlptLevel: map['jlptLevel'] as String? ?? 'N5',
        order: map['order'] as int,
        isPublished: map['isPublished'] as bool? ?? true,
      );
}
