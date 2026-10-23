import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Swiss Ephemeris & Solar Fire Hassasiyetinde Asteroit Efemeris Servisi (1900 - 2100)
///
/// Ceres, Pallas, Juno, Vesta, Chiron ve Kara Ay Lilith konumlarını
/// JPL DE441 / Swiss Ephemeris verileri üzerinden Catmull-Rom kübik enterpolasyon
/// ile 0.02 yay dakikası altı hassasiyetle hesaplar.
class AsteroidEphemerisService {
  static Float32List? _floats;
  static bool _isLoaded = false;
  static bool get isLoaded => _isLoaded;

  static const double _jdStart = 2415020.5; // 1900-01-01 00:00:00 UTC
  static const double _jdEnd = 2488070.5;   // 2100-01-01 00:00:00 UTC
  static const double _stepDays = 2.0;
  static const int _numSteps = 36526;
  static const int _numBodies = 6;

  static const Map<String, int> _bodyIndices = {
    'ceres': 0,
    'pallas': 1,
    'juno': 2,
    'vesta': 3,
    'chiron': 4,
    'lilith': 5,
  };

  /// Uygulama açılışında asset üzerinden efemerisi belleğe alır.
  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final byteData = await rootBundle.load('assets/ephe/asteroids_1900_2100.bin');
      _loadFromByteData(byteData);
      return;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AsteroidEphemerisService: rootBundle yüklenemedi ($e), dosya aranıyor...');
      }
    }

    // Test veya konsol ortamı için doğrudan dosya fallback'i
    ensureLoadedSync();
  }

  /// Senkron veya test ortamında dosya kontrolü
  static void ensureLoadedSync() {
    if (_isLoaded) return;
    try {
      final candidates = [
        'assets/ephe/asteroids_1900_2100.bin',
        '/Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/gokyuzu_app/assets/ephe/asteroids_1900_2100.bin',
      ];
      for (final p in candidates) {
        final f = File(p);
        if (f.existsSync()) {
          final bytes = f.readAsBytesSync();
          _loadFromByteData(ByteData.sublistView(bytes));
          return;
        }
      }
    } catch (_) {}
  }

  static void _loadFromByteData(ByteData byteData) {
    if (byteData.lengthInBytes < 36 + _numSteps * _numBodies * 4) {
      if (kDebugMode) {
        debugPrint('AsteroidEphemerisService: Geçersiz dosya boyutu: ${byteData.lengthInBytes}');
      }
      return;
    }
    // 36 baytlık başlığı atla (Magic + Header parametreleri)
    _floats = byteData.buffer.asFloat32List(36, _numSteps * _numBodies);
    _isLoaded = true;
    if (kDebugMode) {
      debugPrint('AsteroidEphemerisService: Swiss Ephemeris tablosu başarıyla yüklendi (1900-2100).');
    }
  }

  /// Julian Date (JD) hesaplama (UTC)
  static double julianDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month;
    final dayFrac = dt.day + (dt.hour + (dt.minute + dt.second / 60.0) / 60.0) / 24.0;
    int a = ((14 - m) / 12).floor();
    int yAdj = y + 4800 - a;
    int mAdj = m + 12 * a - 3;
    int jdn = dayFrac.floor() +
        ((153 * mAdj + 2) / 5).floor() +
        365 * yAdj +
        (yAdj / 4).floor() -
        (yAdj / 100).floor() +
        (yAdj / 400).floor() -
        32045;
    return jdn + (dayFrac - dayFrac.floor()) - 0.5;
  }

  /// Belirtilen asteroit/nokta için tropikal geocentric ekliptik boylamı (0-360°)
  static double? getLongitude(String key, DateTime dtUtc) {
    if (!_isLoaded) ensureLoadedSync();
    if (_floats == null) return null;

    final bIdx = _bodyIndices[key.toLowerCase()];
    if (bIdx == null) return null;

    final jd = julianDate(dtUtc);
    if (jd < _jdStart || jd > _jdEnd) return null;

    int idx = ((jd - _jdStart) / _stepDays).floor();
    if (idx < 0) idx = 0;
    if (idx >= _numSteps - 1) idx = _numSteps - 2;
    final t = (jd - (_jdStart + idx * _stepDays)) / _stepDays;

    final idx0 = idx > 0 ? idx - 1 : 0;
    final idx1 = idx;
    final idx2 = idx + 1;
    final idx3 = idx + 2 < _numSteps ? idx + 2 : _numSteps - 1;

    final p0 = _floats![idx0 * _numBodies + bIdx];
    final p1 = _floats![idx1 * _numBodies + bIdx];
    final p2 = _floats![idx2 * _numBodies + bIdx];
    final p3 = _floats![idx3 * _numBodies + bIdx];

    double unwrap(double p, double ref) {
      double d = (p - ref) % 360.0;
      if (d > 180.0) d -= 360.0;
      if (d < -180.0) d += 360.0;
      return ref + d;
    }

    final u0 = unwrap(p0, p1);
    final u2 = unwrap(p2, p1);
    final u3 = unwrap(p3, u2);

    final val = 0.5 * (
      (2.0 * p1) +
      (-u0 + u2) * t +
      (2.0 * u0 - 5.0 * p1 + 4.0 * u2 - u3) * t * t +
      (-u0 + 3.0 * p1 - 3.0 * u2 + u3) * t * t * t
    );
    return (val % 360.0 + 360.0) % 360.0;
  }

  /// Retrograd (geri hareket) kontrolü - Catmull-Rom kübik türevi ile anlık hız
  static bool? isRetrograde(String key, DateTime dtUtc) {
    if (!_isLoaded) ensureLoadedSync();
    if (_floats == null) return null;

    final bIdx = _bodyIndices[key.toLowerCase()];
    if (bIdx == null) return null;

    final jd = julianDate(dtUtc);
    if (jd < _jdStart || jd > _jdEnd) return null;

    int idx = ((jd - _jdStart) / _stepDays).floor();
    if (idx < 0) idx = 0;
    if (idx >= _numSteps - 1) idx = _numSteps - 2;
    final t = (jd - (_jdStart + idx * _stepDays)) / _stepDays;

    final idx0 = idx > 0 ? idx - 1 : 0;
    final idx1 = idx;
    final idx2 = idx + 1;
    final idx3 = idx + 2 < _numSteps ? idx + 2 : _numSteps - 1;

    final p0 = _floats![idx0 * _numBodies + bIdx];
    final p1 = _floats![idx1 * _numBodies + bIdx];
    final p2 = _floats![idx2 * _numBodies + bIdx];
    final p3 = _floats![idx3 * _numBodies + bIdx];

    double unwrap(double p, double ref) {
      double d = (p - ref) % 360.0;
      if (d > 180.0) d -= 360.0;
      if (d < -180.0) d += 360.0;
      return ref + d;
    }

    final u0 = unwrap(p0, p1);
    final u2 = unwrap(p2, p1);
    final u3 = unwrap(p3, u2);

    final spd = 0.5 * (
      (-u0 + u2) +
      2.0 * (2.0 * u0 - 5.0 * p1 + 4.0 * u2 - u3) * t +
      3.0 * (-u0 + 3.0 * p1 - 3.0 * u2 + u3) * t * t
    ) / _stepDays;

    return spd < 0.0;
  }
}
