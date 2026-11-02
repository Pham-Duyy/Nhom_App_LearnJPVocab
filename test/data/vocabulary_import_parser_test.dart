import 'package:chibakanji/data/vocabulary_import_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = VocabularyImportParser();

  group('US23: đọc danh sách từ để import', () {
    test('dán từ Excel: các cột cách nhau bằng Tab', () {
      final lines = parser.parse('工場\tこうじょう\tkoujou\tNhà máy, xưởng');

      expect(lines, hasLength(1));
      final draft = lines.single.draft!;
      expect(draft.kanji, '工場');
      expect(draft.kana, 'こうじょう');
      expect(draft.meaning, 'Nhà máy, xưởng');
    });

    test('gõ tay: cột cách nhau bằng dấu |, có cả câu ví dụ', () {
      final draft = parser
          .parse('安全 | あんぜん | anzen | An toàn | 安全第一 | An toàn trên hết')
          .single
          .draft!;

      expect(draft.romaji, 'anzen');
      expect(draft.exampleJapanese, '安全第一');
      expect(draft.exampleVietnamese, 'An toàn trên hết');
    });

    test('từ không có chữ Hán để trống cột đầu', () {
      final draft = parser.parse(' | マスク | masuku | Khẩu trang').single.draft!;

      expect(draft.kanji, isEmpty);
      expect(draft.kana, 'マスク');
    });

    test('bỏ qua dòng trống; dòng lỗi ghi rõ số dòng và lý do', () {
      final lines = parser.parse(
        '工場 | こうじょう | koujou | Nhà máy\n'
        '\n'
        'chỉ một cột\n'
        '安全 |  | anzen | An toàn\n'
        '危険 | きけん | kiken | ',
      );

      expect(lines.map((l) => l.lineNumber), [1, 3, 4, 5]);
      expect(lines[0].isValid, isTrue);
      expect(lines[1].error, contains('ít nhất 4 cột'));
      expect(lines[2].error, contains('cách đọc'));
      expect(lines[3].error, contains('nghĩa'));
    });
  });
}
