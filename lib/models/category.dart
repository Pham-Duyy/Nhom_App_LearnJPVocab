class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int order;
  final bool isPublished;

  const Category({
    required this.id,
    required this.name,
    required this.description,
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
