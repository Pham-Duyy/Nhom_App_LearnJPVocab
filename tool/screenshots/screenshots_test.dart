// Chụp ảnh mọi màn hình của app (dữ liệu mẫu, font thật) vào
// docs/screenshots để đưa vào báo cáo.
//
// Chạy: flutter test tool/screenshots/screenshots_test.dart --update-goldens
// (nằm ngoài thư mục test/ nên không chạy cùng bộ test thường và CI.)
import 'dart:io';

import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/widgets/swipe_flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../test/helpers/test_app.dart';

const _size = Size(412, 892);

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(file).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  await load('BeVietnamPro', [
    for (final file in Directory('assets/fonts/BeVietnamPro').listSync())
      if (file.path.endsWith('.ttf')) file.path,
  ]);
  await load('ShipporiMincho', [
    'assets/fonts/ShipporiMincho/ShipporiMincho-Bold.ttf',
  ]);
  // flutter_tester nằm trong bin/cache/artifacts/engine/<nền tảng>/.
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  await load('MaterialIcons', [
    '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = _size * 2;
  tester.view.devicePixelRatio = 2;
}

Future<void> _shot(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/screenshots/$name.png'),
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      150,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

Future<void> _closeSheet(WidgetTester tester) async {
  await tester.tapAt(const Offset(20, 40));
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  ));
  await tester.pumpAndSettle();
}

T _read<T>(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).last).read<T>();

void main() {
  setUpAll(_loadFonts);

  testWidgets('khởi động, đăng ký, đăng nhập', (tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(buildTestApp(showWelcome: true));
    await tester.pump(const Duration(milliseconds: 800));
    await _shot(tester, '01-khoi-dong');

    await passSplash(tester);
    await _shot(tester, '02-dang-ky');

    await _tap(
      tester,
      find.text('Bạn đã có tài khoản? Đăng nhập', findRichText: true),
    );
    await _shot(tester, '03-dang-nhap');
  });

  testWidgets('trang chủ, học mới, flashcard', (tester) async {
    _setPhoneSize(tester);
    await pumpTestApp(tester);
    await _shot(tester, '04-on-tap');

    await _openTab(tester, 'Học mới');
    await _shot(tester, '05-hoc-moi');

    await _tap(tester, find.text('Chào hỏi và giao tiếp'));
    await _shot(tester, '06-bai-hoc');

    await _tap(tester, find.text('Chào hỏi cơ bản'));
    await _shot(tester, '07-flashcard');

    tester.state<SwipeFlashcardState>(find.byType(SwipeFlashcard)).flip();
    await tester.pumpAndSettle();
    await _shot(tester, '08-flashcard-mat-sau');

    while (find.text('Đã nhớ').evaluate().isNotEmpty) {
      await _tap(tester, find.text('Đã nhớ'));
    }
    await _shot(tester, '09-ket-qua-hoc');
  });

  testWidgets('quiz', (tester) async {
    _setPhoneSize(tester);
    await pumpTestApp(tester);
    await _tap(tester, find.text('Quiz nhanh'));
    await _shot(tester, '10-quiz');

    final quiz = _read<QuizProvider>(tester);
    for (var i = 0; i < quiz.questions.length; i++) {
      final question = quiz.currentQuestion!;
      final index = i < 2
          ? (question.correctIndex + 1) % question.options.length
          : question.correctIndex;
      await _tap(tester, find.text(question.options[index]));
      if (i == 0) await _shot(tester, '11-quiz-giai-thich');
      await _tap(
        tester,
        find.text(quiz.isLastQuestion ? 'Xem kết quả' : 'Câu tiếp theo'),
      );
    }
    await _shot(tester, '12-ket-qua-quiz');
  });

  testWidgets('thi thử', (tester) async {
    _setPhoneSize(tester);
    await pumpTestApp(tester);
    await _openTab(tester, 'Thi thử');
    await _shot(tester, '13-thi-thu');

    await _tap(tester, find.text('Bắt đầu làm bài'));
    await _shot(tester, '14-bai-thi');

    await _tap(tester, find.textContaining('Nộp bài sớm'));
    // Nút "Nộp bài" của bảng xác nhận.
    await tester.tap(find.text('Nộp bài').last);
    await tester.pumpAndSettle();
    await _shot(tester, '15-ket-qua-thi');
  });

  testWidgets('sổ từ và kho từ', (tester) async {
    _setPhoneSize(tester);
    await pumpTestApp(tester);
    await _openTab(tester, 'Sổ từ');
    await _shot(tester, '16-so-tu');

    await _tap(tester, find.text('Xin chào (ban ngày)'));
    await _shot(tester, '17-chi-tiet-tu');
    await _back(tester);

    await _tap(tester, find.text('Kho từ của tôi'));
    await _shot(tester, '18-kho-tu');

    await _tap(tester, find.text('Từ mới'));
    await _shot(tester, '19-them-tu');
    await _back(tester);

    await _tap(tester, find.text('Import'));
    await _shot(tester, '20-import');
  });

  testWidgets('cá nhân', (tester) async {
    _setPhoneSize(tester);
    // Bật âm thanh để mục Âm thanh hiện trạng thái thường dùng.
    await tester.pumpWidget(buildTestApp(soundEnabled: true));
    await tester.pumpAndSettle();
    await _openTab(tester, 'Cá nhân');
    await _shot(tester, '21-ca-nhan');

    for (final (title, name) in [
      ('Tùy chọn học', '22-tuy-chon-hoc'),
      ('Thành tích', '23-thanh-tich'),
      ('Lịch sử quiz', '24-lich-su-quiz'),
      ('Tài khoản', '25-tai-khoan'),
      ('Hướng dẫn sử dụng', '26-huong-dan'),
    ]) {
      await _tap(tester, find.text(title));
      await _shot(tester, name);
      await _back(tester);
    }

    await _tap(tester, find.text('Nhắc học mỗi ngày'));
    await _shot(tester, '27-nhac-hoc');
    await _closeSheet(tester);

    await _tap(tester, find.text('Âm thanh'));
    await _shot(tester, '28-am-thanh');
    await _closeSheet(tester);

    await _tap(tester, find.text('Giao diện'));
    await _tap(tester, find.text('Tối'));
    await _openTab(tester, 'Ôn tập');
    await _shot(tester, '29-giao-dien-toi');
  });
}
