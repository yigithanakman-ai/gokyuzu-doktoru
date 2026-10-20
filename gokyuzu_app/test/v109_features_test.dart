import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/app_location_service.dart';
import 'package:gokyuzu_app/data/services/world_cities_service.dart';
import 'package:gokyuzu_app/data/services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdService.resetCounter();
  });

  group('v1.0.9 AppLocationService & GPS Tests', () {
    test('findClosestCity correctly identifies Datça for Datça GPS coordinates', () {
      // Datça: 36.7265, 27.6853
      final city = AppLocationService.findClosestCity(36.7265, 27.6853);
      expect(city.city, equals('Datça'));
      expect(city.country, equals('Türkiye'));
    });

    test('findClosestCity correctly identifies İstanbul for Istanbul GPS coordinates', () {
      final city = AppLocationService.findClosestCity(41.0082, 28.9784);
      expect(city.city, equals('İstanbul'));
    });

    test('findClosestCity correctly identifies Ankara for Ankara GPS coordinates', () {
      final city = AppLocationService.findClosestCity(39.9334, 32.8597);
      expect(city.city, equals('Ankara'));
    });

    test('findClosestCity correctly identifies Muğla for Muğla coordinates', () {
      final city = AppLocationService.findClosestCity(37.2153, 28.3636);
      expect(city.city, equals('Muğla'));
    });

    test('WorldCitiesService default fallback is Datça', () {
      final unknown = WorldCitiesService.findCity('TamamenBilinmeyenYerXYZ');
      expect(unknown.city, equals('Datça'));
      expect(unknown.country, equals('Türkiye'));
      expect(unknown.latitude, closeTo(36.7265, 0.01));
      expect(unknown.longitude, closeTo(27.6853, 0.01));
    });

    test('CityLocation displayName formats as "City, Country"', () {
      const loc = CityLocation(
        city: 'Datça',
        country: 'Türkiye',
        latitude: 36.7265,
        longitude: 27.6853,
        timezoneOffset: 3.0,
      );
      expect(loc.displayName, equals('Datça, Türkiye'));
    });
  });

  group('v1.0.9 AdService Global 4-Action Interstitial Tests', () {
    test('registerActionAndShowInterstitial calls onDone callback on desktop/test environments', () async {
      int doneCount = 0;
      await AdService.registerActionAndShowInterstitial(onDone: () {
        doneCount++;
      });
      expect(doneCount, equals(1));
    });

    test('resetCounter resets global action count without throwing', () {
      expect(() => AdService.resetCounter(), returnsNormally);
    });
  });
}
