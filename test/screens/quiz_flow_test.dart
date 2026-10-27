import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/providers/progress_provider.dart';
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

/// Mở quiz nhanh từ trang chủ.
Future<void> _openQuickQuiz(WidgetTester tester) async {
  await pumpTestApp(tester);
  await _tap(tester, find.text('Quiz nhanh'));
}

/// Chọn đáp án đúng (hoặc sai) cho câu hiện tại rồi bấm nút tiếp theo.
Future<void> _answer(WidgetTester tester, {required bool correct}) async {
  final quiz = _read<QuizProvider>(tester);
  final question = quiz.currentQuestion!;
  final index = correct
      ? question.correctIndex
      : (question.correctIndex + 1) % question.options.length;
  await _scrollAndTap(tester, find.text(question.options[index]));

  // Nút nằm cuối danh sách, có thể chưa được ListView dựng: cuộn tới trước.
  final label = quiz.isLastQuestion ? 'Xem kết quả' : 'Câu tiếp theo';
  await tester.scrollUntilVisible(
    find.text(label),
    100,
    scrollable: find.byType(Scrollable).last,
  );
  await _tap(tester, find.text(label));
}

void main() {
  testWidgets('US16: làm hết quiz nhanh và đúng tất cả thì được điểm tối đa', (
    tester,
  ) async {
    await _openQuickQuiz(tester);
    final total = _read<QuizProvider>(tester).questions.length;

    for (var i = 0; i < total; i++) {
      await _answer(tester, correct: true);
    }

    expect(find.text('Kết quả quiz'), findsOneWidget);
    expect(find.text('$total/$total'), findsOneWidget);
    expect(find.textContaining('CẦN ÔN LẠI'), findsNothing);
  });

  testWidgets('US16: trả lời sai thì hiện đáp án đúng và đưa từ về mức 1', (
    tester,
  ) async {
    await _openQuickQuiz(tester);
    final quiz = _read<QuizProvider>(tester);
    final question = quiz.currentQuestion!;

    await _scrollAndTap(
      tester,
      find.text(question.options[(question.correctIndex + 1) % 4]),
    );

    expect(find.textContaining('Chưa đúng.'), findsOneWidget);
    final progress = _read<ProgressProvider>(tester).progressList.firstWhere(
          (Progress p) => p.vocabularyId == question.vocabularyId,
        );
    expect(progress.memoryLevel, 1);
  });

  testWidgets('US16: trả lời đúng thì từ lên một mức ghi nhớ', (tester) async {
    await _openQuickQuiz(tester);
    final question = _read<QuizProvider>(tester).currentQuestion!;
    Progress progressOf() => _read<ProgressProvider>(tester)
        .progressList
        .firstWhere((Progress p) => p.vocabularyId == question.vocabularyId);
    final before = progressOf();

    await _scrollAndTap(
      tester,
      find.text(question.options[question.correctIndex]),
    );

    // Mức 5 là cao nhất nên giữ nguyên; số lần đúng thì luôn tăng.
    final after = progressOf();
    expect(
        after.memoryLevel, before.memoryLevel < 5 ? before.memoryLevel + 1 : 5);
    expect(after.correctCount, before.correctCount + 1);
  });

  testWidgets('trả lời sai thì ôn lại đúng các từ đó bằng flashcard', (
    tester,
  ) async {
    await _openQuickQuiz(tester);
    final total = _read<QuizProvider>(tester).questions.length;
    for (var i = 0; i < total; i++) {
      await _answer(tester, correct: i >= 2);
    }

    await _scrollAndTap(tester, find.text('Ôn lại 2 từ sai bằng flashcard'));

    expect(find.text('Ôn lại từ sai'), findsOneWidget);
    expect(find.text('Từ 1/2'), findsOneWidget);
  });

  testWidgets('US16: bấm Back giữa chừng thì hỏi lại, chọn Làm tiếp thì ở lại',
      (
    tester,
  ) async {
    await _openQuickQuiz(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Thoát quiz?'), findsOneWidget);

    await _tap(tester, find.text('Làm tiếp'));
    expect(find.textContaining('Câu 1/'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Thoát quiz'));
    expect(find.text('Quiz nhanh'), findsOneWidget);
  });

  testWidgets('US17: lượt vừa làm hiện trong Lịch sử quiz ở Cá nhân', (
    tester,
  ) async {
    await _openQuickQuiz(tester);
    final total = _read<QuizProvider>(tester).questions.length;
    for (var i = 0; i < total; i++) {
      await _answer(tester, correct: i != 0);
    }
    await _tap(tester, find.text('Về trang chủ'));

    await _tap(tester, find.text('Cá nhân'));
    await tester.scrollUntilVisible(find.text('Lịch sử quiz'), 200);
    await _tap(tester, find.text('Lịch sử quiz'));

    expect(find.text('Quiz nhanh'), findsOneWidget);
    expect(find.text('${total - 1}/$total'), findsOneWidget);
  });
}
