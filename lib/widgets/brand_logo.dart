import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({Key? key, this.size = 36, this.showName = true})
      : super(key: key);

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final mark = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        'ち',
        style: TextStyle(
          color: palette.onPrimary,
          fontSize: size * 0.56,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );

    if (!showName) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        Flexible(
          child: Text(
            'ChibaKanji',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }
}
