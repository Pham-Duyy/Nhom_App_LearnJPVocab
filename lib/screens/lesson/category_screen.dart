import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/lesson_provider.dart';
import '../common/generic_list_screen.dart';
import 'lesson_screen.dart';

class CategoryScreen extends GenericListScreen<Category> {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Học mới';

  @override
  bool get showAppBar => false;

  @override
  List<Category> getItems(BuildContext context) =>
      context.watch<LessonProvider>().categories;

  @override
  bool isLoading(BuildContext context) =>
      context.watch<LessonProvider>().isLoading;

  @override
  String? getErrorMessage(BuildContext context) =>
      context.watch<LessonProvider>().errorMessage;

  @override
  String get emptyMessage => 'Chưa có chủ đề nào.';

  @override
  void onRetry(BuildContext context) {
    context.read<LessonProvider>().loadCategories();
  }

  @override
  Future<void> onItemTap(BuildContext context, Category item) async {
    await context.read<LessonProvider>().selectCategory(item);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LessonScreen()),
    );
  }
}
