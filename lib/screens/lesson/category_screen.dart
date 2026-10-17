import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/entity_card.dart';
import '../base/generic_list_screen.dart';
import 'lesson_screen.dart';

/// Màn hình đầu tiên của luồng "Học mới": hiển thị danh sách chủ đề.
/// Kế thừa bố cục chung [GenericListScreen] với T = Category.
/// Màn hình nằm trong tab của MainScreen nên không có AppBar riêng.
class CategoryScreen extends GenericListScreen<Category> {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  void onLoad(BuildContext context) =>
      context.read<LessonProvider>().loadCategories();

  @override
  bool isLoading(BuildContext context) {
    final provider = context.watch<LessonProvider>();
    return provider.isLoading && provider.categories.isEmpty;
  }

  @override
  String? errorMessage(BuildContext context) {
    final provider = context.watch<LessonProvider>();
    return provider.categories.isEmpty ? provider.errorMessage : null;
  }

  @override
  List<Category> items(BuildContext context) =>
      context.watch<LessonProvider>().categories;

  @override
  void onRetry(BuildContext context) =>
      context.read<LessonProvider>().loadCategories();

  @override
  String get emptyMessage => 'Chưa có chủ đề nào.';

  @override
  Widget buildItem(BuildContext context, Category item) {
    return EntityCard(
      entity: item,
      onTap: () => _openCategory(context, item),
    );
  }

  Future<void> _openCategory(BuildContext context, Category category) async {
    final provider = context.read<LessonProvider>();
    await provider.selectCategory(category);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LessonScreen()),
    );
  }
}
