import 'package:chibakanji/providers/exam_provider.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/test_app.dart';

T _read<T>(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).last).read<T>();

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// ListView chỉ dựng các mục gần màn hình: cuộn tới [finder] rồi mới bấm.
Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await _tap(tester, finder);
}

/// Mở tab Thi thử trên thanh điều hướng rồi bắt đầu bài 10 câu.
Future<void> _startExam(WidgetTester tester) async {
  await pumpTestApp(tester);
  await _tap(
    tester,
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Thi thử'),
    ),
  );
  expect(find.text('Thi thử như đề JLPT'), findsOneWidget);
  await _tap(tester, find.text('10 câu'));
  await _tap(tester, find.text('Bắt đầu làm bài'));
}

void main() {
  testWidgets('US21: làm đúng hết 10 câu, nộp bài thì đạt 合格', (tester) async {
    await _startExam(tester);
    final exam = _read<ExamProvider>(tester);
    expect(find.text('05:00'), findsOneWidget);

    for (var i = 0; i < exam.questions.length; i++) {
      final question = exam.questions[i];
      await _scrollAndTap(
        tester,
        find.text(question.options[question.correctIndex]),
      );
      await _scrollAndTap(
        tester,
        find.text(exam.isLastQuestion ? 'Nộp bài' : 'Câu sau'),
      );
    }
    // Bảng xác nhận: nút "Nộp bài" thứ hai là của bảng.
    await _tap(tester, find.text('Nộp bài').last);

    expect(find.text('合格'), findsOneWidget);
    expect(find.text('10/10 câu đúng'), findsOneWidget);
    expect(find.text('XEM LẠI BÀI LÀM'), findsOneWidget);
    // Lượt thi hiện trong lịch sử quiz.
    expect(
      _read<QuizProvider>(tester).history.map((a) => a.title),
      contains('Thi thử N5'),
    );
  });

  testWidgets('US21: ô Thi thử ở trang chủ chuyển sang tab Thi thử', (
    tester,
  ) async {
    await pumpTestApp(tester);

    await _tap(tester, find.text('Làm bài có giờ như đề JLPT'));

    expect(find.text('Thi thử như đề JLPT'), findsOneWidget);
  });

  testWidgets('US21: hết giờ thì tự nộp, chưa làm câu nào là 不合格', (
    tester,
  ) async {
    await _startExam(tester);

    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(find.text('不合格'), findsOneWidget);
    expect(find.text('0/10 câu đúng'), findsOneWidget);
  });

  testWidgets('US21: thoát giữa chừng phải xác nhận, bài không được lưu', (
    tester,
  ) async {
    await _startExam(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Thoát bài thi?'), findsOneWidget);
    await _tap(tester, find.text('Thoát'));

    expect(find.text('Thi thử như đề JLPT'), findsOneWidget);
    expect(_read<QuizProvider>(tester).history, isEmpty);
  });
}
