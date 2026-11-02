import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

enum HankoShape { square, circle }

/// Dấu triện hanko: chữ đỏ son trong khung, hơi nghiêng như đóng bằng tay.
/// Dùng cho chuỗi ngày học, thành tích và đáp án đúng.
class HankoStamp extends StatelessWidget {
  const HankoStamp({
    Key? key,
    required this.text,
    this.caption,
    this.size = 56,
    this.shape = HankoShape.square,
    this.angle = -0.08,
    this.faded = false,
  }) : super(key: key);

  final String text;

  /// Dòng chữ nhỏ dưới [text], vd. "liên tiếp".
  final String? caption;
  final double size;
  final HankoShape shape;

  /// Góc nghiêng (radian).
  final double angle;

  /// Dấu mờ, nét đứt: thành tích chưa đạt.
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = faded ? palette.textMuted : palette.stamp;
    return Transform.rotate(
      angle: faded ? 0 : angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: faded ? null : palette.stamp.withValues(alpha: 0.08),
          border: Border.all(color: color, width: size / 24),
          shape:
              shape == HankoShape.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == HankoShape.square
              ? BorderRadius.circular(size / 6)
              : null,
        ),
        padding: EdgeInsets.all(size / 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chữ dài (vd. 不合格) tự thu nhỏ cho vừa khung dấu.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: AppTextStyles.japaneseDisplay.copyWith(
                  fontSize: size * (caption == null ? 0.44 : 0.34),
                  color: color,
                  height: 1,
                ),
              ),
            ),
            if (caption != null)
              Text(
                caption!,
                maxLines: 1,
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
