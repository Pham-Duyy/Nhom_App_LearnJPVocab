import 'package:chibakanji/widgets/pill_choices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PillChoices<String>: chạm vào nút thì trả về đúng lựa chọn', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PillChoices<String>(
            options: const ['N5', 'N4', 'Ngành'],
            selected: 'N5',
            onChanged: (level) => picked = level,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ngành'));

    expect(picked, 'Ngành');
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'N5')).selected,
      isTrue,
    );
  });
}
