import '../models/word_draft.dart';

/// Kết quả đọc một dòng khi import: có [draft] nếu dòng hợp lệ, ngược lại có
/// [error] giải thích vì sao bỏ qua dòng đó.
class ImportLine {
  const ImportLine({required this.lineNumber, this.draft, this.error});

  final int lineNumber;
  final WordDraft? draft;
  final String? error;

  bool get isValid => draft != null;
}

/// Đọc danh sách từ vựng dán vào ô import. Mỗi dòng một từ, các cột theo thứ
/// tự: chữ Hán, kana, romaji, nghĩa, câu ví dụ, nghĩa câu ví dụ. Cột cách
/// nhau bằng Tab (dán thẳng từ Excel, Google Sheets) hoặc dấu `|` (gõ tay).
/// Không dùng dấu phẩy vì nghĩa tiếng Việt hay có dấu phẩy.
class VocabularyImportParser {
  const VocabularyImportParser();

  static const minColumns = 4;

  List<ImportLine> parse(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    return [
      for (var i = 0; i < lines.length; i++)
        if (lines[i].trim().isNotEmpty) _parseLine(lines[i], i + 1),
    ];
  }

  ImportLine _parseLine(String line, int lineNumber) {
    final columns =
        line.split(line.contains('\t') ? '\t' : '|').map((c) => c.trim());
    final cells = columns.toList();
    if (cells.length < minColumns) {
      return ImportLine(
        lineNumber: lineNumber,
        error: 'Cần ít nhất $minColumns cột: chữ Hán, kana, romaji, nghĩa.',
      );
    }
    String cell(int index) => index < cells.length ? cells[index] : '';
    final draft = WordDraft(
      kanji: cell(0),
      kana: cell(1),
      romaji: cell(2),
      meaning: cell(3),
      exampleJapanese: cell(4),
      exampleVietnamese: cell(5),
    );
    final error = draft.validate();
    return error == null
        ? ImportLine(lineNumber: lineNumber, draft: draft)
        : ImportLine(lineNumber: lineNumber, error: error);
  }
}
