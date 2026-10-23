import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gokyuzu_app/data/services/cloud_account_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';
import 'package:gokyuzu_app/data/services/profile_archive_service.dart';
import 'package:gokyuzu_app/data/models/saved_profile_model.dart';
import 'package:gokyuzu_app/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('CloudAccountService & Cross-Device VIP Transfer Tests', () {
    test('1. Linking Google Account generates recovery key and triggers backup', () async {
      final account = await CloudAccountService.linkGoogleAccount(
        email: 'yigithanakman@gmail.com',
        displayName: 'Yiğithan Akman',
      );

      expect(account.email, equals('yigithanakman@gmail.com'));
      expect(account.displayName, equals('Yiğithan Akman'));
      expect(account.provider, equals('google'));
      expect(account.recoveryKey.startsWith('GKY-VIP-'), isTrue);

      final active = await CloudAccountService.getActiveAccount();
      expect(active, isNotNull);
      expect(active!.email, equals('yigithanakman@gmail.com'));
      expect(active.recoveryKey, equals(account.recoveryKey));
    });

    test('2. Backup and restore preserves user profile, saved archives, and VIP status', () async {
      // Setup initial data
      final testProfile = UserProfile(
        name: 'Patron Yiğithan',
        birthDate: '06.03.1991',
        birthTime: '10:07',
        birthCountry: 'Türkiye',
        birthCity: 'Bolu',
        sunSign: 'Balık',
        moonSign: 'Akrep',
        risingSign: 'Boğa',
        gender: 'Erkek',
        language: 'tr',
        isVip: true,
      );
      await StorageService.saveProfile(testProfile);
      await StorageService.setVipTier(VipTier.platinum);

      final client = SavedProfile(
        id: 'client_1',
        name: 'Ahmet Danışan',
        birthDate: DateTime(1995, 8, 15),
        birthTime: '14:20',
        birthCountry: 'Türkiye',
        birthCity: 'İstanbul',
        sunSign: 'Aslan',
        moonSign: 'Koç',
        risingSign: 'Akrep',
        gender: 'Erkek',
        createdAt: DateTime.now(),
      );
      await ProfileArchiveService.saveProfile(client);

      // Link Google Account & Backup
      await CloudAccountService.linkGoogleAccount(
        email: 'patron@gmail.com',
        displayName: 'Patron',
      );
      await CloudAccountService.backupToCloud();

      // Retrieve cloud payload to simulate cloud server transfer
      final prefs = await SharedPreferences.getInstance();
      final cloudPayload = prefs.getString('gokyuzu_cloud_payload_v1');
      expect(cloudPayload, isNotNull);

      // Simulate new phone installation (wiping local device storage)
      await StorageService.clearAll();
      final wipedProfile = await StorageService.getProfile();
      expect(wipedProfile, isNull);

      // New device connects to cloud and downloads backup payload
      final newPrefs = await SharedPreferences.getInstance();
      await newPrefs.setString('gokyuzu_cloud_payload_v1', cloudPayload!);

      // Restore from Cloud
      final restored = await CloudAccountService.restoreFromCloud();
      expect(restored, isTrue);

      final recoveredProfile = await StorageService.getProfile();
      expect(recoveredProfile, isNotNull);
      expect(recoveredProfile!.name, equals('Patron Yiğithan'));
      expect(recoveredProfile.birthCity, equals('Bolu'));

      final recoveredVip = await StorageService.isVipUnlocked();
      expect(recoveredVip, isTrue);

      final recoveredTier = await StorageService.getVipTier();
      expect(recoveredTier, equals(VipTier.platinum));

      final recoveredArchives = await ProfileArchiveService.getProfiles();
      expect(recoveredArchives.length, equals(1));
      expect(recoveredArchives.first.name, equals('Ahmet Danışan'));
    });

    test('3. Cross-platform VIP License Key carries exact remaining duration (NO full year reset)', () async {
      // User on Android has VIP with exactly 180 days remaining (started 6 months ago)
      final targetExpiry = DateTime.now().add(const Duration(days: 180));
      await StorageService.setVipTier(VipTier.platinum, expiryDate: targetExpiry);

      // Generate VIP Transfer Key on Android
      final key = await CloudAccountService.generateVipTransferKey();
      expect(key, isNotNull);
      expect(key!.startsWith('GKY-VIP-P-'), isTrue);

      // Simulate switching to new iOS device (wipe local storage, VIP initially false)
      await StorageService.clearAll();
      final initialVip = await StorageService.isVipUnlocked();
      expect(initialVip, isFalse);

      // Redeem on iOS
      final result = await CloudAccountService.redeemVipTransferKey(key);
      expect(result.success, isTrue);
      expect(result.tier, equals(VipTier.platinum));
      // Remaining days must be ~180 days, NOT 365 days!
      expect(result.remainingDays, inInclusiveRange(179, 180));

      final activeVip = await StorageService.isVipUnlocked();
      expect(activeVip, isTrue);

      final recoveredExpiry = await StorageService.getVipExpiryDate();
      expect(recoveredExpiry, isNotNull);
      expect(recoveredExpiry!.year, equals(targetExpiry.year));
      expect(recoveredExpiry.month, equals(targetExpiry.month));
      expect(recoveredExpiry.day, equals(targetExpiry.day));
    });

    test('4. VIP Transfer Key is strictly single-use (Cannot be redeemed twice)', () async {
      final targetExpiry = DateTime.now().add(const Duration(days: 90));
      await StorageService.setVipTier(VipTier.gold, expiryDate: targetExpiry);

      final key = await CloudAccountService.generateVipTransferKey();
      expect(key, isNotNull);

      // 1st redemption on Device B
      final firstAttempt = await CloudAccountService.redeemVipTransferKey(key!);
      expect(firstAttempt.success, isTrue);

      // 2nd redemption attempt with the same key (e.g. sharing with friend or reuse)
      final secondAttempt = await CloudAccountService.redeemVipTransferKey(key);
      expect(secondAttempt.success, isFalse);
      expect(secondAttempt.message.contains('tek kullanımlıktır'), isTrue);
    });

    test('5. Tampered or expired VIP keys are rejected immediately', () async {
      // Expired date key (in the past: 2020-01-01)
      const expiredDateStr = '20200101';
      final expiredChecksum = CloudAccountService.computeChecksum('P', expiredDateStr, '1234');
      final expiredKey = 'GKY-VIP-P-$expiredDateStr-1234-$expiredChecksum';

      final expiredResult = await CloudAccountService.redeemVipTransferKey(expiredKey);
      expect(expiredResult.success, isFalse);
      expect(expiredResult.message.contains('dolmuştur'), isTrue);

      // Tampered checksum
      final tamperedKey = 'GKY-VIP-P-20271231-1234-FFFF';
      final tamperedResult = await CloudAccountService.redeemVipTransferKey(tamperedKey);
      expect(tamperedResult.success, isFalse);
      expect(tamperedResult.message.contains('doğrulanamadı'), isTrue);
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders all sections: Cloud Sync, VIP, Notifications, Legal', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final testProfile = UserProfile(
        name: 'Yiğithan',
        birthDate: '06.03.1991',
        birthTime: '10:07',
        birthCountry: 'Türkiye',
        birthCity: 'Bolu',
        sunSign: 'Balık',
        moonSign: 'Akrep',
        risingSign: 'Boğa',
        gender: 'Erkek',
        language: 'tr',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(profile: testProfile),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ayarlar & Hesap Yönetimi'), findsOneWidget);
      expect(find.text('Bulut Hesabı & Cihaz Değişimi'), findsOneWidget);
      expect(find.text('VIP Üyelik & Abonelik'), findsOneWidget);
      expect(find.text('Canlı Gökyüzü Bildirimleri'), findsOneWidget);
      expect(find.text('Uygulama Dili / Language'), findsOneWidget);
      expect(find.text('Yasal Mevzuat & KVKK'), findsOneWidget);
      expect(find.text('Tehlikeli Bölge'), findsOneWidget);
    });
  });
}
