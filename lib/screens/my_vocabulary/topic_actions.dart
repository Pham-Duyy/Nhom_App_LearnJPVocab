import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_topic.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/error_view.dart';
import '../flashcard/flashcard_screen.dart';

/// Học ngay các từ của [topic] bằng flashcard.
Future<void> studyTopic(BuildContext context, UserTopic topic) async {
  final words = context.read<MyVocabularyProvider>().wordsOf(topic);
  if (words.isEmpty) {
    showErrorSnackBar(context, 'Chủ đề "${topic.name}" chưa có từ nào.');
    return;
  }
  await context.read<VocabularyProvider>().loadWords(words);
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FlashcardScreen(
        title: topic.name,
        completionTitle: 'Đã học xong "${topic.name}"!',
      ),
    ),
  );
}

/// Bảng nhỏ chỉ hỏi tên để tạo chủ đề nhanh, thay cho cả một màn form.
Future<void> showCreateTopicSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CreateTopicSheet(),
  );
}

class _CreateTopicSheet extends StatefulWidget {
  const _CreateTopicSheet();

  @override
  State<_CreateTopicSheet> createState() => _CreateTopicSheetState();
}

class _CreateTopicSheetState extends State<_CreateTopicSheet> {
  final _name = TextEditingController();
  String? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _isSaving = true);
    final error =
        await context.read<MyVocabularyProvider>().createTopic(_name.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _error = error;
        _isSaving = false;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Đẩy bảng lên trên bàn phím khi đang gõ.
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Chủ đề mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: UserTopic.maxNameLength,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              labelText: 'Tên chủ đề',
              hintText: 'Vd. Từ vựng ở chỗ làm',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSaving ? null : _create,
            child: const Text('Tạo chủ đề'),
          ),
        ],
      ),
    );
  }
}
