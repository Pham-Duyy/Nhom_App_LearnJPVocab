import 'package:chibakanji/models/study_preferences.dart';
import 'package:chibakanji/widgets/choice_segments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  testWidgets('ChoiceSegments<int>: hiện nhãn và trả về đúng số được chọn', (
    tester,
  ) async {
    int? picked;
    await _pump(
      tester,
      ChoiceSegments<int>(
        options: StudyPreferences.quizLengthOptions,
        selected: 10,
        labelOf: (length) => '$length câu',
        onChanged: (length) => picked = length,
      ),
    );

    await tester.tap(find.text('15 câu'));

    expect(picked, 15);
  });

  testWidgets('ChoiceSegments<CardFront>: chọn theo enum, không theo vị trí', (
    tester,
  ) async {
    CardFront? picked;
    await _pump(
      tester,
      ChoiceSegments<CardFront>(
        options: CardFront.values,
        selected: CardFront.japanese,
        labelOf: (front) => front.name,
        onChanged: (front) => picked = front,
      ),
    );

    await tester.tap(find.text('meaning'));

    expect(picked, CardFront.meaning);
  });

  testWidgets('không có labelOf thì hiện chính giá trị', (tester) async {
    await _pump(
      tester,
      ChoiceSegments<String>(
        options: const ['N5', 'N4'],
        selected: 'N5',
        onChanged: (_) {},
      ),
    );

    expect(find.text('N5'), findsOneWidget);
    expect(find.text('N4'), findsOneWidget);
  });
}
