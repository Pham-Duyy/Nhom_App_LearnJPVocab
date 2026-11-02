import 'dart:convert';
import 'dart:typed_data';

import 'package:chibakanji/data/vocabulary_file_reader.dart';
import 'package:chibakanji/data/vocabulary_import_parser.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Uint8List _utf8(String text) => Uint8List.fromList(utf8.encode(text));

void main() {
  const reader = VocabularyFileReader();
  const parser = VocabularyImportParser();

  group('US23: đọc file Excel', () {
    test('mỗi hàng thành một từ, bỏ dòng tiêu đề', () {
      final book = Excel.createExcel();
      final sheet = book[book.getDefaultSheet()!];
      sheet.appendRow([
        TextCellValue('Kanji'),
        TextCellValue('Kana'),
        TextCellValue('Romaji'),
        TextCellValue('Nghĩa'),
      ]);
      sheet.appendRow([
        TextCellValue('工場'),
        TextCellValue('こうじょう'),
        TextCellValue('koujou'),
        TextCellValue('Nhà máy, xưởng'),
      ]);
      final bytes = Uint8List.fromList(book.encode()!);

      final lines = parser.parse(reader.read(bytes, 'xlsx'));

      expect(lines, hasLength(1));
      expect(lines.single.draft!.kanji, '工場');
      expect(lines.single.draft!.meaning, 'Nhà máy, xưởng');
    });

    test('file Excel hỏng thì báo lỗi dễ hiểu', () {
      expect(
        () => reader.read(_utf8('không phải excel'), 'xlsx'),
        throwsA(isA<VocabularyFileException>()),
      );
    });
  });

  group('US23: đọc file CSV và TXT', () {
    test('ô trong ngoặc kép giữ nguyên dấu phẩy; bỏ BOM và dòng tiêu đề', () {
      const csv = '﻿Kanji,Kana,Romaji,Nghĩa\r\n'
          '工場,こうじょう,koujou,"Nhà máy, xưởng"\r\n'
          ',マスク,masuku,Khẩu trang\r\n';

      final lines = parser.parse(reader.read(_utf8(csv), 'csv'));

      expect(lines, hasLength(2));
      expect(lines[0].draft!.meaning, 'Nhà máy, xưởng');
      expect(lines[1].draft!.kanji, isEmpty);
      expect(lines[1].draft!.kana, 'マスク');
    });

    test('CSV ngăn cột bằng dấu chấm phẩy (Excel tiếng Việt)', () {
      final rows = VocabularyFileReader.parseCsv('安全;あんぜん;anzen;An toàn');

      expect(rows.single, ['安全', 'あんぜん', 'anzen', 'An toàn']);
    });

    test('từ 意味 (Ý nghĩa) ở dòng đầu không bị coi là tiêu đề', () {
      final text = reader.read(_utf8('意味,いみ,imi,Ý nghĩa'), 'csv');

      expect(parser.parse(text).single.draft!.kana, 'いみ');
    });

    test('TXT giữ nguyên định dạng gõ tay', () {
      const txt = '工場 | こうじょう | koujou | Nhà máy';

      expect(reader.read(_utf8(txt), 'txt'), txt);
    });

    test('đuôi file chưa hỗ trợ thì báo lỗi', () {
      expect(
        () => reader.read(_utf8('x'), 'docx'),
        throwsA(isA<VocabularyFileException>()),
      );
    });
  });

  group('US23: đọc file PDF', () {
    test('lấy chữ trong PDF, nhiều dấu cách liền nhau thành ngăn cột', () {
      final document = PdfDocument();
      document.pages.add().graphics.drawString(
            'anzen    an toan',
            PdfStandardFont(PdfFontFamily.helvetica, 12),
          );
      final bytes = Uint8List.fromList(document.saveSync());
      document.dispose();

      final text = reader.read(bytes, 'pdf');

      expect(text, contains('anzen'));
      expect(text, contains('an toan'));
    });

    test('file PDF hỏng thì báo lỗi dễ hiểu', () {
      expect(
        () => reader.read(_utf8('không phải pdf'), 'pdf'),
        throwsA(isA<VocabularyFileException>()),
      );
    });
  });
}
