import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Bố cục chung (Generics) cho các màn hình dạng danh sách.
///
/// T là kiểu phần tử trong danh sách, ví dụ:
///   - CategoryScreen extends GenericListScreen<Category>
///   - LessonScreen   extends GenericListScreen<Lesson>
///
/// Lớp cha lo phần bố cục giống nhau ở mọi màn hình:
/// đang tải → vòng xoay, lỗi → thông báo + nút "Thử lại",
/// rỗng → dòng chữ, có dữ liệu → ListView.
/// Lớp con chỉ cần cho biết dữ liệu lấy ở đâu và mỗi dòng trông thế nào.
abstract class GenericListScreen<T> extends StatefulWidget {
  const GenericListScreen({Key? key}) : super(key: key);

  // ===== Lớp con CÓ THỂ override =====

  /// Tiêu đề AppBar. Trả về null nếu màn hình không cần AppBar riêng
  /// (ví dụ màn hình nằm trong một tab của MainScreen).
  String? appBarTitle(BuildContext context) => null;

  /// Gọi một lần khi mở màn hình, dùng để tải dữ liệu.
  void onLoad(BuildContext context) {}

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
  State<GenericListScreen<T>> createState() => _GenericListScreenState<T>();
}

class _GenericListScreenState<T> extends State<GenericListScreen<T>> {
  @override
  void initState() {
    super.initState();
    // Việc tải dữ liệu thường gọi notifyListeners() ngay lập tức; gọi thẳng
    // trong initState sẽ rơi vào lúc widget đang build, nên đợi qua frame đầu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoad(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);
    final title = widget.appBarTitle(context);
    if (title == null) return body;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        title: Text(title),
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.isLoading(context)) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = widget.errorMessage(context);
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => widget.onRetry(context),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final list = widget.items(context);
    if (list.isEmpty) {
      return Center(child: Text(widget.emptyMessage));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => widget.buildItem(context, list[index]),
    );
  }
}
