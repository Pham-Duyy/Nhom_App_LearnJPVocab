import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Nạp font thật của app. Mặc định test dùng font "Ahem" (mỗi ký tự là một ô
/// vuông rộng bằng cỡ chữ), rộng gần gấp đôi chữ thật nên báo tràn sai.
Future<void> _loadAppFont() async {
  const weights = ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'];
  final loader = FontLoader('BeVietnamPro');
  for (final weight in weights) {
    loader.addFont(
      rootBundle.load('assets/fonts/BeVietnamPro/BeVietnamPro-$weight.ttf'),
    );
  }
  await loader.load();
}

/// 8e: mọi màn hình chính phải hiển thị được trên điện thoại nhỏ, kể cả khi
/// người dùng phóng to cỡ chữ hệ thống. Flutter báo tràn bố cục (RenderFlex
/// overflow) là lỗi, nên màn nào bị tràn thì test sẽ thất bại.
void main() {
  setUpAll(_loadAppFont);

  const phones = {
    'điện thoại nhỏ 360dp': (size: Size(360, 720), textScale: 1.0),
    'chữ phóng to 130%': (size: Size(360, 720), textScale: 1.3),
  };

  for (final MapEntry(key: name, value: phone) in phones.entries) {
    testWidgets('8e: các màn hình chính không bị tràn trên $name', (
      tester,
    ) async {
      tester.view.physicalSize = phone.size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = phone.textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      Future<void> open(String text) async {
        final target = find.text(text).first;
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await pumpTestApp(tester);
      // Ôn tập -> Học mới -> danh sách bài -> flashcard.
      await open('Học mới');
      await open('Chào hỏi và giao tiếp');
      await open('Chào hỏi cơ bản');
      expect(find.text('Từ 1/5'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Sổ từ, Cá nhân và các màn con của Cá nhân.
      await open('Sổ từ');
      await open('Cá nhân');
      for (final title in [
        'Thành tích',
        'Tùy chọn học',
        'Tài khoản',
        'Hướng dẫn sử dụng',
      ]) {
        await tester.scrollUntilVisible(find.text(title), 300);
        await open(title);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await tester.scrollUntilVisible(find.text('Đăng xuất'), 300);

      // Quiz nhanh từ trang chủ.
      await open('Ôn tập');
      await tester.scrollUntilVisible(find.text('Quiz nhanh'), 300);
      await open('Quiz nhanh');
      expect(find.textContaining('Câu 1/'), findsOneWidget);
    });
  }
}
