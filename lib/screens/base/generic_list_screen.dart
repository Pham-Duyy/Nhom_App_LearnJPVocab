import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';
import 'generic_screen.dart';

/// LỚP 2 — bố cục chung (Generics) cho các màn hình dạng danh sách.
/// Kế thừa [GenericScreen] (AppBar + tải dữ liệu) và viết sẵn phần nội dung:
/// đang tải → vòng xoay, lỗi → thông báo + nút "Thử lại",
/// rỗng → dòng chữ, có dữ liệu → ListView.
///
/// T là kiểu phần tử trong danh sách, ví dụ:
///   - CategoryScreen extends GenericListScreen<Category>
///   - LessonScreen   extends GenericListScreen<Lesson>
abstract class GenericListScreen<T> extends GenericScreen {
  const GenericListScreen({Key? key}) : super(key: key);

  /// Dòng chữ hiện khi danh sách rỗng.
  String get emptyMessage => 'Chưa có dữ liệu.';

  // ===== Lớp con BẮT BUỘC override =====

  bool isLoading(BuildContext context);
  String? errorMessage(BuildContext context);
  List<T> items(BuildContext context);
  void onRetry(BuildContext context);

  /// Giao diện của một phần tử kiểu T trong danh sách.
  Widget buildItem(BuildContext context, T item);

  @override
  Widget buildContent(BuildContext context) {
    if (isLoading(context)) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = errorMessage(context);
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onRetry(context),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final list = items(context);
    if (list.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => buildItem(context, list[index]),
    );
  }
}
