// Vẽ icon app vào assets/icon: bản đầy đủ (có nền) và lớp trước trong suốt
// cho icon thích ứng (adaptive icon) của Android. Icon giống màn khởi động:
// Chibi cầm thẻ あ trên vòng tròn xanh nhạt, nền giấy washi.
//
// Chạy: flutter test tool/app_icon/app_icon_test.dart --update-goldens
// rồi: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:math' as math;

import 'package:chibakanji/widgets/chibi_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

/// Màu nền washi, trùng với adaptive_icon_background trong pubspec.yaml.
const _paper = Color(0xFFF7F3EC);
const _paperLight = Color(0xFFFCFAF6);
const _circleCenter = Color(0xFFFFFFFF);
const _circleEdge = Color(0xFFDCE6F1);
const _wave = Color(0xFF1F3A5F);
const _petal = Color(0xFFF4A7B6);

Future<void> _loadMincho() async {
  final loader = FontLoader('ShipporiMincho')
    ..addFont(Future.value(ByteData.sublistView(File(
      'assets/fonts/ShipporiMincho/ShipporiMincho-Bold.ttf',
    ).readAsBytesSync())));
  await loader.load();
}

/// [scale] thu nội dung vào giữa: lớp trước của adaptive icon chỉ chắc chắn
/// hiện phần 66% ở giữa.
class _IconArt extends StatelessWidget {
  const _IconArt({required this.withBackground, this.scale = 1});

  final bool withBackground;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: Stack(
        children: [
          if (withBackground)
            const Positioned.fill(
              child: CustomPaint(painter: _BackgroundPainter()),
            ),
          Positioned.fill(
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: Container(
                  width: _size * 0.86,
                  height: _size * 0.86,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_circleCenter, _circleEdge],
                    ),
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, _size * 0.02),
                    child: const ChibiMascot(size: _size * 0.74),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nền giấy washi: chuyển màu kem, sóng seigaiha rất mờ và vài cánh hoa.
class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_paperLight, _paper],
        ).createShader(rect),
    );
    final wave = Paint()
      ..color = _wave.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    const radius = 96.0;
    var row = 0;
    for (var y = size.height + radius; y > -radius; y -= radius / 2) {
      final offset = row.isOdd ? radius : 0.0;
      for (var x = -radius + offset; x < size.width + radius; x += radius * 2) {
        for (var ring = 1; ring <= 3; ring++) {
          canvas.drawArc(
            Rect.fromCircle(center: Offset(x, y), radius: radius * ring / 3),
            math.pi,
            math.pi,
            false,
            wave,
          );
        }
      }
      row++;
    }
    for (final (x, y, angle) in const [
      (0.1, 0.12, 0.5),
      (0.9, 0.86, 1.8),
      (0.88, 0.1, 2.4),
    ]) {
      canvas.save();
      canvas.translate(size.width * x, size.height * y);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 44, height: 26),
        Paint()..color = _petal.withValues(alpha: 0.7),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => false;
}

Future<void> _render(WidgetTester tester, Widget art, String file) async {
  tester.view.physicalSize = const Size(_size, _size);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: RepaintBoundary(child: art)),
    ),
  );
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../../assets/icon/$file'),
  );
}

void main() {
  setUpAll(_loadMincho);

  testWidgets('icon đầy đủ', (tester) async {
    await _render(
      tester,
      const _IconArt(withBackground: true),
      'app_icon.png',
    );
  });

  testWidgets('lớp trước của adaptive icon', (tester) async {
    await _render(
      tester,
      const _IconArt(withBackground: false, scale: 0.66),
      'app_icon_foreground.png',
    );
  });
}
