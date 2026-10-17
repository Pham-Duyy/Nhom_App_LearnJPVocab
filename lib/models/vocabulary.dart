import 'learning_content.dart';

class Vocabulary extends LearningContent {
  final String lessonId;
  final String kanji;
  final String kana;
  final String romaji;
  final String exampleJapanese;
  final String exampleVietnamese;
  final String? audioUrl;
  final String jlptLevel;

  const Vocabulary({
    required String id,
    required this.lessonId,
    required this.kanji,
    required this.kana,
    required this.romaji,
    required String meaning,
    required this.exampleJapanese,
    required this.exampleVietnamese,
    this.audioUrl,
    required this.jlptLevel,
    required int order,
  }) : super(
          id: id,
          name: kanji == '' ? kana : kanji,
          description: meaning,
          order: order,
        );

  String get meaning => description;

  Vocabulary copyWith({
    String? id,
    String? lessonId,
    String? kanji,
    String? kana,
    String? romaji,
    String? meaning,
    String? exampleJapanese,
    String? exampleVietnamese,
    String? audioUrl,
    String? jlptLevel,
    int? order,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      kanji: kanji ?? this.kanji,
      kana: kana ?? this.kana,
      romaji: romaji ?? this.romaji,
      meaning: meaning ?? this.meaning,
      exampleJapanese: exampleJapanese ?? this.exampleJapanese,
      exampleVietnamese: exampleVietnamese ?? this.exampleVietnamese,
      audioUrl: audioUrl ?? this.audioUrl,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      order: order ?? this.order,
    );
  }

  /// Tìm kiếm không phân biệt hoa thường theo kanji, kana, romaji hoặc nghĩa.
  @override
  bool matches(String keyword) {
    if (super.matches(keyword)) return true;
    final lower = keyword.toLowerCase().trim();
    if (lower.isEmpty) return false;
    return kana.toLowerCase().contains(lower) ||
        romaji.toLowerCase().contains(lower);
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'lessonId': lessonId,
        'kanji': kanji,
        'kana': kana,
        'romaji': romaji,
        'meaning': meaning,
        'exampleJapanese': exampleJapanese,
        'exampleVietnamese': exampleVietnamese,
        'audioUrl': audioUrl,
        'jlptLevel': jlptLevel,
        'order': order,
      };

  factory Vocabulary.fromMap(Map<String, dynamic> map) => Vocabulary(
        id: map['id'] as String,
        lessonId: map['lessonId'] as String,
        kanji: map['kanji'] as String,
        kana: map['kana'] as String,
        romaji: map['romaji'] as String,
        meaning: map['meaning'] as String,
        exampleJapanese: map['exampleJapanese'] as String,
        exampleVietnamese: map['exampleVietnamese'] as String,
        audioUrl: map['audioUrl'] as String?,
        jlptLevel: map['jlptLevel'] as String,
        order: map['order'] as int,
      );

  @override
  String toString() => 'Vocabulary($kanji - $meaning)';
}
