import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// LỚP 1 — bố cục chung cho MỌI màn hình.
///
/// Cây kế thừa màn hình:
///
///   GenericScreen                    (lớp 1: AppBar + tải dữ liệu + nội dung)
///   ├── ProfileScreen                (dùng trực tiếp lớp 1)
///   └── GenericListScreen<T>         (lớp 2: bố cục danh sách)
///       ├── CategoryScreen           (lớp 3: T = Category)
///       └── LessonScreen             (lớp 3: T = Lesson)
abstract class GenericScreen extends StatefulWidget {
  const GenericScreen({Key? key}) : super(key: key);

  /// Tiêu đề AppBar. Trả về null nếu màn hình không cần AppBar riêng
  /// (ví dụ màn hình nằm trong một tab của MainScreen).
  String? appBarTitle(BuildContext context) => null;

  /// Gọi một lần khi mở màn hình, dùng để tải dữ liệu.
  void onLoad(BuildContext context) {}

  /// Phần nội dung chính — lớp con bắt buộc viết.
  Widget buildContent(BuildContext context);

  @override
  State<GenericScreen> createState() => _GenericScreenState();
}

class _GenericScreenState extends State<GenericScreen> {
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
    final content = widget.buildContent(context);
    final title = widget.appBarTitle(context);
    if (title == null) return content;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        title: Text(title),
      ),
      body: content,
    );
  }
}
