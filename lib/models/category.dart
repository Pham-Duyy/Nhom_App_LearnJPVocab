import 'generic_entity.dart';

/// Chủ đề học. Kế thừa id, name, description từ [GenericEntity].
class Category extends GenericEntity<String> {
  final String? imageUrl;
  final int order;
  final bool isPublished;

  const Category({
    required super.id,
    required super.name,
    required super.description,
    this.imageUrl,
    required this.order,
    this.isPublished = true,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? order,
    bool? isPublished,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
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
        'order': order,
        'isPublished': isPublished,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        imageUrl: map['imageUrl'] as String?,
        order: map['order'] as int,
        isPublished: map['isPublished'] as bool? ?? true,
      );

  @override
  String toString() => 'Category($name)';
}
