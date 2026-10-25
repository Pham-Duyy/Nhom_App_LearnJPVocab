import 'package:flutter/material.dart';

import '../../models/generic_entity.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeleton.dart';
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

  Widget? buildHeader(BuildContext context) => null;

  Widget buildSeparator(BuildContext context) => const SizedBox(height: 12);

  Widget buildLoading(BuildContext context) => const SkeletonList();

  Widget buildEmptyState(BuildContext context) => Text(
        emptyMessage,
        textAlign: TextAlign.center,
        style: context.palette.body,
      );

  Widget buildItem(BuildContext context, T item) {
    final subtitle = getSubtitle(item);
    return AppCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(item.name, style: AppTextStyles.cardTitle),
        subtitle: Text(subtitle),
        isThreeLine: subtitle.contains('\n'),
        trailing: Icon(Icons.chevron_right, color: context.palette.primary),
        onTap: () => onItemTap(context, item),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final items = getItems(context);
    final header = buildHeader(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        if (header != null) header,
        if (items.isNotEmpty)
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) buildSeparator(context),
            buildItem(context, items[i]),
          ]
        else if (isLoading(context))
          buildLoading(context)
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(child: _buildMessage(context)),
          ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context) {
    final errorMessage = getErrorMessage(context);
    if (errorMessage == null) return buildEmptyState(context);

    return ErrorView(message: errorMessage, onRetry: () => onRetry(context));
  }
}
