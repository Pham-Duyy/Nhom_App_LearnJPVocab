import 'package:chibakanji/services/music_player.dart';

/// Trình phát nhạc giả: chỉ ghi lại trạng thái thay vì phát ra loa.
class FakeMusicPlayer implements MusicPlayer {
  bool isPlaying = false;
  double volume = 0;

  @override
  Future<void> play(double volume) async {
    isPlaying = true;
    this.volume = volume;
  }

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;

  @override
  Future<void> stop() async => isPlaying = false;

  /// Số lần đã phát tiếng chuông giới thiệu.
  int introCount = 0;

  @override
  Future<void> playIntro(double volume) async => introCount++;
}
