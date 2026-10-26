import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/vocabulary_file_reader.dart';
import '../../data/vocabulary_import_parser.dart';
import '../../models/user_topic.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/choice_segments.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import '../flashcard/flashcard_screen.dart';
import 'topic_picker.dart';

/// File người dùng chọn: tên (để lấy đuôi file) và nội dung.
typedef PickedFile = ({String name, Uint8List bytes});

/// Mở hộp thoại chọn file; null nếu người dùng hủy.
Future<PickedFile?> pickVocabularyFile() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: VocabularyFileReader.extensions,
  );
  if (file == null) return null;
  return (name: file.name, bytes: await file.readAsBytes());
}

/// Import nhiều từ một lúc từ file Excel, CSV, TXT hoặc PDF: xem trước
/// dòng nào hợp lệ, rồi đưa vào kho. Import xong mở danh sách từ vừa
/// thêm.
class ImportWordsScreen extends StatefulWidget {
  const ImportWordsScreen({Key? key, this.pickFile = pickVocabularyFile})
      : super(key: key);

  /// Truyền vào để test dùng file giả thay cho hộp thoại thật.
  final Future<PickedFile?> Function() pickFile;

  @override
  State<ImportWordsScreen> createState() => _ImportWordsScreenState();
}

class _ImportWordsScreenState extends GenericScreenState<ImportWordsScreen> {
  static const _parser = VocabularyImportParser();
  static const _reader = VocabularyFileReader();

  List<ImportLine> _lines = [];
  String? _topicId;
  String? _fileName;
  bool _isImporting = false;

  /// Mặc định tạo chủ đề mới đặt theo tên file, đỡ phải tạo chủ đề trước.
  bool _newTopic = true;
  final _newTopicName = TextEditingController();

  @override
  void dispose() {
    _newTopicName.dispose();
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) => 'Import từ vựng';

  /// "tu-vung-cong-viec.xlsx" → "Cong viec": bỏ đuôi file, tiền tố "tu-vung"
  /// và đổi gạch nối thành dấu cách.
  static String topicNameFromFile(String fileName) {
    final name = fileName
        .replaceFirst(RegExp(r'\.[^.]+$'), '')
        .replaceFirst(
            RegExp(r'^t[uừ][-_ ]?v[uự]ng[-_ ]?', caseSensitive: false), '')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .trim();
    if (name.isEmpty) return 'Từ vựng mới';
    final capitalized = name[0].toUpperCase() + name.substring(1);
    return capitalized.length > UserTopic.maxNameLength
        ? capitalized.substring(0, UserTopic.maxNameLength)
        : capitalized;
  }

  /// Chủ đề để thêm từ vào: tạo mới (hoặc dùng chủ đề trùng tên) nếu chọn
  /// "Chủ đề mới". Trả về lỗi nếu không tạo được.
  Future<({String? topicId, String? error})> _targetTopic() async {
    if (!_newTopic) return (topicId: _topicId, error: null);
    final provider = context.read<MyVocabularyProvider>();
    final name = _newTopicName.text;
    final existing = provider.topicByName(name);
    if (existing != null) return (topicId: existing.id, error: null);
    final error = await provider.createTopic(name);
    return (topicId: provider.topicByName(name)?.id, error: error);
  }

