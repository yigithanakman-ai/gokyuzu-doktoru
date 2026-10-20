import 'dart:math';

class PlanetaryHour {
  final int hourNumber; // 1 to 24 (1-12 day, 13-24 night)
  final bool isDayHour;
  final String planetName;
  final String planetSymbol;
  final String startFormatted;
  final String endFormatted;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCurrent;
  final String title;
  final String energyDescription;
  final String suitableActivities;

  const PlanetaryHour({
    required this.hourNumber,
    required this.isDayHour,
    required this.planetName,
    required this.planetSymbol,
    required this.startFormatted,
    required this.endFormatted,
    required this.startTime,
    required this.endTime,
    required this.isCurrent,
    required this.title,
    required this.energyDescription,
    required this.suitableActivities,
  });
}

class PlanetaryDayInfo {
  final String cityName;
  final String dayName;
  final String dayRulerPlanet;
  final String dayRulerSymbol;
  final String sunriseFormatted;
  final String sunsetFormatted;
  final PlanetaryHour currentHour;
  final PlanetaryHour previousHour;
  final PlanetaryHour nextHour;
  final int minutesRemainingInCurrentHour;
  final List<PlanetaryHour> allHours;
  final List<PlanetaryHour> dayHours;
  final List<PlanetaryHour> nightHours;

  const PlanetaryDayInfo({
    required this.cityName,
    required this.dayName,
    required this.dayRulerPlanet,
    required this.dayRulerSymbol,
    required this.sunriseFormatted,
    required this.sunsetFormatted,
    required this.currentHour,
    required this.previousHour,
    required this.nextHour,
    required this.minutesRemainingInCurrentHour,
    required this.allHours,
    required this.dayHours,
    required this.nightHours,
  });
}

/// Babil & Klasik Helenistik Astroloji Gezegen Saatleri & Günleri Motoru
/// NOAA Güneş Astronomi Algoritmaları ile %100 Gerçek ve Hassas Hesaplama
class PlanetaryHoursService {
  // Klasik Keldani (Chaldean) Sıralaması: Satürn'den Ay'a doğru iniş
  static const List<String> chaldeanOrder = [
    'Satürn',
    'Jüpiter',
    'Mars',
    'Güneş',
    'Venüs',
    'Merkür',
    'Ay',
  ];

  static const Map<String, String> planetSymbols = {
    'Satürn': '♄',
    'Jüpiter': '♃',
    'Mars': '♂\uFE0E',
    'Güneş': '☉',
    'Venüs': '♀\uFE0E',
    'Merkür': '☿',
    'Ay': '☽',
  };

  // Haftanın günlerinin yöneticileri (Dart DateTime.weekday: 1=Pazartesi ... 7=Pazar)
  static const Map<int, String> dayRulers = {
    1: 'Ay', // Pazartesi (Monday / Moon Day)
    2: 'Mars', // Salı (Tuesday / Mars Day)
    3: 'Merkür', // Çarşamba (Wednesday / Mercury Day)
    4: 'Jüpiter', // Perşembe (Thursday / Jupiter Day)
    5: 'Venüs', // Cuma (Friday / Venus Day)
    6: 'Satürn', // Cumartesi (Saturday / Saturn Day)
    7: 'Güneş', // Pazar (Sunday / Sun Day)
  };

