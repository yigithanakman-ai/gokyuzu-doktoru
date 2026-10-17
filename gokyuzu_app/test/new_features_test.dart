import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gokyuzu_app/data/services/planetary_hours_service.dart';
import 'package:gokyuzu_app/data/services/cosmic_compass_service.dart';
import 'package:gokyuzu_app/data/services/referral_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';
import 'package:gokyuzu_app/data/services/frequency_synth_service.dart';
import 'package:gokyuzu_app/data/services/cosmic_theme_service.dart';
import 'package:gokyuzu_app/presentation/widgets/birthday_solar_return_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. PlanetaryHoursService Tests', () {
    test('Calculates exactly 24 planetary hours (12 day, 12 night)', () {
      final info = PlanetaryHoursService.calculatePlanetaryHours(
        date: DateTime(2026, 10, 24, 14, 0),
      );

      expect(info.allHours.length, 24);
      final dayHours = info.allHours.where((h) => h.isDayHour).toList();
      final nightHours = info.allHours.where((h) => !h.isDayHour).toList();
      expect(dayHours.length, 12);
      expect(nightHours.length, 12);
      expect(info.currentHour, isNotNull);
      expect(info.dayRulerPlanet, isNotEmpty);
    });

    test('Chaldean planet cycle is respected in sequence', () {
      final info = PlanetaryHoursService.calculatePlanetaryHours(
        date: DateTime(2026, 10, 24, 10, 0), // Cumartesi -> Satürn
      );
      expect(info.dayRulerPlanet, 'Satürn');
      expect(info.allHours[0].planetName, 'Satürn');
      expect(info.allHours[1].planetName, 'Jüpiter');
      expect(info.allHours[2].planetName, 'Mars');
      expect(info.allHours[3].planetName, 'Güneş');
      expect(info.allHours[4].planetName, 'Venüs');
      expect(info.allHours[5].planetName, 'Merkür');
      expect(info.allHours[6].planetName, 'Ay');
      expect(info.allHours[7].planetName, 'Satürn');
    });
  });

  group('2. CosmicCompassService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Standard user has 1 question quota daily and can add bonus via ad', () async {
      var status = await CosmicCompassService.checkQuotaStatus();
      expect(status['canAsk'], isTrue);
      expect(status['remaining'], 1);

      await CosmicCompassService.consumeQuota();
      status = await CosmicCompassService.checkQuotaStatus();
      expect(status['canAsk'], isFalse);
      expect(status['remaining'], 0);

      // Ad bonus gives +1 question
      final firstAdRes = await CosmicCompassService.addAdBonusQuota();
      expect(firstAdRes, isTrue);
      status = await CosmicCompassService.checkQuotaStatus();
      expect(status['canAsk'], isTrue);
      expect(status['remaining'], 1);

      // Second ad bonus on same day is STRICTLY REJECTED
      final secondAdRes = await CosmicCompassService.addAdBonusQuota();
      expect(secondAdRes, isFalse);
      status = await CosmicCompassService.checkQuotaStatus();
      expect(status['canWatchAdForBonus'], isFalse);
    });

    test('Consulting compass returns score, needle degrees, and mandatory legal notice', () async {
      final profile = UserProfile(
        name: 'Test Patron',
        birthDate: '1991-06-06',
        birthTime: '17:42',
        birthCity: 'Sakarya',
        sunSign: 'İkizler',
        moonSign: 'Balık',
        risingSign: 'Akrep',
      );

      final result = await CosmicCompassService.consultCompass(
        profile: profile,
        category: 'Kariyer',
        optionalQuestion: 'Yeni bir ortaklığa adım atmalı mıyım?',
      );

      expect(result.cosmicScore, inInclusiveRange(12, 96));
      expect(result.needleAngleDegrees, isNonZero);
      expect(result.legalDisclaimer, contains('YASAL UYARI'));
      expect(result.legalDisclaimer, anyOf([contains('doktorunuza'), contains('uzman hekimlere')]));
      expect(result.timingRecommendation, isNotEmpty);
    });
  });

  group('3. ReferralService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Generates secure alphanumeric single-use voucher code', () async {
      final profile = UserProfile(
        name: 'Patron',
        birthDate: '1991-06-06',
        birthTime: '17:42',
        birthCity: 'Sakarya',
        sunSign: 'İkizler',
        moonSign: 'Balık',
        risingSign: 'Akrep',
      );

      final code = await ReferralService.getOrCreateUserReferralCode(profile);
      expect(code, startsWith('GOK-'));
      expect(code.length, 13);
    });

    test('Redeeming friend code awards free 10-page PDF report and enforces single-use', () async {
      final profile = UserProfile(
        name: 'Patron',
        birthDate: '1991-06-06',
        birthTime: '17:42',
        birthCity: 'Sakarya',
        sunSign: 'İkizler',
        moonSign: 'Balık',
        risingSign: 'Akrep',
      );

      final myCode = await ReferralService.getOrCreateUserReferralCode(profile);

      // Self-redemption should be blocked
      final selfRes = await ReferralService.redeemCode(code: myCode, currentProfile: profile);
      expect(selfRes['success'], isFalse);

      // Valid friend code gives free PDF gift
      final friendRes = await ReferralService.redeemCode(code: 'GOK-ARK1-KOD2', currentProfile: profile);
      expect(friendRes['success'], isTrue);
      expect(await ReferralService.hasFreePdfGift(), isTrue);
      expect(await ReferralService.hasRedeemedReferral(), isTrue);

      // Cannot redeem second time on this device
      final duplicateRes = await ReferralService.redeemCode(code: 'GOK-ARK3-KOD4', currentProfile: profile);
      expect(duplicateRes['success'], isFalse);

      // If another user tries to use the already redeemed code 'GOK-ARK1-KOD2', it is rejected as consumed!
      final otherProfile = UserProfile(
        name: 'Other User',
        birthDate: '1995-01-01',
        birthTime: '12:00',
        birthCity: 'Ankara',
        sunSign: 'Oğlak',
        moonSign: 'Kova',
        risingSign: 'Balık',
      );
      // Reset device redemption state for testing the code's ledger
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_has_redeemed_referral', false);

      final consumedCodeRes = await ReferralService.redeemCode(code: 'GOK-ARK1-KOD2', currentProfile: otherProfile);
      expect(consumedCodeRes['success'], isFalse);
      expect(consumedCodeRes['message'], contains('tek kullanımlıktır'));
    });

    test('Successful invite grants 3-day VIP membership to inviter and prepares fresh code', () async {
      await ReferralService.recordSuccessfulInvite();
      final count = await ReferralService.getInvitedCount();
      expect(count, 1);
      final remainingVip = await ReferralService.getRemainingVipGiftDays();
      expect(remainingVip, inInclusiveRange(3, 4));
      expect(await StorageService.isVipUnlocked(), isTrue);
    });
  });

  group('4. Birthday Solar Return Exact Day Tests', () {
    test('isTodayUserBirthday matches only on exact birth day and month', () {
      final now = DateTime.now();

      final birthdayTodayProfile = UserProfile(
        name: 'Birthday Boy',
        birthDate: '${now.year - 25}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        birthTime: '12:00',
        birthCity: 'İstanbul',
        sunSign: 'Koç',
        moonSign: 'Boğa',
        risingSign: 'İkizler',
      );

      final notBirthdayProfile = UserProfile(
        name: 'Not Today',
        birthDate: '1990-01-01',
        birthTime: '12:00',
        birthCity: 'İstanbul',
        sunSign: 'Oğlak',
        moonSign: 'Kova',
        risingSign: 'Balık',
      );

      expect(BirthdaySolarReturnModal.isTodayUserBirthday(birthdayTodayProfile), isTrue);
      // Not today unless today happens to be Jan 1
      if (now.month != 1 || now.day != 1) {
        expect(BirthdaySolarReturnModal.isTodayUserBirthday(notBirthdayProfile), isFalse);
      }
    });
  });

  group('5. FrequencySynthService Tests', () {
    test('generateSineWavBytes generates valid WAV header and correct sample count', () {
      final wavBytes = FrequencySynthService.generateSineWavBytes(
        frequencyHz: 136.10, // Om / Dünya yılı frekansı
        durationSeconds: 1.0,
        sampleRate: 44100,
      );

      // Header should start with 'RIFF'
      expect(String.fromCharCodes(wavBytes.sublist(0, 4)), 'RIFF');
      // Format is 'WAVE'
      expect(String.fromCharCodes(wavBytes.sublist(8, 12)), 'WAVE');
      // Subchunk 1 is 'fmt '
      expect(String.fromCharCodes(wavBytes.sublist(12, 16)), 'fmt ');
      // Subchunk 2 is 'data'
      expect(String.fromCharCodes(wavBytes.sublist(36, 40)), 'data');

      // 44-byte header + (44100 samples * 4 bytes for stereo) = 176444 bytes
      expect(wavBytes.length, 44 + (44100 * 4));
    });
  });

  group('6. CosmicThemeService Tests', () {
    test('Season switcher dynamically updates background gradient and scaffold color', () {
      CosmicThemeService.setOverrideSeason(CosmicSeason.halloween);
      expect(CosmicThemeService.currentSeason, CosmicSeason.halloween);
      expect(CosmicThemeService.scaffoldBackgroundColor, isNotNull);
      expect(CosmicThemeService.backgroundGradient.colors.length, 3);

      CosmicThemeService.setOverrideSeason(CosmicSeason.newYear);
      expect(CosmicThemeService.currentSeason, CosmicSeason.newYear);
      expect(CosmicThemeService.scaffoldBackgroundColor, isNotNull);

      CosmicThemeService.setOverrideSeason(CosmicSeason.valentines);
      expect(CosmicThemeService.currentSeason, CosmicSeason.valentines);

      CosmicThemeService.setOverrideSeason(CosmicSeason.springEquinox);
      expect(CosmicThemeService.currentSeason, CosmicSeason.springEquinox);

      CosmicThemeService.setOverrideSeason(null);
    });
  });
}


