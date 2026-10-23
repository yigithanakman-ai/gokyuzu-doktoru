import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/lunar_mansions_service.dart';
import 'package:gokyuzu_app/data/services/notification_service.dart';
import 'package:gokyuzu_app/data/services/sky_transits_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.0.14+19 Celestial Notifications & Ephemeris Detection Tests', () {
    test('SkyTransitsService.findUpcomingMoonSignIngresses detects sign boundaries accurately', () {
      final now = DateTime(2026, 10, 22, 12, 0);
      final ingresses = SkyTransitsService.findUpcomingMoonSignIngresses(
        from: now,
        daysAhead: 14,
      );

      // 14 günlük pencerede Ay ~5-6 kez burç değiştirir
      expect(ingresses.isNotEmpty, isTrue);
      expect(ingresses.length, inInclusiveRange(4, 8));

      for (final event in ingresses) {
        expect(event.oldSign.isNotEmpty, isTrue);
        expect(event.newSign.isNotEmpty, isTrue);
        expect(event.oldSign, isNot(equals(event.newSign)));
        expect(event.title, contains(event.newSign));
        expect(event.body, contains(event.oldSign));
        expect(event.eventTime.isAfter(now), isTrue);

        // Olay anından 1 dakika önce eski burçta, olay anından 1 dakika sonra yeni burçta olmalı
        final beforeLon = SkyTransitsService.calculateMoonLongitude(
          event.eventTime.subtract(const Duration(minutes: 1)),
        );
        final afterLon = SkyTransitsService.calculateMoonLongitude(
          event.eventTime.add(const Duration(minutes: 1)),
        );
        final beforeSignIdx = (beforeLon / 30.0).floor() % 12;
        final afterSignIdx = (afterLon / 30.0).floor() % 12;
        expect(SkyTransitsService.signs[beforeSignIdx], equals(event.oldSign));
        expect(SkyTransitsService.signs[afterSignIdx], equals(event.newSign));
      }
    });

    test('LunarMansionsService.findUpcomingMoonMansionTransitions detects 28 mansion transitions', () {
      final now = DateTime(2026, 10, 22, 12, 0);
      final transitions = LunarMansionsService.findUpcomingMoonMansionTransitions(
        from: now,
        daysAhead: 14,
      );

      // 14 günlük pencerede Ay ~13-16 kez menzil değiştirir
      expect(transitions.isNotEmpty, isTrue);
      expect(transitions.length, inInclusiveRange(12, 18));

      for (final ev in transitions) {
        expect(ev.oldMansionNumber, inInclusiveRange(1, 28));
        expect(ev.newMansionNumber, inInclusiveRange(1, 28));
        expect(ev.oldMansionNumber, isNot(equals(ev.newMansionNumber)));
        expect(ev.title, contains(ev.newMansionName));
        expect(ev.body, contains(ev.arabicName));
        expect(ev.eventTime.isAfter(now), isTrue);

        // Olay anından 1 dakika önce eski menzilde, 1 dakika sonra yeni menzilde olmalı
        final beforeMansion = LunarMansionsService.getMansionForDegree(
          SkyTransitsService.calculateMoonLongitude(
            ev.eventTime.subtract(const Duration(minutes: 1)),
          ),
        );
        final afterMansion = LunarMansionsService.getMansionForDegree(
          SkyTransitsService.calculateMoonLongitude(
            ev.eventTime.add(const Duration(minutes: 1)),
          ),
        );
        expect(beforeMansion.number, equals(ev.oldMansionNumber));
        expect(afterMansion.number, equals(ev.newMansionNumber));
      }
    });

    test('SkyTransitsService.findUpcomingPlanetaryIngresses scans 21 days for major ingresses', () {
      final now = DateTime(2026, 10, 22, 12, 0);
      final ingresses = SkyTransitsService.findUpcomingPlanetaryIngresses(
        from: now,
        daysAhead: 21,
      );

      // 21 gün boyunca en azından Güneş veya hızlı bir gezegen (Merkür/Venüs) burç geçişi yapabilir
      // Liste deterministik olarak sıralı olmalı
      for (int i = 0; i < ingresses.length - 1; i++) {
        expect(
          ingresses[i].eventTime.isBefore(ingresses[i + 1].eventTime) ||
              ingresses[i].eventTime.isAtSameMomentAs(ingresses[i + 1].eventTime),
          isTrue,
        );
      }
    });

    test('NotificationService scheduleDailyCosmicNotifications schedules all streams without error', () async {
      final profile = UserProfile(
        name: 'Patron',
        birthDate: '1991-06-06',
        birthTime: '17:42',
        birthCity: 'Sakarya',
        birthCountry: 'Türkiye',
        sunSign: 'İkizler',
        moonSign: 'Balık',
        risingSign: 'Akrep',
      );

      await expectLater(
        NotificationService.scheduleDailyCosmicNotifications(profile),
        completes,
      );
    });
  });
}
