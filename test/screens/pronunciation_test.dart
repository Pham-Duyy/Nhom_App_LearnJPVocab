import 'dart:math';

import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/data/quiz_generator.dart';
import 'package:chibakanji/services/speaker.dart';
import 'package:chibakanji/widgets/speak_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_speaker.dart';
import '../helpers/test_app.dart';

Future<void> _openFirstLesson(WidgetTester tester, FakeSpeaker speaker) async {
  await tester.pumpWidget(buildTestApp(speaker: speaker));
  await tester.pumpAndSettle();
  for (final text in ['Học mới', 'Chào hỏi và giao tiếp', 'Chào hỏi cơ bản']) {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('bấm loa trên thẻ thì đọc cách đọc kana, thẻ không bị lật', (
    tester,
  ) async {
    final speaker = FakeSpeaker();
    await _openFirstLesson(tester, speaker);

    await tester.tap(find.byType(SpeakButton));
    await tester.pumpAndSettle();

    expect(speaker.spoken, ['こんにちは']);
    expect(find.text('Xin chào (ban ngày)'), findsNothing);
  });

  testWidgets('chi tiết từ: nghe được cả từ lẫn câu ví dụ', (tester) async {
    final speaker = FakeSpeaker();
    await tester.pumpWidget(buildTestApp(speaker: speaker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sổ từ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'chichi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ちち · chichi').last);
    await tester.pumpAndSettle();

    final buttons = find.byType(SpeakButton);
    expect(buttons, findsNWidgets(2));
    await tester.tap(buttons.first);
    await tester.tap(buttons.last);
    await tester.pumpAndSettle();

    final father =
        MockLearningData.vocabulary.firstWhere((w) => w.kanji == '父');
    expect(speaker.spoken, ['ちち', father.exampleJapanese]);
  });

  testWidgets('máy không có giọng tiếng Nhật thì hướng dẫn cài thêm', (
    tester,
  ) async {
    final speaker = FakeSpeaker()
      ..failure = const SpeakerUnavailableException();
    await _openFirstLesson(tester, speaker);

    await tester.tap(find.byType(SpeakButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('chưa có giọng đọc tiếng Nhật'), findsOneWidget);
  });

  test('quiz: chỉ đề bài tiếng Nhật mới có phát âm, đề tiếng Việt thì không',
      () {
    final questions = QuizGenerator(random: Random(3))
        .generate(MockLearningData.vocabulary, quizId: 'q', maxQuestions: 30);

    for (final question in questions) {
      final word = MockLearningData.vocabulary
          .firstWhere((w) => w.id == question.vocabularyId);
      if (question.prompt == word.meaning) {
        expect(question.pronunciation, isNull, reason: question.prompt);
      } else {
        expect(question.pronunciation, word.kana, reason: question.prompt);
      }
    }
  });
}
