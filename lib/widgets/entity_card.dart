import 'package:flutter/material.dart';

import '../models/generic_entity.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'app_card.dart';

/// Card dùng chung cho mọi entity kế thừa [GenericEntity]:
/// tiêu đề là name, dòng phụ là description (hoặc [subtitle] nếu truyền vào).
class EntityCard extends StatelessWidget {
  const EntityCard({
    Key? key,
    required this.entity,
    required this.onTap,
    this.subtitle,
    this.isThreeLine = false,
  }) : super(key: key);

  final GenericEntity entity;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isThreeLine;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(entity.getName(), style: AppTextStyles.cardTitle),
        subtitle: Text(subtitle ?? entity.getDescription()),
        isThreeLine: isThreeLine,
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}
