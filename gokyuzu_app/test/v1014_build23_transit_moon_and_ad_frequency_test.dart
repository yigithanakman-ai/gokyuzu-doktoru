import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/astro_bulletin_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';
import 'package:gokyuzu_app/data/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.0.14+23 Astro Bulletin & Ad Frequency Tests', () {
    final testProfile = UserProfile(
      name: 'Patron',
      birthDate: '1991-06-06',
      birthTime: '17:42',
      birthCity: 'Sakarya',
      sunSign: 'İkizler',
      moonSign: 'Balık',
      risingSign: 'Akrep',
      gender: 'Erkek',
      language: 'tr',
      isVip: false,
    );

    test('PersonalizedDailyBulletin calculates real-time Transit Moon, Placidus house, and aspects', () {
      final bulletin = AstroBulletinService.getPersonalizedDailyBulletin(
        profile: testProfile,
        customNow: DateTime.utc(2026, 10, 24, 12, 0),
      );

      // Transit Ay pozisyon doğrulaması
      expect(bulletin.transitMoonSign.isNotEmpty, isTrue);
      expect(bulletin.transitMoonDegree.isNotEmpty, isTrue);
      expect(bulletin.transitMoonFormatted.contains(bulletin.transitMoonSign), isTrue);
      expect(bulletin.transitMoonLongitude, greaterThanOrEqualTo(0.0));
      expect(bulletin.transitMoonLongitude, lessThan(360.0));

      // Kişisel Natal Placidus Ev hesabı
      expect(bulletin.natalHouse, inInclusiveRange(1, 12));
      expect(bulletin.natalHouseName, equals('${bulletin.natalHouse}. Ev'));
      expect(bulletin.natalHouseTheme.isNotEmpty, isTrue);
      expect(bulletin.natalHouseDescription.isNotEmpty, isTrue);
      expect(bulletin.natalHouseCuspRange.isNotEmpty, isTrue);

      // Dinamik günlük sentez yorumu
      expect(bulletin.compiledDailySynthesis.isNotEmpty, isTrue);
      expect(bulletin.compiledDailySynthesis.contains(bulletin.natalHouseName), isTrue);
      expect(bulletin.compiledDailySynthesis.contains(bulletin.transitMoonSign), isTrue);

      // Enerji skoru ve şanslı saatler
      expect(bulletin.cosmicEnergyScore, inInclusiveRange(60, 99));
      expect(bulletin.dailyLuckyHours.isNotEmpty, isTrue);
      expect(bulletin.dailyFocus.isNotEmpty, isTrue);

      // Açı listesi kontrolü
      for (final aspect in bulletin.activeAspects) {
        expect(aspect.aspectName.isNotEmpty, isTrue);
        expect(aspect.natalPlanet.isNotEmpty, isTrue);
        expect(aspect.interpretation.isNotEmpty, isTrue);
        expect(aspect.strategicTip.isNotEmpty, isTrue);
      }
    });

    test('Different dates produce dynamically changing Moon positions and houses', () {
      final bulletinDay1 = AstroBulletinService.getPersonalizedDailyBulletin(
        profile: testProfile,
        customNow: DateTime.utc(2026, 10, 24, 0, 0),
      );

      final bulletinDay4 = AstroBulletinService.getPersonalizedDailyBulletin(
        profile: testProfile,
        customNow: DateTime.utc(2026, 10, 28, 0, 0),
      );

      // 4 gün sonra Ay burcu ve derecesi kesinlikle değişmelidir (~50-52 derece hareket eder)
      expect(bulletinDay1.transitMoonLongitude != bulletinDay4.transitMoonLongitude, isTrue);
      expect(bulletinDay1.compiledDailySynthesis != bulletinDay4.compiledDailySynthesis, isTrue);
    });

    test('AdService counter tracks actions and resets accurately', () {
      AdService.resetCounter();
      expect(AdService.globalActionCounter, equals(0));

      AdService.globalActionCounter = 3;
      expect(AdService.globalActionCounter, equals(3));

      AdService.resetCounter();
      expect(AdService.globalActionCounter, equals(0));
    });
  });
}
