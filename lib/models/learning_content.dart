import 'generic_entity.dart';

/// Lớp trung gian cho nội dung học (chủ đề, bài học, quiz, từ vựng): ngoài
/// id/tên/mô tả của [GenericEntity] còn có thứ tự hiển thị và trạng thái xuất
/// bản. Id của nội dung học luôn là String nên kế thừa GenericEntity<String>.
abstract class LearningContent extends GenericEntity<String> {
  final int order;
  final bool isPublished;

  const LearningContent({
    required String id,
    required String name,
    required String description,
    required this.order,
    this.isPublished = true,
  }) : super(id: id, name: name, description: description);
}
