import 'package:chibakanji/models/user_profile.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/repositories/mock/mock_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/test_app.dart';

/// Màn chào có animation lặp vô hạn nên không dùng pumpAndSettle được.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// 8c: kiểm thử toàn bộ ứng dụng theo hành trình của một người dùng mới,
/// đi qua các tính năng chính theo đúng thứ tự sử dụng thật.
void main() {
  testWidgets(
      '8c: người mới đăng ký → học một bài → làm quiz → '
      'chuỗi ngày tăng và lịch sử có lượt quiz', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final profiles = MockUserProfileRepository(
      initialProfile: const UserProfile(),
    );

    // US01: màn chào.
    await tester.pumpWidget(
      buildTestApp(showWelcome: true, userProfileRepository: profiles),
    );
    await _pumpFrames(tester);
    await tester.tap(find.text('Bắt đầu cùng Chibi →'));
    await _pumpFrames(tester);

    // US03: đăng ký bằng email, đặt tên hiển thị.
    final fields = find.byType(TextFormField);
    for (final (index, value)
        in ['Lan', 'lan@gmail.com', '123456', '123456'].indexed) {
      await tester.ensureVisible(fields.at(index));
      await tester.enterText(fields.at(index), value);
    }
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Tạo tài khoản'));
    expect(find.text('Chào Lan!'), findsOneWidget);
    expect(find.text('0日'), findsOneWidget);

    // US06-US10: chọn chủ đề, chọn bài, học hết 5 thẻ.
    await _tap(tester, find.text('Học mới'));
    await _tap(tester, find.text('Chào hỏi và giao tiếp'));
    await _tap(tester, find.text('Chào hỏi cơ bản'));
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Đã nhớ'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Kết quả buổi học'), findsOneWidget);

    // US16: làm quiz ngay trên bộ từ vừa học, trả lời đúng hết.
    await _tap(tester, find.text('Làm quiz bài này'));
    final quiz =
        tester.element(find.byType(Scaffold).last).read<QuizProvider>();
    final total = quiz.questions.length;
    for (var i = 0; i < total; i++) {
      final question = quiz.currentQuestion!;
      await _tap(tester, find.text(question.correctAnswer));
      final label = quiz.isLastQuestion ? 'Xem kết quả' : 'Câu tiếp theo';
      await tester.scrollUntilVisible(
        find.text(label),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await _tap(tester, find.text(label));
    }
    expect(find.text('$total/$total'), findsOneWidget);

    // US19: về trang chủ, chuỗi ngày đã lên 1.
    await _tap(tester, find.text('Về trang chủ'));
    expect(find.text('1日'), findsOneWidget);

    // US17 + US20: Cá nhân hiện đúng tên và lượt quiz vừa làm.
    await _tap(tester, find.text('Cá nhân'));
    expect(find.text('Lan'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Lịch sử quiz'), 200);
    await _tap(tester, find.text('Lịch sử quiz'));
    expect(find.text('Chào hỏi cơ bản'), findsOneWidget);
    expect(find.text('$total/$total'), findsOneWidget);
  });
}
