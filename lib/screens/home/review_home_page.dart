import 'package:flutter/material.dart';

import '../../widgets/greeting_section.dart';
import '../../widgets/memory_card.dart';
import '../../widgets/review_card.dart';

class ReviewHomePage extends StatelessWidget {
  const ReviewHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const GreetingSection(),
        const SizedBox(height: 24),
        const MemoryCard(),
        const SizedBox(height: 16),
        ReviewCard(
          onReview: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bắt đầu phiên ôn tập 3 từ!'),
              ),
            );
          },
        ),
      ],
    );
  }
}
