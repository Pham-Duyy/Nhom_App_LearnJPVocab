import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/my_vocabulary_provider.dart';

/// Ô chọn chủ đề tự tạo, dùng trong form thêm từ, thêm từ vào chủ đề và
/// import. [allowNone] cho phép chọn "Không thêm vào chủ đề nào".
class TopicPicker extends StatelessWidget {
  const TopicPicker({
    Key? key,
    required this.value,
    required this.onChanged,
    this.allowNone = true,
  }) : super(key: key);

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    final topics = context.watch<MyVocabularyProvider>().topics;
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Chủ đề'),
      hint: const Text('Chọn chủ đề'),
      validator: (selected) =>
          !allowNone && selected == null ? 'Hãy chọn một chủ đề.' : null,
      items: [
        if (allowNone)
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Không thêm vào chủ đề nào'),
          ),
        for (final topic in topics)
          DropdownMenuItem<String?>(
            value: topic.id,
            child: Text(
              '${topic.name} (${topic.wordCount} từ)',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
