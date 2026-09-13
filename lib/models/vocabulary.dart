class Vocabulary {
  final int _id;
  final String _japanese;
  final String _meaning;
  final String _pronunciation;
  final String _example;
  final String _level; // N5, N4, N3...
  final int _categoryId;

  Vocabulary({
    required int id,
    required String japanese,
    required String meaning,
    required String pronunciation,
    required String example,
    required String level,
    required int categoryId,
  })  : _id = id,
        _japanese = japanese,
        _meaning = meaning,
        _pronunciation = pronunciation,
        _example = example,
        _level = level,
        _categoryId = categoryId;

  int get id => _id;
  String get japanese => _japanese;
  String get pronunciation => _pronunciation;
  String get example => _example;
  String get level => _level;
  int get categoryId => _categoryId;

  String getMeaning() => _meaning;

  bool matches(String keyword) {
    final lower = keyword.toLowerCase().trim();
    if (lower.isEmpty) return false;
    return _japanese.toLowerCase().contains(lower) ||
        _meaning.toLowerCase().contains(lower) ||
        _pronunciation.toLowerCase().contains(lower);
  }

  Map<String, dynamic> toMap() => {
        'id': _id,
        'japanese': _japanese,
        'meaning': _meaning,
        'pronunciation': _pronunciation,
        'example': _example,
        'level': _level,
        'categoryId': _categoryId,
      };

  factory Vocabulary.fromMap(Map<String, dynamic> map) => Vocabulary(
        id: map['id'] as int,
        japanese: map['japanese'] as String,
        meaning: map['meaning'] as String,
        pronunciation: map['pronunciation'] as String,
        example: map['example'] as String,
        level: map['level'] as String,
        categoryId: map['categoryId'] as int,
      );

  @override
  String toString() => 'Vocabulary($_japanese - $_meaning)';
}