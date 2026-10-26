import 'package:chibakanji/services/welcome_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('US01: lần đầu mở app thì chưa xem màn chào', () async {
    expect(await WelcomeStore.hasSeen(), isFalse);
  });

  test('US01: đã vào app thì lần sau bỏ qua màn chào', () async {
    await WelcomeStore.setSeen(true);

    expect(await WelcomeStore.hasSeen(), isTrue);
  });

  test('US05: đăng xuất thì lần sau hiện lại màn chào', () async {
    await WelcomeStore.setSeen(true);
    await WelcomeStore.setSeen(false);

    expect(await WelcomeStore.hasSeen(), isFalse);
  });
}
