import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    Key? key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.minHeight = 6,
  }) : super(key: key);

  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(minHeight),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0).toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) => LinearProgressIndicator(
          value: animatedValue,
          minHeight: minHeight,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
