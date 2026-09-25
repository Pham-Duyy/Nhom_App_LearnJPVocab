import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BẠN ĐÃ HỌC'),
            Text(
              '9 từ vựng',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MemoryBar(level: 1, count: 3, height: 55),
                MemoryBar(level: 2, count: 3, height: 75),
                MemoryBar(level: 3, count: 1, height: 35),
                MemoryBar(level: 4, count: 1, height: 42),
                MemoryBar(level: 5, count: 1, height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryBar extends StatelessWidget {
  const MemoryBar({
    Key? key,
    required this.level,
    required this.count,
    required this.height,
  }) : super(key: key);

  final int level;
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$count'),
          const SizedBox(height: 5),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.memoryLevelColors[level - 1],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text('Mức $level', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
