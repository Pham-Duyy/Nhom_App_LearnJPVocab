import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'app_card.dart';

/// Widget thẻ học từ vựng (Flashcard) với hiệu ứng lật 3D (Flip Card).
/// Dùng chung cho cả màn hình Học mới và Ôn tập.
class FlashcardWidget extends StatefulWidget {
  const FlashcardWidget({
    Key? key,
    required this.word,
    this.duration = const Duration(milliseconds: 400),
    this.onFlip,
  }) : super(key: key);

  final Vocabulary word;
  final Duration duration;
  final ValueChanged<bool>? onFlip;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi chuyển sang từ mới (next card), tự động reset về mặt trước ngay lập tức
    if (oldWidget.word.id != widget.word.id) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_controller.isCompleted) {
      _controller.reverse();
      widget.onFlip?.call(false);
    } else {
      _controller.forward();
      widget.onFlip?.call(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final value = _animation.value;
          final angle = value * math.pi;
          final isBack = value >= 0.5;

          // Hiệu ứng lật 3D theo trục Y với phối cảnh chiều sâu
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCardContainer(
                      child: _buildBack(),
                    ),
                  )
                : _buildCardContainer(
                    child: _buildFront(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AppCard(
        radius: AppRadius.cardLarge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(child: child),
        ),
      ),
    );
  }

  /// Mặt trước: Hiển thị Kanji, Kana, Romaji và gợi ý chạm để lật
  Widget _buildFront() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.word.kanji.isNotEmpty) ...[
          Text(
            widget.word.kanji,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          widget.word.kana,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.word.romaji,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 16, color: Colors.grey),
            SizedBox(width: 6),
            Text(
              'Chạm để xem nghĩa',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  /// Mặt sau: Hiển thị Nghĩa tiếng Việt, Câu ví dụ và dịch nghĩa
  Widget _buildBack() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.word.meaning,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.appBarForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (widget.word.exampleJapanese.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  widget.word.exampleJapanese,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                if (widget.word.exampleVietnamese.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.word.exampleVietnamese,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flip_to_front_outlined, size: 16, color: Colors.grey),
            SizedBox(width: 6),
            Text(
              'Chạm để quay lại từ vựng',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
