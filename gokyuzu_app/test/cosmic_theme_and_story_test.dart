import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/cosmic_theme_service.dart';
import 'package:gokyuzu_app/data/services/app_translation_service.dart';

void main() {
  group('CosmicThemeService Tests', () {
    test('Default auto detection returns a valid CosmicSeason', () {
      CosmicThemeService.setOverrideSeason(null);
      expect(CosmicThemeService.currentSeason, isA<CosmicSeason>());
    });

    test('Halloween override sets costumes and banner texts correctly', () {
      CosmicThemeService.setOverrideSeason(CosmicSeason.halloween);
      expect(CosmicThemeService.isHalloween, isTrue);
      expect(CosmicThemeService.seasonBadgeText, contains('CADILAR BAYRAMI'));
      expect(CosmicThemeService.getPlanetCostumeEmoji('Pluto'), '🧙‍♀️');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Moon'), '🦇');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Mars'), '🎃');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Sun'), '🍁');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Rising'), '👻');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Yükselen'), '👻');
    });

    test('New Year override sets costumes correctly', () {
      CosmicThemeService.setOverrideSeason(CosmicSeason.newYear);
      expect(CosmicThemeService.isNewYear, isTrue);
      expect(CosmicThemeService.seasonBadgeText, contains('YENİ YIL'));
      expect(CosmicThemeService.getPlanetCostumeEmoji('Sun'), '👑');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Moon'), '❄️');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Jupiter'), '🎁');
    });

    test('Valentines override sets costumes correctly', () {
      CosmicThemeService.setOverrideSeason(CosmicSeason.valentines);
      expect(CosmicThemeService.isValentines, isTrue);
      expect(CosmicThemeService.getPlanetCostumeEmoji('Venus'), '💖');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Mars'), '🏹');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Moon'), '🌹');
    });

    test('Spring Equinox override sets costumes correctly', () {
      CosmicThemeService.setOverrideSeason(CosmicSeason.springEquinox);
      expect(CosmicThemeService.isSpringEquinox, isTrue);
      expect(CosmicThemeService.getPlanetCostumeEmoji('Sun'), '🌱');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Venus'), '🌸');
      expect(CosmicThemeService.getPlanetCostumeEmoji('Mars'), '⚡');
    });

    test('Reset to null reverts back to auto detection', () {
      CosmicThemeService.setOverrideSeason(null);
      expect(CosmicThemeService.currentSeason, isA<CosmicSeason>());
    });
  });

  group('Story and Theme Translations Tests', () {
    test('Story card button text translation', () {
      expect(
        AppTranslationService.tr('📸 Instagram Story Kartı Oluştur (9:16)'),
        isNotEmpty,
      );
    });

    test('Cosmic season theme title translation', () {
      expect(
        AppTranslationService.tr('Kozmik Sezon & Bayram Teması'),
        isNotEmpty,
      );
    });
  });
}
