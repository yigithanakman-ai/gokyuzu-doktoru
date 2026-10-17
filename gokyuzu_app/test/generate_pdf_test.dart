import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/pdf_report_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';


void main() {
  test('Generate 10 page Word style PDF booklet for native', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final profile = UserProfile(
      name: 'Yiğithan Akman',
      birthDate: '06.03.1991',
      birthTime: '10:07',
      birthCountry: 'Türkiye',
      birthCity: 'Bolu',
      sunSign: 'Balık',
      moonSign: 'Akrep',
      risingSign: 'İkizler',
      gender: 'Erkek',
      language: 'tr',
      isVip: true,
    );

    final file = await PdfReportService.generate10PageBooklet(profile: profile);
    expect(file.existsSync(), isTrue);
    print('Generated PDF successfully with real live chart at: ${file.path}');
  });
}
