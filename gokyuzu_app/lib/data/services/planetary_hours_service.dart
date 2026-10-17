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
  final String dayName;
  final String dayRulerPlanet;
  final String dayRulerSymbol;
  final String sunriseFormatted;
  final String sunsetFormatted;
  final PlanetaryHour currentHour;
  final List<PlanetaryHour> allHours;

  const PlanetaryDayInfo({
    required this.dayName,
    required this.dayRulerPlanet,
    required this.dayRulerSymbol,
    required this.sunriseFormatted,
    required this.sunsetFormatted,
    required this.currentHour,
    required this.allHours,
  });
}

/// Babil & Klasik Helenistik Astroloji Gezegen Saatleri & Günleri Motoru
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
    'Mars': '♂',
    'Güneş': '☉',
    'Venüs': '♀',
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

  /// Belirli bir enlem, boylam ve tarih için günün tüm 24 gezegen saatini hesaplar
  static PlanetaryDayInfo calculatePlanetaryHours({
    DateTime? date,
    double latitude = 41.0082, // Varsayılan İstanbul
    double longitude = 28.9784,
  }) {
    final now = date ?? DateTime.now();
    final weekday = now.weekday;
    final dayRuler = dayRulers[weekday] ?? 'Güneş';
    final dayName = dayNames[weekday] ?? 'Pazar';

    // Güneş doğuş ve batış vakitlerini enlem ve yılın gününe göre hesapla
    final dayOfYear = int.parse(
      now.difference(DateTime(now.year, 1, 1)).inDays.toString(),
    );
    final sunTimes = _calculateSunriseSunset(now.year, now.month, now.day, latitude, longitude, dayOfYear);
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    // Gece süresi (Bugünün batışından yarının doğuşuna kadar)
    final tomorrowSunrise = sunrise.add(const Duration(days: 1));
    final dayDuration = sunset.difference(sunrise);
    final nightDuration = tomorrowSunrise.difference(sunset);

    final dayHourDuration = Duration(milliseconds: (dayDuration.inMilliseconds / 12).round());
    final nightHourDuration = Duration(milliseconds: (nightDuration.inMilliseconds / 12).round());

    // Keldani dizisindeki başlangıç indeksini bul
    int planetIndex = chaldeanOrder.indexOf(dayRuler);
    final List<PlanetaryHour> hours = [];
    PlanetaryHour? activeHour;

    // 12 Gündüz Saati
    for (int i = 0; i < 12; i++) {
      final startTime = sunrise.add(dayHourDuration * i);
      final endTime = sunrise.add(dayHourDuration * (i + 1));
      final pName = chaldeanOrder[planetIndex % chaldeanOrder.length];
      final isCurrent = now.isAfter(startTime) && now.isBefore(endTime);

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

      hours.add(hour);
      if (isCurrent) activeHour = hour;
      planetIndex++;
    }

    // 12 Gece Saati
    for (int i = 0; i < 12; i++) {
      final startTime = sunset.add(nightHourDuration * i);
      final endTime = sunset.add(nightHourDuration * (i + 1));
      final pName = chaldeanOrder[planetIndex % chaldeanOrder.length];
      final isCurrent = now.isAfter(startTime) && now.isBefore(endTime);

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

      hours.add(hour);
      if (isCurrent) activeHour = hour;
      planetIndex++;
    }

    // Aktif saat bulunamadıysa (örneğin gün doğumu öncesi) en yakın saati seç
    activeHour ??= hours.firstWhere(
      (h) => now.isBefore(h.endTime),
      orElse: () => hours.first,
    );

    return PlanetaryDayInfo(
      dayName: dayName,
      dayRulerPlanet: dayRuler,
      dayRulerSymbol: planetSymbols[dayRuler] ?? '✨',
      sunriseFormatted: _formatTime(sunrise),
      sunsetFormatted: _formatTime(sunset),
      currentHour: activeHour,
      allHours: hours,
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static Map<String, DateTime> _calculateSunriseSunset(
    int year,
    int month,
    int day,
    double lat,
    double lng,
    int dayOfYear,
  ) {
    // Güneş sapma açısı (Solar Declination)
    final declination = 23.45 * sin((2 * pi / 365.0) * (dayOfYear - 81));
    final latRad = lat * pi / 180.0;
    final decRad = declination * pi / 180.0;

    // Saat açısı (Hour Angle)
    double cosHA = -tan(latRad) * tan(decRad);
    if (cosHA > 1.0) cosHA = 1.0;
    if (cosHA < -1.0) cosHA = -1.0;
    final haDeg = acos(cosHA) * 180.0 / pi;
    final dayLengthHours = (haDeg * 2.0) / 15.0;

    // Yerel Güneş Saati Düzeltmesi (Merkez 12:00)
    final solarNoon = 12.0;
    final riseHourDec = solarNoon - (dayLengthHours / 2.0);
    final setHourDec = solarNoon + (dayLengthHours / 2.0);

    final riseHour = riseHourDec.floor();
    final riseMinute = ((riseHourDec - riseHour) * 60).round();

    final setHour = setHourDec.floor();
    final setMinute = ((setHourDec - setHour) * 60).round();

    return {
      'sunrise': DateTime(year, month, day, riseHour, riseMinute),
      'sunset': DateTime(year, month, day, setHour, setMinute),
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
