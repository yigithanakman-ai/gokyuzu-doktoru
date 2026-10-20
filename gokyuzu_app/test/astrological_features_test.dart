import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/world_cities_service.dart';
import 'package:gokyuzu_app/data/services/crystals_service.dart';
import 'package:gokyuzu_app/data/services/kabbalah_tree_service.dart';
import 'package:gokyuzu_app/data/services/cosmic_quotes_service.dart';

void main() {
  group('WorldCitiesService Tests', () {
    test('Search "t" returns both Turkish cities (Tokat, Trabzon) and World metropolises (Tokyo)', () {
      final results = WorldCitiesService.search('t', limit: 15);
      expect(results.isNotEmpty, isTrue);

      final cityNames = results.map((c) => c.city).toList();
      expect(cityNames.contains('Tokyo'), isTrue, reason: 'Tokyo must be suggested');
      expect(cityNames.any((c) => c == 'Tokat' || c == 'Trabzon'), isTrue, reason: 'Turkish cities must be suggested');
    });

    test('Search "virginia" or "berlin" finds international cities', () {
      final virginia = WorldCitiesService.search('virginia');
      expect(virginia.any((c) => c.city.toLowerCase().contains('virginia')), isTrue);

      final berlin = WorldCitiesService.search('berlin');
      expect(berlin.any((c) => c.city == 'Berlin' && c.country == 'Almanya'), isTrue);
    });

    test('Turkish character normalization works for search', () {
      final istanbul1 = WorldCitiesService.search('istanbul');
      final istanbul2 = WorldCitiesService.search('İstanbul');
      expect(istanbul1.isNotEmpty, isTrue);
      expect(istanbul2.isNotEmpty, isTrue);
      expect(istanbul1.first.city, equals('İstanbul'));
    });

    test('findCity returns correct coordinates or fallback', () {
      final tokyo = WorldCitiesService.findCity('Tokyo');
      expect(tokyo.city, equals('Tokyo'));
      expect(tokyo.country, equals('Japonya'));
      expect(tokyo.latitude, closeTo(35.6762, 0.01));

      final fallback = WorldCitiesService.findCity('BilinmeyenYer123');
      expect(fallback.city, equals('Datça'));
    });
  });

  group('CrystalsService Tests', () {
    test('Contains minimum 16 curated natural crystals with complete metadata', () {
      expect(CrystalsService.allCrystals.length, greaterThanOrEqualTo(16));
      for (final c in CrystalsService.allCrystals) {
        expect(c.name.isNotEmpty, isTrue);
        expect(c.planets.isNotEmpty, isTrue);
        expect(c.zodiacSigns.isNotEmpty, isTrue);
        expect(c.chakras.isNotEmpty, isTrue);
        expect(c.physicalBenefits.isNotEmpty, isTrue);
        expect(c.spiritualBenefits.isNotEmpty, isTrue);
      }
    });

    test('getBySign returns matching crystals for Koç', () {
      final ariesCrystals = CrystalsService.getBySign('Koç');
      expect(ariesCrystals.isNotEmpty, isTrue);
      expect(ariesCrystals.any((c) => c.name == 'Granat' || c.zodiacSigns.any((s) => s.contains('Koç'))), isTrue);
    });

    test('getBirthStones returns curated crystal list for chart profile', () {
      final stones = CrystalsService.getBirthStones(
        sunSign: 'Koç',
        ascendantSign: 'Akrep',
        moonSign: 'Balık',
      );
      expect(stones.isNotEmpty, isTrue);
      expect(stones.length, greaterThanOrEqualTo(3));
    });
  });

  group('KabbalahTreeService Tests', () {
    test('Contains 10 Sefirot and 22 Paths', () {
      expect(KabbalahTreeService.sephirot.length, equals(10));
      expect(KabbalahTreeService.paths.length, equals(22));
    });

    test('Keter is the Crown and Malkhut is the Kingdom', () {
      final keter = KabbalahTreeService.sephirot.firstWhere((s) => s.number == 1);
      expect(keter.hebrewName, contains('Keter'));
      expect(keter.turkishName, contains('Taç'));

      final malkhut = KabbalahTreeService.sephirot.firstWhere((s) => s.number == 10);
      expect(malkhut.hebrewName, contains('Malkhut'));
      expect(malkhut.turkishName, contains('Krallık'));
    });

    test('getByNumber and getByPlanet work as expected', () {
      final tiferet = KabbalahTreeService.getByNumber(6);
      expect(tiferet.hebrewName, contains('Tiferet'));
      expect(tiferet.planetaryCorrespondence, contains('Güneş'));

      final saturn = KabbalahTreeService.getByPlanet('Satürn');
      expect(saturn, isNotNull);
      expect(saturn!.number, equals(3)); // Binah
    });
  });

  group('CosmicQuotesService Tests', () {
    test('Returns valid daily quote with philosopher and transit theme', () {
      final quote = CosmicQuotesService.getDailyQuote();
      expect(quote.author.isNotEmpty, isTrue);
      expect(quote.quote.isNotEmpty, isTrue);
      expect(quote.transitTheme.isNotEmpty, isTrue);
      expect(quote.practicalReflection.isNotEmpty, isTrue);
    });
  });
}
