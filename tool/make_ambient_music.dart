// Tạo âm thanh cho app: nhạc nền assets/audio/ambient.wav và tiếng chuông
// giới thiệu ở màn khởi động assets/audio/intro.wav.
//
// Chạy: dart run tool/make_ambient_music.dart
//
// Chuông gió furin (風鈴) leng keng thưa thớt, ngân dài. Đoạn dài 32 giây
// và lặp liền mạch: đuôi ngân của chuông được cộng vòng về đầu đoạn.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const sampleRate = 22050;
const seconds = 32;
const length = sampleRate * seconds;

/// Cao độ chuông (Hz): âm giai ngũ cung ở quãng tám cao.
const chimeNotes = [1174.66, 1318.51, 1567.98, 1760.00, 1975.53, 2349.32];

final random = math.Random(7);

void main() {
  final ambient = Float64List(length);
  _addChimes(ambient);
  _save('assets/audio/ambient.wav', ambient);

  // Tiếng chuông giới thiệu ở màn khởi động: chuỗi 5 nốt đi lên rồi ngân.
  final intro = Float64List(sampleRate * 4);
  const notes = [0, 1, 2, 3, 5];
  for (final (index, note) in notes.indexed) {
    final at = index == notes.length - 1 ? 0.62 : index * 0.12;
    _strike(intro, (at * sampleRate).round(), chimeNotes[note], 1, wrap: false);
  }
  _save('assets/audio/intro.wav', intro);
}

void _save(String path, Float64List mix) {
  final peak = mix.fold<double>(0, (max, v) => math.max(max, v.abs()));
  final samples = Int16List(mix.length);
  for (var i = 0; i < mix.length; i++) {
    samples[i] = (mix[i] / peak * 0.8 * 32767).round();
  }
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(_wav(samples));
  stdout.writeln('Đã tạo ${file.path} (${file.lengthSync() ~/ 1024} KB)');
}

/// Chuông gió: từng cụm 2–4 tiếng leng keng, mỗi cụm cách nhau 3–6 giây.
/// Mỗi tiếng gồm vài họa âm không chẵn như chuông kim loại, ngân dài.
void _addChimes(Float64List mix) {
  var start = 1.0;
  while (start < seconds - 1) {
    final strikes = 2 + random.nextInt(3);
    var at = start;
    for (var s = 0; s < strikes; s++) {
      final freq = chimeNotes[random.nextInt(chimeNotes.length)];
      final loudness = 0.5 + random.nextDouble() * 0.5;
      _strike(mix, (at * sampleRate).round(), freq, loudness);
      at += 0.15 + random.nextDouble() * 0.35;
    }
    start += 3 + random.nextDouble() * 3;
  }
}

/// Một tiếng chuông bắt đầu ở mẫu [start]. [wrap]: đuôi ngân vượt cuối
/// đoạn thì cộng vòng về đầu (cho đoạn lặp), không thì cắt bỏ.
void _strike(Float64List mix, int start, double freq, double loudness,
    {bool wrap = true}) {
  const ring = sampleRate * 5;
  for (var i = 0; i < ring; i++) {
    final t = i / sampleRate;
    final attack = math.min(1.0, t / 0.002);
    final value = attack *
        (math.exp(-t * 0.9) * math.sin(2 * math.pi * freq * t) +
            0.4 * math.exp(-t * 2.2) * math.sin(2 * math.pi * freq * 2.76 * t) +
            0.15 * math.exp(-t * 4) * math.sin(2 * math.pi * freq * 5.4 * t));
    final index = start + i;
    if (!wrap && index >= mix.length) break;
    mix[index % mix.length] += 0.12 * loudness * value;
  }
}

/// Đóng gói PCM 16-bit mono thành file WAV.
Uint8List _wav(Int16List samples) {
  final dataSize = samples.length * 2;
  final header = ByteData(44)
    ..setUint32(0, 0x52494646) // "RIFF"
    ..setUint32(4, 36 + dataSize, Endian.little)
    ..setUint32(8, 0x57415645) // "WAVE"
    ..setUint32(12, 0x666d7420) // "fmt "
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // "data"
    ..setUint32(40, dataSize, Endian.little);
  return Uint8List.fromList([
    ...header.buffer.asUint8List(),
    ...samples.buffer.asUint8List(),
  ]);
}
