import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/music_player.dart';
import '../services/speaker.dart';
import '../utils/app_error.dart';

/// Âm thanh của app: lời chào tiếng Nhật khi vào app và nhạc nền nhẹ.
/// Bật/tắt và âm lượng lưu trên thiết bị (SharedPreferences), vì đây là
/// cài đặt của từng máy chứ không theo tài khoản.
class SoundProvider extends ChangeNotifier {
  /// [requireInteraction]: chờ lần chạm đầu tiên mới được phát tiếng (web);
  /// test truyền vào để giả lập trình duyệt.
  SoundProvider(this._speaker, this._music, {bool? requireInteraction})
      : _userInteracted = !(requireInteraction ?? kIsWeb);

  static const _enabledKey = 'sound_enabled';
  static const _volumeKey = 'sound_volume';
  static const defaultVolume = 0.6;

  /// Nhạc nền nhỏ hơn giọng đọc để chỉ làm nền.
  static const musicLevel = 0.35;

  final Speaker _speaker;
  final MusicPlayer _music;

  bool _enabled = true;
  double _volume = defaultVolume;
  Future<void>? _loaded;

  /// Đang ở trong app (sau đăng nhập), tức là nhạc nền nên phát nếu bật.
  bool _inApp = false;
  bool _musicPlaying = false;

  /// Trình duyệt chặn phát âm thanh khi người dùng chưa chạm vào trang lần
  /// nào; lời chào phải chờ tới lần chạm đầu tiên.
  bool _userInteracted;
  bool _introPending = false;
  bool _welcomePending = false;

  bool get enabled => _enabled;
  double get volume => _volume;

  /// Lời giới thiệu ở màn khởi động: "Chào mừng đến với ChibaKanji! Cùng học
  /// tiếng Nhật vui vẻ nhé."
  static const introText = 'チバカンジへようこそ！楽しく日本語を学びましょう。';

  /// Lời chào theo giờ: sáng (trước 11 giờ), chiều (trước 18 giờ), tối.
  static String greetingFor(DateTime time) {
    final hello = time.hour < 11
        ? 'おはようございます'
        : time.hour < 18
            ? 'こんにちは'
            : 'こんばんは';
    return '$hello。今日も一緒に頑張りましょう！';
  }

  Future<void> load() => _loaded ??= _read();

  Future<void> _read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_enabledKey) ?? true;
      _volume = prefs.getDouble(_volumeKey) ?? defaultVolume;
    } catch (e, stack) {
      AppError.log('SoundProvider.load', e, stack);
    }
    await _speaker.setVolume(_volume);
    notifyListeners();
  }

  /// Màn khởi động: tiếng chuông rồi Chibi đọc tên app.
  Future<void> introduce() async {
    if (!_userInteracted) {
      _introPending = true;
      return;
    }
    await load();
    if (!_enabled || _volume == 0) return;
    try {
      await _music.playIntro(_volume);
      await _speaker.speak(introText);
    } catch (e, stack) {
      AppError.log('SoundProvider.introduce', e, stack);
    }
  }

  /// Gọi khi vừa vào màn chính sau đăng nhập: chào rồi bật nhạc nền.
  Future<void> welcome({DateTime? now}) async {
    _inApp = true;
    if (!_userInteracted) {
      _welcomePending = true;
      return;
    }
    await load();
    if (!_enabled || _volume == 0) return;
    try {
      await _speaker.speak(greetingFor(now ?? DateTime.now()));
    } catch (e, stack) {
      AppError.log('SoundProvider.welcome', e, stack);
    }
    await _startMusic();
  }

  /// Rời màn khởi động: lời giới thiệu chưa kịp phát (web chưa được chạm)
  /// thì bỏ luôn, để không đè lên lời chào ở trang chủ.
  void cancelIntro() => _introPending = false;

  /// Gọi ở lần chạm đầu tiên vào trang để phát lời giới thiệu hoặc lời chào
  /// đang chờ (web).
  void userInteracted() {
    if (_userInteracted) return;
    _userInteracted = true;
    if (_introPending) {
      _introPending = false;
      introduce();
    }
    if (_welcomePending) {
      _welcomePending = false;
      welcome();
    }
  }

  /// Rời màn chính (đăng xuất): tắt nhạc nền.
  Future<void> leaveApp() async {
    _inApp = false;
    _welcomePending = false;
    await _stopMusic();
  }

  Future<void> setEnabled(bool enabled) async {
    if (enabled == _enabled) return;
    _enabled = enabled;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_enabledKey, enabled));
    enabled ? await _startMusic() : await _stopMusic();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    await _speaker.setVolume(_volume);
    if (_volume == 0) {
      await _stopMusic();
    } else if (_musicPlaying) {
      await _music.setVolume(_volume * musicLevel);
    } else {
      await _startMusic();
    }
    await _save((prefs) => prefs.setDouble(_volumeKey, _volume));
  }

  /// Đọc thử lời chào ở âm lượng hiện tại (trong phần cài đặt).
  Future<void> preview() async {
    try {
      await _speaker.speak(greetingFor(DateTime.now()));
    } catch (e, stack) {
      AppError.log('SoundProvider.preview', e, stack);
    }
  }

  Future<void> _startMusic() async {
    if (!_inApp || !_enabled || _volume == 0 || _musicPlaying) return;
    _musicPlaying = true;
    try {
      await _music.play(_volume * musicLevel);
    } catch (e, stack) {
      _musicPlaying = false;
      AppError.log('SoundProvider.startMusic', e, stack);
    }
  }

  Future<void> _stopMusic() async {
    if (!_musicPlaying) return;
    _musicPlaying = false;
    try {
      await _music.stop();
    } catch (e, stack) {
      AppError.log('SoundProvider.stopMusic', e, stack);
    }
  }

  Future<void> _save(Future<bool> Function(SharedPreferences) write) async {
    try {
      await write(await SharedPreferences.getInstance());
    } catch (e, stack) {
      AppError.log('SoundProvider.save', e, stack);
    }
  }

  @override
  void dispose() {
    _music.stop();
    super.dispose();
  }
}
