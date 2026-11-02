import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = palette.progressTrack;
    final highlight = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.07 : 0.65),
      base,
    );

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.35, 0.5, 0.65],
          begin: const Alignment(-1, -0.3),
          end: const Alignment(1, 0.3),
          transform: _SlideGradient(_controller.value * 2 - 1),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.slide);

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    Key? key,
    this.width,
    this.height = 14,
    this.radius = 8,
  }) : super(key: key);

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.palette.progressTrack,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({Key? key, this.itemCount = 3}) : super(key: key);

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Đang tải',
      child: Shimmer(
        child: Column(
          children: [
            for (var i = 0; i < itemCount; i++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 54, height: 54, radius: 16),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.6,
                            child: SkeletonBox(height: 18),
                          ),
                          SizedBox(height: 12),
                          SkeletonBox(),
                          SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 0.75,
                            child: SkeletonBox(),
                          ),
                          SizedBox(height: 16),
                          SkeletonBox(height: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
