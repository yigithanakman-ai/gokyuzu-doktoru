import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'astrology_engine.dart';
import 'lunar_mansions_service.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';

/// Gerçek Cihaz Bildirim Servisi (Android 13+ ve iOS Tam Uyumlu)
/// Cihaz kilitli, uykuda, ekran koruyucuda veya şarjda olsa bile
/// tam zamanlı (exactAllowWhileIdle & wake_lock) bildirim iletimi sağlar.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefEnabledKey = 'cosmic_notifications_enabled';
  static const String _prefAskedKey = 'cosmic_notifications_prompted';
  static const String channelId = 'gokyuzu_cosmic_channel';
  static const String channelName = 'Gökyüzü Doktoru Kozmik Bildirimler';

  static bool _isInitialized = false;

  /// Servisi başlat, saat dilimini senkronize et ve yüksek öncelikli bildirim kanalını aç
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      try {
        final now = DateTime.now();
        // Cihazın yerel saat dilimi ofsetini otomatik IANA lokasyonuna eşleştir veya Europe/Istanbul varsay
        String locationName = 'Europe/Istanbul';
        final offset = now.timeZoneOffset;
        for (final entry in tz.timeZoneDatabase.locations.entries) {
          if (entry.value.currentTimeZone.offset == offset) {
            locationName = entry.key;
            break;
          }
        }
        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
        } catch (_) {}
      }

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

      // Android İçin En Yüksek Öncelikli ve Kilit Ekranında Görünen Kanal Oluştur
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
          showBadge: true,
          enableLights: true,
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
    // Varsayılan olarak bildirimler açık başlar (kullanıcı kapatmadığı sürece true)
    final prefVal = prefs.getBool(_prefEnabledKey) ?? true;
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
        // Android 13+ (API 33+) resmi bildirim izin penceresini açar
        granted =
            await androidImpl?.requestNotificationsPermission() ?? false;
        // Android 12+ ve 14+ tam zamanlı alarm (Exact Alarm) izni
        try {
          await androidImpl?.requestExactAlarmsPermission();
        } catch (_) {}
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

  /// Uygulamaya hiç girilmese bile 14 gün boyunca her gün 3 farklı saatte (09:30, 14:30, 20:30)
  /// o günün gerçek Ay burcu, derecesi ve fazıyla arka plan bildirimlerini önceden işletim sistemine kaydeder.
  /// Telefon kilitli, uykuda veya şarjda olsa dahi ekranda görünür.
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

    final cleanName =
        profile.name.trim().isEmpty ? 'Kozmik Yolcu' : profile.name.trim();

    // Kilit ekranında açıkça görünmesi (public visibility) ve en yüksek öncelik
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          'Günlük gezegen transitleri ve astrolojik rehber bildirimleri.',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      showWhen: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final tz.TZDateTime nowTz = tz.TZDateTime.now(tz.local);

    // Gelecek 14 günün her biri için (09:30, 14:30, 20:30) 42 bağımsız tam zamanlı alarm kur
    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
      final targetDay = nowTz.add(Duration(days: dayOffset));
      final sampleDt = DateTime(targetDay.year, targetDay.month, targetDay.day, 12, 0);

      final transits = SkyTransitsService.getCurrentTransits(sampleDt);
      final moonPhase = SkyTransitsService.getMoonPhase(sampleDt);
      final voc = SkyTransitsService.getVoidOfCourse(sampleDt);

      TransitPlanet? sunT;
      TransitPlanet? moonT;
      for (final t in transits) {
        if (t.name == 'Güneş') sunT = t;
        if (t.name == 'Ay') moonT = t;
      }

      final sunSign = sunT?.sign ?? 'Koç';
      final moonSign = moonT?.sign ?? 'Balık';
      final moonDeg = moonT?.degree.toInt().clamp(0, 29) ?? 11;

      final slots = [
        {
          'slotIndex': 0,
          'hour': 9,
          'minute': 30,
          'title': '☀️ Günaydın $cleanName • Günün Kozmik Enerjisi',
          'body':
              'Bugün Güneş $sunSign, Ay $moonDeg° $moonSign burcunda (${moonPhase.phaseName}) ilerliyor. Yükselen ${liveChart.ascendant} haritanıza özel günlük transit yorumunuz hazır!',
        },
        {
          'slotIndex': 1,
          'hour': 14,
          'minute': 30,
          'title': '🌙 Gün Ortası Gökyüzü & Ay Rehberi',
          'body':
              'Transit Ay $moonDeg° $moonSign derecesinde. ${voc.isVoid ? "Ay Boşlukta: Yeni imzalar yerine mevcut işleri tamamlayın." : "Gökyüzü akışı aktif: Önemli görüşme ve adımlar için destekleyici saatler."}',
        },
        {
          'slotIndex': 2,
          'hour': 20,
          'minute': 30,
          'title': '✨ Gece Gökyüzü & Yıldız Rehberi',
          'body':
              'Günün yorgunluğunu geride bırakırken ${liveChart.sunSign} Güneş ve $moonSign Ay enerjinizi dengeleyin. Gece transitlerini incelemek için dokunun.',
        },
      ];

      for (final slot in slots) {
        final slotIdx = slot['slotIndex'] as int;
        final hour = slot['hour'] as int;
        final minute = slot['minute'] as int;
        final title = slot['title'] as String;
        final body = slot['body'] as String;
        final notificationId = 1000 + (dayOffset * 3) + slotIdx;

        final scheduledDate = tz.TZDateTime(
          tz.local,
          targetDay.year,
          targetDay.month,
          targetDay.day,
          hour,
          minute,
        );

        if (scheduledDate.isBefore(nowTz)) continue;

        // Önce tam zamanlı (exactAllowWhileIdle) kur; cihaz izin vermezse inexactAllowWhileIdle ile düşür
        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (_) {
          try {
            await _notificationsPlugin.zonedSchedule(
              id: notificationId,
              title: title,
              body: body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          } catch (_) {}
        }
      }
    }

    // 2. Ay Burç Değişimleri (Gelecek 14 gün için anlık ingress alarmları - 2000+)
    try {
      final moonIngresses = SkyTransitsService.findUpcomingMoonSignIngresses(
        from: DateTime.now(),
        daysAhead: 14,
      );
      for (int i = 0; i < moonIngresses.length; i++) {
        final ev = moonIngresses[i];
        final scheduledDate = tz.TZDateTime.from(ev.eventTime, tz.local);
        if (scheduledDate.isBefore(nowTz)) continue;

        final notificationId = 2000 + i;
        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: ev.title,
            body: ev.body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (_) {
          try {
            await _notificationsPlugin.zonedSchedule(
              id: notificationId,
              title: ev.title,
              body: ev.body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 3. Ay Menzil Geçişleri (28 Kadim Ay Menzili Değişimleri - 3000+)
    try {
      final mansionTransitions =
          LunarMansionsService.findUpcomingMoonMansionTransitions(
        from: DateTime.now(),
        daysAhead: 14,
      );
      for (int i = 0; i < mansionTransitions.length; i++) {
        final ev = mansionTransitions[i];
        final scheduledDate = tz.TZDateTime.from(ev.eventTime, tz.local);
        if (scheduledDate.isBefore(nowTz)) continue;

        final notificationId = 3000 + i;
        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: ev.title,
            body: ev.body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (_) {
          try {
            await _notificationsPlugin.zonedSchedule(
              id: notificationId,
              title: ev.title,
              body: ev.body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 4. Gezegenlerin Yeni Bir Burca Geçişi (İngress Alarmları - 4000+)
    try {
      final planetIngresses =
          SkyTransitsService.findUpcomingPlanetaryIngresses(
        from: DateTime.now(),
        daysAhead: 21,
      );
      for (int i = 0; i < planetIngresses.length; i++) {
        final ev = planetIngresses[i];
        final scheduledDate = tz.TZDateTime.from(ev.eventTime, tz.local);
        if (scheduledDate.isBefore(nowTz)) continue;

        final notificationId = 4000 + i;
        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: ev.title,
            body: ev.body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (_) {
          try {
            await _notificationsPlugin.zonedSchedule(
              id: notificationId,
              title: ev.title,
              body: ev.body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          } catch (_) {}
        }
      }
    } catch (_) {}

    // Ayrıca 14 gün sonrasında da kesintisiz devam etmesi için 3 ana döngüsel (repeating) alarmı kaydet
    final fallbackItems = [
      {
        'id': 101,
        'hour': 9,
        'minute': 30,
        'title': '☀️ Günaydın $cleanName • Günün Kozmik Enerjisi',
        'body':
            'Yükselen ${liveChart.ascendant} haritanıza özel bugünkü gezegen transitleri ve Ay menzili rehberiniz hazır!',
      },
      {
        'id': 102,
        'hour': 14,
        'minute': 30,
        'title': '🌙 Gün Ortası Gökyüzü & Ay Rehberi',
        'body':
            'Gün ortası Ay fazı, gezegen saatleri ve kozmik karar pusulası analiziniz için dokunun.',
      },
      {
        'id': 103,
        'hour': 20,
        'minute': 30,
        'title': '✨ Gece Gökyüzü & Yıldız Rehberi',
        'body':
            'Gece gökyüzündeki canlı transit açıları ve yarının astrolojik enerjilerini keşfedin.',
      },
    ];

    for (final item in fallbackItems) {
      final id = item['id'] as int;
      final hour = item['hour'] as int;
      final minute = item['minute'] as int;
      final scheduledTime = _nextInstanceOfTime(hour, minute);
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: item['title'] as String,
          body: item['body'] as String,
          scheduledDate: scheduledTime,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {
        try {
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: item['title'] as String,
            body: item['body'] as String,
            scheduledDate: scheduledTime,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (_) {}
      }
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
    final mansion = LunarMansionsService.getCurrentMoonMansion();

    final title = isWelcome
        ? '🔔 Kozmik Bildirimler Aktif Edildi!'
        : '🌌 Günün Transit Bildirimi (${liveChart.ascendant} Yükselen)';
    final body =
        'Transit Ay $moonDeg° $moonSign burcunda (${moonPhase.phaseName}) ve ${mansion.name} menzilinde. Günlük transitler (09:30, 14:30, 20:30), anlık Ay burç/menzil geçişleri ve gezegen burç değişimleri telefonunuza tam zamanında iletilecektir.';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          'Günlük gezegen transitleri ve astrolojik rehber bildirimleri.',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Kozmik Bildirim',
      playSound: true,
      enableVibration: true,
      showWhen: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      audioAttributesUsage: AudioAttributesUsage.notification,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
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
    await init();
    final prefs = await SharedPreferences.getInstance();
    final userDisabled = prefs.getBool(_prefEnabledKey) == false;
    if (userDisabled) return;

    // İzin henüz alınmadıysa işletim sisteminden sessizce/resmi olarak iste
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final osEnabled = await androidImpl?.areNotificationsEnabled() ?? false;
      if (!osEnabled) {
        await requestPermissionAndEnable(
          profile,
          sendImmediateConfirmation: false,
        );
        return;
      }
    }

    // 14 günlük arka plan alarmlarını (09:30, 14:30, 20:30) sessizce güncelle
    // (Uygulamaya girildiğinde anlık bildirim fırlatmaz, sadece zamanlanmış arka plan alarmlarını senkronize eder)
    await scheduleDailyCosmicNotifications(profile);
  }
}
