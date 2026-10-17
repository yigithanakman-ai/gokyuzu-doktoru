import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/models/birth_chart_model.dart';
import 'package:gokyuzu_app/data/services/predictive_astrology_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';
import 'package:gokyuzu_app/data/services/pdf_report_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('1. Element Balance Scoring adheres strictly to 15-point rule', () {
    // Test chart with Yiğithan's configuration:
    // ASC: İkizler (Hava 3)
    // Sun: Balık (Su 3)
    // Moon: Akrep (Su 3)
    // Mercury: Balık (Su 1)
    // Venus: Koç (Ateş 1)
    // Mars: İkizler (Hava 1)
    // Jupiter: Aslan (Ateş 1)
    // Saturn: Kova (Hava 1)
    // MC: Kova (Hava 1)
    // Uranus: Oğlak (0)
    // Neptune: Oğlak (0)
    // Pluto: Akrep (0)
    // Chiron: Yengeç (0)
    final planets = <String, PlanetPosition>{
      'ascendant': PlanetPosition(name: 'Yükselen', sign: 'İkizler', formatted: '08°45\' İkizler'),
      'sun': PlanetPosition(name: 'Güneş', sign: 'Balık', formatted: '15°17\' Balık'),
      'moon': PlanetPosition(name: 'Ay', sign: 'Akrep', formatted: '09°32\' Akrep'),
      'mercury': PlanetPosition(name: 'Merkür', sign: 'Balık', formatted: '02°11\' Balık'),
      'venus': PlanetPosition(name: 'Venüs', sign: 'Koç', formatted: '14°42\' Koç'),
      'mars': PlanetPosition(name: 'Mars', sign: 'İkizler', formatted: '16°08\' İkizler'),
      'jupiter': PlanetPosition(name: 'Jüpiter', sign: 'Aslan', formatted: '04°29\' Aslan'),
      'saturn': PlanetPosition(name: 'Satürn', sign: 'Kova', formatted: '02°58\' Kova'),
      'mc': PlanetPosition(name: 'MC', sign: 'Kova', formatted: '14°30\' Kova'),
      'uranus': PlanetPosition(name: 'Uranüs', sign: 'Oğlak', formatted: '13°02\' Oğlak'),
      'neptune': PlanetPosition(name: 'Neptün', sign: 'Oğlak', formatted: '16°15\' Oğlak'),
      'pluto': PlanetPosition(name: 'Plüton', sign: 'Akrep', formatted: '20°20\' Akrep'),
    };

    final scores = BirthChartModel.calculateElementScores(planets);
    print('Calculated Element Scores: $scores');

    // Expected:
    // Ateş: Venus (1) + Jupiter (1) = 2
    // Toprak: 0 (Uranus/Neptune in Capricorn are NOT scored)
    // Hava: ASC (3) + Mars (1) + Saturn (1) + MC (1) = 6
    // Su: Sun (3) + Moon (3) + Mercury (1) = 7
    expect(scores['Ateş'], equals(2));
    expect(scores['Toprak'], equals(0));
    expect(scores['Hava'], equals(6));
    expect(scores['Su'], equals(7));

    final total = scores.values.fold(0, (a, b) => a + b);
    expect(total, equals(15));
  });

  test('2. Zodiacal Releasing Level 3 for 6.6.1991 Sakarya 17:42 is Boğa on 8.10.2026', () {
    final profile = UserProfile(
      name: 'Test Danışan',
      birthDate: '06.06.1991',
      birthTime: '17:42',
      birthCountry: 'Türkiye',
      birthCity: 'Sakarya',
      sunSign: 'İkizler',
      moonSign: 'Koç',
      risingSign: 'Akrep',
      gender: 'Erkek',
      rawChart: {
        'sun': '15°24\' İkizler',
        'moon': '12°10\' Balık',
        'rising': '20°15\' Akrep',
      },
    );

    final targetDate = DateTime(2026, 10, 8);
    final zr = PredictiveAstrologyService.calculateZodiacalReleasing(
      profile: profile,
      targetDate: targetDate,
    );

    print('ZR Spirit: ${zr["spiritSign"]}');
    print('ZR L1: ${zr["l1Sign"]} (${zr["l1StartDate"]} - ${zr["l1EndDate"]})');
    print('ZR L2: ${zr["l2Sign"]} (${zr["l2StartDate"]} - ${zr["l2EndDate"]})');
    print('ZR L3: ${zr["l3Sign"]} (${zr["l3StartDate"]} - ${zr["l3EndDate"]})');

    expect(zr['l1Sign'], equals('Balık'));
    expect(zr['l2Sign'], equals('Yengeç'));
    expect(zr['l3Sign'], equals('Boğa'));
  });

  test('3. PDF 10-page report generation succeeds with new data', () async {
    final profile = UserProfile(
      name: 'Yiğithan Akman',
      birthDate: '06.03.1991',
      birthTime: '16:30',
      birthCountry: 'Türkiye',
      birthCity: 'Bolu',
      sunSign: 'Balık',
      moonSign: 'Akrep',
      risingSign: 'İkizler',
      gender: 'Erkek',
      rawChart: {
        'sun': '15°17\' Balık',
        'moon': '22°15\' Akrep',
        'rising': '08°45\' İkizler',
        'mercury': '02°11\' Balık',
        'venus': '14°42\' Koç',
        'mars': '16°08\' İkizler',
        'jupiter': '04°29\' Aslan',
        'saturn': '02°58\' Kova',
      },
    );

    final file = await PdfReportService.generate10PageBooklet(profile: profile);
    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(10000));
    print('PDF generated successfully at: ${file.path} (${await file.length()} bytes)');
  });
}
