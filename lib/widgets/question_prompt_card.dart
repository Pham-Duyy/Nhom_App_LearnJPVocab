import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'speak_button.dart';

/// Đề bài một câu trắc nghiệm trên nền chàm, dùng chung cho Quiz và Thi thử.
/// Câu nghe thì không hiện chữ mà tự đọc và có nút loa lớn.
class QuestionPromptCard extends StatelessWidget {
  const QuestionPromptCard({Key? key, required this.question})
      : super(key: key);

  final Question question;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: palette.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: Column(
          children: [
            Text(
              question.instruction ?? '',
              style: palette.body.copyWith(
                color: palette.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 14),
            if (question.isListening)
              _ListeningPrompt(
                key: ObjectKey(question),
                text: question.pronunciation!,
              )
            else ...[
              Text(
                question.prompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: palette.onPrimary,
                ),
              ),
              if (question.pronunciation != null) ...[
                const SizedBox(height: 4),
                SpeakButton(
                  text: question.pronunciation!,
                  color: palette.onPrimary,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Đề bài câu hỏi nghe: không hiện chữ (chữ chính là đáp án), tự đọc một lần
/// khi câu hiện ra và có nút loa lớn để nghe lại.
class _ListeningPrompt extends StatefulWidget {
  const _ListeningPrompt({super.key, required this.text});

  final String text;

  @override
  State<_ListeningPrompt> createState() => _ListeningPromptState();
}

class _ListeningPromptState extends State<_ListeningPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speak();
    });
  }

  void _speak() => SpeakButton.speak(context, widget.text);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ring = palette.onPrimary.withValues(alpha: 0.25);
    return Column(
      children: [
        Container(
          width: 124,
          height: 124,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring),
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring),
            ),
            child: IconButton.filled(
              tooltip: 'Nghe lại',
              iconSize: 36,
              padding: const EdgeInsets.all(18),
              style: IconButton.styleFrom(
                backgroundColor: palette.onPrimary,
                foregroundColor: palette.primary,
              ),
              onPressed: _speak,
              icon: const Icon(Icons.volume_up_rounded),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Nhấn loa để nghe lại',
          style: palette.body.copyWith(
            color: palette.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
