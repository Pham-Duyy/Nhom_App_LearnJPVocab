import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

enum ChibiMood { neutral, happy, sleepy, celebrate }

class ChibiMascot extends StatelessWidget {
  const ChibiMascot({
    Key? key,
    this.size = 200,
    this.mood = ChibiMood.neutral,
  }) : super(key: key);

  final double size;
  final ChibiMood mood;

  static const _labels = {
    ChibiMood.neutral: 'Chibi, bạn nhỏ cầm thẻ chữ あ',
    ChibiMood.happy: 'Chibi đang vui',
    ChibiMood.sleepy: 'Chibi đang buồn ngủ',
    ChibiMood.celebrate: 'Chibi đang ăn mừng',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _labels[mood],
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _ChibiPainter(mood)),
      ),
    );
  }
}

class _ChibiPainter extends CustomPainter {
  const _ChibiPainter(this.mood);

  final ChibiMood mood;

  static const _furLight = Color(0xFFFFFAF1);
  static const _fur = Color(0xFFF8EEDD);
  static const _furShade = Color(0xFFE9D9BF);
  static const _earInner = Color(0xFFF4C1CB);
  static const _blush = Color(0xFFF5A3B5);
  static const _eye = Color(0xFF2F2536);
  static const _nose = Color(0xFFC9808C);
  static const _mouth = Color(0xFF7A5560);
  static const _mouthOpen = Color(0xFF7A4552);
  static const _tongue = Color(0xFFF08FA5);
  static const _shadow = Color(0x26594A8C);
  static const _cardTop = Color(0xFFA486E6);
  static const _cardBottom = Color(0xFF7657C9);
  static const _sleepLetters = Color(0xFF9B8FC4);
  static const _confetti = [
    Color(0xFFF5A3B5),
    Color(0xFF9B7FDC),
    Color(0xFFF2C46D),
    Color(0xFF86C9B0),
  ];

