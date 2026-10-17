import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/pdf_report_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';


void main() {
  test('Generate 10 page Word style PDF booklet for native', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final profile = UserProfile(
      name: 'Test Danışan',
      birthDate: '06.06.1991',
      birthTime: '17:42',
      birthCountry: 'Türkiye',
      birthCity: 'Sakarya',
      sunSign: 'İkizler',
      moonSign: 'Balık',
      risingSign: 'Akrep',
      gender: 'Erkek',
      language: 'tr',
      isVip: true,
    );

    final file = await PdfReportService.generate10PageBooklet(profile: profile, autoOpen: false);
    expect(file.existsSync(), isTrue);
    print('Generated PDF successfully with real live chart at: ${file.path}');
  });
}
