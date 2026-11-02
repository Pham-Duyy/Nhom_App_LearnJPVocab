import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Định dạng file không đọc được, hoặc file hỏng.
class VocabularyFileException implements Exception {
  const VocabularyFileException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Đọc file từ vựng (Excel, CSV, TXT, PDF) thành văn bản mỗi dòng một từ,
/// các cột cách nhau bằng Tab: đúng định dạng VocabularyImportParser đọc,
/// nên người dùng xem trước và sửa được trước khi import.
class VocabularyFileReader {
  const VocabularyFileReader();

  static const extensions = ['xlsx', 'csv', 'txt', 'pdf'];

  /// Chữ trong dòng tiêu đề (nếu có) để bỏ qua, vd. "Kanji | Kana | Nghĩa".
  static const _headerWords = ['kanji', 'kana', 'nghĩa', 'romaji', 'chữ hán'];

  String read(Uint8List bytes, String extension) {
    switch (extension.toLowerCase()) {
      case 'xlsx':
        return _withoutHeader(_readExcel(bytes));
      case 'csv':
        return _withoutHeader(
          parseCsv(_decodeText(bytes)).map((r) => r.join('\t')).toList(),
        );
      case 'txt':
        return _decodeText(bytes);
      case 'pdf':
        return _readPdf(bytes);
      default:
        throw VocabularyFileException(
          'Chưa hỗ trợ file .$extension. Hãy dùng Excel, CSV, TXT hoặc PDF.',
        );
    }
  }

  /// Sheet đầu tiên của file Excel; mỗi hàng thành một dòng.
  List<String> _readExcel(Uint8List bytes) {
    final Excel book;
    try {
      book = Excel.decodeBytes(bytes);
    } catch (_) {
      throw const VocabularyFileException(
          'File Excel bị hỏng hoặc sai định dạng.');
    }
    if (book.tables.isEmpty) return [];
    final sheet = book.tables.values.first;
    return [
      for (final row in sheet.rows)
        row.map((cell) => cell?.value?.toString().trim() ?? '').join('\t'),
    ];
  }

  /// PDF không lưu cột: các cột trong bảng thường cách nhau bằng nhiều dấu
  /// cách, nên đổi chúng thành Tab. Người dùng sửa lại trong ô xem trước.
  String _readPdf(Uint8List bytes) {
    try {
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim().replaceAll(RegExp(r' {2,}'), '\t'))
          .where((line) => line.isNotEmpty)
          .join('\n');
    } catch (_) {
      throw const VocabularyFileException(
        'Không đọc được file PDF. File có thể là ảnh chụp hoặc bị khóa.',
      );
    }
  }

  String _decodeText(Uint8List bytes) {
    // Bỏ ký tự BOM mà Excel thêm vào đầu file CSV UTF-8.
    final text = utf8.decode(bytes, allowMalformed: true);
    return text.startsWith('﻿') ? text.substring(1) : text;
  }

  String _withoutHeader(List<String> lines) {
    final rows = lines.where((line) => line.trim().isNotEmpty).toList();
    if (rows.isEmpty) return '';
    // Dòng tiêu đề có chữ "kana", "nghĩa"... nhưng không có chữ Nhật; một từ
    // thật như 意味 (Ý nghĩa) thì có, nên không bị bỏ nhầm.
    final first = rows.first.toLowerCase();
    final isHeader = _headerWords.any(first.contains) &&
        !RegExp(r'[぀-ヿ一-鿿]').hasMatch(first);
    return (isHeader ? rows.skip(1) : rows).join('\n');
  }

  /// Tách CSV có hỗ trợ ô trong ngoặc kép, vd. `"Nhà máy, xưởng"` vẫn là
  /// một ô dù chứa dấu phẩy. Dấu phân cách là `,` hoặc `;` (Excel tiếng
  /// Việt hay xuất bằng `;`).
  static List<List<String>> parseCsv(String text) {
    final firstLine = text.split('\n').first;
    final separator =
        ';'.allMatches(firstLine).length > ','.allMatches(firstLine).length
            ? ';'
            : ',';
    final rows = <List<String>>[];
    var row = <String>[];
    final cell = StringBuffer();
    var quoted = false;

    void endCell() {
      row.add(cell.toString().trim());
      cell.clear();
    }

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (quoted) {
        if (char == '"' && i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else if (char == '"') {
          quoted = false;
        } else {
          cell.write(char);
        }
      } else if (char == '"') {
        quoted = true;
      } else if (char == separator) {
        endCell();
      } else if (char == '\n') {
        endCell();
        rows.add(row);
        row = [];
      } else if (char != '\r') {
        cell.write(char);
      }
    }
    if (cell.isNotEmpty || row.isNotEmpty) {
      endCell();
      rows.add(row);
    }
    return rows;
  }
}
