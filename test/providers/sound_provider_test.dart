import 'package:chibakanji/providers/sound_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_music_player.dart';
import '../fakes/fake_speaker.dart';

void main() {
  late FakeSpeaker speaker;
  late FakeMusicPlayer music;

  SoundProvider create([Map<String, Object> saved = const {}]) {
    SharedPreferences.setMockInitialValues(saved);
    speaker = FakeSpeaker();
    music = FakeMusicPlayer();
    return SoundProvider(speaker, music);
  }

  test('lời chào tiếng Nhật đổi theo buổi sáng, chiều, tối', () {
    String at(int hour) =>
        SoundProvider.greetingFor(DateTime(2026, 1, 15, hour));

    expect(at(7), startsWith('おはようございます'));
    expect(at(10), startsWith('おはようございます'));
    expect(at(11), startsWith('こんにちは'));
    expect(at(17), startsWith('こんにちは'));
    expect(at(18), startsWith('こんばんは'));
    expect(at(23), startsWith('こんばんは'));
  });

  test('vào app thì đọc lời chào theo giờ và bật nhạc nền', () async {
    final sound = create();

    await sound.welcome(now: DateTime(2026, 1, 15, 20));

    expect(
        speaker.spoken, [SoundProvider.greetingFor(DateTime(2026, 1, 15, 20))]);
    expect(music.isPlaying, isTrue);
    expect(music.volume,
        closeTo(SoundProvider.defaultVolume * SoundProvider.musicLevel, 1e-9));
  });

  test('đã tắt âm thanh thì không chào, không phát nhạc', () async {
    final sound = create({'sound_enabled': false});

    await sound.welcome();

    expect(speaker.spoken, isEmpty);
    expect(music.isPlaying, isFalse);
  });

  test('tắt rồi bật lại trong app thì nhạc dừng rồi phát lại, có lưu',
      () async {
    final sound = create();
    await sound.welcome();

    await sound.setEnabled(false);
    expect(music.isPlaying, isFalse);
    expect((await SharedPreferences.getInstance()).getBool('sound_enabled'),
        isFalse);

    await sound.setEnabled(true);
    expect(music.isPlaying, isTrue);
  });

  test('chỉnh âm lượng áp dụng cho giọng đọc và nhạc nền, có lưu', () async {
    final sound = create();
    await sound.welcome();

    await sound.setVolume(0.2);

    expect(speaker.volume, 0.2);
    expect(music.volume, closeTo(0.2 * SoundProvider.musicLevel, 1e-9));
    expect(
        (await SharedPreferences.getInstance()).getDouble('sound_volume'), 0.2);
  });

  test('âm lượng 0 thì dừng nhạc nền', () async {
    final sound = create();
    await sound.welcome();

    await sound.setVolume(0);

    expect(music.isPlaying, isFalse);
  });

  test('đọc lại cài đặt đã lưu trên thiết bị', () async {
    final sound = create({'sound_enabled': false, 'sound_volume': 0.3});

    await sound.load();

    expect(sound.enabled, isFalse);
    expect(sound.volume, 0.3);
    expect(speaker.volume, 0.3);
  });

  test('đăng xuất (rời app) thì tắt nhạc nền', () async {
    final sound = create();
    await sound.welcome();

    await sound.leaveApp();

    expect(music.isPlaying, isFalse);
  });

  test('giới thiệu: phát tiếng chuông rồi đọc tên app', () async {
    final sound = create();

    await sound.introduce();

    expect(music.introCount, 1);
    expect(speaker.spoken, [SoundProvider.introText]);
    expect(SoundProvider.introText, contains('チバカンジ'));
  });

  test('đã tắt âm thanh thì màn khởi động im lặng', () async {
    final sound = create({'sound_enabled': false});

    await sound.introduce();

    expect(music.introCount, 0);
    expect(speaker.spoken, isEmpty);
  });

  group('trình duyệt chặn phát tiếng trước lần chạm đầu tiên', () {
    SoundProvider browser() {
      SharedPreferences.setMockInitialValues({});
      speaker = FakeSpeaker();
      music = FakeMusicPlayer();
      return SoundProvider(speaker, music, requireInteraction: true);
    }

    test('chạm vào màn khởi động thì phát lời giới thiệu đang chờ', () async {
      final sound = browser();

      await sound.introduce();
      expect(speaker.spoken, isEmpty);

      sound.userInteracted();
      await pumpEventQueue();
      expect(speaker.spoken, [SoundProvider.introText]);
    });

    test(
        'rời màn khởi động mà chưa chạm thì bỏ lời giới thiệu, lần chạm '
        'đầu ở trang chủ chỉ phát lời chào', () async {
      final sound = browser();

      await sound.introduce();
      sound.cancelIntro();
      await sound.welcome();
      sound.userInteracted();
      await pumpEventQueue();

      expect(speaker.spoken, [SoundProvider.greetingFor(DateTime.now())]);
    });
  });
}
