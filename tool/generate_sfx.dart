// ignore_for_file: avoid_print
/// 🎵 K-Poker 효과음 WAV 생성기 (Dart)
/// dart run tool/generate_sfx.dart 로 실행
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int sampleRate = 22050;
const String outputDir = 'assets/audio/sfx';

void main() {
  Directory(outputDir).createSync(recursive: true);

  // 1. card_play.wav — 카드 던짐 (짧은 휙)
  writeWav('card_play.wav', fade(sine(800, 0.05, 0.6) + sine(400, 0.05, 0.3)));

  // 2. card_match.wav — 매칭 성공 (상승 차임)
  writeWav('card_match.wav', fade(sine(523, 0.08, 0.5) + sine(659, 0.08, 0.5) + sine(784, 0.12, 0.6)));

  // 3. card_sweep.wav — 쓸어먹기 (상승 스윕)
  writeWav('card_sweep.wav', fade(sweep(300, 900, 0.3, 0.5)));

  // 4. bright_capture.wav — 광 획득 (황금 벨)
  writeWav('bright_capture.wav', fade(mixAll([
    sine(880, 0.15, 0.5) + sine(1108, 0.15, 0.4) + sine(1318, 0.2, 0.5),
    sine(440, 0.5, 0.2),
  ])));

  // 5. go_declare.wav — 고! (드라마틱 상승)
  writeWav('go_declare.wav', fade(sine(440, 0.1, 0.5) + sine(554, 0.1, 0.5) + sine(659, 0.1, 0.5) + sine(880, 0.15, 0.6)));

  // 6. stop_declare.wav — 스톱! (단호한 하강)
  writeWav('stop_declare.wav', fade(sine(660, 0.12, 0.6) + sine(440, 0.12, 0.5) + sine(330, 0.15, 0.4)));

  // 7. win.wav — 승리 팡파레
  writeWav('win.wav', fade(sine(523, 0.12, 0.5) + sine(659, 0.12, 0.5) + sine(784, 0.12, 0.5) + sine(1047, 0.15, 0.6) + sine(784, 0.1, 0.4) + sine(1047, 0.2, 0.6)));

  // 8. lose.wav — 패배 (하강 소멸)
  writeWav('lose.wav', fade(sweep(400, 150, 0.8, 0.4)));

  // 9. shop_buy.wav — 상점 구매 (코인)
  writeWav('shop_buy.wav', fade(sine(1200, 0.05, 0.5) + sine(1600, 0.05, 0.5) + sine(2000, 0.08, 0.4)));

  // 10. stage_clear.wav — 스테이지 클리어
  writeWav('stage_clear.wav', fade(
    sine(523, 0.1, 0.5) + sine(659, 0.1, 0.5) + sine(784, 0.1, 0.5) +
    sine(1047, 0.1, 0.5) + sine(1318, 0.1, 0.5) + sine(1568, 0.15, 0.6)));

  print('\n🎵 효과음 10개 생성 완료! → $outputDir');
}

List<double> sine(double freq, double duration, double volume) {
  final count = (sampleRate * duration).round();
  return List.generate(count, (t) =>
    volume * sin(2 * pi * freq * t / sampleRate));
}

List<double> sweep(double startFreq, double endFreq, double duration, double volume) {
  final count = (sampleRate * duration).round();
  return List.generate(count, (t) {
    final f = startFreq + (endFreq - startFreq) * t / count;
    return volume * sin(2 * pi * f * t / sampleRate);
  });
}

List<double> fade(List<double> samples, {double fadeIn = 0.01, double fadeOut = 0.05}) {
  final fi = (sampleRate * fadeIn).round();
  final fo = (sampleRate * fadeOut).round();
  for (var i = 0; i < fi && i < samples.length; i++) {
    samples[i] *= i / fi;
  }
  for (var i = 0; i < fo && i < samples.length; i++) {
    samples[samples.length - 1 - i] *= i / fo;
  }
  return samples;
}

List<double> mixAll(List<List<double>> tracks) {
  final len = tracks.map((t) => t.length).reduce(max);
  final result = List.filled(len, 0.0);
  for (final t in tracks) {
    for (var i = 0; i < t.length; i++) {
      result[i] += t[i];
    }
  }
  final mx = result.map((s) => s.abs()).reduce(max);
  if (mx > 0) {
    for (var i = 0; i < result.length; i++) {
      result[i] = result[i] / mx * 0.8;
    }
  }
  return result;
}

void writeWav(String filename, List<double> samples) {
  final path = '$outputDir/$filename';
  final file = File(path);
  final byteData = ByteData(44 + samples.length * 2);

  // WAV header
  void writeString(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      byteData.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
  final dataSize = samples.length * 2;
  writeString(0, 'RIFF');
  byteData.setUint32(4, 36 + dataSize, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  byteData.setUint32(16, 16, Endian.little);       // chunk size
  byteData.setUint16(20, 1, Endian.little);         // PCM
  byteData.setUint16(22, 1, Endian.little);         // mono
  byteData.setUint32(24, sampleRate, Endian.little); // sample rate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  byteData.setUint16(32, 2, Endian.little);         // block align
  byteData.setUint16(34, 16, Endian.little);        // bits per sample
  writeString(36, 'data');
  byteData.setUint32(40, dataSize, Endian.little);

  // 샘플 데이터
  for (var i = 0; i < samples.length; i++) {
    final s = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    byteData.setInt16(44 + i * 2, s, Endian.little);
  }

  file.writeAsBytesSync(byteData.buffer.asUint8List());
  print('✅ $filename (${(samples.length / sampleRate).toStringAsFixed(2)}s)');
}
