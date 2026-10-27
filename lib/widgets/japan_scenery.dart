import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'seigaiha_pattern.dart';

/// Màu hoa anh đào và cành cây, dùng chung cho các tranh trang trí.
const _blossom = Color(0xFFF4A7B6);
const _blossomCenter = Color(0xFFE0607E);
const _branch = Color(0xFF7A5646);
const _torii = Color(0xFFC8442F);
const _pine = Color(0xFF6F8BAE);

/// Nền giấy washi chung cho mọi màn hình: chuyển màu kem nhẹ, họa tiết
/// sóng seigaiha rất mờ và vài cánh hoa anh đào rơi.
class WashiBackground extends StatelessWidget {
  const WashiBackground({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.background, palette.backgroundTinted],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Stack(
                children: [
                  SeigaihaPattern(
                    color: palette.primary.withValues(alpha: 0.035),
                    radius: 34,
                  ),
                  const CustomPaint(
                    painter: _PetalsPainter(opacity: 0.35),
                    size: Size.infinite,
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Tranh đầu trang chủ: cành hoa anh đào góc trái, mặt trời và núi Phú Sĩ
/// bên phải, cánh hoa bay.
class HomeScenery extends StatelessWidget {
  const HomeScenery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _HomeSceneryPainter(context.palette),
        size: Size.infinite,
      ),
    );
  }
}

/// Tranh nhỏ trong thẻ ôn tập: mặt trời nhạt, cổng torii và hàng thông.
class ToriiScene extends StatelessWidget {
  const ToriiScene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _ToriiScenePainter(context.palette),
        size: Size.infinite,
      ),
    );
  }
}

/// Icon cổng torii (鳥居) cho tab Thi thử; lấy màu và cỡ từ [IconTheme] như
/// một [Icon] thường.
class ToriiIcon extends StatelessWidget {
  const ToriiIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 24;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ToriiPainter(color: theme.color ?? Colors.black),
      ),
    );
  }
}

/// Bông hoa anh đào 5 cánh tâm [center], bán kính [r].
void _drawBlossom(Canvas canvas, Offset center, double r, double opacity) {
  final petal = Paint()..color = _blossom.withValues(alpha: opacity);
  for (var i = 0; i < 5; i++) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(i * 2 * math.pi / 5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -r * 0.55), width: r * 0.8, height: r),
      petal,
    );
    canvas.restore();
  }
  canvas.drawCircle(
    center,
    r * 0.22,
    Paint()..color = _blossomCenter.withValues(alpha: opacity),
  );
}

/// Một cánh hoa rơi: hình bầu dục nhỏ xoay nghiêng.
void _drawPetal(
    Canvas canvas, Offset at, double size, double angle, double opacity) {
  canvas.save();
  canvas.translate(at.dx, at.dy);
  canvas.rotate(angle);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.6),
    Paint()..color = _blossom.withValues(alpha: opacity),
  );
  canvas.restore();
}

/// Cổng torii vẽ trong khung [rect].
void _drawTorii(Canvas canvas, Rect rect, Color color) {
  final w = rect.width;
  final h = rect.height;
  Offset at(double x, double y) => Offset(rect.left + x * w, rect.top + y * h);
  final paint = Paint()..color = color;

  // Xà trên (kasagi) cong hai đầu.
  final top = Path()
    ..moveTo(at(0, 0.02).dx, at(0, 0.02).dy)
    ..quadraticBezierTo(
        at(0.5, 0.14).dx, at(0.5, 0.14).dy, at(1, 0.02).dx, at(1, 0.02).dy)
    ..lineTo(at(0.94, 0.17).dx, at(0.94, 0.17).dy)
    ..quadraticBezierTo(at(0.5, 0.24).dx, at(0.5, 0.24).dy, at(0.06, 0.17).dx,
        at(0.06, 0.17).dy)
    ..close();
  canvas.drawPath(top, paint);
  // Xà dưới (nuki) và cột chống giữa.
  canvas.drawRect(Rect.fromPoints(at(0.1, 0.34), at(0.9, 0.43)), paint);
  canvas.drawRect(Rect.fromPoints(at(0.46, 0.2), at(0.54, 0.34)), paint);
  // Hai cột, hơi choãi ra ở chân.
  for (final x in [0.22, 0.78]) {
    final spread = x < 0.5 ? -0.03 : 0.03;
    canvas.drawPath(
      Path()
        ..moveTo(at(x - 0.05, 0.2).dx, at(x - 0.05, 0.2).dy)
        ..lineTo(at(x + 0.05, 0.2).dx, at(x + 0.05, 0.2).dy)
        ..lineTo(at(x + 0.055 + spread, 1).dx, at(x + 0.055 + spread, 1).dy)
        ..lineTo(at(x - 0.055 + spread, 1).dx, at(x - 0.055 + spread, 1).dy)
        ..close(),
      paint,
    );
  }
}

class _ToriiPainter extends CustomPainter {
  const _ToriiPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawTorii(canvas, Offset.zero & size, color);
  }

  @override
  bool shouldRepaint(_ToriiPainter old) => old.color != color;
}

class _PetalsPainter extends CustomPainter {
  const _PetalsPainter({required this.opacity});

  final double opacity;

