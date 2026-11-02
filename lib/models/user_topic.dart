import 'learning_content.dart';

/// Chủ đề do người học tự tạo trong kho từ của mình, lưu tại
/// `users/{uid}/topics`. Giữ danh sách id từ vựng ([wordIds]) nên một từ có
/// thể nằm trong nhiều chủ đề, kể cả từ có sẵn của app.
class UserTopic extends LearningContent {
  final List<String> wordIds;
  final DateTime createdAt;

  const UserTopic({
    required String id,
    required String name,
    String description = '',
    required int order,
    this.wordIds = const [],
    required this.createdAt,
  }) : super(id: id, name: name, description: description, order: order);

  static const maxNameLength = 40;

  int get wordCount => wordIds.length;

  bool contains(String vocabularyId) => wordIds.contains(vocabularyId);

  /// Trả về thông báo lỗi nếu [name] không dùng được làm tên chủ đề.
  static String? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Hãy nhập tên chủ đề.';
    if (trimmed.length > maxNameLength) {
      return 'Tên chủ đề tối đa $maxNameLength ký tự.';
    }
    return null;
  }

  UserTopic copyWith({
    String? name,
    String? description,
    List<String>? wordIds,
  }) {
    return UserTopic(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order,
      wordIds: wordIds ?? this.wordIds,
      createdAt: createdAt,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'order': order,
        'wordIds': wordIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserTopic.fromMap(Map<String, dynamic> map) => UserTopic(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        order: map['order'] as int? ?? 0,
        wordIds: List<String>.from(map['wordIds'] as List? ?? const []),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime(2000),
      );
}
