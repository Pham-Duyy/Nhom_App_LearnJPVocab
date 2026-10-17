import 'package:flutter/material.dart';

import '../../models/generic_entity.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_card.dart';
import 'generic_screen.dart';

abstract class GenericListScreen<T extends GenericEntity>
    extends GenericScreen {
  const GenericListScreen({Key? key}) : super(key: key);

  List<T> getItems(BuildContext context);

  bool isLoading(BuildContext context);

  String? getErrorMessage(BuildContext context);

  void onRetry(BuildContext context);

  void onItemTap(BuildContext context, T item);

  String get emptyMessage => 'Chưa có dữ liệu.';

  String getSubtitle(T item) => item.description;

  Widget buildItem(BuildContext context, T item) {
    final subtitle = getSubtitle(item);
    return AppCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(item.name, style: AppTextStyles.cardTitle),
        subtitle: Text(subtitle),
        isThreeLine: subtitle.contains('\n'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: () => onItemTap(context, item),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final items = getItems(context);
    final errorMessage = getErrorMessage(context);

    if (isLoading(context) && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onRetry(context),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => buildItem(context, items[index]),
    );
  }
}
