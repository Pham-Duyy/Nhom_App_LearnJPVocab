import 'package:chibakanji/screens/common/generic_screen.dart';
import 'package:chibakanji/screens/flashcard/learning_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterScreen extends StatefulWidget {
  const _CounterScreen({required this.title});

  final String title;

  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends GenericScreenState<_CounterScreen> {
  int _count = 0;

  @override
  String getTitle(BuildContext context) => widget.title;

  @override
  Widget buildBody(BuildContext context) {
    return TextButton(
      onPressed: () => setState(() => _count++),
      child: Text('Đếm: $_count'),
    );
  }
}

Future<void> _push(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => screen),
          ),
          child: const Text('Mở'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Mở'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('GenericScreenState dựng AppBar từ widget và giữ state riêng', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: _CounterScreen(title: 'Đếm thử')),
    );

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Đếm thử')),
      findsOneWidget,
    );

    await tester.tap(find.text('Đếm: 0'));
    await tester.pump();

    expect(find.text('Đếm: 1'), findsOneWidget);
  });

  testWidgets('mặc định có nút quay lại khi màn hình được push', (
    tester,
  ) async {
    await _push(tester, const _CounterScreen(title: 'Đếm thử'));

    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('LearningResultScreen ẩn nút quay lại nhờ showBackButton', (
    tester,
  ) async {
    await _push(
      tester,
      const LearningResultScreen(
        title: 'Chào hỏi cơ bản',
        completionTitle: 'Hoàn thành bài học!',
        correctCount: 3,
        wrongCount: 1,
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Kết quả buổi học'),
      ),
      findsOneWidget,
    );
    expect(find.text('Đã ôn 4 từ'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}
