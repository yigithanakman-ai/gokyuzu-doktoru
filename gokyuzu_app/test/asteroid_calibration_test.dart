import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/astrology_engine.dart';
import 'package:gokyuzu_app/data/services/asteroid_ephemeris_service.dart';

void main() {
  setUpAll(() {
    AsteroidEphemerisService.ensureLoadedSync();
  });

  test('Asteroids calibration 6 Mart 1991 10:07 Bolu matches Solar Fire & Astro Gold', () {
    final chart = AstrologyEngine.calculateChart(
      name: 'Test 1991',
      birthDate: DateTime(1991, 3, 6),
      timeStr: '10:07',
      city: 'Bolu',
      country: 'Turkey',
    );
    print('================ SOLAR FIRE CALIBRATION TEST ================');
    print('Pallas: ${chart.planets['pallas']?.formatted}');
    print('Ceres : ${chart.planets['ceres']?.formatted}');
    print('Lilith: ${chart.planets['lilith']?.formatted}');
    print('Juno  : ${chart.planets['juno']?.formatted}');
    print('Vesta : ${chart.planets['vesta']?.formatted}');
    print('Chiron: ${chart.planets['chiron']?.formatted}');
    print('==============================================================');

    expect(chart.planets['pallas']?.formatted, '15°15\' Başak (r)');
    expect(chart.planets['ceres']?.formatted, '03°47\' Akrep (r)');
    expect(chart.planets['lilith']?.formatted, '24°23\' Yay');
    expect(chart.planets['juno']?.formatted, '17°05\' Oğlak');
    expect(chart.planets['vesta']?.formatted, '26°53\' Boğa');
  });
}
