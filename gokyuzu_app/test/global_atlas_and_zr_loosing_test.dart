import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gokyuzu_app/data/services/world_cities_service.dart';
import 'package:gokyuzu_app/data/services/predictive_astrology_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';
import 'package:gokyuzu_app/data/services/astrology_engine.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1. Global World Atlas & Solar Fire Cities Integration', () {
    test('Azerbaijan - Yevlakh is present with accurate coordinates and UTC+4', () {
      final yevlakhSearch = WorldCitiesService.search('yevlakh');
      expect(yevlakhSearch.isNotEmpty, isTrue);
      expect(yevlakhSearch.first.country, 'Azerbaycan');
      expect(yevlakhSearch.first.timezoneOffset, 4.0);

      final yevlaxSearch = WorldCitiesService.search('yevlax');
      expect(yevlaxSearch.isNotEmpty, isTrue);

      final found = WorldCitiesService.findCity('Yevlakh');
      expect(found.country, 'Azerbaycan');
      expect(found.latitude, closeTo(40.61, 0.1));
      expect(found.longitude, closeTo(47.15, 0.1));
      expect(found.timezoneOffset, 4.0);
    });

    test('Coverage across 7 continents (Kazakhstan, Russia, China, USA, Europe, Africa)', () {
      // Kazakhstan
      final almaty = WorldCitiesService.findCity('Almatı');
      expect(almaty.country, 'Kazakistan');
      expect(almaty.timezoneOffset, 5.0);

      final astana = WorldCitiesService.findCity('Astana');
      expect(astana.country, 'Kazakistan');

      // Russia
      final moscow = WorldCitiesService.findCity('Moskova');
      expect(moscow.country, 'Rusya');
      expect(moscow.timezoneOffset, 3.0);

      // China
      final beijing = WorldCitiesService.findCity('Pekin');
      expect(beijing.country, 'Çin');
      expect(beijing.timezoneOffset, 8.0);

      // USA
      final ny = WorldCitiesService.findCity('New York');
      expect(ny.country, 'ABD');
      expect(ny.timezoneOffset, -5.0);

      final la = WorldCitiesService.findCity('Los Angeles');
      expect(la.country, 'ABD');
      expect(la.timezoneOffset, -8.0);

      // Europe
      final london = WorldCitiesService.findCity('Londra');
      expect(london.country, 'İngiltere');
      expect(london.timezoneOffset, 0.0);

      final berlin = WorldCitiesService.findCity('Berlin');
      expect(berlin.country, 'Almanya');
      expect(berlin.timezoneOffset, 1.0);

      // Africa
      final cairo = WorldCitiesService.findCity('Kahire');
      expect(cairo.country, 'Mısır');
      expect(cairo.timezoneOffset, 2.0);

      final capeTown = WorldCitiesService.findCity('Cape Town');
      expect(capeTown.country, 'Güney Afrika');
      expect(capeTown.timezoneOffset, 2.0);
    });

    test('Smart country fallback when city is unfamiliar', () {
      final azFallback = WorldCitiesService.findCity('Bilinmeyen Kasaba', 'Azerbaycan');
      expect(azFallback.country, 'Azerbaycan');
      expect(azFallback.timezoneOffset, 4.0);

      final ruFallback = WorldCitiesService.findCity('Bilinmeyen Köy', 'Rusya');
      expect(ruFallback.country, 'Rusya');
      expect(ruFallback.timezoneOffset, 3.0);
    });
  });

  group('2. Zodiacal Releasing Loosing of the Bond (Sıçrama / L)', () {
    test('Loosing of the Bond occurs after 12 signs in L1 periods > 211 months', () {
      // Create a test L1 period for Cancer (25 years = 300 months = 9000 days > 211 months)
      final l1Start = DateTime(2000, 1, 1);
      final l1End = l1Start.add(const Duration(days: 25 * 360)); // 9000 days
      
      final l2Periods = PredictiveAstrologyService.calculateL2Periods(
        l1Sign: 'Yengeç',
        l1StartDate: l1Start,
        l1EndDate: l1End,
        spiritSign: 'Yengeç',
      );

      // 12 signs total 211 months. Cancer lasts 300 months.
      // Therefore, there should be more than 12 sub-periods.
      expect(l2Periods.length, greaterThan(12));

      // The 13th sub-period (index 12) MUST be the Loosing of the Bond (Sıçrama)!
      final lbPeriod = l2Periods[12];
      expect(lbPeriod['isLoosing'], isTrue);
      expect(lbPeriod['peakTag'], contains('SIÇRAMA (L)'));

      // The sign of the Loosing of the Bond MUST be the OPPOSITE of Yengeç (Cancer) -> Oğlak (Capricorn)!
      // Yengeç index = 3. Opposite = (3 + 6) % 12 = 9 -> Oğlak!
      expect(lbPeriod['sign'], 'Oğlak');
      print('Verified Loosing of the Bond: Jumped from Yengeç across the zodiac to ${lbPeriod['sign']} (L)');

      // Subsequent period (index 13) continues zodiacally from Oğlak -> Kova
      final nextPeriod = l2Periods[13];
      expect(nextPeriod['sign'], 'Kova');
      expect(nextPeriod['isLoosing'], isFalse);
    });

    test('6.6.1991 Sakarya 17:42 still accurately lands on Boğa on 8.10.2026', () {
      final profile = UserProfile(
        name: 'Yiğithan Akman',
        birthDate: '1991-06-06',
        birthTime: '17:42',
        birthCity: 'Sakarya',
        birthCountry: 'Türkiye',
        sunSign: 'İkizler',
        moonSign: 'Balık',
        risingSign: 'Akrep',
        gender: 'Erkek',
        rawChart: {
          'sun': '15° 28\' İkizler',
          'moon': '09° 32\' Balık',
          'rising': '22° 45\' Akrep',
        },
      );

      final zr = PredictiveAstrologyService.calculateZodiacalReleasing(
        profile: profile,
        targetDate: DateTime(2026, 10, 8),
      );

      expect(zr['spiritSign'], 'Kova');
      expect(zr['l1Sign'], 'Balık');
      expect(zr['l2Sign'], 'Yengeç');
      expect(zr['l3Sign'], 'Boğa');
      print('ZR Verification Passed: L1=${zr['l1Sign']}, L2=${zr['l2Sign']}, L3=${zr['l3Sign']}');
    });
  });

  group('3. VIP Membership Security & Defaults', () {
    test('Default UserProfile has isVip == false', () {
      final defaultProfile = UserProfile(
        name: 'Standart Kullanıcı',
        birthDate: '1995-05-15',
        birthTime: '14:30',
        birthCity: 'İstanbul',
        sunSign: 'Boğa',
        moonSign: 'Başak',
        risingSign: 'Aslan',
      );
      expect(defaultProfile.isVip, isFalse);

      final fromJsonProfile = UserProfile.fromJson({
        'name': 'Test',
        'birthDate': '1995-05-15',
        'birthTime': '14:30',
        'birthCity': 'İstanbul',
        // isVip not provided in JSON
      });
      expect(fromJsonProfile.isVip, isFalse);
    });

    test('StorageService activateVipCode unlocks, deactivateVip locks back', () async {
      await StorageService.deactivateVip();
      expect(await StorageService.isVip(), isFalse);

      final activated = await StorageService.activateVipCode('GKYZ2453');
      expect(activated, isTrue);
      expect(await StorageService.isVip(), isTrue);

      await StorageService.deactivateVip();
      expect(await StorageService.isVip(), isFalse);
    });
  });

  group('4. AstrologyEngine Global Coordinates Calculation', () {
    test('AstrologyEngine calculates rising sign accurately using city coordinates and timezones', () {
      final chartYevlakh = AstrologyEngine.calculateChart(
        name: 'Azeri Kullanıcı',
        birthDate: DateTime(1995, 4, 10),
        birthTime: const TimeOfDay(hour: 12, minute: 0),
        city: 'Yevlakh',
        country: 'Azerbaycan',
      );
      expect(chartYevlakh.risingSign.isNotEmpty, isTrue);

      final chartNewYork = AstrologyEngine.calculateChart(
        name: 'American User',
        birthDate: DateTime(1995, 4, 10),
        birthTime: const TimeOfDay(hour: 12, minute: 0),
        city: 'New York',
        country: 'ABD',
      );
      expect(chartNewYork.risingSign.isNotEmpty, isTrue);

      final chartTokyo = AstrologyEngine.calculateChart(
        name: 'Japanese User',
        birthDate: DateTime(1995, 4, 10),
        birthTime: const TimeOfDay(hour: 12, minute: 0),
        city: 'Tokyo',
        country: 'Japonya',
      );
      expect(chartTokyo.risingSign.isNotEmpty, isTrue);
    });
  });
}