  static const Map<int, String> dayNames = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };

  /// Belirli bir enlem, boylam, saat dilimi ve tarih için günün tüm 24 gezegen saatini hesaplar
  static PlanetaryDayInfo calculatePlanetaryHours({
    DateTime? date,
    double latitude = 41.0082, // Varsayılan İstanbul
    double longitude = 28.9784,
    double timezoneOffset = 3.0,
    String cityName = 'İstanbul',
  }) {
    final now = date ?? DateTime.now();

    // 1. Bugüne ait astronomik Güneş Doğuş & Batışını hesapla (NOAA Algoritması)
    final todaySunTimes = _calculateSunriseSunset(
      now.year,
      now.month,
      now.day,
      latitude,
      longitude,
      timezoneOffset,
    );
    final todaySunrise = todaySunTimes['sunrise']!;

    // Klasik astrolojide gezegen günü yerel gün doğumunda (Sunrise) başlar.
    // Gece yarısı 00:00 - Sunrise arası, bir önceki günün gece saatleridir.
    final bool isBeforeTodaySunrise = now.isBefore(todaySunrise);
    final DateTime targetDate = isBeforeTodaySunrise
        ? now.subtract(const Duration(days: 1))
        : now;

    final weekday = targetDate.weekday;
    final dayRuler = dayRulers[weekday] ?? 'Güneş';
    final dayName = dayNames[weekday] ?? 'Pazar';

    final DateTime sunrise;
    final DateTime sunset;
    final DateTime nextDaySunrise;

    if (isBeforeTodaySunrise) {
      final prevSunTimes = _calculateSunriseSunset(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        latitude,
        longitude,
        timezoneOffset,
      );
      sunrise = prevSunTimes['sunrise']!;
      sunset = prevSunTimes['sunset']!;
      nextDaySunrise = todaySunrise;
    } else {
      sunrise = todaySunrise;
      sunset = todaySunTimes['sunset']!;
      final tomorrow = targetDate.add(const Duration(days: 1));
      final nextSunTimes = _calculateSunriseSunset(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        latitude,
        longitude,
        timezoneOffset,
      );
      nextDaySunrise = nextSunTimes['sunrise']!;
    }

    // Gündüz ve Gece süreleri
    final dayDuration = sunset.difference(sunrise);
    final nightDuration = nextDaySunrise.difference(sunset);

    final dayHourDuration = Duration(milliseconds: (dayDuration.inMilliseconds / 12).round());
    final nightHourDuration = Duration(milliseconds: (nightDuration.inMilliseconds / 12).round());

    // Keldani dizisindeki başlangıç indeksi: Günün yöneticisi 1. saati yönetir
    int planetIndex = chaldeanOrder.indexOf(dayRuler);
    final List<PlanetaryHour> dayHoursList = [];
    final List<PlanetaryHour> nightHoursList = [];
    final List<PlanetaryHour> allHoursList = [];

    // 12 Gündüz Saati
    for (int i = 0; i < 12; i++) {
      final startTime = sunrise.add(dayHourDuration * i);
      final endTime = (i == 11) ? sunset : sunrise.add(dayHourDuration * (i + 1));
      final pName = chaldeanOrder[planetIndex % chaldeanOrder.length];
      final isCurrent = (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) && now.isBefore(endTime);

      final hour = PlanetaryHour(
        hourNumber: i + 1,
        isDayHour: true,
        planetName: pName,
        planetSymbol: planetSymbols[pName] ?? '✨',
        startFormatted: _formatTime(startTime),
        endFormatted: _formatTime(endTime),
        startTime: startTime,
        endTime: endTime,
        isCurrent: isCurrent,
        title: _getPlanetTitle(pName),
        energyDescription: _getPlanetEnergy(pName),
        suitableActivities: _getPlanetActivities(pName),
      );

      dayHoursList.add(hour);
      allHoursList.add(hour);
      planetIndex++;
    }

    // 12 Gece Saati
    for (int i = 0; i < 12; i++) {
      final startTime = sunset.add(nightHourDuration * i);
      final endTime = (i == 11) ? nextDaySunrise : sunset.add(nightHourDuration * (i + 1));
      final pName = chaldeanOrder[planetIndex % chaldeanOrder.length];
      final isCurrent = (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) && now.isBefore(endTime);

      final hour = PlanetaryHour(
        hourNumber: i + 13,
        isDayHour: false,
        planetName: pName,
        planetSymbol: planetSymbols[pName] ?? '✨',
        startFormatted: _formatTime(startTime),
        endFormatted: _formatTime(endTime),
        startTime: startTime,
        endTime: endTime,
        isCurrent: isCurrent,
        title: _getPlanetTitle(pName),
        energyDescription: _getPlanetEnergy(pName),
        suitableActivities: _getPlanetActivities(pName),
      );

      nightHoursList.add(hour);
      allHoursList.add(hour);
      planetIndex++;
    }

    // Aktif saat
    int activeIndex = allHoursList.indexWhere((h) => h.isCurrent);
    if (activeIndex == -1) {
      activeIndex = allHoursList.indexWhere((h) => now.isBefore(h.endTime));
      if (activeIndex == -1) activeIndex = 0;
    }

    final currentHour = allHoursList[activeIndex];
    final prevIndex = (activeIndex - 1 + allHoursList.length) % allHoursList.length;
    final nextIndex = (activeIndex + 1) % allHoursList.length;
    final previousHour = allHoursList[prevIndex];
    final nextHour = allHoursList[nextIndex];

    final minutesRemaining = currentHour.endTime.difference(now).inMinutes.clamp(0, 180);

    return PlanetaryDayInfo(
      cityName: cityName,
      dayName: dayName,
      dayRulerPlanet: dayRuler,
      dayRulerSymbol: planetSymbols[dayRuler] ?? '✨',
      sunriseFormatted: _formatTime(sunrise),
      sunsetFormatted: _formatTime(sunset),
      currentHour: currentHour,
      previousHour: previousHour,
      nextHour: nextHour,
      minutesRemainingInCurrentHour: minutesRemaining,
      allHours: allHoursList,
      dayHours: dayHoursList,
      nightHours: nightHoursList,
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// NOAA Astronomi Algoritması: Doğuş, Batış, Güneş Öğleni ve Zaman Denklemi (Equation of Time)
  static Map<String, DateTime> _calculateSunriseSunset(
    int year,
    int month,
    int day,
    double lat,
    double lng,
    double timezoneOffset,
  ) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jdn = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    final t = (jdn - 2451545.0) / 36525.0;

    final l0 = (280.46646 + t * (36000.76983 + 0.0003032 * t)) % 360.0;
    final mAnom = 357.52911 + t * (35999.05029 - 0.0001537 * t);
    final mRad = mAnom * pi / 180.0;

    final c = sin(mRad) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        sin(2 * mRad) * (0.019993 - 0.000101 * t) +
        sin(3 * mRad) * 0.000289;

    final sunTrueLong = l0 + c;
    final omega = 125.04 - 1934.136 * t;
    final sunAppLong = sunTrueLong - 0.00569 - 0.00478 * sin(omega * pi / 180.0);

    final eps0 = 23.0 + (26.0 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60.0) / 60.0;
    final eps = eps0 + 0.00256 * cos(omega * pi / 180.0);

    final sinDec = sin(eps * pi / 180.0) * sin(sunAppLong * pi / 180.0);
    final decRad = asin(sinDec);

    final yVar = tan((eps * pi / 180.0) / 2.0) * tan((eps * pi / 180.0) / 2.0);
    final eotRad = yVar * sin(2 * l0 * pi / 180.0) -
        2 * 0.016708634 * sin(mRad) +
        4 * 0.016708634 * yVar * sin(mRad) * cos(2 * l0 * pi / 180.0) -
        0.5 * (yVar * yVar) * sin(4 * l0 * pi / 180.0) -
        1.25 * (0.016708634 * 0.016708634) * sin(2 * mRad);
    final eotMin = 4.0 * (eotRad * 180.0 / pi);

    const zenith = 90.8333 * pi / 180.0;
    final latRad = lat * pi / 180.0;

    double cosHA = (cos(zenith) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad));
    if (cosHA > 1.0) cosHA = 1.0;
    if (cosHA < -1.0) cosHA = -1.0;
    final haDeg = acos(cosHA) * 180.0 / pi;

    final solarNoonMin = 720.0 - (4.0 * lng) - eotMin + (timezoneOffset * 60.0);
    final sunriseMin = solarNoonMin - (haDeg * 4.0);
    final sunsetMin = solarNoonMin + (haDeg * 4.0);

    DateTime minToDateTime(int yr, int mo, int d, double totalMin) {
      final base = DateTime(yr, mo, d);
      return base.add(Duration(seconds: (totalMin * 60).round()));
    }

    return {
      'sunrise': minToDateTime(year, month, day, sunriseMin),
      'sunset': minToDateTime(year, month, day, sunsetMin),
    };
  }

  static String _getPlanetTitle(String planet) {
    switch (planet) {
      case 'Jüpiter':
        return 'Bereket, Finans ve Şans Saati';
      case 'Venüs':
        return 'Aşk, Cazibe ve Estetik Saati';
      case 'Merkür':
        return 'Zihin, Ticaret ve İletişim Saati';
      case 'Güneş':
        return 'Liderlik, Özgüven ve Görünürlük Saati';
      case 'Mars':
        return 'Cesaret, Girişim ve Eylem Saati';
      case 'Ay':
        return 'Sezgi, Duygusal Denge ve Aile Saati';
      case 'Satürn':
        return 'Disiplin, Sabır ve Strateji Saati';
      default:
        return 'Kozmik Enerji Saati';
    }
  }

  static String _getPlanetEnergy(String planet) {
    switch (planet) {
      case 'Jüpiter':
        return 'Evrensel genişleme ve ilahi lütuf frekansı. Maddi ve manevi fırsatlar için gökyüzünün en cömert koridoru.';
      case 'Venüs':
        return 'Sevgi, çekim yasası ve kalp çakrası açık. Kalıcı ilişkiler ve estetik yaratıcılık için en uyumlu atmosfer.';
      case 'Merkür':
        return 'Zihinsel odaklanma, hızlı kavrayış ve sözleşme gücü dorukta. Fikirlerinizi aktarmak için ideal zaman.';
      case 'Güneş':
        return 'Kişisel karizma, saygınlık ve otorite figürleriyle görüşmelerde parlama enerjisi.';
      case 'Mars':
        return 'Yüksek fiziksel dinamizm ve kararlılık. Ertelediğiniz zorlu meseleleri çözmek için savaşçı ruh aktif.';
      case 'Ay':
        return 'Bilinçaltı, sezgisel rüyalar ve beslenme enerjisi. İç dünyanıza çekilmek ve dinlenmek için kutsal saat.';
      case 'Satürn':
        return 'Kalıcı yapılar kurma, planlama ve ciddiyet zamanı. Acele etmeyin, sağlam temeller atın.';
      default:
        return 'Kozmik denge frekansı devrede.';
    }
  }

  static String _getPlanetActivities(String planet) {
    switch (planet) {
      case 'Jüpiter':
        return 'Finansal anlaşmalar, yeni iş başvuruları, yatırım planları, dua & ritüeller ve büyük başlangıçlar.';
      case 'Venüs':
        return 'Flört ve randevular, barışma konuşmaları, güzellik bakımları, alışveriş ve sanat çalışmaları.';
      case 'Merkür':
        return 'Önemli e-postalar, sözleşme imzalamak, sınavlara çalışmak, pazarlık yapmak ve sunum hazırlamak.';
      case 'Güneş':
        return 'Yöneticilerle görüşmek, zam istemek, sahneye çıkmak ve kendini topluma ifade etmek.';
      case 'Mars':
        return 'Ağır spor ve antrenman, rakiplerle yüzleşme, cerrahi kararlar ve cesaret isteyen yüzleşmeler.';
      case 'Ay':
        return 'Ev düzenleme, aile sohbetleri, su kenarında yürüyüş, meditasyon ve sezgisel dinleme.';
      case 'Satürn':
        return 'Harcamaları kısıtlama, bütçe yapma, uzun vadeli gayrimenkul ve miras planları oluşturma.';
      default:
        return 'Bilinçli gözlem ve farkındalık çalışmaları.';
    }
  }
}
