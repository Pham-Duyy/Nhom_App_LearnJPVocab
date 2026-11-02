import 'dart:math';

import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/data/quiz_generator.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:chibakanji/screens/quiz/quiz_screen.dart';
import 'package:chibakanji/services/speaker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_speaker.dart';

/// Màn hình quiz chỉ có câu hỏi nghe.
Future<QuizProvider> _openListeningQuiz(
  WidgetTester tester,
  FakeSpeaker speaker,
) async {
  final quiz = QuizProvider(
    MockQuizAttemptRepository(),
    MockVocabularyRepository(),
    generator:
        QuizGenerator(random: Random(5), builders: const [ListenToWord()]),
  )..start(
      quizId: 'listen',
      title: 'Quiz nghe',
      words: MockLearningData.vocabulary,
    );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<Speaker>.value(value: speaker),
        ChangeNotifierProvider.value(value: quiz),
      ],
      child: const MaterialApp(home: QuizScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return quiz;
}

void main() {
  testWidgets('câu nghe tự đọc từ khi hiện ra và không lộ chữ trên đề bài', (
    tester,
  ) async {
    final speaker = FakeSpeaker();
    final quiz = await _openListeningQuiz(tester, speaker);
    final question = quiz.currentQuestion!;

    expect(find.text('Nghe và chọn từ đúng'), findsOneWidget);
    expect(speaker.spoken, [question.pronunciation]);
    // Chữ đáp án chỉ xuất hiện một lần: trong danh sách đáp án.
    expect(find.text(question.correctAnswer), findsOneWidget);
  });

  testWidgets('bấm loa thì nghe lại; sang câu mới thì tự đọc câu mới', (
    tester,
  ) async {
    final speaker = FakeSpeaker();
    final quiz = await _openListeningQuiz(tester, speaker);
    final first = quiz.currentQuestion!;

    await tester.tap(find.byTooltip('Nghe lại'));
    await tester.pumpAndSettle();
    expect(speaker.spoken, [first.pronunciation, first.pronunciation]);

    quiz.answer(first.correctIndex);
    await quiz.next();
    await tester.pumpAndSettle();
    expect(speaker.spoken.last, quiz.currentQuestion!.pronunciation);
    expect(speaker.spoken, hasLength(3));
  });
}