  Future<void> _pickFile() async {
    final file = await widget.pickFile();
    if (file == null || !mounted) return;
    final extension = file.name.split('.').last;
    try {
      final text = _reader.read(file.bytes, extension);
      if (text.trim().isEmpty) {
        showErrorSnackBar(context, 'File "${file.name}" không có dòng nào.');
        return;
      }
      setState(() {
        _lines = _parser.parse(text);
        _fileName = file.name;
        _newTopicName.text = topicNameFromFile(file.name);
      });
    } on VocabularyFileException catch (e) {
      showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _import() async {
    final drafts = [
      for (final line in _lines)
        if (line.isValid) line.draft!,
    ];
    if (drafts.isEmpty) return;
    setState(() => _isImporting = true);
    final target = await _targetTopic();
    if (!mounted) return;
    if (target.error != null) {
      setState(() => _isImporting = false);
      showErrorSnackBar(context, target.error!);
      return;
    }
    final topicId = target.topicId;
    final result = await context
        .read<MyVocabularyProvider>()
        .importWords(drafts, topicId: topicId);
    if (!mounted) return;
    setState(() => _isImporting = false);
    if (result.error != null) {
      showErrorSnackBar(context, result.error!);
      return;
    }
    final words = result.words;
    if (words.isEmpty) {
      showErrorSnackBar(context, 'Các từ trong file đều đã có trong kho.');
      return;
    }

    // Vào học ngay các từ vừa import bằng flashcard.
    final messenger = ScaffoldMessenger.of(context);
    final topicName = topicId == null
        ? null
        : context.read<MyVocabularyProvider>().topicById(topicId)?.name;
    await context.read<VocabularyProvider>().loadWords(words);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          title: topicName ?? 'Từ vừa import',
          completionTitle: 'Đã học xong ${words.length} từ mới!',
        ),
      ),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ${words.length} từ'
          '${result.skipped > 0 ? ', bỏ qua ${result.skipped} từ trùng' : ''}.',
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final validCount = _lines.where((line) => line.isValid).length;
    final fileName = _fileName;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        _FilePickArea(
          fileName: fileName,
          lineCount: _lines.length,
          onTap: _isImporting ? null : _pickFile,
        ),
        if (fileName != null && fileName.toLowerCase().endsWith('.pdf')) ...[
          const SizedBox(height: 8),
          Text(
            'PDF không lưu cột nên có dòng có thể bị đọc sai và bỏ qua. Nếu '
            'có bản Excel, hãy dùng Excel để chính xác hơn.',
            style: TextStyle(color: palette.danger),
          ),
        ],
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text('Định dạng file', style: palette.sectionLabel),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mỗi hàng trong Excel (hoặc mỗi dòng trong CSV, TXT) là một từ, '
              'các cột theo thứ tự: chữ Hán · kana · romaji · nghĩa · câu ví '
              'dụ · nghĩa câu ví dụ. Chữ Hán và hai cột cuối có thể để trống. '
              'Dòng tiêu đề ở đầu file được tự bỏ qua. File TXT ngăn cột bằng '
              'dấu | hoặc Tab.',
              style: palette.body,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('THÊM VÀO', style: palette.sectionLabel),
        const SizedBox(height: 8),
        ChoiceSegments<bool>(
          options: const [true, false],
          selected: _newTopic,
          labelOf: (isNew) => isNew ? 'Chủ đề mới' : 'Chủ đề có sẵn',
          onChanged: (isNew) => setState(() => _newTopic = isNew),
        ),
        const SizedBox(height: 12),
        if (_newTopic)
          TextField(
            controller: _newTopicName,
            maxLength: UserTopic.maxNameLength,
            decoration: const InputDecoration(
              labelText: 'Tên chủ đề mới',
              hintText: 'Tự đặt theo tên file khi chọn file',
            ),
          )
        else
          TopicPicker(
            value: _topicId,
            onChanged: (value) => setState(() => _topicId = value),
          ),
        if (_lines.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'XEM TRƯỚC · $validCount/${_lines.length} DÒNG HỢP LỆ',
            style: palette.sectionLabel,
          ),
          const SizedBox(height: 8),
          for (final line in _lines) _PreviewRow(line: line),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: validCount == 0 || _isImporting ? null : _import,
          child: Text(
            validCount == 0 ? 'Chưa có dòng hợp lệ' : 'Import $validCount từ',
          ),
        ),
      ],
    );
  }
}

/// Vùng bấm để chọn file; đã chọn thì hiện tên file và số dòng, bấm lại
/// để đổi file.
class _FilePickArea extends StatelessWidget {
  const _FilePickArea({
    required this.fileName,
    required this.lineCount,
    required this.onTap,
  });

  final String? fileName;
  final int lineCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final name = fileName;
    return Material(
      color: palette.accentSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        side: BorderSide(color: palette.accentBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: name == null
              ? Column(
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      size: 44,
                      color: palette.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chọn file từ vựng',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Excel (.xlsx), CSV, TXT hoặc PDF',
                      style: palette.body,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 32,
                      color: palette.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text('$lineCount dòng', style: palette.body),
                        ],
                      ),
                    ),
                    Text(
                      'Đổi file',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: palette.primary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Một dòng xem trước: từ đọc được, hoặc lý do dòng bị bỏ qua.
class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.line});

  final ImportLine line;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final draft = line.draft;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        draft == null ? Icons.error_outline_rounded : Icons.check_rounded,
        color: draft == null ? palette.danger : palette.primary,
      ),
      title: Text(
        draft == null
            ? 'Dòng ${line.lineNumber}: ${line.error}'
            : '${draft.kanji.isEmpty ? draft.kana : draft.kanji} · '
                '${draft.meaning}',
      ),
      subtitle: draft == null || draft.kanji.isEmpty ? null : Text(draft.kana),
    );
  }
}
