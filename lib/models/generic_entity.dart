abstract class GenericEntity<ID> {
  final ID id;
  final String name;
  final String description;

  const GenericEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  ID getId() => id;

  String getName() => name;

  String getDescription() => description;

  bool matches(String keyword) {
    final lower = keyword.toLowerCase().trim();
    if (lower.isEmpty) return false;
    return name.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower);
  }

  Map<String, dynamic> toMap();

  @override
  String toString() => '$runtimeType($name)';
}
