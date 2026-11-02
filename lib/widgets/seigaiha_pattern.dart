import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Họa tiết sóng biển seigaiha (青海波): các hàng vòng cung đồng tâm xếp so
/// le. Chỉ để trang trí, đặt phía sau nội dung.
class SeigaihaPattern extends StatelessWidget {
  const SeigaihaPattern({Key? key, required this.color, this.radius = 28})
      : super(key: key);

  final Color color;

  /// Bán kính vòng ngoài của mỗi con sóng.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _SeigaihaPainter(color: color, radius: radius),
        size: Size.infinite,
      ),
    );
  }
}

class _SeigaihaPainter extends CustomPainter {
  _SeigaihaPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _rings = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rowHeight = radius / 2;
    var row = 0;
    for (var y = size.height + radius; y > -radius; y -= rowHeight, row++) {
      final offsetX = row.isOdd ? radius : 0.0;
      for (var x = -radius + offsetX;
          x < size.width + radius;
          x += radius * 2) {
        for (var ring = 1; ring <= _rings; ring++) {
          final r = radius * ring / _rings;
          canvas.drawArc(
            Rect.fromCircle(center: Offset(x, y), radius: r),
            math.pi,
            math.pi,
            false,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SeigaihaPainter old) =>
      old.color != color || old.radius != radius;
}
