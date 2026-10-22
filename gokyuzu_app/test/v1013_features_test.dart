import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/lunar_mansions_service.dart';
import 'package:gokyuzu_app/data/services/astrology_engine.dart';
import 'package:gokyuzu_app/data/services/aspects_service.dart';
import 'package:gokyuzu_app/data/services/sky_transits_service.dart';

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
  });
}
