import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class SwipeFlashcard extends StatefulWidget {
  const SwipeFlashcard({
    Key? key,
    required this.cardId,
    required this.front,
    required this.back,
    required this.onSwiped,
    this.enabled = true,
  }) : super(key: key);

  final String cardId;
  final Widget front;
  final Widget back;
  final Future<void> Function(bool remembered) onSwiped;
  final bool enabled;

  @override
  State<SwipeFlashcard> createState() => SwipeFlashcardState();
}

class SwipeFlashcardState extends State<SwipeFlashcard>
    with TickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..addListener(_onSlideTick);
  Animation<double>? _slideAnimation;
  double _dx = 0;
  double _width = 1;
  bool _busy = false;
  bool _pastThreshold = false;

  double get _threshold => _width * 0.28;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void didUpdateWidget(SwipeFlashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cardId != widget.cardId) {
      _slide.stop();
      _flip.value = 0;
      _dx = 0;
      _busy = false;
      _pastThreshold = false;
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _slide.dispose();
    super.dispose();
  }

  void _onSlideTick() {
    final animation = _slideAnimation;
    if (animation != null) setState(() => _dx = animation.value);
  }

  Future<void> _slideTo(double target) async {
    if (_reduceMotion) {
      setState(() => _dx = target);
      return;
    }
    _slideAnimation = Tween(begin: _dx, end: target).animate(
      CurvedAnimation(parent: _slide, curve: Curves.easeOutCubic),
    );
    await _slide.forward(from: 0);
  }

  void flip() {
    if (_busy) return;
    final showingBack = _flip.status == AnimationStatus.forward ||
        _flip.status == AnimationStatus.completed;
    if (_reduceMotion) {
      _flip.value = showingBack ? 0 : 1;
    } else if (showingBack) {
      _flip.reverse();
    } else {
      _flip.forward();
    }
  }

  Future<void> swipe(bool remembered) async {
    if (_busy || !widget.enabled) return;
    _busy = true;
    HapticFeedback.selectionClick();
    final cardId = widget.cardId;
    await _slideTo((remembered ? 1 : -1) * _width * 1.4);
    if (!mounted || widget.cardId != cardId) return;
    await widget.onSwiped(remembered);
  }

  void reset() {
    _busy = false;
    _pastThreshold = false;
    _slideTo(0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_busy || !widget.enabled) return;
    setState(() => _dx += details.delta.dx);
    final pastThreshold = _dx.abs() >= _threshold;
    if (pastThreshold != _pastThreshold) {
      _pastThreshold = pastThreshold;
      if (pastThreshold) HapticFeedback.lightImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_busy || !widget.enabled) return;
    final velocity = details.primaryVelocity ?? 0;
    final direction = _dx != 0 ? _dx : velocity;
    final isFling = velocity.abs() > 900 && velocity.sign == direction.sign;
    if (_dx.abs() >= _threshold || isFling) {
      swipe(direction > 0);
    } else {
      _pastThreshold = false;
      _slideTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        final progress = (_dx / _threshold).clamp(-1.0, 1.0).toDouble();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              bottom: -12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.lavenderSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: palette.lavenderBorder),
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: flip,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Transform.translate(
                  offset: Offset(_dx, 0),
                  child: Transform.rotate(
                    angle: _dx / _width * 0.22,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _flip,
                            builder: (context, _) => _buildFace(),
                          ),
                        ),
                        if (progress.abs() > 0.05)
                          Positioned(
                            top: 22,
                            left: progress > 0 ? 22 : null,
                            right: progress < 0 ? 22 : null,
                            child: Opacity(
                              opacity: progress.abs(),
                              child: _SwipeLabel(remembered: progress > 0),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFace() {
    final angle = _flip.value * math.pi;
    final showBack = angle > math.pi / 2;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(angle),
      child: showBack
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: widget.back,
            )
          : widget.front,
    );
  }
}

class _SwipeLabel extends StatelessWidget {
  const _SwipeLabel({required this.remembered});

  final bool remembered;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = remembered ? palette.primary : palette.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            remembered ? Icons.check_rounded : Icons.replay_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            remembered ? 'Đã nhớ' : 'Chưa nhớ',
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
