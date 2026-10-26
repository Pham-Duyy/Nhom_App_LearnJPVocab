import 'vocabulary.dart';

/// Một từ người học đang nhập (từ form hoặc từ một dòng import), chưa có id.
/// Kiểm tra dữ liệu ở đây để form và import dùng chung một quy tắc.
class WordDraft {
  const WordDraft({
    this.kanji = '',
    required this.kana,
    this.romaji = '',
    required this.meaning,
    this.exampleJapanese = '',
    this.exampleVietnamese = '',
  });

  /// Lấy nội dung của một từ đã có, để sửa.
  factory WordDraft.of(Vocabulary word) => WordDraft(
        kanji: word.kanji,
        kana: word.kana,
        romaji: word.romaji,
        meaning: word.meaning,
        exampleJapanese: word.exampleJapanese,
        exampleVietnamese: word.exampleVietnamese,
      );

  final String kanji;
  final String kana;
  final String romaji;
  final String meaning;
  final String exampleJapanese;
  final String exampleVietnamese;

  /// Trả về thông báo lỗi nếu thiếu cách đọc hoặc nghĩa, null nếu hợp lệ.
  String? validate() {
    if (kana.trim().isEmpty) return 'Thiếu cách đọc (kana).';
    if (meaning.trim().isEmpty) return 'Thiếu nghĩa tiếng Việt.';
    return null;
  }

  /// Hai từ coi là trùng khi cùng cách viết, cách đọc và nghĩa.
  bool sameAs(Vocabulary word) =>
      word.kanji == kanji.trim() &&
      word.kana == kana.trim() &&
      word.meaning.toLowerCase() == meaning.trim().toLowerCase();

  Vocabulary toVocabulary({required String id, required int order}) {
    return Vocabulary(
      id: id,
      lessonId: '',
      kanji: kanji.trim(),
      kana: kana.trim(),
      romaji: romaji.trim(),
      meaning: meaning.trim(),
      exampleJapanese: exampleJapanese.trim(),
      exampleVietnamese: exampleVietnamese.trim(),
      jlptLevel: Vocabulary.personalLevel,
      order: order,
    );
  }
}
