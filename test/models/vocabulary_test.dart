import 'package:chibakanji/models/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const word = Vocabulary(
    id: 'v1',
    lessonId: 'l1',
    kanji: '学校',
    kana: 'がっこう',
    romaji: 'gakkou',
    meaning: 'trường học',
    exampleJapanese: '毎日学校へ行きます。',
    exampleVietnamese: 'Tôi đến trường mỗi ngày.',
    jlptLevel: 'N5',
    order: 1,
  );

  group('Vocabulary.matches', () {
    test('tìm được theo kanji', () {
      expect(word.matches('学校'), isTrue);
    });

    test('tìm được theo kana', () {
      expect(word.matches('がっこう'), isTrue);
    });

    test('tìm được theo romaji, không phân biệt hoa thường', () {
      expect(word.matches('GAKKOU'), isTrue);
    });

    test('tìm được theo nghĩa tiếng Việt', () {
      expect(word.matches('trường'), isTrue);
    });

    test('không khớp với từ khóa không liên quan', () {
      expect(word.matches('bệnh viện'), isFalse);
    });

    test('từ khóa rỗng không khớp', () {
      expect(word.matches('   '), isFalse);
    });
  });
}
