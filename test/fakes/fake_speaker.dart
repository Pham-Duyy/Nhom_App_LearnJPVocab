import 'package:chibakanji/services/speaker.dart';

/// Speaker giả: ghi lại những gì được đọc thay vì phát ra loa.
class FakeSpeaker implements Speaker {
  final spoken = <String>[];

  /// Nếu khác null, mỗi lần đọc đều ném lỗi này.
  Object? failure;

  @override
  Future<void> speak(String text) async {
    final error = failure;
    if (error != null) throw error;
    spoken.add(text);
  }

  /// Âm lượng được đặt gần nhất.
  double volume = 1;

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;
}
