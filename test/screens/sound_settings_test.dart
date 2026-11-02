import 'package:chibakanji/providers/sound_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_music_player.dart';
import '../fakes/fake_speaker.dart';
import '../helpers/test_app.dart';

Future<void> _openSoundSheet(WidgetTester tester) async {
  await tester.tap(find.text('Cá nhân'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Âm thanh'), 200);
  await tester.ensureVisible(find.text('Âm thanh'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Âm thanh'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('vào app thì Chibi chào bằng tiếng Nhật và nhạc nền phát', (
    tester,
  ) async {
    final speaker = FakeSpeaker();
    final music = FakeMusicPlayer();
    await tester.pumpWidget(buildTestApp(
      soundEnabled: true,
      speaker: speaker,
      musicPlayer: music,
    ));
    await tester.pumpAndSettle();

    expect(speaker.spoken, [SoundProvider.greetingFor(DateTime.now())]);
    expect(music.isPlaying, isTrue);
  });

  testWidgets('tắt âm thanh trong Cá nhân thì nhạc nền dừng', (tester) async {
    final music = FakeMusicPlayer();
    await tester.pumpWidget(
      buildTestApp(soundEnabled: true, musicPlayer: music),
    );
    await tester.pumpAndSettle();

    await _openSoundSheet(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(music.isPlaying, isFalse);
    // Thanh âm lượng khóa lại khi đã tắt âm thanh.
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Tắt'), findsWidgets);
  });

  testWidgets('kéo thanh âm lượng thì phần trăm đổi theo', (tester) async {
    final speaker = FakeSpeaker();
    await tester.pumpWidget(
      buildTestApp(soundEnabled: true, speaker: speaker),
    );
    await tester.pumpAndSettle();

    await _openSoundSheet(tester);
    await tester.drag(find.byType(Slider), const Offset(-1000, 0));
    await tester.pumpAndSettle();

    expect(find.text('Âm lượng · 0%'), findsOneWidget);
    expect(speaker.volume, 0);
  });

  testWidgets('màn khởi động: chuông kêu và Chibi đọc tên app', (
    tester,
  ) async {
    final speaker = FakeSpeaker();
    final music = FakeMusicPlayer();
    await tester.pumpWidget(buildTestApp(
      showWelcome: true,
      soundEnabled: true,
      speaker: speaker,
      musicPlayer: music,
    ));
    await tester.pump();

    expect(music.introCount, 1);
    expect(speaker.spoken, [SoundProvider.introText]);

    await passSplash(tester);
  });
}
