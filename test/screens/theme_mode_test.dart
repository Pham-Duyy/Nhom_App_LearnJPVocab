import 'package:chibakanji/app.dart';
import 'package:chibakanji/providers/app_providers.dart';
import 'package:chibakanji/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chọn Giao diện Tối ở Cá nhân thì cả app chuyển sang nền tối', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AppProviders(child: ChibaKanjiApp(showWelcome: false)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Giao diện'), 200);
    await tester.tap(find.text('Giao diện'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Giao diện'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.palette.background, AppPalette.dark.background);
    expect(find.text('Tối'), findsOneWidget);
  });
}
