import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'astrology_engine.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';

class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.gokyuzudoktoru.gokyuzu_app/notifications');

  static const String _prefEnabledKey = 'cosmic_notifications_enabled';
  static const String _prefAskedKey = 'cosmic_notifications_prompted';
  static const String _prefLastDailyPushKey = 'cosmic_last_daily_push_date';

  static Future<bool> hasPromptedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefAskedKey) ?? false;
  }

  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAskedKey, true);
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final prefVal = prefs.getBool(_prefEnabledKey) ?? false;
    if (!prefVal) return false;
    try {
      final osEnabled =
          await _channel.invokeMethod<bool>('areNotificationsEnabled') ?? true;
      return osEnabled;
    } catch (_) {
      return prefVal;
    }
  }

  static Future<bool> requestPermissionAndEnable(
    UserProfile profile, {
    bool sendImmediateConfirmation = true,
  }) async {
    await markPrompted();
    bool granted = true;
    try {
      granted =
          await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } catch (_) {
      granted = true;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, granted);

    if (granted) {
      await scheduleDailyCosmicNotifications(profile);
      if (sendImmediateConfirmation) {
        await sendTestOrDailyNotification(profile, isWelcome: true);
      }
    }
    return granted;
  }

  static Future<void> disableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, false);
    try {
      await _channel.invokeMethod('cancelAllNotifications');
    } catch (_) {}
  }

  static Future<void> scheduleDailyCosmicNotifications(
    UserProfile profile,
  ) async {
    final liveChart = AstrologyEngine.calculateChart(
      name: profile.name,
      dateStr: profile.birthDate,
      timeStr: profile.birthTime,
      city: profile.birthCity,
      country: profile.birthCountry,
    );
    final transits = SkyTransitsService.getCurrentTransits();
    final moonPhase = SkyTransitsService.getMoonPhase();
    final voc = SkyTransitsService.getVoidOfCourse();

    TransitPlanet? sunT;
    TransitPlanet? moonT;
    for (final t in transits) {
      if (t.name == 'Güneş') sunT = t;
      if (t.name == 'Ay') moonT = t;
    }

    final sunSign = sunT?.sign ?? 'Koç';
    final moonSign = moonT?.sign ?? 'Boğa';
    final moonDeg = moonT?.degree.toInt() ?? 15;
    final cleanName = profile.name.trim().isEmpty ? 'Kozmik Yolcu' : profile.name.trim();

    final items = [
      {
        'id': 101,
        'hour': 9,
        'minute': 30,
        'title': '☀️ Günaydın $cleanName • Günün Kozmik Enerjisi',
        'body':
            'Bugün Güneş $sunSign, Ay $moonSign burcunda (${moonPhase.phaseName}) ilerliyor. Yükselen ${liveChart.ascendant} haritanıza özel günlük transit yorumunuz hazır!',
      },
      {
        'id': 102,
        'hour': 14,
        'minute': 30,
        'title': '🌙 Gün Ortası Gökyüzü & Ay Rehberi',
        'body':
            'Transit Ay $moonDeg° $moonSign derecesinde. ${voc.isVoid ? "Ay Boşlukta: Yeni imzalar yerine mevcut işleri tamamlayın." : "Gökyüzü akışı aktif: Önemli görüşme ve adımlar için destekleyici saatler."}',
      },
      {
        'id': 103,
        'hour': 20,
        'minute': 30,
        'title': '✨ Gece Gökyüzü & Yıldız Rehberi',
        'body':
            'Günün yorgunluğunu geride bırakırken ${liveChart.sunSign} Güneş ve ${liveChart.moonSign} Ay enerjinizi dengeleyin. Gece transitlerini incelemek için dokunun.',
      },
    ];

    try {
      await _channel.invokeMethod('scheduleDailyNotifications', {
        'items': items,
      });
    } catch (_) {}
  }

  static Future<void> sendTestOrDailyNotification(
    UserProfile profile, {
    bool isWelcome = false,
  }) async {
    final liveChart = AstrologyEngine.calculateChart(
      name: profile.name,
      dateStr: profile.birthDate,
      timeStr: profile.birthTime,
      city: profile.birthCity,
      country: profile.birthCountry,
    );
    final transits = SkyTransitsService.getCurrentTransits();
    final moonPhase = SkyTransitsService.getMoonPhase();
    TransitPlanet? moonT;
    for (final t in transits) {
      if (t.name == 'Ay') moonT = t;
    }
    final moonSign = moonT?.sign ?? 'Boğa';
    final moonDeg = moonT?.degree.toInt() ?? 15;

    final title = isWelcome
        ? '🔔 Kozmik Bildirimler Aktif Edildi!'
        : '🌌 Günün Transit Bildirimi (${liveChart.ascendant} Yükselen)';
    final body =
        'Transit Ay $moonDeg° $moonSign burcunda (${moonPhase.phaseName}). Sabah 09:30, Öğle 14:30 ve Akşam 20:30 kozmik bildirimleriniz telefonunuza düzenli olarak iletilecektir.';

    try {
      await _channel.invokeMethod('showInstantNotification', {
        'id': 999,
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  static Future<void> syncDailyNotificationsIfEnabled(UserProfile profile) async {
    final enabled = await isEnabled();
    if (!enabled) return;

    await scheduleDailyCosmicNotifications(profile);

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final lastPush = prefs.getString(_prefLastDailyPushKey);
    if (lastPush != todayKey) {
      await prefs.setString(_prefLastDailyPushKey, todayKey);
      await sendTestOrDailyNotification(profile, isWelcome: false);
    }
  }
}
