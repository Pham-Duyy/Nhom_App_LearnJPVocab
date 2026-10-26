import 'package:chibakanji/services/speaker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late bool japaneseAvailable;

  /// Giả lập giọng đọc của máy gửi sự kiện về Flutter (vd. đã bắt đầu đọc).
  Future<void> platformSends(String method) async {
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall(method)),
      (_) {},
    );
  }

  setUp(() {
    calls = [];
    japaneseAvailable = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'isLanguageAvailable') return japaneseAvailable;
      // Máy thật báo "đã hủy" sau khi dừng.
      if (call.method == 'stop') Future(() => platformSends('speak.onCancel'));
      return 1;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  List<String> methods() => calls.map((c) => c.method).toList();

  test('đọc bằng giọng tiếng Nhật, chậm hơn bình thường cho dễ nghe', () async {
    final speaker = TtsSpeaker(tts: FlutterTts());

    await speaker.speak('こんにちは');

    expect(methods(), [
      'isLanguageAvailable',
      'setLanguage',
      'setSpeechRate',
      'speak',
    ]);
    expect(calls[1].arguments, 'ja-JP');
    expect(calls[2].arguments as double, lessThan(0.5));
    expect(calls.last.arguments.toString(), contains('こんにちは'));
  });

  test('chỉ cấu hình một lần, các lần đọc sau chỉ việc đọc', () async {
    final speaker = TtsSpeaker(tts: FlutterTts());

    await speaker.speak('いち');
    await platformSends('speak.onComplete');
    calls.clear();
    await speaker.speak('に');

    expect(methods(), ['speak']);
  });

  test('bấm lại khi đang đọc thì dừng câu cũ, chờ dừng hẳn rồi mới đọc',
      () async {
    final speaker = TtsSpeaker(tts: FlutterTts());
    await speaker.speak('いち');
    await platformSends('speak.onStart');
    calls.clear();

    await speaker.speak('に');

    expect(methods(), ['stop', 'speak']);
    expect(calls.last.arguments.toString(), contains('に'));
  });

  test('nền tảng không báo sự kiện dừng thì vẫn đọc được, không bị treo',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'isLanguageAvailable' ? true : 1;
    });
    final speaker = TtsSpeaker(tts: FlutterTts());
    await speaker.speak('いち');
    await platformSends('speak.onStart');

    await speaker.speak('に');

    expect(methods().last, 'speak');
  });

  test('máy không có giọng tiếng Nhật thì báo lỗi riêng, không đọc', () async {
    japaneseAvailable = false;
    final speaker = TtsSpeaker(tts: FlutterTts());

    await expectLater(
      speaker.speak('こんにちは'),
      throwsA(isA<SpeakerUnavailableException>()),
    );
    expect(methods(), isNot(contains('speak')));
  });

  test('sau khi cài thêm giọng tiếng Nhật, bấm lại là đọc được', () async {
    japaneseAvailable = false;
    final speaker = TtsSpeaker(tts: FlutterTts());
    await expectLater(speaker.speak('a'), throwsA(anything));

    japaneseAvailable = true;
    await speaker.speak('こんにちは');

    expect(methods().last, 'speak');
  });
}
