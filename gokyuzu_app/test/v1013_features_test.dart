import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/lunar_mansions_service.dart';
import 'package:gokyuzu_app/data/services/astrology_engine.dart';
import 'package:gokyuzu_app/data/services/aspects_service.dart';
import 'package:gokyuzu_app/data/services/sky_transits_service.dart';
import 'package:gokyuzu_app/data/services/predictive_astrology_service.dart';
import 'package:gokyuzu_app/data/services/world_cities_service.dart';
import 'package:gokyuzu_app/data/models/saved_profile_model.dart';

void main() {
  group('v1.0.13+14 Yeni Özellikler Doğrulama Testleri', () {
    test('1. 11 Derece Balık burcundaki Ay, 25. Menzil Sa\'d el-Ahbiye (Saadülahbiye) olarak hesaplanır', () {
      final mansion = LunarMansionsService.getMansionForSignDegree('Balık', 11.0);
      expect(mansion.number, 25);
      expect(mansion.name, contains('Ahbiye'));
      expect(mansion.hermeticStepTitle, isNotEmpty);
      expect(mansion.hermeticIncense, isNotEmpty);
      expect(mansion.hermeticPractice, isNotEmpty);
    });

    test('2. Tüm 28 Ay Menzili derece aralıkları 00°-29° burç sınırına ve dk formatına uygundur', () {
      for (final m in LunarMansionsService.mansions) {
        expect(m.signRange, contains('dk'));
        expect(m.signRange.contains('30°'), isFalse);
        expect(m.signRange.contains('51°'), isFalse);
      }
    });

    test('3. AstrologyEngine True Node / Mean Node ve 9 Seçilebilir Asteroit/Noktayı hesaplar', () {
      final chart = AstrologyEngine.calculateChart(
        name: 'Yiğithan Akman',
        dateStr: '1991-03-06',
        timeStr: '12:30',
        city: 'Datça',
        country: 'Türkiye',
      );
      expect(chart.planets.containsKey('true_north_node'), isTrue);
      expect(chart.planets.containsKey('true_south_node'), isTrue);
      expect(chart.planets.containsKey('mean_north_node'), isTrue);
      expect(chart.planets.containsKey('mean_south_node'), isTrue);

      for (final key in [
        'lilith',
        'vesta',
        'juno',
        'amor',
        'hekate',
        'isis',
        'vertex',
        'pallas',
        'ceres',
      ]) {
        expect(chart.planets.containsKey(key), isTrue, reason: 'Eksik asteroit/nokta: $key');
      }
    });

    test('4. SkyTransitsService getExtraTransitBodies tüm asteroit ve düğümleri döner', () {
      final extra = SkyTransitsService.getExtraTransitBodies();
      expect(extra.containsKey('true_north_node'), isTrue);
      expect(extra.containsKey('mean_north_node'), isTrue);
      expect(extra.containsKey('lilith'), isTrue);
      expect(extra.containsKey('hekate'), isTrue);
      expect(extra.containsKey('isis'), isTrue);
      expect(extra.containsKey('amor'), isTrue);
    });

    test('5. AspectsService Evrensel Açı Orbları (0/180: 10°, 120: 8°, 90/60: 7°) aktiftir', () {
      final defs = AspectsService.allAspectDefinitions;
      expect(defs.firstWhere((d) => d.degree == 0.0).defaultOrb, 10.0);
      expect(defs.firstWhere((d) => d.degree == 180.0).defaultOrb, 10.0);
      expect(defs.firstWhere((d) => d.degree == 120.0).defaultOrb, 8.0);
      expect(defs.firstWhere((d) => d.degree == 90.0).defaultOrb, 7.0);
      expect(defs.firstWhere((d) => d.degree == 60.0).defaultOrb, 7.0);
    });

    test('6. Solar Fire & Astro Gold Kalibrasyonu #1: 10 Eylül 1971 İzmir 16:46 -> Yükselen 10° 38\' Kova', () {
      // 1965-1972 arasında Türkiye'de Yaz Saati uygulanmadı (UTC+2).
      final izmir = WorldCitiesService.findCity('İzmir', 'Türkiye');
      final offset = PredictiveAstrologyService.getHistoricalUtcOffset(
        dt: DateTime(1971, 9, 10),
        cityLoc: izmir,
        hour: 16,
        minute: 46,
      );
      expect(offset, 2.0);

      final chart = AstrologyEngine.calculateChart(
        name: 'Test İzmir 1971',
        dateStr: '1971-09-10',
        timeStr: '16:46',
        city: 'İzmir',
        country: 'Türkiye',
      );
      expect(chart.risingSign, 'Kova');
      expect(chart.risingFormatted, '10°38\' Kova');

      // SavedProfile ve calculateRisingSign doğrulaması
      final risingDirect = AstrologyEngine.calculateRisingSign(
        DateTime(1971, 9, 10),
        const TimeOfDay(hour: 16, minute: 46),
        city: 'İzmir',
        country: 'Türkiye',
      );
      expect(risingDirect, 'Kova');

      final profile = SavedProfile(
        id: 'test-1971',
        name: 'İzmir 1971',
        gender: 'Kadın',
        birthDate: DateTime(1971, 9, 10),
        birthTime: '16:46',
        birthCity: 'İzmir',
        birthCountry: 'Türkiye',
      );
      expect(profile.risingSign, 'Kova');
    });

    test('7. Solar Fire & Astro Gold Kalibrasyonu #2: 11.09.1959 Kırıkkale ("kırkkale") 10:30 -> Yükselen 18° 06\' Akrep', () {
      // Yazım hatası toleransı ("kırkkale" -> "Kırıkkale")
      final cityLoc = WorldCitiesService.findCity('kırkkale', 'Türkiye');
      expect(cityLoc.city, 'Kırıkkale');

      // 1952-1961 arasında Türkiye'de Yaz Saati uygulanmadı (UTC+2).
      final offset = PredictiveAstrologyService.getHistoricalUtcOffset(
        dt: DateTime(1959, 9, 11),
        cityLoc: cityLoc,
        hour: 10,
        minute: 30,
      );
      expect(offset, 2.0);

      final chart = AstrologyEngine.calculateChart(
        name: 'Test Kırıkkale 1959',
        dateStr: '1959-09-11',
        timeStr: '10:30',
        city: 'kırkkale',
        country: 'Türkiye',
      );
      expect(chart.risingSign, 'Akrep');
      expect(chart.risingFormatted, '18°06\' Akrep');
    });

    test('8. Türkiye Tarihi Yaz Saati Uygulaması (1940-2026+) Resmi Gazete & IANA Doğrulaması', () {
      final trCity = WorldCitiesService.findCity('İstanbul', 'Türkiye');

      // 1940: 1 Temmuz 00:00'da başladı -> 30 Haziran UTC+2, 15 Temmuz UTC+3
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1940, 6, 30), cityLoc: trCity, hour: 12), 2.0);
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1940, 7, 15), cityLoc: trCity, hour: 12), 3.0);

      // 1941: Tüm kış boyunca devam etti (20 Eylül 1941'e kadar kesintisiz UTC+3)
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1941, 1, 15), cityLoc: trCity, hour: 12), 3.0);
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1941, 10, 1), cityLoc: trCity, hour: 12), 2.0);

      // 1952-1961: Yaz saati yok (UTC+2)
      for (final y in [1952, 1955, 1959, 1961]) {
        expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(y, 7, 15), cityLoc: trCity, hour: 12), 2.0);
      }

      // 1962: 15 Temmuz - 8 Ekim arası UTC+3
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1962, 7, 10), cityLoc: trCity, hour: 12), 2.0);
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1962, 8, 10), cityLoc: trCity, hour: 12), 3.0);

      // 1965-1969 ve 1971-1972: Yaz saati yok (UTC+2)
      for (final y in [1965, 1968, 1971, 1972]) {
        expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(y, 8, 15), cityLoc: trCity, hour: 12), 2.0);
      }

      // 1978-1982: Kalıcı UTC+3 (29 Ekim 1978'den 1 Kasım 1984'e kadar kışın da UTC+3)
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1979, 1, 15), cityLoc: trCity, hour: 12), 3.0);
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1981, 12, 15), cityLoc: trCity, hour: 12), 3.0);

      // 1983: 31 Temmuz - 2 Ekim arası ileri saat (GMT+3 baz üzerine +1 saat = GMT+4!)
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1983, 8, 15), cityLoc: trCity, hour: 12), 4.0);
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(1983, 11, 15), cityLoc: trCity, hour: 12), 3.0);

      // 2016 sonrası: Kalıcı UTC+3
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(2017, 1, 15), cityLoc: trCity, hour: 12), 3.0);
      expect(PredictiveAstrologyService.getHistoricalUtcOffset(dt: DateTime(2026, 12, 15), cityLoc: trCity, hour: 12), 3.0);
    });
  });
}
