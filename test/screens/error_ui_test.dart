import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/widgets/error_view.dart';
import 'package:chibakanji/widgets/favorite_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/flaky_repositories.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets(
      '8a/8e: mất mạng khi mở app thì hiện lỗi, bấm Thử lại là vào được',
      (tester) async {
    final progress = FlakyProgressRepository(
      initialProgress: MockLearningData.createInitialProgress(),
    )..failure = offlineError;
    await tester.pumpWidget(buildTestApp(progressRepository: progress));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.textContaining('Không có kết nối mạng'), findsOneWidget);
    expect(find.textContaining('abc123'), findsNothing);

    progress.failure = null;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('Quiz nhanh'), findsOneWidget);
  });

  testWidgets('8a/8e: đánh dấu yêu thích lỗi thì hiện thông báo, tim không đổi',
      (tester) async {
    final progress = FlakyProgressRepository(
      initialProgress: MockLearningData.createInitialProgress(),
    );
    await tester.pumpWidget(buildTestApp(progressRepository: progress));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sổ từ'));
    await tester.pumpAndSettle();

    progress.failure = offlineError;
    final heart = find.byType(FavoriteButton).first;
    final before = tester.widget<FavoriteButton>(heart).isFavorite;
    await tester.tap(heart);
    await tester.pumpAndSettle();

    expect(find.textContaining('lưu từ yêu thích'), findsOneWidget);
    expect(tester.widget<FavoriteButton>(heart).isFavorite, before);
  });
}
