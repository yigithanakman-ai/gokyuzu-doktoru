import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 100% On-Device (Cihaz Üzerinde) Kozmik Frekans Sentezleyici
/// Sıfır Bulut Depolaması, Sıfır İnternet Trafiği, Sıfır Maliyet.
/// Cihazın ses işlemcisini kullanarak tam matematiksel Hertz (Hz) değerinde
/// zengin stereo sinüs ses dalgası üretir ve kesintisiz (loop) meditasyon döngüsünde çalar.
class FrequencySynthService {
  static final AudioPlayer _player = AudioPlayer();
  static final ValueNotifier<double?> playingFrequencyNotifier = ValueNotifier<double?>(null);
  static Process? _afplayProcess;

  static bool get isPlaying => playingFrequencyNotifier.value != null;

  /// Belirli bir frekansta (Hz) saf sinüs dalgası içeren kesintisiz döngülü Stereo WAV üretir
  static Uint8List generateSineWavBytes({
    required double frequencyHz,
    double targetDurationSeconds = 12.0,
    int sampleRate = 44100,
    double volume = 0.88,
  }) {
    const numChannels = 2; // Stereo
    const bitsPerSample = 16;
    const blockAlign = numChannels * (bitsPerSample ~/ 8); // 4 bytes

    // Dikişsiz ve çıtlamasız döngü için tam dalga periyodu sayısına yuvarla
    final numCycles = (targetDurationSeconds * frequencyHz).round();
    final actualDuration = numCycles / frequencyHz;
    final numSamples = (sampleRate * actualDuration).toInt();

    final byteRate = sampleRate * blockAlign; // 176400 bytes/sec
    final subChunk2Size = numSamples * blockAlign;
    final chunkSize = 36 + subChunk2Size;

    final byteData = ByteData(44 + subChunk2Size);

    // 1. RIFF Header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57); // 'W'
    byteData.setUint8(9, 0x41); // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // 2. 'fmt ' Sub-chunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    byteData.setUint16(22, numChannels, Endian.little); // NumChannels (2 = Stereo)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, byteRate, Endian.little); // ByteRate
    byteData.setUint16(32, blockAlign, Endian.little); // BlockAlign (4 bytes)
    byteData.setUint16(34, bitsPerSample, Endian.little); // BitsPerSample (16 bits)

    // 3. 'data' Sub-chunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Mikro taper: İlk ve son 10ms yumuşak geçiş
    final taperSamples = (sampleRate * 0.015).toInt();

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final angle = 2.0 * pi * frequencyHz * t;

      double envelope = 1.0;
      if (i < taperSamples) {
        envelope = i / taperSamples;
      } else if (i > numSamples - taperSamples) {
        envelope = (numSamples - i) / taperSamples;
      }

      // Saf sinüs + akustik harmonikler (kulak ve küçük mobil hoparlörler için zengin akustik derinlik)
      final sample = (sin(angle) * 0.72 + sin(angle * 2.0) * 0.20 + sin(angle * 3.0) * 0.08) * envelope * volume;
      final sampleClamped = sample.clamp(-1.0, 1.0);
      final sample16 = (sampleClamped * 32767.0).toInt();

      // Sol kanal (Left)
      byteData.setInt16(offset, sample16, Endian.little);
      offset += 2;
      // Sağ kanal (Right)
      byteData.setInt16(offset, sample16, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  /// Frekansı kesintisiz çalar (Eğer aynı frekans çalıyorsa durdurur)
  static Future<void> togglePlayFrequency(double frequencyHz) async {
    if (playingFrequencyNotifier.value == frequencyHz) {
      await stop();
      return;
    }

    try {
      await stop();
      playingFrequencyNotifier.value = frequencyHz;

      final wavBytes = generateSineWavBytes(frequencyHz: frequencyHz);
      
      String targetPath;
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/cosmic_${frequencyHz.toStringAsFixed(2)}.wav');
        await file.writeAsBytes(wavBytes);
        targetPath = file.path;
      } catch (_) {
        final file = File('/tmp/cosmic_${frequencyHz.toStringAsFixed(2)}.wav');
        await file.writeAsBytes(wavBytes);
        targetPath = file.path;
      }

      // macOS üzerinde sıfır gecikmeli kesintisiz sonsuz oynatma
      if (Platform.isMacOS) {
        final macFile = File('/tmp/cosmic_${frequencyHz.toStringAsFixed(2)}.wav');
        if (!macFile.existsSync()) {
          await macFile.writeAsBytes(wavBytes);
        }
        try {
          _afplayProcess = await Process.start('/bin/sh', [
            '-c',
            'while true; do /usr/bin/afplay "${macFile.path}"; done'
          ]);
          return;
        } catch (e) {
          debugPrint('macOS afplay loop fallback: $e');
        }
      }

      // Mobil (Android, iOS) için kesintisiz loop modunda audioplayers
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      await _player.play(DeviceFileSource(targetPath, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('Kozmik frekans sentezleme hatası: $e');
      playingFrequencyNotifier.value = null;
    }
  }

  /// Çalan sesi tamamen durdurur
  static Future<void> stop() async {
    try {
      if (_afplayProcess != null) {
        final pid = _afplayProcess!.pid;
        _afplayProcess?.kill(ProcessSignal.sigkill);
        _afplayProcess = null;
        try {
          Process.runSync('/usr/bin/pkill', ['-9', '-P', '$pid']);
          Process.runSync('/usr/bin/killall', ['afplay']);
        } catch (_) {}
      }
      await _player.stop();
    } catch (_) {}
    playingFrequencyNotifier.value = null;
  }
}