  /// Vị trí cố định (tỉ lệ theo khung) để cánh hoa không nhảy khi vẽ lại.
  static const _petals = [
    (0.12, 0.08, 0.4),
    (0.88, 0.18, 1.2),
    (0.05, 0.42, 2.1),
    (0.93, 0.55, 0.7),
    (0.3, 0.72, 1.8),
    (0.75, 0.86, 2.6),
    (0.5, 0.33, 0.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, angle) in _petals) {
      _drawPetal(
          canvas, Offset(x * size.width, y * size.height), 9, angle, opacity);
    }
  }

  @override
  bool shouldRepaint(_PetalsPainter old) => old.opacity != opacity;
}

class _HomeSceneryPainter extends CustomPainter {
  const _HomeSceneryPainter(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mặt trời đỏ son nhạt, nửa khuất sau núi.
    canvas.drawCircle(
      Offset(w * 0.8, h * 0.42),
      w * 0.085,
      Paint()..color = palette.stamp.withValues(alpha: 0.25),
    );

    // Núi Phú Sĩ thấp và rộng ở góc phải dưới.
    final peakLeft = Offset(w * 0.765, h * 0.5);
    final peakRight = Offset(w * 0.835, h * 0.5);
    final mountain = Path()
      ..moveTo(w * 0.5, h * 0.95)
      ..quadraticBezierTo(w * 0.68, h * 0.68, peakLeft.dx, peakLeft.dy)
      ..lineTo(peakRight.dx, peakRight.dy)
      ..quadraticBezierTo(w * 0.92, h * 0.68, w * 1.1, h * 0.95)
      ..close();
    canvas.drawPath(
      mountain,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.primarySoft.withValues(alpha: 0.45),
            palette.primarySoft.withValues(alpha: 0.04),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.45)),
    );
    // Tuyết trên đỉnh, mép dưới răng cưa.
    final snow = Path()
      ..moveTo(peakLeft.dx, peakLeft.dy)
      ..lineTo(peakRight.dx, peakRight.dy)
      ..lineTo(w * 0.86, h * 0.565)
      ..lineTo(w * 0.84, h * 0.55)
      ..lineTo(w * 0.815, h * 0.58)
      ..lineTo(w * 0.79, h * 0.55)
      ..lineTo(w * 0.765, h * 0.575)
      ..lineTo(w * 0.74, h * 0.555)
      ..close();
    canvas.drawPath(snow, Paint()..color = palette.card.withValues(alpha: 0.9));

    // Cành hoa anh đào chạy dọc mép trên, phía trên logo.
    final branch = Paint()
      ..color = _branch.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(-10, h * 0.055)
        ..quadraticBezierTo(w * 0.22, h * 0.07, w * 0.5, h * 0.01),
      branch..strokeWidth = 3.5,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, h * 0.065)
        ..quadraticBezierTo(w * 0.28, h * 0.02, w * 0.32, -4),
      branch..strokeWidth = 2,
    );
    const blossoms = [
      (0.03, 0.05, 11.0),
      (0.13, 0.07, 9.0),
      (0.24, 0.04, 11.0),
      (0.31, 0.005, 8.0),
      (0.37, 0.05, 9.0),
      (0.48, 0.015, 10.0),
    ];
    for (final (x, y, r) in blossoms) {
      _drawBlossom(canvas, Offset(w * x, h * y), r, 0.85);
    }

    // Cánh hoa bay ngang tranh.
    const petals = [
      (0.58, 0.08, 0.5),
      (0.66, 0.2, 1.4),
      (0.52, 0.3, 2.2),
      (0.6, 0.7, 0.9),
    ];
    for (final (x, y, angle) in petals) {
      _drawPetal(canvas, Offset(w * x, h * y), 8, angle, 0.8);
    }
  }

  @override
  bool shouldRepaint(_HomeSceneryPainter old) => old.palette != palette;
}

class _ToriiScenePainter extends CustomPainter {
  const _ToriiScenePainter(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.55, h * 0.38),
      math.min(w, h) * 0.36,
      Paint()..color = palette.stamp.withValues(alpha: 0.1),
    );

    // Hàng thông xa phía sau.
    final pine = Paint()..color = _pine.withValues(alpha: 0.45);
    for (final (x, s) in [(0.12, 0.16), (0.88, 0.2), (0.74, 0.13)]) {
      final base = Offset(w * x, h * 0.82);
      for (var tier = 0; tier < 3; tier++) {
        final y = base.dy - tier * h * s * 0.45;
        final half = w * s * (0.5 - tier * 0.12);
        canvas.drawPath(
          Path()
            ..moveTo(base.dx - half, y)
            ..lineTo(base.dx + half, y)
            ..lineTo(base.dx, y - h * s * 0.6)
            ..close(),
          pine,
        );
      }
    }

    _drawTorii(
      canvas,
      Rect.fromLTWH(w * 0.24, h * 0.3, w * 0.62, h * 0.56),
      _torii.withValues(alpha: 0.9),
    );

    // Mặt đất.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.55, h * 0.88),
        width: w * 0.95,
        height: h * 0.1,
      ),
      Paint()..color = palette.primarySoft.withValues(alpha: 0.15),
    );
  }

  @override
  bool shouldRepaint(_ToriiScenePainter old) => old.palette != palette;
}
