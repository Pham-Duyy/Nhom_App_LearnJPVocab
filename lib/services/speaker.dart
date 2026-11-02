import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_error.dart';

/// Đọc to một đoạn tiếng Nhật. Giao diện chỉ biết interface này, nên test
/// dùng được bản giả mà không cần giọng đọc thật của máy.
abstract class Speaker {
  Future<void> speak(String text);

  Future<void> stop();

  /// Âm lượng giọng đọc, từ 0 (im lặng) đến 1.
  Future<void> setVolume(double volume);
}

/// Máy không có giọng đọc tiếng Nhật.
class SpeakerUnavailableException implements Exception {
  const SpeakerUnavailableException();
}

/// Phát âm tiếng Nhật trực tuyến qua Google Translate TTS bằng audioplayers.
/// Đảm bảo hoạt động trên mọi thiết bị và hệ điều hành kể cả khi máy chưa cài
/// gói giọng đọc tiếng Nhật offline.
class OnlineSpeaker implements Speaker {
  OnlineSpeaker({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  double _volume = 1.0;

  static String urlFor(String text) =>
      'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=ja&q=${Uri.encodeComponent(text)}';

  @override
  Future<void> speak(String text) async {
    await stop();
    await _player.setVolume(_volume);
    await _player.play(UrlSource(urlFor(text)));
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0).toDouble();
    await _player.setVolume(_volume);
  }
}

/// Đọc bằng giọng đọc có sẵn của hệ điều hành hoặc trình duyệt.
class TtsSpeaker implements Speaker {
  TtsSpeaker({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(_markStopped);
    _tts.setCancelHandler(_markStopped);
    _tts.setErrorHandler((_) => _markStopped());
  }

  static const language = 'ja-JP';

  /// Trình duyệt nạp danh sách giọng đọc chậm sau khi mở trang.
  static const _voiceLoadTimeout = Duration(seconds: 2);
  static const _stopTimeout = Duration(milliseconds: 500);

  final FlutterTts _tts;
  Future<void>? _setup;
  bool _isSpeaking = false;
  Completer<void>? _stopped;

  @override
  Future<void> speak(String text) async {
    await _ensureSetup();
    if (_isSpeaking) await stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    if (!_isSpeaking) return;
    final stopped = _stopped = Completer<void>();
    await _tts.stop();
    await stopped.future.timeout(_stopTimeout, onTimeout: () {});
    _isSpeaking = false;
  }

  @override
  Future<void> setVolume(double volume) => _tts.setVolume(volume);

  void _markStopped() {
    _isSpeaking = false;
    _stopped?.complete();
    _stopped = null;
  }

  /// Chỉ cấu hình một lần; nếu lỗi thì lần bấm sau thử lại từ đầu.
  Future<void> _ensureSetup() {
    return _setup ??= _configure().catchError((Object error) {
      _setup = null;
      throw error;
    });
  }

  Future<void> _configure() async {
    // Web: chờ nạp xong giọng đọc, nếu không setLanguage bị bỏ qua.
    if (kIsWeb) await _waitForVoices();

    bool available = false;
    try {
      final res = await _tts.isLanguageAvailable(language);
      available = res == true || res == 1;
    } catch (_) {
      // Một số nền tảng (như Windows) plugin C++ không cài isLanguageAvailable.
      // Thử gọi setLanguage để kiểm tra xem có giọng Nhật hay không.
      try {
        final res = await _tts.setLanguage(language);
        available = res == 1 || res == true;
      } catch (_) {
        available = false;
      }
    }

    if (!available) {
      throw const SpeakerUnavailableException();
    }
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(kIsWeb ? 0.85 : 0.42);
  }

  Future<void> _waitForVoices() async {
    final deadline = DateTime.now().add(_voiceLoadTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final voices = await _tts.getVoices;
      if (voices is List && voices.isNotEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}

/// Tự động ưu tiên giọng đọc nội bộ (TtsSpeaker). Nếu máy chưa cài giọng Nhật
/// hoặc gặp lỗi thì tự động chuyển sang phát âm trực tuyến (OnlineSpeaker).
class FallbackSpeaker implements Speaker {
  FallbackSpeaker({
    Speaker? local,
    Speaker? online,
  })  : _local = local ?? TtsSpeaker(),
        _online = online ?? OnlineSpeaker();

  final Speaker _local;
  final Speaker _online;
  double _volume = 1.0;

  @override
  Future<void> speak(String text) async {
    try {
      await _local.speak(text);
    } catch (e, stack) {
      AppError.log('TtsSpeaker.fallbackToOnline', e, stack);
      try {
        await _online.speak(text);
      } catch (_) {
        throw const SpeakerUnavailableException();
      }
    }
  }

  @override
  Future<void> stop() async {
    await _local.stop();
    await _online.stop();
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _local.setVolume(volume);
    await _online.setVolume(volume);
  }
}
