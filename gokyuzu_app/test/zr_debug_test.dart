import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/predictive_astrology_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';

void main() {
  test('ZR Level 3 verification for 6.6.1991 Sakarya 17:42 on 8.10.2026', () {
    final profile = UserProfile(
      name: 'Sakarya Danışan',
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

    print('Spirit: ${zr["spiritSign"]}');
    print('L1: ${zr["l1Sign"]} (${zr["l1StartDate"]} - ${zr["l1EndDate"]})');
    print('L2: ${zr["l2Sign"]} (${zr["l2StartDate"]} - ${zr["l2EndDate"]})');
    print('L3: ${zr["l3Sign"]} (${zr["l3StartDate"]} - ${zr["l3EndDate"]})');

    expect(zr['l3Sign'], equals('Boğa'));
  });
}
