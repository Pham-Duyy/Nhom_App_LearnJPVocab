import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<MockUserProfileRepository> _openProfile(WidgetTester tester) async {
  final repository = MockUserProfileRepository(
    initialProfile: const UserProfile(displayName: 'Duy'),
  );
  await tester.pumpWidget(buildTestApp(userProfileRepository: repository));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Cá nhân'));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _openEditNameDialog(WidgetTester tester) async {
  await tester.tap(find.text('Chỉnh sửa'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('US20: đổi tên ở Cá nhân thì lời chào ở Ôn tập đổi theo', (
    tester,
  ) async {
    final repository = await _openProfile(tester);

    await _openEditNameDialog(tester);
    await tester.enterText(find.byType(TextFormField), 'Sơn');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Sơn'), findsOneWidget);
    expect((await repository.load())!.displayName, 'Sơn');

    await tester.tap(find.text('Ôn tập'));
    await tester.pumpAndSettle();
    expect(find.text('Chào Sơn!'), findsOneWidget);
  });

  testWidgets('US20: tên để trống thì báo lỗi và không đóng hộp thoại', (
    tester,
  ) async {
    final repository = await _openProfile(tester);

    await _openEditNameDialog(tester);
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Tên không được để trống.'), findsOneWidget);
    expect(find.text('Đổi tên hiển thị'), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('US20: bấm Hủy thì giữ nguyên tên cũ', (tester) async {
    final repository = await _openProfile(tester);

    await _openEditNameDialog(tester);
    await tester.enterText(find.byType(TextFormField), 'Tên khác');
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();

    expect(find.text('Duy'), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('US18: chọn mục tiêu 20 từ thì Cá nhân và Ôn tập cùng cập nhật', (
    tester,
  ) async {
    final repository = await _openProfile(tester);

    // ensureVisible cuộn cả mục vào vùng nhìn thấy; scrollUntilVisible có thể
    // dừng khi mục mới ló ra một phần, còn nửa dưới nằm sau thanh điều hướng.
    await tester.ensureVisible(find.text('Mục tiêu mỗi ngày'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mục tiêu mỗi ngày'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 từ mỗi ngày'));
    await tester.pumpAndSettle();

    expect(find.text('20 từ'), findsOneWidget);
    expect((await repository.load())!.dailyGoal, 20);

    await tester.tap(find.text('Ôn tập'));
    await tester.pumpAndSettle();
    expect(find.textContaining('/ 20 từ'), findsOneWidget);
  });

  testWidgets('US19: học một thẻ thì chuỗi ngày ở Ôn tập từ 0 lên 1', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(
      userProfileRepository: MockUserProfileRepository(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('0 ngày'), findsOneWidget);

    await tester.tap(find.text('Học mới'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chào hỏi và giao tiếp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chào hỏi cơ bản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã nhớ'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ôn tập'));
    await tester.pumpAndSettle();

    expect(find.text('1 ngày'), findsOneWidget);
  });
}