  bool get _isCheerful =>
      mood == ChibiMood.happy || mood == ChibiMood.celebrate;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset at(double x, double y) => Offset(x * s, y * s);
    Rect oval(double cx, double cy, double w, double h) =>
        Rect.fromCenter(center: at(cx, cy), width: w * s, height: h * s);
    Paint solid(Color color) => Paint()..color = color;
    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * s
      ..strokeCap = StrokeCap.round;
    Paint fur(Rect rect) => Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [_furLight, _fur, _furShade],
        stops: [0, 0.55, 1],
      ).createShader(rect);
    void drawFur(Rect rect) => canvas.drawOval(rect, fur(rect));

    if (mood == ChibiMood.celebrate) _paintConfetti(canvas, s);

    canvas.drawOval(oval(0.5, 0.95, 0.52, 0.06), solid(_shadow));

    drawFur(oval(0.37, 0.88, 0.2, 0.11));
    drawFur(oval(0.63, 0.88, 0.2, 0.11));
    drawFur(oval(0.5, 0.72, 0.54, 0.36));

    for (final x in [0.29, 0.71]) {
      drawFur(oval(x, 0.17, 0.2, 0.2));
      canvas.drawOval(oval(x, 0.18, 0.11, 0.11), solid(_earInner));
    }

    drawFur(oval(0.5, 0.38, 0.66, 0.52));

    for (final x in [0.39, 0.61]) {
      switch (mood) {
        case ChibiMood.neutral:
          canvas.drawOval(oval(x, 0.37, 0.06, 0.08), solid(_eye));
          canvas.drawCircle(
            at(x + 0.012, 0.355),
            0.012 * s,
            solid(Colors.white),
          );
          break;
        case ChibiMood.happy:
        case ChibiMood.celebrate:
          canvas.drawArc(
            oval(x, 0.38, 0.075, 0.065),
            math.pi,
            math.pi,
            false,
            stroke(_eye, 0.014),
          );
          break;
        case ChibiMood.sleepy:
          canvas.drawArc(
            oval(x, 0.365, 0.07, 0.04),
            0,
            math.pi,
            false,
            stroke(_eye, 0.013),
          );
          break;
      }
    }

    final blushAlpha = mood == ChibiMood.sleepy ? 0.45 : 0.75;
    for (final x in [0.31, 0.69]) {
      canvas.drawOval(
        oval(x, 0.45, 0.1, 0.05),
        solid(_blush.withValues(alpha: blushAlpha)),
      );
    }
    canvas.drawOval(oval(0.5, 0.425, 0.035, 0.022), solid(_nose));
    _paintMouth(canvas, s, oval, stroke);

    if (mood == ChibiMood.sleepy) {
      _paintLetter(canvas, s, 'z', at(0.78, 0.13), 0.08);
      _paintLetter(canvas, s, 'Z', at(0.87, 0.03), 0.11);
    }

    _paintCard(canvas, s);

    drawFur(oval(0.34, 0.7, 0.11, 0.1));
    drawFur(oval(0.66, 0.7, 0.11, 0.1));
  }

  void _paintMouth(
    Canvas canvas,
    double s,
    Rect Function(double, double, double, double) oval,
    Paint Function(Color, double) stroke,
  ) {
    if (_isCheerful) {
      final mouth = Path()
        ..addArc(oval(0.5, 0.445, 0.09, 0.07), 0, math.pi)
        ..close();
      canvas.drawPath(mouth, Paint()..color = _mouthOpen);
      canvas.save();
      canvas.clipPath(mouth);
      canvas.drawOval(oval(0.5, 0.475, 0.05, 0.03), Paint()..color = _tongue);
      canvas.restore();
    } else if (mood == ChibiMood.sleepy) {
      canvas.drawOval(oval(0.5, 0.46, 0.028, 0.032), stroke(_mouth, 0.009));
    } else {
      canvas.drawArc(
        oval(0.5, 0.445, 0.07, 0.05),
        0.25,
        2.64,
        false,
        stroke(_mouth, 0.01),
      );
    }
  }

  void _paintConfetti(Canvas canvas, double s) {
    const pieces = [
      [0.10, 0.20, 0.0],
      [0.90, 0.24, 0.6],
      [0.05, 0.47, 1.1],
      [0.95, 0.52, 0.3],
      [0.20, 0.05, 0.9],
      [0.80, 0.07, 1.4],
      [0.10, 0.74, 0.2],
      [0.92, 0.78, 0.8],
    ];
    for (var i = 0; i < pieces.length; i++) {
      final piece = pieces[i];
      final paint = Paint()..color = _confetti[i % _confetti.length];
      final center = Offset(piece[0] * s, piece[1] * s);
      if (i.isEven) {
        canvas.drawCircle(center, 0.018 * s, paint);
      } else {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(piece[2]);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 0.045 * s,
              height: 0.02 * s,
            ),
            Radius.circular(0.006 * s),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  void _paintLetter(
    Canvas canvas,
    double s,
    String letter,
    Offset center,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          color: _sleepLetters,
          fontSize: fontSize * s,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _paintCard(Canvas canvas, double s) {
    canvas.save();
    canvas.translate(0.5 * s, 0.71 * s);
    canvas.rotate(-0.08);

    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 0.32 * s, height: 0.21 * s),
      Radius.circular(0.04 * s),
    );
    canvas.drawRRect(
      card.shift(Offset(0, 0.014 * s)),
      Paint()..color = _shadow,
    );
    canvas.drawRRect(
      card,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cardTop, _cardBottom],
        ).createShader(card.outerRect),
    );

    final glyph = TextPainter(
      text: TextSpan(
        text: 'あ',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontFamilyFallback: AppTextStyles.fontFamilyFallback,
          color: Colors.white,
          fontSize: 0.13 * s,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glyph.paint(canvas, Offset(-glyph.width / 2, -glyph.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChibiPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
