import 'dart:math' as math;
import 'astrology_engine.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';
import 'world_cities_service.dart';

/// Tüm öngörü metotlarını (Solar Return, Lunar Return, Solar Arc, Secondary Progressions,
/// Zodiacal Releasing, Firdaria ve Profection) kullanıcının gerçek doğum bilgilerine,
/// dünya genelindeki koordinatlara (enlem, boylam, zaman dilimi) ve astronomik
/// ephemeris kanunlarına göre dinamik olarak hesaplayan evrensel servis.
class PredictiveAstrologyService {
  // --- Zodyak İsimleri ve Sembolleri ---
  static const List<String> zodiacSigns = AstrologyEngine.zodiacSigns;

  static const List<String> zodiacSymbols = [
    '♈', '♉', '♊', '♋', '♌', '♍',
    '♎', '♏', '♐', '♑', '♒', '♓'
  ];

  static const Map<String, int> signIndices = {
    'Koç': 0, 'Boğa': 1, 'İkizler': 2, 'Yengeç': 3,
    'Aslan': 4, 'Başak': 5, 'Terazi': 6, 'Akrep': 7,
    'Yay': 8, 'Oğlak': 9, 'Kova': 10, 'Balık': 11,
  };

  // Helenistik Gezegen Yılları (Minor Planetary Periods - 360 Günlük Mısır Yılı)
  static const Map<String, int> planetaryMinorYears = {
    'Koç': 15,      // Mars
    'Boğa': 8,      // Venüs
    'İkizler': 20,  // Merkür
    'Yengeç': 25,   // Ay
    'Aslan': 19,    // Güneş
    'Başak': 20,    // Merkür
    'Terazi': 8,    // Venüs
    'Akrep': 15,    // Mars
    'Yay': 12,      // Jüpiter
    'Oğlak': 27,    // Satürn
    'Kova': 30,     // Satürn
    'Balık': 12,    // Jüpiter
  };

  // --- YARDIMCI MATEMATİK & ASTRONOMİ METOTLARI ---

