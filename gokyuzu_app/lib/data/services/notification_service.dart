import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'astrology_engine.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';

/// Gerçek Cihaz Bildirim Servisi (Android 13+ ve iOS Tam Uyumlu)
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefEnabledKey = 'cosmic_notifications_enabled';
  static const String _prefAskedKey = 'cosmic_notifications_prompted';
  static const String _prefLastDailyPushKey = 'cosmic_last_daily_push_date';
  static const String channelId = 'gokyuzu_cosmic_channel';
  static const String channelName = 'Gökyüzü Doktoru Kozmik Bildirimler';

  static bool _isInitialized = false;

  /// Servisi başlat ve bildirim kanalını aç
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      } catch (_) {}

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: 'Open');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
      );

      // Android İçin Yüksek Öncelikli Kanal Oluştur
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description:
              'Günlük gezegen transitleri, Ay fazı ve kişisel astrolojik rehber bildirimleri.',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidImpl.createNotificationChannel(channel);
      }

      _isInitialized = true;
    } catch (_) {}
  }

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

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final osEnabled = await androidImpl?.areNotificationsEnabled();
      if (osEnabled != null) return osEnabled && prefVal;
    }
    return prefVal;
  }

  /// Kullanıcıdan resmi işletim sistemi izinlerini iste ve bildirimleri aktif et
  static Future<bool> requestPermissionAndEnable(
    UserProfile profile, {
    bool sendImmediateConfirmation = true,
  }) async {
    await init();
    await markPrompted();

    bool granted = false;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        // Android 13+ (API 33+) resmi izin penceresini açar
        granted =
            await androidImpl?.requestNotificationsPermission() ?? false;
      } else if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        final iosImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        granted = await iosImpl?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      } else {
        granted = true;
      }
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

  /// Bildirimleri tamamen kapat
  static Future<void> disableNotifications() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, false);
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  /// 3 Farklı Saat Diliminde Günlük Kozmik Bildirimleri Planla (09:30, 14:30, 20:30)
  static Future<void> scheduleDailyCosmicNotifications(
    UserProfile profile,
  ) async {
    await init();

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
    final cleanName =
        profile.name.trim().isEmpty ? 'Kozmik Yolcu' : profile.name.trim();

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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          'Günlük gezegen transitleri ve astrolojik rehber bildirimleri.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    for (final item in items) {
      final id = item['id'] as int;
      final hour = item['hour'] as int;
      final minute = item['minute'] as int;
      final title = item['title'] as String;
      final body = item['body'] as String;

      try {
        final scheduledTime = _nextInstanceOfTime(hour, minute);
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {}
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Anında Canlı Test / Hoş Geldin Bildirimi Gönder (Telefonda Hemen Görünür)
  static Future<void> sendTestOrDailyNotification(
    UserProfile profile, {
    bool isWelcome = false,
  }) async {
    await init();

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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          'Günlük gezegen transitleri ve astrolojik rehber bildirimleri.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Kozmik Bildirim',
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: 999,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (_) {}
  }

  static Future<void> syncDailyNotificationsIfEnabled(
      UserProfile profile) async {
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
