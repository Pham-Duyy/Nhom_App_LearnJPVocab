import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/vocabulary_import_parser.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import 'topic_picker.dart';

/// Import nhiều từ một lúc: dán danh sách (từ Excel, Google Sheets hoặc gõ
/// tay), xem trước dòng nào hợp lệ, rồi đưa vào kho.
class ImportWordsScreen extends StatefulWidget {
  const ImportWordsScreen({Key? key}) : super(key: key);

  @override
  State<ImportWordsScreen> createState() => _ImportWordsScreenState();
}

class _ImportWordsScreenState extends GenericScreenState<ImportWordsScreen> {
  static const _parser = VocabularyImportParser();
  static const _example = '工場 | こうじょう | koujou | Nhà máy\n'
      '安全 | あんぜん | anzen | An toàn | 安全第一です。 | An toàn là trên hết.';

  final _input = TextEditingController();
  List<ImportLine> _lines = [];
  String? _topicId;
  bool _isImporting = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) => 'Import từ vựng';

  Future<void> _import() async {
    final drafts = [
      for (final line in _lines)
        if (line.isValid) line.draft!,
    ];
    if (drafts.isEmpty) return;
    setState(() => _isImporting = true);
    final result = await context
        .read<MyVocabularyProvider>()
        .importWords(drafts, topicId: _topicId);
    if (!mounted) return;
    setState(() => _isImporting = false);
    if (result.error != null) {
      showErrorSnackBar(context, result.error!);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ${result.added} từ'
          '${result.skipped > 0 ? ', bỏ qua ${result.skipped} từ trùng' : ''}.',
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final validCount = _lines.where((line) => line.isValid).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text('CÁCH NHẬP', style: palette.sectionLabel),
        const SizedBox(height: 8),
        Text(
          'Mỗi dòng một từ, các cột theo thứ tự: chữ Hán · kana · romaji · '
          'nghĩa · câu ví dụ · nghĩa câu ví dụ. Hai cột cuối không bắt buộc. '
          'Dán thẳng từ Excel hoặc Google Sheets, hoặc gõ tay và ngăn cột '
          'bằng dấu |.',
          style: palette.body,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() {
            _input.text = _example;
            _lines = _parser.parse(_example);
          }),
          child: const Text('Dùng ví dụ mẫu'),
        ),
        TextField(
          controller: _input,
          minLines: 5,
          maxLines: 10,
          onChanged: (text) => setState(() => _lines = _parser.parse(text)),
          decoration: const InputDecoration(
            hintText: 'Dán danh sách từ vựng vào đây',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
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
