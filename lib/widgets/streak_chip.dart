import 'package:flutter/material.dart';

import 'hanko_stamp.dart';

/// Chuỗi ngày học liên tiếp, đóng như một con dấu: "5日" (5 ngày).
class StreakChip extends StatelessWidget {
  const StreakChip({Key? key, required this.days}) : super(key: key);

  final int days;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$days ngày học liên tiếp',
      excludeSemantics: true,
      child: HankoStamp(text: '$days日', caption: 'liên tiếp', size: 60),
    );
  }
}
