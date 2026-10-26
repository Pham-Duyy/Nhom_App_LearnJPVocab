import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import 'topic_picker.dart';
import 'word_tile.dart';

/// Thêm từ có sẵn (của app hoặc tự thêm) vào một chủ đề: chọn chủ đề, tìm
/// và đánh dấu các từ rồi thêm một lần.
class AddToTopicScreen extends StatefulWidget {
  const AddToTopicScreen({Key? key, this.topicId}) : super(key: key);

  /// Chủ đề chọn sẵn khi mở từ màn chi tiết chủ đề.
  final String? topicId;

  @override
  State<AddToTopicScreen> createState() => _AddToTopicScreenState();
}

class _AddToTopicScreenState extends GenericScreenState<AddToTopicScreen> {
  final _search = TextEditingController();
  late String? _topicId = widget.topicId;
  final Set<String> _selected = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) => 'Thêm từ vào chủ đề';

  Future<void> _save() async {
    final topicId = _topicId;
    if (topicId == null || _selected.isEmpty) return;
    setState(() => _isSaving = true);
    final error = await context
        .read<MyVocabularyProvider>()
        .addWordsToTopic(topicId, _selected.toList());
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Đã thêm ${_selected.length} từ vào chủ đề.')),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<MyVocabularyProvider>();
    if (provider.topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Bạn chưa có chủ đề nào. Hãy tạo chủ đề trước.',
            textAlign: TextAlign.center,
            style: palette.body,
          ),
        ),
      );
    }
    final topic = _topicId == null ? null : provider.topicById(_topicId!);
    final keyword = _search.text.trim();
    final words = provider.allWords
        .where((word) => topic == null || !topic.contains(word.id))
        .where((word) => keyword.isEmpty || word.matches(keyword))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            8,
          ),
          child: Column(
            children: [
              TopicPicker(
                value: _topicId,
                allowNone: false,
                onChanged: (value) => setState(() {
                  _topicId = value;
                  _selected.clear();
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Tìm từ để thêm',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              final checked = _selected.contains(word.id);
              void toggle() => setState(
                    () => checked
                        ? _selected.remove(word.id)
                        : _selected.add(word.id),
                  );
              return WordTile(
                word: word,
                onTap: toggle,
                trailing: Checkbox(
                  value: checked,
                  onChanged: (_) => toggle(),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: ElevatedButton(
              onPressed: _topicId == null || _selected.isEmpty || _isSaving
                  ? null
                  : _save,
              child: Text(
                _selected.isEmpty
                    ? 'Chọn từ để thêm'
                    : 'Thêm ${_selected.length} từ vào chủ đề',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
