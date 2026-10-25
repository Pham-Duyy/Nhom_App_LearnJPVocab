import 'generic_entity.dart';

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
