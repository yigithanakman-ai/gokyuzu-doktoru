import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/predictive_astrology_service.dart';
import 'package:gokyuzu_app/data/services/sky_transits_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';

void main() {
  test('PredictiveAstrologyService calculation test for Yigithan and another profile', () {
    final yigithan = UserProfile(
      name: 'Yiğithan Akman',
      birthDate: '06.03.1991',
      birthTime: '10:07',
      birthCountry: 'Türkiye',
      birthCity: 'Bolu',
      sunSign: 'Balık',
      moonSign: 'Akrep',
      risingSign: 'İkizler',
      gender: 'Erkek',
      language: 'tr',
      isVip: true,
      rawChart: {
        'sun': '15°17\' Balık',
        'moon': '09°32\' Akrep',
        'rising': '22°45\' İkizler',
        'mc': '04°12\' Balık',
      },
    );

    final fixedNow = DateTime(2026, 10, 12, 12, 0);
    // 1. Secondary Progressions
    final progY = PredictiveAstrologyService.calculateSecondaryProgressions(profile: yigithan, targetDate: fixedNow);
    print('Yigithan Prog Moon: ${progY['progMoonFormatted']}');
    print('Yigithan Prog ASC: ${progY['progAscFormatted']}');
    print('Yigithan Prog Sun: ${progY['progSunFormatted']}');
    expect(progY['progMoonSign'], 'Balık');
    expect(progY['progAscSign'], 'Yengeç');

    // 2. Solar Arc
    final arcY = PredictiveAstrologyService.calculateSolarArc(profile: yigithan, targetDate: fixedNow);
    print('Yigithan Solar Arc: ${arcY['arcFormatted']}');
    print('Yigithan Dir Sun: ${arcY['dirSunFormatted']}');
    print('Yigithan Dir Moon: ${arcY['dirMoonFormatted']}');
    expect(arcY['arcFormatted'], '+35° 08\'');

    // 3. Zodiacal Releasing
    final zrY = PredictiveAstrologyService.calculateZodiacalReleasing(profile: yigithan, targetDate: fixedNow);
    print('Yigithan ZR Spirit: ${zrY['spiritSign']}');
    print('Yigithan ZR L1: ${zrY['l1Sign']} (${zrY['l1StartDate']} - ${zrY['l1EndDate']})');
    print('Yigithan ZR L2: ${zrY['l2Sign']}');
    expect(zrY['l1Sign'], 'Oğlak');
    expect(zrY['isPeak'], isTrue);
    expect(zrY['peakStatusText'], contains('KÖK & TEMEL PİKİ'));

    // 4. Test Another Profile (Ahmet born 15.08.1998 in Izmir)
    final ahmet = UserProfile(
      name: 'Ahmet Yılmaz',
      birthDate: '15.08.1998',
      birthTime: '14:30',
      birthCountry: 'Türkiye',
      birthCity: 'İzmir',
      sunSign: 'Aslan',
      moonSign: 'Boğa',
      risingSign: 'Akrep',
      gender: 'Erkek',
      language: 'tr',
      isVip: true,
      rawChart: {
        'sun': '22°15\' Aslan',
        'moon': '14°40\' Boğa',
        'rising': '05°20\' Akrep',
        'mc': '18°10\' Aslan',
      },
    );

    final progA = PredictiveAstrologyService.calculateSecondaryProgressions(profile: ahmet, targetDate: fixedNow);
    print('Ahmet Prog Moon: ${progA['progMoonFormatted']}');
    expect(progA['progMoonSign'], isNot('Balık')); // Ahmet is NOT Balık Moon!

    final arcA = PredictiveAstrologyService.calculateSolarArc(profile: ahmet, targetDate: fixedNow);
    print('Ahmet Solar Arc: ${arcA['arcFormatted']}');
    expect(arcA['arcFormatted'], isNot('+35° 08\'')); // Ahmet is age 28, not 35!

    final zrA = PredictiveAstrologyService.calculateZodiacalReleasing(profile: ahmet, targetDate: fixedNow);
    print('Ahmet ZR Spirit: ${zrA['spiritSign']}, L1: ${zrA['l1Sign']}');

    // 5. Solar & Lunar Return dynamic lock check
    final srA = PredictiveAstrologyService.calculateSolarReturn(profile: ahmet, selectedCity: 'İzmir');
    print('Ahmet SR Natal Sun Locked: ${srA['natalSunLabel']}');
    expect(srA['natalSunLabel'].contains('Aslan'), isTrue); // Ahmet Sun locked to Aslan!
    expect(srA['returnYear'], isNotNull);
    expect(srA['returnYear'], isA<int>());

    final lrA = PredictiveAstrologyService.calculateLunarReturn(profile: ahmet, selectedCity: 'İzmir');
    print('Ahmet LR Natal Moon Locked: ${lrA['natalMoonLabel']}');
    expect(lrA['natalMoonLabel'].contains('Boğa'), isTrue); // Ahmet Moon locked to Boğa!

    // 6. Placidus Houses, Intercepted Signs and Day/Night Sect
    final placidusY = PredictiveAstrologyService.calculatePlacidusHouses(profile: yigithan);
    print('Yigithan Placidus Cusps: ${placidusY['cuspFormatted']}');
    print('Yigithan Intercepted Signs: ${placidusY['interceptedSigns']}');
    print('Yigithan Sect: ${placidusY['sectName']}');
    expect(placidusY['isDayChart'], isTrue);
    expect(placidusY['sectName'], contains('Gündüz'));
    expect((placidusY['cusps'] as Map).length, 12);
    expect((placidusY['interceptedSigns'] as List), isNotEmpty);

    // Night chart profile
    final nightProfile = UserProfile(
      name: 'Gece Doğumu',
      birthDate: '10.10.1995',
      birthTime: '23:45',
      birthCity: 'İstanbul',
      sunSign: 'Terazi',
      moonSign: 'Boğa',
      risingSign: 'Yengeç',
      rawChart: {
        'sun': '17°05\' Terazi',
        'rising': '12°30\' Yengeç',
      },
    );
    final placidusNight = PredictiveAstrologyService.calculatePlacidusHouses(profile: nightProfile);
    print('Night Profile Sect: ${placidusNight['sectName']}');
    expect(placidusNight['isDayChart'], isFalse);
    expect(placidusNight['sectName'], contains('Gece'));
  });
}
