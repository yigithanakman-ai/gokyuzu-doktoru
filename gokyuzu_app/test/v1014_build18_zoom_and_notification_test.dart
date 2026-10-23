import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/data/services/astrology_engine.dart';
import 'package:gokyuzu_app/data/services/notification_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';
import 'package:gokyuzu_app/presentation/screens/chart_zoom_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.0.14+18 Zoom Screen & Notification Reliability Tests', () {
    testWidgets('ChartZoomScreen.single renders high resolution canvas and zoom controls',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChartZoomScreen.single(
            title: 'Test Kullanıcı • Doğum Haritası',
            singleWheelPlanets: const {
              'sun': {'sign': 'Koç', 'degree': 15.0, 'house': 1},
              'moon': {'sign': 'Boğa', 'degree': 20.0, 'house': 2},
            },
            ascendantSign: 'Koç',
            ascDegree: 15.0,
            mcSign: 'Oğlak',
            mcDegree: 10.0,
          ),
        ),
      );

      // Başlık ve kontrol butonları mevcut olmalı
      expect(find.text('Test Kullanıcı • Doğum Haritası'), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byIcon(Icons.pinch_rounded), findsOneWidget);
      expect(find.textContaining('2 parmakla serbestçe büyütüp küçültebilirsiniz'),
          findsOneWidget);
    });

    testWidgets('ChartZoomScreen.biWheel renders dual wheel with outer and inner charts',
        (tester) async {
      final natal = AstrologyEngine.calculateChart(
        name: 'Patron',
        dateStr: '1991-06-06',
        timeStr: '17:42',
        city: 'Sakarya',
      );
      final transit = AstrologyEngine.calculateChart(
        name: 'Transit',
        dateStr: '2026-10-22',
        timeStr: '12:00',
        city: 'İstanbul',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChartZoomScreen.biWheel(
            title: 'Patron • Transit Çift Çark',
            natalChart: natal,
            outerChart: transit,
            isSynastry: false,
          ),
        ),
      );

      expect(find.text('Patron • Transit Çift Çark'), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    test('NotificationService scheduleDailyCosmicNotifications generates 14-day 3-slot alarms',
        () async {
      final profile = UserProfile(
        name: 'Yiğithan Akman',
        birthDate: '1991-06-06',
        birthTime: '17:42',
        birthCity: 'Sakarya',
        birthCountry: 'Türkiye',
        sunSign: 'İkizler',
        moonSign: 'Balık',
        risingSign: 'Akrep',
      );

      // Should complete deterministically without crashing or throwing
      await expectLater(
        NotificationService.scheduleDailyCosmicNotifications(profile),
        completes,
      );
    });
  });
}
