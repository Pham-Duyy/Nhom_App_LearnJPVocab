import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Khung báo lỗi kèm nút làm lại, dùng chung cho mọi màn hình tải dữ liệu.
class ErrorView extends StatelessWidget {
  const ErrorView({
    Key? key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off_rounded,
    this.actionLabel = 'Thử lại',
  }) : super(key: key);

  final String message;

  /// Null thì nút bị khóa (vd. đang thử lại).
  final VoidCallback? onRetry;
  final IconData icon;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: palette.primary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: palette.body),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Báo lỗi ngắn ở cuối màn hình, cho các thao tác nhỏ (yêu thích, lưu...).
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
