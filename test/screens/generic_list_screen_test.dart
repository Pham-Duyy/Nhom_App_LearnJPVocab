import 'package:chibakanji/models/category.dart';
import 'package:chibakanji/screens/common/generic_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Màn hình giả lập kế thừa GenericListScreen<Category>, nhận dữ liệu cố định
/// qua constructor để kiểm tra bố cục chung mà không cần Provider.
class _FakeCategoryList extends GenericListScreen<Category> {
  const _FakeCategoryList({
    this.items = const [],
    this.loading = false,
    this.error,
    this.onTapped,
    this.onRetried,
  });

  final List<Category> items;
  final bool loading;
  final String? error;
  final void Function(Category item)? onTapped;
  final VoidCallback? onRetried;

  @override
  String getTitle(BuildContext context) => 'Danh sách thử';

  @override
  List<Category> getItems(BuildContext context) => items;

  @override
  bool isLoading(BuildContext context) => loading;

  @override
  String? getErrorMessage(BuildContext context) => error;

  @override
  void onRetry(BuildContext context) => onRetried?.call();

  @override
  void onItemTap(BuildContext context, Category item) => onTapped?.call(item);
}

const _categories = [
  Category(id: 'c1', name: 'Chào hỏi', description: 'Câu chào', order: 1),
  Category(id: 'c2', name: 'Gia đình', description: 'Người thân', order: 2),
];

Future<void> _pump(WidgetTester tester, Widget screen) {
  return tester.pumpWidget(MaterialApp(home: screen));
}

void main() {
  testWidgets('GenericScreen dựng AppBar với tiêu đề của lớp con', (
    tester,
  ) async {
    await _pump(tester, const _FakeCategoryList(items: _categories));

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Danh sách thử'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('đang tải và chưa có dữ liệu thì hiện vòng quay', (
    tester,
  ) async {
    await _pump(tester, const _FakeCategoryList(loading: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lỗi và chưa có dữ liệu thì hiện lỗi, bấm Thử lại gọi onRetry', (
    tester,
  ) async {
    var retried = 0;
    await _pump(
      tester,
      _FakeCategoryList(error: 'Mất kết nối', onRetried: () => retried++),
    );

    expect(find.text('Mất kết nối'), findsOneWidget);

    await tester.tap(find.text('Thử lại'));
    expect(retried, 1);
  });

  testWidgets('không có dữ liệu thì hiện emptyMessage mặc định', (
    tester,
  ) async {
    await _pump(tester, const _FakeCategoryList());

    expect(find.text('Chưa có dữ liệu.'), findsOneWidget);
  });

  testWidgets('thẻ mặc định hiện name/description, chạm trả về đúng item', (
    tester,
  ) async {
    Category? tapped;
    await _pump(
      tester,
      _FakeCategoryList(items: _categories, onTapped: (item) => tapped = item),
    );

    expect(find.text('Chào hỏi'), findsOneWidget);
    expect(find.text('Người thân'), findsOneWidget);

    await tester.tap(find.text('Gia đình'));
    expect(tapped?.id, 'c2');
  });

  testWidgets('đã có dữ liệu thì vẫn giữ danh sách khi đang tải lại', (
    tester,
  ) async {
    await _pump(
      tester,
      const _FakeCategoryList(items: _categories, loading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Chào hỏi'), findsOneWidget);
  });
}