  static double _normalize(double deg) {
    deg = deg % 360.0;
    return deg < 0 ? deg + 360.0 : deg;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;

  /// Doğum Tarihini Güvenli Çözümleme
  static DateTime parseBirthDate(String dateStr) {
    if (dateStr.trim().isEmpty) return DateTime(1991, 3, 6);
    try {
      if (dateStr.contains('.')) {
        final p = dateStr.split('.');
        if (p.length >= 3) {
          return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }
      }
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime(1991, 3, 6);
    }
  }

  /// Doğum Saatini Güvenli Çözümleme (0-24 saat, 0-60 dakika)
  static Map<String, int> parseBirthTime(String timeStr) {
    if (timeStr.trim().isEmpty) return {'hour': 12, 'minute': 0};
    try {
      final p = timeStr.split(':');
      final h = p.isNotEmpty ? (int.tryParse(p[0]) ?? 12) : 12;
      final m = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
      return {'hour': h.clamp(0, 23), 'minute': m.clamp(0, 59)};
    } catch (_) {
      return {'hour': 12, 'minute': 0};
    }
  }

  /// Tarihsel Zaman Dilimi & Yaz/Kış Saati (DST) Çözümleyici (Solar Fire Standardı)
  static double getHistoricalUtcOffset({
    required CityLocation cityLoc,
    required DateTime dt,
  }) {
    if (cityLoc.country == 'Türkiye') {
      // 7 Eylül 2016 öncesi Türkiye kışın UTC+2, yazın UTC+3 kullanıyordu:
      if (dt.isBefore(DateTime(2016, 9, 7))) {
        final m = dt.month;
        if (m > 3 && m < 10) return 3.0; // Nisan - Eylül arası yaz saati (+3)
        if (m < 3 || m > 10) return 2.0; // Kasım - Şubat arası kış saati (+2)
        if (m == 3) {
          return dt.day >= 25 ? 3.0 : 2.0; // Mart sonu yaz saatine geçiş
        }
        if (m == 10) {
          return dt.day >= 25 ? 2.0 : 3.0; // Ekim sonu kış saatine dönüş
        }
      }
      return 3.0; // 2016 sonrası kalıcı UTC+3
    }
    return cityLoc.timezoneOffset;
  }

  /// Metinsel Dereceyi Boylama Çevirme ("15°17' Balık" -> 345.283°)
  static double parseDegreeStringToLongitude(String? formatted, String fallbackSign, double fallbackDeg) {
    if (formatted != null && formatted.isNotEmpty) {
      final regex = RegExp(r"(\d+)[°\s]+(\d+)?['\s]*([a-zA-ZğüşıöçĞÜŞİÖÇ]+)?");
      final m = regex.firstMatch(formatted);
      if (m != null) {
        final deg = double.tryParse(m.group(1) ?? '0') ?? 0.0;
        final min = double.tryParse(m.group(2) ?? '0') ?? 0.0;
        final sign = (m.group(3) ?? fallbackSign).trim();
        final idx = signIndices[sign];
        if (idx != null) {
          return idx * 30.0 + deg + min / 60.0;
        }
      }
    }
    final idx = signIndices[fallbackSign] ?? 0;
    return idx * 30.0 + fallbackDeg;
  }

  /// Boylamı Metinsel Dereceye Çevirme (345.283° -> "15° 17' Balık")
  static String formatLongitude(double lon, {bool includeSymbol = false}) {
    lon = _normalize(lon);
    int signIdx = (lon / 30.0).floor() % 12;
    final degInSign = lon % 30.0;
    int deg = degInSign.floor();
    int min = ((degInSign - deg) * 60.0).round();
    if (min == 60) {
      deg += 1;
      min = 0;
      if (deg >= 30) {
        deg = 0;
        signIdx = (signIdx + 1) % 12;
      }
    }
    final signName = zodiacSigns[signIdx];
    final symbol = includeSymbol ? ' ${zodiacSymbols[signIdx]}' : '';
    return '${deg.toString().padLeft(2, '0')}° ${min.toString().padLeft(2, '0')}\'$symbol $signName';
  }

  /// Koordinatlara Göre Astronomik Ascendant (Yükselen) & MC Hesaplama
  static Map<String, double> calculateAscAndMc({
    required DateTime utcDateTime,
    required double latitude,
    required double longitude,
  }) {
    final utc = utcDateTime.toUtc();
    int y = utc.year;
    int m = utc.month;
    final d = utc.day + (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
    final t = (jd - 2451545.0) / 36525.0;

    // Greenwich Mean Sidereal Time (GMST)
    double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0;
    gmst = _normalize(gmst);

    // Local Sidereal Time / RAMC
    final ramc = _normalize(gmst + longitude);

    // Obliquity of Ecliptic
    final eps = 23.439291 - 0.0130042 * t;
    final epsRad = _rad(eps);
    final latRad = _rad(latitude);
    final ramcRad = _rad(ramc);

    // MC Calculation
    double mcRad = math.atan2(math.tan(ramcRad), math.cos(epsRad));
    double mcDeg = _deg(mcRad);
    if (math.cos(ramcRad) < 0) mcDeg += 180.0;
    mcDeg = _normalize(mcDeg);

    // ASC Calculation
    final yCoord = -math.cos(ramcRad);
    final xCoord = math.sin(ramcRad) * math.cos(epsRad) + math.tan(latRad) * math.sin(epsRad);
    double ascDeg = _deg(math.atan2(yCoord, xCoord));
    ascDeg = _normalize(ascDeg + 180.0);

    // Vertex Calculation (Prime Vertical Western Intersection using Co-Latitude)
    final coLat = (90.0 - latitude).clamp(-89.5, 89.5);
    final coLatRad = _rad(coLat);
    final ramcWestRad = _rad(_normalize(ramc + 180.0));
    final vyCoord = -math.cos(ramcWestRad);
    final vxCoord = math.sin(ramcWestRad) * math.cos(epsRad) + math.tan(coLatRad) * math.sin(epsRad);
    double vertexDeg = _deg(math.atan2(vyCoord, vxCoord));
    vertexDeg = _normalize(vertexDeg + 180.0);

    return {
      'asc': ascDeg,
      'mc': mcDeg,
      'vertex': vertexDeg,
      'ramc': ramc,
      'gmst': gmst,
    };
  }

  /// Gezegenin Evini Belirleme (1-12 Ev)
  static int getHouseNumber(double planetLon, double ascLon) {
    final diff = _normalize(planetLon - ascLon);
    return (diff / 30.0).floor() + 1;
  }

  // =========================================================================
  // 1. SOLAR RETURN (GÜNEŞ DÖNÜŞÜ - GÜNEŞ NATAL DERECEYE KİLİTLİ)
  // =========================================================================
  static Map<String, dynamic> calculateSolarReturn({
    required UserProfile profile,
    required String selectedCity,
    String? selectedCountry,
    int? targetYear,
  }) {
    final birthDate = parseBirthDate(profile.birthDate);
    final cityLoc = WorldCitiesService.findCity(selectedCity, selectedCountry);

    // Natal Güneş Boylamı (Kilitli Değer)
    final natalSunLon = parseDegreeStringToLongitude(
      profile.rawChart['sun'],
      profile.sunSign.isNotEmpty ? profile.sunSign : 'Balık',
      15.283,
    );
    final natalSunLabel = formatLongitude(natalSunLon, includeSymbol: true);

    // Hedef Yıl: Kullanıcının içinde bulunduğu veya sıradaki doğum günü dönüşü
    final now = DateTime.now();
    final year = targetYear ?? (now.isAfter(DateTime(now.year, birthDate.month, birthDate.day))
        ? now.year
        : now.year);

    // Dönüş Anı: Transit Güneş'in natal boylama tam kavuştuğu an
    // Güneş her gün ~0.9856° ilerler. Doğum günü civarında hassas eşleşme:
    DateTime returnApprox = DateTime.utc(year, birthDate.month, birthDate.day, 12, 0);
    for (int iter = 0; iter < 5; iter++) {
      final currentSun = SkyTransitsService.calculateSunLongitude(returnApprox);
      double diff = natalSunLon - currentSun;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      final offsetHours = (diff / 0.9856) * 24.0;
      returnApprox = returnApprox.add(Duration(minutes: (offsetHours * 60).round()));
    }

    // Seçilen Şehir Ufkuna Göre Solar ASC & MC
    final angles = calculateAscAndMc(
      utcDateTime: returnApprox,
      latitude: cityLoc.latitude,
      longitude: cityLoc.longitude,
    );

    final solarAsc = angles['asc']!;
    final solarMc = angles['mc']!;
    final solarAscSign = zodiacSigns[(solarAsc / 30.0).floor() % 12];
    final solarAscDeg = (solarAsc % 30.0).floor();
    final solarAscMin = (((solarAsc % 30.0) - solarAscDeg) * 60.0).round();
    final solarAscStr = '$solarAscSign ${zodiacSymbols[(solarAsc / 30.0).floor() % 12]} ${solarAscDeg.toString().padLeft(2, '0')}° ${solarAscMin.toString().padLeft(2, '0')}\'';

    final sunHouse = getHouseNumber(natalSunLon, solarAsc);

    final Map<int, String> sunHouseThemes = {
      1: 'Kişisel Parlama, Sağlık & Kendini Baştan Yaratma Yılı',
      2: 'Finansal Büyüme, Özdeğer & Maddi Temelleri Güçlendirme Yılı',
      3: 'İletişim Trafiği, Eğitim, Sözleşmeler & Yakın Çevre Atılımları',
      4: 'Kökler, Aile, Gayrimenkul & İçsel Güvenlik İnşa Yılı',
      5: 'Yaratıcı Zirve, Aşk, Sahneye Çıkış & Eser Üretme Yılı',
      6: 'Üretkenlik, Çalışma Disiplini, Sağlık & Günlük Düzen Yılı',
      7: 'İkili İlişkiler, Evlilik, Ortaklıklar & Anlaşmalar Yılı',
      8: 'Köklü Dönüşüm, Ortak Finans, Miras & Sezgisel Simya Yılı',
      9: 'Uzak Ufuklar, Yurt Dışı, Akademik Vizyon & Hayat Felsefesi Yılı',
      10: 'Kariyer Zirvesi, Toplumsal Statü & Mesleki Liderlik Yılı',
      11: 'Büyük Gelecek Vizyonları, İttifaklar & Topluluk Başarısı Yılı',
      12: 'Manevi Hazırlık, Arınma, Bilinçaltı Şifası & Büyük Uyanış Yılı',
    };

    final theme = sunHouseThemes[sunHouse] ?? 'Dönüşüm ve Gelişim Yılı';

    final localReturnTime = returnApprox.add(Duration(minutes: (cityLoc.timezoneOffset * 60).round()));
    final dateStr = '${localReturnTime.day} ${_turkishMonthName(localReturnTime.month)} ${localReturnTime.year}';

    return {
      'returnYear': year,
      'cityLabel': '${cityLoc.city}, ${cityLoc.country}',
      'returnDate': dateStr,
      'ascSign': solarAscStr,
      'themeTitle': theme,
      'sunHouse': '$sunHouse. Ev (${_houseName(sunHouse)})',
      'sunHouseDesc': 'Güneş, doğum haritanızdaki tam derece ve dakikasında ($natalSunLabel) kilitli korunarak $selectedCity ufkunda $sunHouse. eve yerleşmiştir. $year yılı Solar ASC $solarAscStr olarak hesaplanmıştır. $theme kapsamında bu yaşam sahası bir yıl boyunca odak noktanız olacaktır.',
      'relocationNote': '$selectedCity (${cityLoc.latitude.toStringAsFixed(1)}° ${cityLoc.latitude >= 0 ? "K" : "G"}, ${cityLoc.longitude.toStringAsFixed(1)}° ${cityLoc.longitude >= 0 ? "D" : "B"}) koordinatlarında Solar ASC $solarAscStr ve Kilitli Güneş $sunHouse. evdedir.',
      'natalSunLabel': natalSunLabel,
      'aspects': [
        {
          'title': 'Solar Güneş: $natalSunLabel (Kilitli Natal Çapa)',
          'tag': 'Sabit Derece ★',
          'desc': 'Güneş, doğum haritanızdaki derece ve dakikasında sabit tutulur. Solar dönüş, Güneş bu noktaya saniyesi saniyesine ulaştığında başlar.',
        },
        {
          'title': 'Solar Yükselen (ASC): $solarAscStr',
          'tag': 'Yıllık Aura & Rota',
          'desc': '$selectedCity koordinatlarına göre hesaplanan yıllık yükselen enerjisi bir yıl boyunca dış dünyayı karşılama tarzınızı belirler.',
        },
        {
          'title': 'Solar $sunHouse. Ev: Güneş Yerleşimi',
          'tag': 'Ana Odak Alanı',
          'desc': 'Güneş\'in Solar haritanızdaki $sunHouse. ev konumu, bu yıl en çok enerji harcayacağınız ve en büyük görünürlüğü kazanacağınız hayat alanıdır.',
        },
        {
          'title': 'Solar Tepe Noktası (MC): ${formatLongitude(solarMc)}',
          'tag': 'Kariyer & Hedefler',
          'desc': 'Yıllık mesleki hedeflerinizi ve toplumsal statü rotanızı belirleyen Solar meridyen aksı.',
        },
      ],
    };
  }

  // =========================================================================
  // PLACIDUS EV SİSTEMİ & KISTIRILMIŞ BURÇLAR (INTERCEPTED SIGNS) & MEZHEP (SECT)
  // =========================================================================

  /// Gündüz Haritası (Diurnal) veya Gece Haritası (Nocturnal) Tespiti
  /// Güneş ufkun üzerindeyse (ASC-DSC aksının üstünde, 7-12. evler): Gündüz Haritası
  /// Güneş ufkun altındaysa (1-6. evler): Gece Haritası
  static bool isDayChart(UserProfile profile) {
    final birthDate = parseBirthDate(profile.birthDate);
    final timeParts = parseBirthTime(profile.birthTime);
    final birthCity = profile.birthCity.isNotEmpty ? profile.birthCity : 'Datça';
    final cityLoc = WorldCitiesService.findCity(birthCity, profile.birthCountry);
    final birthOffset = getHistoricalUtcOffset(cityLoc: cityLoc, dt: birthDate);
    
    final utcDateTime = DateTime.utc(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      timeParts['hour']!,
      timeParts['minute']!,
    ).subtract(Duration(minutes: (birthOffset * 60).round()));
    
    final angles = calculateAscAndMc(utcDateTime: utcDateTime, latitude: cityLoc.latitude, longitude: cityLoc.longitude);
    final asc = angles['asc']!;
    
    final natalSunLon = parseDegreeStringToLongitude(profile.rawChart['sun'], profile.sunSign.isNotEmpty ? profile.sunSign : 'Balık', 15.283);
    final diff = _normalize(natalSunLon - asc);
    return diff >= 180.0;
  }

  /// Placidus Ev Sistemi ve Kıstırılmış Burçlar (Intercepted Signs) Hesaplaması
  static Map<String, dynamic> calculatePlacidusHouses({required UserProfile profile}) {
    final birthDate = parseBirthDate(profile.birthDate);
    final timeParts = parseBirthTime(profile.birthTime);
    final birthCity = profile.birthCity.isNotEmpty ? profile.birthCity : 'Datça';
    final cityLoc = WorldCitiesService.findCity(birthCity, profile.birthCountry);
    final birthOffset = getHistoricalUtcOffset(cityLoc: cityLoc, dt: birthDate);

    final utcDateTime = DateTime.utc(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      timeParts['hour']!,
      timeParts['minute']!,
    ).subtract(Duration(minutes: (birthOffset * 60).round()));

    final angles = calculateAscAndMc(
      utcDateTime: utcDateTime,
      latitude: cityLoc.latitude,
      longitude: cityLoc.longitude,
    );

    final double ramc = angles['ramc']!;
    final double asc = angles['asc']!;
    final double mc = angles['mc']!;
    final double latRad = _rad(cityLoc.latitude);

    // Ecliptic Obliquity
    final utc = utcDateTime.toUtc();
    int y = utc.year;
    int m = utc.month;
    final d = utc.day + (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
    if (m <= 2) { y -= 1; m += 12; }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
    final t = (jd - 2451545.0) / 36525.0;
    final double eps = 23.439291 - 0.0130042 * t;
    final double epsRad = _rad(eps);

    double solveCusp(double baseOffset, double factor) {
      final double rDeg = _normalize(ramc + baseOffset);
      double alpha = _rad(rDeg);
      for (int iter = 0; iter < 25; iter++) {
        final tanDelta = math.sin(alpha) * math.tan(epsRad);
        double sinAd = tanDelta * math.tan(latRad);
        sinAd = sinAd.clamp(-0.9999, 0.9999);
        final ad = math.asin(sinAd);
        final alphaNext = _rad(rDeg) + factor * ad;
        if ((alphaNext - alpha).abs() < 1e-7) {
          alpha = alphaNext;
          break;
        }
        alpha = alphaNext;
      }
      final lam = _deg(math.atan2(math.sin(alpha), math.cos(alpha) * math.cos(epsRad)));
      return _normalize(lam);
    }

    final c11 = solveCusp(30.0, 1.0 / 3.0);
    final c12 = solveCusp(60.0, 2.0 / 3.0);
    final c2 = solveCusp(120.0, 2.0 / 3.0);
    final c3 = solveCusp(150.0, 1.0 / 3.0);

    final c1 = asc;
    final c10 = mc;
    final c7 = _normalize(c1 + 180.0);
    final c4 = _normalize(c10 + 180.0);
    final c5 = _normalize(c11 + 180.0);
    final c6 = _normalize(c12 + 180.0);
    final c8 = _normalize(c2 + 180.0);
    final c9 = _normalize(c3 + 180.0);

    final Map<int, double> cusps = {
      1: c1, 2: c2, 3: c3, 4: c4, 5: c5, 6: c6,
      7: c7, 8: c8, 9: c9, 10: c10, 11: c11, 12: c12,
    };

    final Map<int, String> cuspFormatted = {};
    final Map<int, String> cuspSigns = {};
    final Map<int, double> cuspSpans = {};
    final Map<int, int> signCounts = {for (var i = 0; i < 12; i++) i: 0};

    for (int h = 1; h <= 12; h++) {
      final lon = cusps[h]!;
      final sIdx = (lon / 30.0).floor() % 12;
      signCounts[sIdx] = (signCounts[sIdx] ?? 0) + 1;
      cuspSigns[h] = zodiacSigns[sIdx];
      cuspFormatted[h] = formatLongitude(lon, includeSymbol: true);

      final nextH = h == 12 ? 1 : h + 1;
      cuspSpans[h] = _normalize(cusps[nextH]! - cusps[h]!);
    }

    // Kıstırılmış Burç Tespiti (Intercepted Signs)
    // Hiçbir ev girişini (cusp) kesmeyen burçlar
    final List<Map<String, dynamic>> interceptedSigns = [];
    final Map<String, String> interceptedInterpretations = {
      'Koç': 'Benlik, inisiyatif alma ve cesaret temaları bilinçdışında saklıdır. Kendini doğrudan ortaya koymakta zorlanabilir ancak kriz anlarında muazzam bir içsel güç açığa çıkar.',
      'Boğa': 'Maddi güvenlik, özdeğer ve bedensel huzur içsel bir arayıştır. Dış dünyada gösterilmeyen güçlü bir dayanıklılık ve gizli bir finansal sağduyu barındırır.',
      'İkizler': 'Zihinsel merak ve iletişim derin bir iç diyalog şeklinde çalışır. Dışarıya konuşulmayan, içeride sürekli işleyen devasa bir bilgi havuzu mevcuttur.',
      'Yengeç': 'Duygusal savunmasızlık ve kökler derinlere kilitlenmiştir. Dışarıya sert veya mesafeli görünse de iç dünyasında okyanuslar kadar derin bir şefkat saklar.',
      'Aslan': 'Yaratıcı ışıltı ve sahne arzusu gizli bir volkan gibidir. Onaylanma ihtiyacı dışarıdan ziyade içsel bir öz-saygı yolculuğuna dönüşür.',
      'Başak': 'Kusursuzluk, analiz ve hizmet bilinci içsel bir muhasebeye dönüşür. Hayatı görünmeyen detaylarda titizlikle inşa etme yeteneği sağlar.',
      'Terazi': 'İkili ilişkiler, adalet ve diplomasi derin bir denge arayışıdır. Başkalarına bağımlı olmadan kendi içinde mutlak uyumu bulmayı öğrenir.',
      'Akrep': 'Dönüşüm, tutku ve sezgisel simya tamamen gizli katmanlarda yaşanır. Küllerinden doğma gücü olağanüstüdür ama bunu kimseye belli etmez.',
      'Yay': 'Hayat felsefesi, manevi inançlar ve büyük vizyonlar kişisel bir tapınak gibi içeride inşa edilir. Dogmalara değil, bizzat keşfedilen hakikate inanır.',
      'Oğlak': 'Kariyer, disiplin ve otorite kurma arzusu sessiz ve derinden ilerler. Başarı hırsını bağırmaz, zamanı geldiğinde zirveye kalıcı taşlar döşer.',
      'Kova': 'Kolektif vizyonlar, özgünlük ve devrimci fikirler iç dünyada olgunlaşır. Sıradışı dehasını kitlelerin onayına sunmadan bağımsızca yaşar.',
      'Balık': 'Manevi teslimiyet, sezgisel kanallık ve evrensel sevgi bilinçaltının derin sularında saklanır. Dünyanın karmaşasından kaçılan kutsal bir sığınaktır.',
    };

    for (int sIdx = 0; sIdx < 12; sIdx++) {
      if ((signCounts[sIdx] ?? 0) == 0) {
        final signName = zodiacSigns[sIdx];
        final signCenter = _normalize(sIdx * 30.0 + 15.0);
        int containedHouse = 1;

        for (int h = 1; h <= 12; h++) {
          final hStart = cusps[h]!;
          final nextH = h == 12 ? 1 : h + 1;
          final hEnd = cusps[nextH]!;
          final span = _normalize(hEnd - hStart);
          final diff = _normalize(signCenter - hStart);
          if (diff < span) {
            containedHouse = h;
            break;
          }
        }

        final oppositeSignIdx = (sIdx + 6) % 12;
        final oppositeSign = zodiacSigns[oppositeSignIdx];
        final oppositeHouse = ((containedHouse + 5) % 12) + 1;

        interceptedSigns.add({
          'sign': signName,
          'symbol': zodiacSymbols[sIdx],
          'house': containedHouse,
          'oppositeSign': oppositeSign,
          'oppositeHouse': oppositeHouse,
          'desc': interceptedInterpretations[signName] ?? 'İçsel potansiyel olarak saklı enerjiler.',
        });
      }
    }

    final List<String> duplicatedSigns = [];
    signCounts.forEach((sIdx, count) {
      if (count > 1) {
        duplicatedSigns.add(zodiacSigns[sIdx]);
      }
    });

    // Harita Mezhebi (Sect - Gündüz / Gece)
    final natalSunLon = parseDegreeStringToLongitude(profile.rawChart['sun'], profile.sunSign.isNotEmpty ? profile.sunSign : 'Balık', 15.283);
    final diffSunAsc = _normalize(natalSunLon - asc);
    final bool isDay = diffSunAsc >= 180.0;

    return {
      'cusps': cusps,
      'cuspSigns': cuspSigns,
      'cuspFormatted': cuspFormatted,
      'cuspSpans': cuspSpans,
      'interceptedSigns': interceptedSigns,
      'duplicatedSigns': duplicatedSigns,
      'isDayChart': isDay,
      'sectName': isDay ? 'Gündüz Haritası (Diurnal Sect)' : 'Gece Haritası (Nocturnal Sect)',
      'sectLight': isDay ? 'Güneş ☉' : 'Ay ☽',
      'sectBenefic': isDay ? 'Jüpiter ♃ (Baş İyicil)' : 'Venüs ♀\uFE0E (Baş İyicil)',
      'sectMalefic': isDay ? 'Mars ♂\uFE0E (Zorlayıcı / Gece Fıtratı)' : 'Satürn ♄ (Zorlayıcı / Gündüz Fıtratı)',
      'sectDescription': isDay
          ? 'Güneş doğum anınızda ufkun üzerinde (Gündüz) parlamaktadır. Yaşamın ana motifi bilinçli irade, dış dünyada görünürlük, liderlik ve somut başarılar üzerine kuruludur. Haritanızın temel ışığı Güneş, en büyük koruyucu rehberi Jüpiter\'dir.'
          : 'Güneş doğum anınızda ufkun altında (Gece) dinlenmektedir. Yaşamın ana motifi sezgisel zeka, derin duygusal bağlar, içsel keşifler ve ruhsal derinlik üzerine kuruludur. Haritanızın temel ışığı Ay, en büyük koruyucu rehberi Venüs\'tür.',
    };
  }

  // =========================================================================
  // 2. LUNAR RETURN (AY DÖNÜŞÜ - AY NATAL DERECEYE KİLİTLİ)
  // =========================================================================
  static Map<String, dynamic> calculateLunarReturn({
    required UserProfile profile,
    required String selectedCity,
    String? selectedCountry,
    DateTime? targetDate,
  }) {
    final cityLoc = WorldCitiesService.findCity(selectedCity, selectedCountry);

    // Natal Ay Boylamı (Kilitli Değer)
    final natalMoonLon = parseDegreeStringToLongitude(
      profile.rawChart['moon'],
      profile.moonSign.isNotEmpty ? profile.moonSign : 'Akrep',
      9.533,
    );
    final natalMoonLabel = formatLongitude(natalMoonLon, includeSymbol: true);

    // İçinde bulunulan ayın döngüsü
    final now = targetDate ?? DateTime.now();

    // Ay her ~27.3216 günde bir aynı boylama döner.
    // Şimdiki zamana en yakın veya sıradaki dönüşü bul:
    DateTime returnApprox = now.toUtc();
    double currentMoon = SkyTransitsService.calculateMoonLongitude(returnApprox);
    double diff = _normalize(natalMoonLon - currentMoon);
    // Ay günde ~13.176° ilerler:
    double daysToReturn = diff / 13.17635;
    if (daysToReturn > 27.3) daysToReturn -= 27.3216;
    returnApprox = returnApprox.add(Duration(minutes: (daysToReturn * 24.0 * 60.0).round()));

    // Hassas eşleşme iterasyonu:
    for (int iter = 0; iter < 4; iter++) {
      final lon = SkyTransitsService.calculateMoonLongitude(returnApprox);
      double d = natalMoonLon - lon;
      if (d > 180) d -= 360;
      if (d < -180) d += 360;
      final hours = (d / 13.17635) * 24.0;
      returnApprox = returnApprox.add(Duration(minutes: (hours * 60.0).round()));
    }

    // Seçilen Şehir Ufkuna Göre Lunar ASC & MC
    final angles = calculateAscAndMc(
      utcDateTime: returnApprox,
      latitude: cityLoc.latitude,
      longitude: cityLoc.longitude,
    );

    final lunarAsc = angles['asc']!;
    final lunarMc = angles['mc']!;
    final lunarAscSign = zodiacSigns[(lunarAsc / 30.0).floor() % 12];
    final lunarAscDeg = (lunarAsc % 30.0).floor();
    final lunarAscMin = (((lunarAsc % 30.0) - lunarAscDeg) * 60.0).round();
    final lunarAscStr = '$lunarAscSign ${zodiacSymbols[(lunarAsc / 30.0).floor() % 12]} ${lunarAscDeg.toString().padLeft(2, '0')}° ${lunarAscMin.toString().padLeft(2, '0')}\'';

    final moonHouse = getHouseNumber(natalMoonLon, lunarAsc);

    final Map<int, String> moonHouseThemes = {
      1: 'Duygusal Yenilenme, Kişisel İhtiyaçlar & Sezgisel Canlılık',
      2: 'Finansal Güvenlik, Özdeğer & Maddi Konularda Netleşme',
      3: 'Zihinsel İletişim, Sözleşmeler, Anlaşmalar & Yakın Çevre Trafiği',
      4: 'Ev, Yuva, Aile Bağları & İçsel Sığınak Huzuru',
      5: 'Yaratıcı İlham, Aşk, Hobiler & Kalbin Sesini Dinleme',
      6: 'Günlük Rutinler, Sağlık, Beslenme & İş Disiplini',
      7: 'İkili İlişkilerde Uyum, Ortaklıklar & Diplomasi',
      8: 'Psikolojik Derinlik, Sezgisel Simya & Ortak Kaynaklar',
      9: 'Uzak Vizyonlar, Seyahatler, Yüksek Eğitim & Felsefe',
      10: 'Kariyer Otoritesi, Prestij, Başarı & Mesleki Sorumluluklar',
      11: 'Gelecek Planları, Sosyal Ağlar & Kolektif Vizyon Hedefleri',
      12: 'Ruhsal Arınma, Bilinçaltı Detoksu & Dingin Meditasyon',
    };

    final theme = moonHouseThemes[moonHouse] ?? 'Aylık Duygusal Döngü';

    final localReturnTime = returnApprox.add(Duration(minutes: (cityLoc.timezoneOffset * 60).round()));
    final dateStr = '${localReturnTime.day} ${_turkishMonthName(localReturnTime.month)} ${localReturnTime.year}';

    return {
      'cityLabel': '${cityLoc.city}, ${cityLoc.country}',
      'returnDate': dateStr,
      'ascSign': lunarAscStr,
      'themeTitle': theme,
      'moonHouse': '$moonHouse. Ev (${_houseName(moonHouse)})',
      'moonHouseDesc': 'Ay döngünüz $dateStr tarihinde yenilenmektedir. Doğum haritanızdaki sabit Ayınız ($natalMoonLabel) derece ve dakikasına kilitli tutulurken, $selectedCity ufkunda Lunar ASC $lunarAscStr olarak hesaplanmıştır. Kilitli Ay $moonHouse. eve oturarak bu 27.3 günlük dönemde duygusal önceliklerinizi bu hayat sahasına taşır.',
      'relocationNote': '$selectedCity ufkunda $dateStr döngüsü için Lunar ASC $lunarAscStr ve kilitli Ay $moonHouse. evdedir.',
      'natalMoonLabel': natalMoonLabel,
      'aspects': [
        {
          'title': 'Doğum Ayı: $natalMoonLabel (Kilitli Natal Çapa)',
          'tag': 'Sabit Derece ★',
          'desc': 'Ay, doğum haritanızdaki tam derece ve dakikasında sabit kilitlidir. Transit Ay bu dereceye ulaştığı anda 27.3 günlük yeni döngü başlar.',
        },
        {
          'title': 'Lunar Yükselen (ASC): $lunarAscStr',
          'tag': 'Aylık Psikolojik Filtre',
          'desc': 'Bu ay dış dünyayı karşılama enerjiniz ve psikolojik tepkileriniz $lunarAscSign burcunun doğasıyla şekillenir.',
        },
        {
          'title': 'Lunar $moonHouse. Ev: Ay Konumu',
          'tag': 'Duygusal Odak',
          'desc': 'Ay\'ın Lunar haritadaki $moonHouse. ev yerleşimi, önümüzdeki ay boyunca en çok doyum ve güvence arayacağınız alandır.',
        },
        {
          'title': 'Lunar Tepe Noktası (MC): ${formatLongitude(lunarMc)}',
          'tag': 'Aylık Hedefler',
          'desc': 'Bu 27 günlük periyotta mesleki ve sosyal duruşunuzu yönlendiren zirve aksı.',
        },
      ],
    };
  }

  // =========================================================================
  // 3. SOLAR ARC DIRECTIONS (GÜNEŞ YAYI YÖNELİMİ)
  // =========================================================================
  static Map<String, dynamic> calculateSolarArc({
    required UserProfile profile,
    DateTime? targetDate,
  }) {
    final birthDate = parseBirthDate(profile.birthDate);
    final now = targetDate ?? DateTime.now();

    final double age = now.difference(birthDate).inDays / 365.2422;
    // Gerçek Astronomik Güneş Yayı Oranı (~0.9868° / Yıl):
    final double arcTotal = age * 0.986847;

    final arcDeg = arcTotal.floor();
    final arcMin = ((arcTotal - arcDeg) * 60.0).round();
    final arcStr = '+${arcDeg.toString().padLeft(2, '0')}° ${arcMin.toString().padLeft(2, '0')}\'';

    final natalSunLon = parseDegreeStringToLongitude(profile.rawChart['sun'], profile.sunSign.isNotEmpty ? profile.sunSign : 'Balık', 15.0);
    final natalMoonLon = parseDegreeStringToLongitude(profile.rawChart['moon'], profile.moonSign.isNotEmpty ? profile.moonSign : 'Akrep', 15.0);
    final natalAscLon = parseDegreeStringToLongitude(profile.rawChart['rising'] ?? profile.rawChart['ascendant'], profile.risingSign.isNotEmpty ? profile.risingSign : 'İkizler', 15.0);
    final natalMcLon = parseDegreeStringToLongitude(profile.rawChart['mc'], 'Kova', 15.0);

    final dirSunLon = _normalize(natalSunLon + arcTotal);
    final dirMoonLon = _normalize(natalMoonLon + arcTotal);
    final dirAscLon = _normalize(natalAscLon + arcTotal);
    final dirMcLon = _normalize(natalMcLon + arcTotal);

    return {
      'age': age,
      'arcFormatted': arcStr,
      'dirSunFormatted': formatLongitude(dirSunLon),
      'dirMoonFormatted': formatLongitude(dirMoonLon),
      'dirAscFormatted': formatLongitude(dirAscLon),
      'dirMcFormatted': formatLongitude(dirMcLon),
      'aspects': [
        {
          'aspect': 'Solar Arc Güneş: ${formatLongitude(dirSunLon)}',
          'tag': 'Bilinç & İrade İlerlemesi',
          'desc': 'Doğum Güneşiniz $arcStr ilerleyerek ${formatLongitude(dirSunLon)} derecesine ulaşmıştır. Yaşam vizyonunuzda ve büyük ideallerinizde öncü adımlar tetiklenir.',
        },
        {
          'aspect': 'Solar Arc Ay: ${formatLongitude(dirMoonLon)}',
          'tag': 'Duygusal & İlişki Genişlemesi',
          'desc': 'Doğum Ayınız $arcStr yönelerek ${formatLongitude(dirMoonLon)} konumuna gelmiştir. İkili ilişkiler, ortaklıklar ve içsel doyum alanında büyük açılımlar gerçekleşir.',
        },
        {
          'aspect': 'Solar Arc MC: ${formatLongitude(dirMcLon)}',
          'tag': 'Kariyer & Statü Eşiği',
          'desc': 'Kariyer tepe noktanız $arcStr ilerlemiştir. Mesleki alanda kalıcı eserler bırakma, otorite kazanma ve kurumsal liderlik zamanlamasıdır.',
        },
        {
          'aspect': 'Solar Arc ASC: ${formatLongitude(dirAscLon)}',
          'tag': 'Kişisel Aura & Karizma',
          'desc': 'Yükselen noktanızın $arcStr yönelimiyle dış dünyadaki duruşunuz, fiziksel enerjiniz ve sosyal prestijiniz güçlenir.',
        },
      ],
    };
  }

  // =========================================================================
  // 4. SECONDARY PROGRESSIONS (İKİNCİL İLERLETİM - 1 GÜN = 1 YIL / SOLAR FIRE ENTEGRASYONU)
  // =========================================================================
  static Map<String, dynamic> calculateSecondaryProgressions({
    required UserProfile profile,
    DateTime? targetDate,
  }) {
    final birthDate = parseBirthDate(profile.birthDate);
    final birthTimeMap = parseBirthTime(profile.birthTime);
    final birthCity = profile.birthCity.isNotEmpty ? profile.birthCity : 'Datça';
    final cityLoc = WorldCitiesService.findCity(birthCity, profile.birthCountry);

    // 1. Doğum UTC Zamanı (Tarihsel Yaz/Kış Saati Hassasiyeti):
    final birthOffset = getHistoricalUtcOffset(cityLoc: cityLoc, dt: birthDate);
    final birthUtc = DateTime.utc(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      birthTimeMap['hour']!,
      birthTimeMap['minute']!,
    ).subtract(Duration(minutes: (birthOffset * 60).round()));

    // 2. Hedef Tarih (Güncel Zaman veya Seçilen Tarih):
    final now = targetDate ?? DateTime.now();
    final nowOffset = getHistoricalUtcOffset(cityLoc: cityLoc, dt: now);
    final nowUtc = (now.isUtc
            ? now
            : DateTime.utc(
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute,
                now.second,
              ))
        .subtract(Duration(minutes: (nowOffset * 60).round()));

    // 3. Yaş (Tropikal Yıl = 365.242199 Gün):
    final double diffSeconds = nowUtc.difference(birthUtc).inSeconds.toDouble();
    const double secondsPerYear = 365.242199 * 86400.0;
    final double age = diffSeconds / secondsPerYear;

    // 4. İlerletilmiş Tarih (Secondary Progression: 1 Gün = 1 Yıl):
    final int progMicroseconds = (age * 86400.0 * 1000000.0).round();
    final progUtc = birthUtc.add(Duration(microseconds: progMicroseconds));

    // 5. Doğum ve İlerletilmiş Göksel Efemeris Konumları:
    final double natalSunLon = SkyTransitsService.calculateSunLongitude(birthUtc);
    final double progSunLon = SkyTransitsService.calculateSunLongitude(progUtc);
    final double progMoonLon = SkyTransitsService.calculateMoonLongitude(progUtc);

    // 6. Doğum MC ve ASC Konumları (Placidus & Küresel Trigonometri):
    final natalHouses = calculateAscAndMc(
      utcDateTime: birthUtc,
      latitude: cityLoc.latitude,
      longitude: cityLoc.longitude,
    );
    final double natalMcLon = natalHouses['mc']!;

    // 7. Solar Fire Uyumlu İlerletilmiş Açılar (Solar Arc in Longitude Metodu):
    // İlerletilmiş MC = Doğum MC + (İlerletilmiş Güneş - Doğum Güneş)
    final double solarArcLon = _normalize(progSunLon - natalSunLon);
    final double progMcLon = _normalize(natalMcLon + solarArcLon);

    // İlerletilmiş MC'den Küresel Trigonometri ile RAMC ve Progressed ASC Hesabı:
    int yProg = progUtc.year;
    int mProg = progUtc.month;
    final dProg = progUtc.day + (progUtc.hour + progUtc.minute / 60.0 + progUtc.second / 3600.0) / 24.0;
    if (mProg <= 2) {
      yProg -= 1;
      mProg += 12;
    }
    final aProg = (yProg / 100).floor();
    final bProg = 2 - aProg + (aProg / 4).floor();
    final jdProg = (365.25 * (yProg + 4716)).floor() + (30.6001 * (mProg + 1)).floor() + dProg + bProg - 1524.5;
    final tProg = (jdProg - 2451545.0) / 36525.0;
    final double epsProg = 23.439291 - 0.0130042 * tProg;
    final double epsRad = _rad(epsProg);
    final double mcRad = _rad(progMcLon);
    final double ramcRad = math.atan2(math.sin(mcRad) * math.cos(epsRad), math.cos(mcRad));

    final double latRad = _rad(cityLoc.latitude);
    final double yCoord = -math.cos(ramcRad);
    final double xCoord = math.sin(ramcRad) * math.cos(epsRad) + math.tan(latRad) * math.sin(epsRad);
    final double progAscLon = _normalize(_deg(math.atan2(yCoord, xCoord)) + 180.0);

    // Burç, Derece ve Dakika Ayrıştırma (Solar Fire Standardı & 60' Yuvarlama Koruması):
    Map<String, dynamic> parseProgCoord(double lon) {
      lon = _normalize(lon);
      int sIdx = (lon / 30.0).floor() % 12;
      double degInSign = lon % 30.0;
      int deg = degInSign.floor();
      int min = ((degInSign - deg) * 60.0).round();
      if (min == 60) {
        deg += 1;
        min = 0;
        if (deg >= 30) {
          deg = 0;
          sIdx = (sIdx + 1) % 12;
        }
      }
      final sign = zodiacSigns[sIdx];
      return {
        'sign': sign,
        'deg': deg,
        'min': min,
        'formatted': '$sign ${deg.toString().padLeft(2, '0')}° ${min.toString().padLeft(2, '0')}\'',
      };
    }

    final moonCoord = parseProgCoord(progMoonLon);
    final ascCoord = parseProgCoord(progAscLon);
    final mcCoord = parseProgCoord(progMcLon);
    final sunCoord = parseProgCoord(progSunLon);

    final progMoonSign = moonCoord['sign'] as String;
    final progMoonDeg = moonCoord['deg'] as int;
    final progMoonMin = moonCoord['min'] as int;

    final progAscSign = ascCoord['sign'] as String;
    final progAscDeg = ascCoord['deg'] as int;
    final progAscMin = ascCoord['min'] as int;

    final progMcSign = mcCoord['sign'] as String;
    final progMcDeg = mcCoord['deg'] as int;
    final progMcMin = mcCoord['min'] as int;

    final progSunSign = sunCoord['sign'] as String;
    final progSunDeg = sunCoord['deg'] as int;
    final progSunMin = sunCoord['min'] as int;

    final Map<String, Map<String, String>> progMoonThemes = {
      'Koç': {'tag': 'Bireysellik & Yenilenme', 'desc': 'İçsel bağımsızlık arzusu, yeni bir hayata başlama cesareti ve fevri kararlar. Hayatınızda yepyeni 28 yıllık döngünün tohumlarını atıyorsunuz.'},
      'Boğa': {'tag': 'Maddi Güvenlik & Dinginlik', 'desc': 'Maddi temelleri sağlamlaştırma, somut kazanımlar, huzur ve sabır arayışı. Hızlı koşturmacayı bırakıp kök salma dönemindesiniz.'},
      'İkizler': {'tag': 'Zihinsel Merak & İletişim', 'desc': 'Yeni eğitimler, yoğun iletişim, fikir alışverişleri ve sosyal hareketlilik. Zihninizin bilgiye en açık olduğu 2.5 yıllık dönem.'},
      'Yengeç': {'tag': 'Kökler & Duygusal Derinlik', 'desc': 'Ev, yuva, aile bağları ve çocukluk hatıraları ön planda. Kendi iç kabuğunuza çekilip ruhunuzu şifalandırma safhası.'},
      'Aslan': {'tag': 'Yaratıcılık & Sahneye Çıkış', 'desc': 'Özgüven patlaması, sanatsal ilham, görünür olma arzusu ve kalbinizin coşkusunu dışarı yansıtma zamanı.'},
      'Başak': {'tag': 'Arınma, Düzen & Sağlık', 'desc': 'Fiziksel bedeninize özen gösterme, beslenme disiplini, hayatınızdaki gereksiz yükleri eleme ve titiz çalışma dönemi.'},
      'Terazi': {'tag': 'İlişkiler, Uyum & Evlilik', 'desc': 'Ortaklıklar, evlilik, iş birlikleri ve sosyal ilişkilerde denge arayışı. Yalnızlıktan ziyade "biz" bilincine geçiş evresi.'},
      'Akrep': {'tag': 'Krizler & Derin Dönüşüm', 'desc': 'Psikolojik yüzleşmeler, tutkular, tabuları yıkma ve küllerinden yeniden doğma dönemi. Ruhsal simya safhasındasınız.'},
      'Yay': {'tag': 'Ufuk Genişletme & Vizyon', 'desc': 'Yabancı ülkeler, felsefi inançlar, yüksek eğitim ve özgürleşme isteği. İçsel vizyonunuzun en geniş olduğu dönem.'},
      'Oğlak': {'tag': 'Kariyer Zirvesi & Disiplin', 'desc': 'Toplumsal statü, mesleki başarı, sorumluluklar ve olgunlaşma. Hayatınızın en somut ve kalıcı eserlerini inşa ediyorsunuz.'},
      'Kova': {'tag': 'Özgünlük & Gelecek Vizyonu', 'desc': 'Toplumsal idealler, kolektif projeler, kalıpları kırma ve radikal özgürlük. Sıradışı hedeflere odaklanma safhası.'},
      'Balık': {'tag': 'Manevi Teslimiyet & Arınma', 'desc': 'Ruhsal uyanış, sezgisel yoğunluk, affetme ve 28 yıllık büyük döngüyü tamamlama dönemi. Büyük bir uyanışın eşiğindesiniz.'},
    };

    final currentTheme = progMoonThemes[progMoonSign] ?? {
      'tag': 'Duygusal Evrim',
      'desc': 'İçsel olgunlaşma ve duygusal kimliğin yeni bir faza geçişi.',
    };

    return {
      'age': age,
      'progMoonSign': progMoonSign,
      'progMoonDeg': progMoonDeg,
      'progMoonMin': progMoonMin,
      'progMoonFormatted': moonCoord['formatted'],
      'progAscSign': progAscSign,
      'progAscDeg': progAscDeg,
      'progAscMin': progAscMin,
      'progAscFormatted': ascCoord['formatted'],
      'progMcSign': progMcSign,
      'progMcDeg': progMcDeg,
      'progMcMin': progMcMin,
      'progMcFormatted': mcCoord['formatted'],
      'progSunSign': progSunSign,
      'progSunDeg': progSunDeg,
      'progSunMin': progSunMin,
      'progSunFormatted': sunCoord['formatted'],
      'solarArc': solarArcLon,
      'solarArcFormatted': '+${solarArcLon.toStringAsFixed(2)}°',
      'progDateFormatted': '${progUtc.day.toString().padLeft(2, '0')}.${progUtc.month.toString().padLeft(2, '0')}.${progUtc.year} ${progUtc.hour.toString().padLeft(2, '0')}:${progUtc.minute.toString().padLeft(2, '0')} UTC',
      'currentTheme': currentTheme,
    };
  }

  // =========================================================================
  // 5. ZODIACAL RELEASING (HELENİSTİK BURÇ SALIMI - 360 GÜNLÜK MISIR YILI)
  // =========================================================================
  static Map<String, dynamic> calculateZodiacalReleasing({
    required UserProfile profile,
    DateTime? targetDate,
  }) {
    final birthDate = parseBirthDate(profile.birthDate);
    final now = targetDate ?? DateTime.now();

    // Gündüz / Gece Doğumu Ayrımı (Astronomik Ufuk / Sect Tespiti)
    final bool isDayBirth = isDayChart(profile);

    final natalSunLon = parseDegreeStringToLongitude(profile.rawChart['sun'], profile.sunSign.isNotEmpty ? profile.sunSign : 'Balık', 15.0);
    final natalMoonLon = parseDegreeStringToLongitude(profile.rawChart['moon'], profile.moonSign.isNotEmpty ? profile.moonSign : 'Akrep', 15.0);
    final natalAscLon = parseDegreeStringToLongitude(profile.rawChart['rising'] ?? profile.rawChart['ascendant'], profile.risingSign.isNotEmpty ? profile.risingSign : 'İkizler', 15.0);

    // Ruh Noktası (Lot of Spirit / Pars Spiritus):
    // Gündüz: ASC + Güneş - Ay | Gece: ASC + Ay - Güneş
    final double spiritLon = isDayBirth
        ? _normalize(natalAscLon + natalSunLon - natalMoonLon)
        : _normalize(natalAscLon + natalMoonLon - natalSunLon);

    final int spiritSignIdx = (spiritLon / 30.0).floor() % 12;
    final String spiritSign = zodiacSigns[spiritSignIdx];

    final int elapsedDays = now.difference(birthDate).inDays;
    final double elapsedEgyptianYears = elapsedDays / 360.0;

    // Seviye 1 (L1) Döngülerini Sırayla İlerlet (Tüm Yaşam Çizelgesi ~95 Yıl)
    int currentSignIdx = spiritSignIdx;
    double accumulatedYears = 0.0;
    String l1Sign = spiritSign;
    int l1Duration = planetaryMinorYears[spiritSign]!;
    DateTime l1StartDate = birthDate;
    DateTime l1EndDate = birthDate;
    int activeL1SignIdx = spiritSignIdx;

    // Timeline Listesi
    final List<Map<String, dynamic>> timeline = [];

    // En az 90 Mısır yılı veya 10 büyük döngü boyunca ilerlet (Gelecek döngüler de görünsün)
    const double maxYearsToProject = 90.0;

    while (accumulatedYears < maxYearsToProject) {
      final signName = zodiacSigns[currentSignIdx];
      final years = planetaryMinorYears[signName]!;
      final startDays = (accumulatedYears * 360.0).round();
      final endDays = ((accumulatedYears + years) * 360.0).round();
      final sDate = birthDate.add(Duration(days: startDays));
      final eDate = birthDate.add(Duration(days: endDays));

      // Ruh Noktasına Göre Açı / Pik Tespiti:
      final signDistance = (currentSignIdx - spiritSignIdx + 12) % 12;
      final bool isPeak = (signDistance == 0 || signDistance == 9 || signDistance == 6 || signDistance == 3);
      String peakTag = '';
      if (signDistance == 9) {
        peakTag = 'MAJOR PEAK ★ (Kariyer Zirvesi)';
      } else if (signDistance == 0) {
        peakTag = 'RUH AÇISI (1. Ev Piki)';
      } else if (signDistance == 6) {
        peakTag = 'İLİŞKİ EKSENİ (7. Ev Piki)';
      } else if (signDistance == 3) {
        peakTag = 'KÖK EKSENİ (4. Ev Piki)';
      }

      final bool isCurrentlyActive = (accumulatedYears <= elapsedEgyptianYears && accumulatedYears + years > elapsedEgyptianYears);

      if (isCurrentlyActive) {
        l1Sign = signName;
        l1Duration = years;
        l1StartDate = sDate;
        l1EndDate = eDate;
        activeL1SignIdx = currentSignIdx;
      }

      // Pre-calculate L2 periods for this L1 period:
      final l2Periods = calculateL2Periods(
        l1Sign: signName,
        l1StartDate: sDate,
        l1EndDate: eDate,
        spiritSign: spiritSign,
        targetDate: now,
      );

      timeline.add({
        'sign': signName,
        'symbol': zodiacSymbols[currentSignIdx],
        'years': years,
        'startDate': sDate,
        'endDate': eDate,
        'startDateFormatted': '${sDate.day.toString().padLeft(2, '0')}.${sDate.month.toString().padLeft(2, '0')}.${sDate.year}',
        'endDateFormatted': '${eDate.day.toString().padLeft(2, '0')}.${eDate.month.toString().padLeft(2, '0')}.${eDate.year}',
        'isPeak': isPeak,
        'peakTag': peakTag,
        'isActive': isCurrentlyActive,
        'l2Periods': l2Periods,
      });

      accumulatedYears += years;
      currentSignIdx = (currentSignIdx + 1) % 12;
    }

    // Seviye 2 (L2) Alt Dönemi Hesaplama (30 Günlük Mısır Ayları)
    final double daysIntoL1 = now.difference(l1StartDate).inDays.toDouble();
    int l2SignIdx = activeL1SignIdx;
    double accumulatedL2Days = 0.0;
    String l2Sign = l1Sign;
    int l2Months = planetaryMinorYears[l1Sign]!;
    DateTime l2StartDate = l1StartDate;
    DateTime l2EndDate = l1StartDate;
    int activeL2SignIdx = activeL1SignIdx;
    bool activeL2IsLoosing = false;
    int l2Step = 0;

    while (true) {
      final isLoosing = (l2Step == 12);
      final subSignName = zodiacSigns[l2SignIdx];
      final subMonths = planetaryMinorYears[subSignName]!;
      final subDays = subMonths * 30.0;

      if (accumulatedL2Days + subDays > daysIntoL1) {
        l2Sign = subSignName;
        l2Months = subMonths;
        l2StartDate = l1StartDate.add(Duration(days: accumulatedL2Days.round()));
        l2EndDate = l2StartDate.add(Duration(days: subDays.round()));
        activeL2SignIdx = l2SignIdx;
        activeL2IsLoosing = isLoosing;
        break;
      }

      accumulatedL2Days += subDays;
      l2Step++;
      if (l2Step == 12) {
        // 12 burç tamamlandı (211 ay doldu) -> Solar Fire Sıçrama (Loosing of the Bond):
        // Başlangıç burcunun 180° tam karşısındaki zıt burca (7. burç) sıçra!
        l2SignIdx = (activeL1SignIdx + 6) % 12;
      } else {
        l2SignIdx = (l2SignIdx + 1) % 12;
      }
    }

    // Seviye 3 (L3) Mikro Dönemi Hesaplama (Solar Fire Standartı: 1 birim = 2.5 gün = 60 saat)
    final double daysIntoL2 = now.difference(l2StartDate).inMinutes / (24.0 * 60.0);
    int l3SignIdx = activeL2SignIdx;
    double accumulatedL3Days = 0.0;
    String l3Sign = l2Sign;
    double l3Days = (planetaryMinorYears[l2Sign]! * 2.5);
    DateTime l3StartDate = l2StartDate;
    DateTime l3EndDate = l2StartDate;
    bool activeL3IsLoosing = false;
    int l3Step = 0;

    while (true) {
      final isLoosing = (l3Step == 12);
      final microSignName = zodiacSigns[l3SignIdx];
      final microDays = planetaryMinorYears[microSignName]! * 2.5;

      if (accumulatedL3Days + microDays > daysIntoL2) {
        l3Sign = microSignName;
        l3Days = microDays;
        l3StartDate = l2StartDate.add(Duration(hours: (accumulatedL3Days * 24.0).round()));
        l3EndDate = l3StartDate.add(Duration(hours: (microDays * 24.0).round()));
        activeL3IsLoosing = isLoosing;
        break;
      }

      accumulatedL3Days += microDays;
      l3Step++;
      if (l3Step == 12) {
        // 12 mikro burç tamamlandı (527.5 gün) -> L3 Sıçrama (Loosing of the Bond):
        // Başlangıç L2 burcunun tam karşısındaki zıt burca sıçra!
        l3SignIdx = (activeL2SignIdx + 6) % 12;
      } else {
        l3SignIdx = (l3SignIdx + 1) % 12;
      }
    }

    final signDistance = (activeL1SignIdx - spiritSignIdx + 12) % 12;
    final bool isPeak = (signDistance == 0 || signDistance == 9 || signDistance == 6 || signDistance == 3);
    final bool isMajorPeak = (signDistance == 9);

    String peakStatusText = 'HAZIRLIK & BÜYÜME EVRESİ';
    if (activeL2IsLoosing) {
      peakStatusText = '★ SIÇRAMA (L) DÖNEMİ AKTİF';
    } else if (signDistance == 9) {
      peakStatusText = 'MAJOR PEAK ★ (Kariyer Zirvesi)';
    } else if (signDistance == 0) {
      peakStatusText = 'RUH EVRESİ ★ (1. Ev Piki)';
    } else if (signDistance == 3) {
      peakStatusText = 'KÖK & TEMEL PİKİ (4. Ev Açısı)';
    } else if (signDistance == 6) {
      peakStatusText = 'İLİŞKİ EKSENİ (7. Ev Açısı)';
    }

    return {
      'spiritSign': spiritSign,
      'spiritFormatted': formatLongitude(spiritLon),
      'l1Sign': l1Sign,
      'l1DurationYears': l1Duration,
      'l1StartDate': '${l1StartDate.day} ${_turkishMonthName(l1StartDate.month)} ${l1StartDate.year}',
      'l1EndDate': '${l1EndDate.day} ${_turkishMonthName(l1EndDate.month)} ${l1EndDate.year}',
      'l2Sign': l2Sign,
      'l2DurationMonths': l2Months,
      'l2StartDate': '${l2StartDate.day} ${_turkishMonthName(l2StartDate.month)} ${l2StartDate.year}',
      'l2EndDate': '${l2EndDate.day} ${_turkishMonthName(l2EndDate.month)} ${l2EndDate.year}',
      'isL2Loosing': activeL2IsLoosing,
      'l3Sign': l3Sign,
      'l3Days': (l3Days % 1 == 0 ? l3Days.toInt() : l3Days),
      'l3StartDate': '${l3StartDate.day} ${_turkishMonthName(l3StartDate.month)} ${l3StartDate.year}',
      'l3EndDate': '${l3EndDate.day} ${_turkishMonthName(l3EndDate.month)} ${l3EndDate.year}',
      'isL3Loosing': activeL3IsLoosing,
      'isPeak': isPeak,
      'isMajorPeak': isMajorPeak,
      'peakStatusText': peakStatusText,
      'timeline': timeline,
    };
  }

  /// Calculates Level 2 (L2) sub-periods (in 30-day Egyptian months) for a given L1 period.
  static List<Map<String, dynamic>> calculateL2Periods({
    required String l1Sign,
    required DateTime l1StartDate,
    required DateTime l1EndDate,
    required String spiritSign,
    DateTime? targetDate,
  }) {
    final now = targetDate ?? DateTime.now();
    final spiritIdx = zodiacSigns.indexOf(spiritSign);
    final validSpiritIdx = spiritIdx >= 0 ? spiritIdx : 0;

    int l1SignIdx = zodiacSigns.indexOf(l1Sign);
    if (l1SignIdx < 0) l1SignIdx = 0;

    final int totalL1Days = l1EndDate.difference(l1StartDate).inDays;
    final List<Map<String, dynamic>> l2List = [];

    int currSignIdx = l1SignIdx;
    int accumulatedDays = 0;
    int l2Step = 0;

    while (accumulatedDays < totalL1Days) {
      final bool isLoosing = (l2Step == 12);
      final signName = zodiacSigns[currSignIdx];
      final months = planetaryMinorYears[signName]!;
      int days = months * 30;

      if (accumulatedDays + days > totalL1Days) {
        days = totalL1Days - accumulatedDays;
      }

      final sDate = l1StartDate.add(Duration(days: accumulatedDays));
      final eDate = sDate.add(Duration(days: days));

      final signDistance = (currSignIdx - validSpiritIdx + 12) % 12;
      final bool isPeak = (signDistance == 0 || signDistance == 9 || signDistance == 6 || signDistance == 3);
      String peakTag = '';
      if (isLoosing) {
        peakTag = 'SIÇRAMA (L) ★';
      } else if (signDistance == 9) {
        peakTag = 'MAJOR PEAK ★ (Kariyer)';
      } else if (signDistance == 0) {
        peakTag = 'RUH PİKİ ★ (1. Ev)';
      } else if (signDistance == 6) {
        peakTag = 'İLİŞKİ PİKİ (7. Ev)';
      } else if (signDistance == 3) {
        peakTag = 'KÖK PİKİ (4. Ev)';
      }

      final bool isActive = now.isAfter(sDate.subtract(const Duration(seconds: 1))) && now.isBefore(eDate);

      // Pre-calculate L3 periods for this L2 period
      final l3Periods = calculateL3Periods(
        l2Sign: signName,
        l2StartDate: sDate,
        l2EndDate: eDate,
        spiritSign: spiritSign,
        targetDate: now,
      );

      l2List.add({
        'sign': signName,
        'symbol': zodiacSymbols[currSignIdx],
        'months': months,
        'days': days,
        'startDate': sDate,
        'endDate': eDate,
        'startDateFormatted': '${sDate.day.toString().padLeft(2, '0')}.${sDate.month.toString().padLeft(2, '0')}.${sDate.year}',
        'endDateFormatted': '${eDate.day.toString().padLeft(2, '0')}.${eDate.month.toString().padLeft(2, '0')}.${eDate.year}',
        'isPeak': isPeak,
        'peakTag': peakTag,
        'isLoosing': isLoosing,
        'isActive': isActive,
        'l3Periods': l3Periods,
      });

      accumulatedDays += days;
      l2Step++;
      if (l2Step == 12) {
        currSignIdx = (l1SignIdx + 6) % 12;
      } else {
        currSignIdx = (currSignIdx + 1) % 12;
      }
    }

    return l2List;
  }

  /// Calculates Level 3 (L3) micro-periods (in days) for a given L2 sub-period.
  static List<Map<String, dynamic>> calculateL3Periods({
    required String l2Sign,
    required DateTime l2StartDate,
    required DateTime l2EndDate,
    required String spiritSign,
    DateTime? targetDate,
  }) {
    final now = targetDate ?? DateTime.now();
    final spiritIdx = zodiacSigns.indexOf(spiritSign);
    final validSpiritIdx = spiritIdx >= 0 ? spiritIdx : 0;

    int l2SignIdx = zodiacSigns.indexOf(l2Sign);
    if (l2SignIdx < 0) l2SignIdx = 0;

    final double totalL2Hours = l2EndDate.difference(l2StartDate).inHours.toDouble();
    final List<Map<String, dynamic>> l3List = [];

    int currSignIdx = l2SignIdx;
    double accumulatedHours = 0.0;
    int l3Step = 0;

    while (accumulatedHours < totalL2Hours) {
      final bool isLoosing = (l3Step == 12);
      final signName = zodiacSigns[currSignIdx];
      final double signDays = planetaryMinorYears[signName]! * 2.5;
      double signHours = signDays * 24.0;

      if (accumulatedHours + signHours > totalL2Hours) {
        signHours = totalL2Hours - accumulatedHours;
      }

      final sDate = l2StartDate.add(Duration(hours: accumulatedHours.round()));
      final eDate = sDate.add(Duration(hours: signHours.round()));

      final signDistance = (currSignIdx - validSpiritIdx + 12) % 12;
      final bool isPeak = (signDistance == 0 || signDistance == 9 || signDistance == 6 || signDistance == 3);
      String peakTag = '';
      if (isLoosing) {
        peakTag = 'SIÇRAMA (L) ★';
      } else if (signDistance == 9) {
        peakTag = 'MAJOR PEAK ★';
      } else if (signDistance == 0) {
        peakTag = 'RUH PİKİ ★';
      } else if (signDistance == 6) {
        peakTag = 'İLİŞKİ PİKİ';
      } else if (signDistance == 3) {
        peakTag = 'KÖK PİKİ';
      }

      final bool isActive = now.isAfter(sDate.subtract(const Duration(seconds: 1))) && now.isBefore(eDate);

      l3List.add({
        'sign': signName,
        'symbol': zodiacSymbols[currSignIdx],
        'days': (signHours / 24.0).toStringAsFixed(1),
        'startDate': sDate,
        'endDate': eDate,
        'startDateFormatted': '${sDate.day.toString().padLeft(2, '0')}.${sDate.month.toString().padLeft(2, '0')}.${sDate.year}',
        'endDateFormatted': '${eDate.day.toString().padLeft(2, '0')}.${eDate.month.toString().padLeft(2, '0')}.${eDate.year}',
        'isPeak': isPeak,
        'peakTag': peakTag,
        'isLoosing': isLoosing,
        'isActive': isActive,
      });

      accumulatedHours += signHours;
      l3Step++;
      if (l3Step == 12) {
        currSignIdx = (l2SignIdx + 6) % 12;
      } else {
        currSignIdx = (currSignIdx + 1) % 12;
      }
    }

    return l3List;
  }

  static String _turkishMonthName(int m) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return m >= 1 && m <= 12 ? months[m] : '';
  }

  static String _houseName(int h) {
    const houses = [
      '', 'Kişisel Kimlik', 'Maddi Kaynaklar', 'Yakın Çevre & Zihin',
      'Yuva & Kökler', 'Yaratıcılık & Aşk', 'Çalışma & Sağlık',
      'İlişkiler & Ortaklık', 'Dönüşüm & Derinlik', 'Yüksek Vizyon & Felsefe',
      'Kariyer & Zirve', 'Kolektif Hedefler', 'Manevi Arınma'
    ];
    return h >= 1 && h <= 12 ? houses[h] : '';
  }
}
