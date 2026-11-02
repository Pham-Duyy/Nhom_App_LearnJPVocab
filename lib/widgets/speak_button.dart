import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/speaker.dart';
import '../theme/app_colors.dart';
import '../utils/app_error.dart';
import 'error_view.dart';

/// Nút loa đọc to [text] bằng tiếng Nhật.
class SpeakButton extends StatelessWidget {
  const SpeakButton({
    Key? key,
    required this.text,
    this.size = 24,
    this.color,
  }) : super(key: key);

  /// Nên là cách đọc kana: giọng đọc tự động hay đọc sai chữ Hán.
  final String text;
  final double size;

  /// Màu biểu tượng loa; mặc định là màu chính.
  final Color? color;

  /// Đọc [text] và báo lỗi bằng SnackBar; dùng chung cho cả chỗ tự phát âm
  /// (vd. câu hỏi nghe trong quiz).
  static Future<void> speak(BuildContext context, String text) async {
    try {
      await context.read<Speaker>().speak(text);
    } on SpeakerUnavailableException {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          'Máy của bạn chưa có giọng đọc tiếng Nhật. Hãy thêm giọng tiếng '
          'Nhật trong cài đặt ngôn ngữ của máy.',
        );
      }
    } catch (e, stack) {
      AppError.log('SpeakButton', e, stack);
      if (context.mounted) {
        showErrorSnackBar(context, 'Không phát được âm thanh. Hãy thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Nghe phát âm',
      onPressed: () => speak(context, text),
      icon: Icon(
        Icons.volume_up_rounded,
        size: size,
        color: color ?? context.palette.primary,
      ),
    );
  }
}
