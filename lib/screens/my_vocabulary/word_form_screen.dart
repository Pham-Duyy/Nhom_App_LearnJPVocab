import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../models/word_draft.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import 'topic_picker.dart';

/// Thêm một từ mới vào kho (có thể kèm chủ đề), hoặc sửa từ tự thêm [word].
class WordFormScreen extends StatefulWidget {
  const WordFormScreen({Key? key, this.word, this.topicId}) : super(key: key);

  final Vocabulary? word;

  /// Chủ đề chọn sẵn khi mở từ màn chi tiết chủ đề.
  final String? topicId;

  @override
  State<WordFormScreen> createState() => _WordFormScreenState();
}

class _WordFormScreenState extends GenericScreenState<WordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final WordDraft _initial = widget.word == null
      ? const WordDraft(kana: '', meaning: '')
      : WordDraft.of(widget.word!);
  late final _kanji = TextEditingController(text: _initial.kanji);
  late final _kana = TextEditingController(text: _initial.kana);
  late final _romaji = TextEditingController(text: _initial.romaji);
  late final _meaning = TextEditingController(text: _initial.meaning);
  late final _exampleJp = TextEditingController(text: _initial.exampleJapanese);
  late final _exampleVi =
      TextEditingController(text: _initial.exampleVietnamese);
  late String? _topicId = widget.topicId;
  bool _isSaving = false;

  bool get _isEditing => widget.word != null;

  @override
  void dispose() {
    for (final controller in [
      _kanji,
      _kana,
      _romaji,
      _meaning,
      _exampleJp,
      _exampleVi,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) =>
      _isEditing ? 'Sửa từ vựng' : 'Thêm từ vựng mới';

  WordDraft get _draft => WordDraft(
        kanji: _kanji.text,
        kana: _kana.text,
        romaji: _romaji.text,
        meaning: _meaning.text,
        exampleJapanese: _exampleJp.text,
        exampleVietnamese: _exampleVi.text,
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<MyVocabularyProvider>();
    final error = _isEditing
        ? await provider.updateWord(widget.word!, _draft)
        : await provider.addWord(_draft, topicId: _topicId);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Đã lưu từ.' : 'Đã thêm "${_draft.kana}".'),
      ),
    );
  }

  String? _required(String? value, String message) =>
      (value ?? '').trim().isEmpty ? message : null;

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text('TỪ VỰNG', style: palette.sectionLabel),
          const SizedBox(height: 12),
          TextFormField(
            controller: _kanji,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Chữ Hán (không bắt buộc)',
              hintText: 'Vd. 工場',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _kana,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Cách đọc kana',
              hintText: 'Vd. こうじょう',
            ),
            validator: (value) => _required(value, 'Hãy nhập cách đọc.'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _romaji,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Romaji',
              hintText: 'Vd. koujou',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _meaning,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nghĩa tiếng Việt',
              hintText: 'Vd. Nhà máy',
            ),
            validator: (value) => _required(value, 'Hãy nhập nghĩa.'),
          ),
          const SizedBox(height: 24),
          Text('VÍ DỤ (KHÔNG BẮT BUỘC)', style: palette.sectionLabel),
          const SizedBox(height: 12),
          TextFormField(
            controller: _exampleJp,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Câu ví dụ'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _exampleVi,
            decoration: const InputDecoration(labelText: 'Nghĩa câu ví dụ'),
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 24),
            TopicPicker(
              value: _topicId,
              onChanged: (value) => setState(() => _topicId = value),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm vào kho'),
          ),
        ],
      ),
    );
  }
}
