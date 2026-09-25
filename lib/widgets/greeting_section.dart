import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.avatarBackground,
          child: Text('•ᴗ•', style: TextStyle(fontSize: 24)),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào Duy!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Mỗi ngày một chút, nhớ lâu hơn.'),
            ],
          ),
        ),
      ],
    );
  }
}
