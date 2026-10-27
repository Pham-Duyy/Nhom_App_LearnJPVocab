import 'package:audioplayers/audioplayers.dart';

/// Phát nhạc nền lặp lại và tiếng chuông giới thiệu. Giao diện chỉ biết
/// interface này, nên test dùng được bản giả mà không cần loa.
abstract class MusicPlayer {
  /// Bắt đầu phát nhạc nền (lặp mãi) ở âm lượng [volume] từ 0 đến 1.
  Future<void> play(double volume);

  Future<void> setVolume(double volume);

  Future<void> stop();

  /// Phát một lần tiếng chuông giới thiệu ở màn khởi động.
  Future<void> playIntro(double volume);
}

/// Phát các file âm thanh trong assets bằng audioplayers.
class AssetMusicPlayer implements MusicPlayer {
  AssetMusicPlayer({AudioPlayer? player, AudioPlayer? introPlayer})
      : _player = player ?? AudioPlayer(),
        _introPlayer = introPlayer ?? AudioPlayer();

  static const asset = 'audio/ambient.wav';
  static const introAsset = 'audio/intro.wav';

  final AudioPlayer _player;
  final AudioPlayer _introPlayer;

  @override
  Future<void> play(double volume) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(asset), volume: volume);
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> playIntro(double volume) =>
      _introPlayer.play(AssetSource(introAsset), volume: volume);
}
