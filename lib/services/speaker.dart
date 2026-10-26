import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Đọc to một đoạn tiếng Nhật. Giao diện chỉ biết interface này, nên test
/// dùng được bản giả mà không cần giọng đọc thật của máy.
abstract class Speaker {
  Future<void> speak(String text);

  Future<void> stop();
}

/// Máy không có giọng đọc tiếng Nhật.
class SpeakerUnavailableException implements Exception {
  const SpeakerUnavailableException();
}

/// Đọc bằng giọng đọc có sẵn của hệ điều hành hoặc trình duyệt.
class TtsSpeaker implements Speaker {
  TtsSpeaker({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    // Theo dõi trạng thái thật của giọng đọc: flutter_tts bỏ qua lệnh đọc
    // mới khi nó vẫn coi là đang đọc câu trước.
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
    // Bấm lại khi đang đọc: dừng câu cũ và chờ xác nhận đã dừng hẳn, nếu
    // không câu mới sẽ bị bỏ qua.
    if (_isSpeaking) await stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    if (!_isSpeaking) return;
    final stopped = _stopped = Completer<void>();
    await _tts.stop();
    // Có nền tảng không báo sự kiện khi dừng: chờ tối đa một chút rồi thôi.
    await stopped.future.timeout(_stopTimeout, onTimeout: () {});
    _isSpeaking = false;
  }

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
    // Trên web, chọn giọng khi danh sách còn rỗng thì flutter_tts lặng lẽ bỏ
    // qua và đọc bằng giọng mặc định (tiếng Việt/Anh), giọng đó im lặng trước
    // chữ Nhật. Phải chờ trình duyệt nạp xong danh sách giọng trước.
    if (kIsWeb) await _waitForVoices();
    if (await _tts.isLanguageAvailable(language) != true) {
      throw const SpeakerUnavailableException();
    }
    await _tts.setLanguage(language);
    // Thang tốc độ khác nhau: web lấy 1.0 làm bình thường, điện thoại lấy
    // 0.5. Đọc chậm hơn bình thường một chút cho dễ nghe.
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
