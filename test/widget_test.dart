// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('displays and updates today\'s tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CalmDayApp());

    expect(find.text('Ngày nhẹ nhàng'), findsOneWidget);
    expect(find.text('1/3 việc đã hoàn thành'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    expect(
      find.text('Không cần vội. Một việc hoàn thành cũng là tiến bộ.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Hoàn thành một việc quan trọng'));
    await tester.pump();

    expect(find.text('2/3 việc đã hoàn thành'), findsOneWidget);
  });
}
