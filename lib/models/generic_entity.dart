/// Lớp cha Generics cho mọi entity có chung 3 đặc điểm: id, name, description.
///
/// T là kiểu của id:
///   - GenericEntity<String>: Category, Lesson, Quiz, Question, Vocabulary
///   - GenericEntity<int>:    User
///
/// Progress và QuizAttempt không có name/description nên không kế thừa lớp này.
abstract class GenericEntity<T> {
  // ===== Đặc điểm chung =====
  final T id;
  final String name;
  final String description;

  const GenericEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  // ===== Phương thức chung =====
  T getId() => id;
  String getName() => name;
  String getDescription() => description;

  /// Tìm kiếm không phân biệt hoa thường theo name hoặc description.
  /// Lớp con có thể override để tìm thêm theo trường riêng (xem Vocabulary).
  bool matches(String keyword) {
    final lower = keyword.toLowerCase().trim();
    if (lower.isEmpty) return false;
    return name.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower);
  }

  /// Mỗi entity tự chuyển dữ liệu của mình sang Map.
  Map<String, dynamic> toMap();
}
