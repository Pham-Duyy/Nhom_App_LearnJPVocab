import 'package:chibakanji/widgets/greeting_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('câu chào tiếng Nhật đổi theo giờ trong ngày', () {
    String at(int hour) =>
        GreetingSection.japaneseGreeting(DateTime(2026, 1, 15, hour));

    expect(at(7), 'おはよう');
    expect(at(10), 'おはよう');
    expect(at(11), 'こんにちは');
    expect(at(17), 'こんにちは');
    expect(at(18), 'こんばんは');
    expect(at(23), 'こんばんは');
  });
}
