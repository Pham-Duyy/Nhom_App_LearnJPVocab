import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/lesson_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_card.dart';
import 'lesson_screen.dart';

/// Màn hình đầu tiên của luồng "Học mới": hiển thị danh sách chủ đề.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    // loadCategories() gọi notifyListeners() ngay khi bắt đầu; gọi thẳng
    // trong initState sẽ rơi vào lúc widget đang build, nên phải đợi qua
    // frame đầu tiên.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadCategories();
    });
  }

  Future<void> _openCategory(Category category) async {
    final provider = context.read<LessonProvider>();
    await provider.selectCategory(category);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LessonScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.errorMessage!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.loadCategories(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.page),
          itemCount: provider.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = provider.categories[index];
            return _CategoryCard(
              category: category,
              onTap: () => _openCategory(category),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(category.name, style: AppTextStyles.cardTitle),
        subtitle: Text(category.description),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}
