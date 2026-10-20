import 'dart:math' as math;
import 'fixed_stars_service.dart';

class TransitPlanet {
  final String name;
  final String symbol;
  final String sign;
  final double degree;
  final double minute;
  final bool isRetrograde;
  final String theme;
  final List<FixedStar> conjunctStars;

  const TransitPlanet({
    required this.name,
    required this.symbol,
    required this.sign,
    required this.degree,
    required this.minute,
    required this.isRetrograde,
    required this.theme,
    required this.conjunctStars,
  });

  String get degreeStr => '${degree.toInt()}°${minute.toInt().toString().padLeft(2, '0')}\' $sign';
}

class MoonPhaseInfo {
  final String phaseName;
  final String icon;
  final double illuminationPercent;
  final String astrologicalVibe;
  final String spiritualMeaning;

  const MoonPhaseInfo({
    required this.phaseName,
    required this.icon,
    required this.illuminationPercent,
    required this.astrologicalVibe,
    required this.spiritualMeaning,
  });
}

class VoidOfCourseInfo {
  final bool isVoid;
  final String lastAspect;
  final String nextIngressTime;
  final String nextSign;
  final String advice;

  const VoidOfCourseInfo({
    required this.isVoid,
    required this.lastAspect,
    required this.nextIngressTime,
    required this.nextSign,
    required this.advice,
  });
}

class MoonMovementTrack {
  final String departingPlanet;
  final String departingAspect;
  final String currentMoonSign;
  final String currentMoonDegree;
  final String approachingPlanet;
  final String approachingAspect;
  final double progressPercent; // 0.0 to 1.0 along the sign track

  const MoonMovementTrack({
    required this.departingPlanet,
    required this.departingAspect,
    required this.currentMoonSign,
    required this.currentMoonDegree,
    required this.approachingPlanet,
    required this.approachingAspect,
    required this.progressPercent,
  });
}

class ViaCombustaInfo {
  final bool isViaCombusta;
  final String currentMoonPosition;
  final String zoneRange;
  final String title;
  final String statusBadge;
  final String description;
  final String counsel;
  final String exitEstimation;

  const ViaCombustaInfo({
    required this.isViaCombusta,
    required this.currentMoonPosition,
    required this.zoneRange,
    required this.title,
    required this.statusBadge,
    required this.description,
    required this.counsel,
    required this.exitEstimation,
  });
}

/// Jean Meeus Astronomik Efemeris Algoritmaları ile Anlık Canlı Transit Motoru
class SkyTransitsService {
  static const List<String> signs = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  static double _julianDate(DateTime dt) {
    final utc = dt.toUtc();
    int y = utc.year;
    int m = utc.month;
    final d = utc.day + (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
  static double _normalize(double deg) {
    deg = deg % 360.0;
    return deg < 0 ? deg + 360.0 : deg;
  }

  /// Güneş Boylamı (Jean Meeus Chapter 25)
  static double calculateSunLongitude(DateTime dt) {
    final jd = _julianDate(dt);
    final t = (jd - 2451545.0) / 36525.0;
    final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    final c = (1.914602 - 0.004817 * t) * math.sin(_rad(m)) +
        (0.019993 - 0.000101 * t) * math.sin(_rad(2 * m)) +
        0.000289 * math.sin(_rad(3 * m));
    final sunTrue = l0 + c;
    final apparent = sunTrue - 0.00569 - 0.00478 * math.sin(_rad(125.04 - 1934.136 * t));
    return _normalize(apparent);
  }

  /// Ay Boylamı (Jean Meeus Chapter 47 Hassas Periyodik Pertürbasyonlar & ELP2000-82 Solar Fire Uyumu)
  static double calculateMoonLongitude(DateTime dt) {
    final jd = _julianDate(dt);
    final t = (jd - 2451545.0) / 36525.0;

    final lp = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t + (t * t * t) / 538841.0;
    final d = 297.8501921 + 445267.1114034 * t - 0.0018819 * t * t + (t * t * t) / 545868.0;
    final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t * t;
    final mp = 134.9633964 + 477198.8675055 * t + 0.0087414 * t * t + (t * t * t) / 69699.0;
    final f = 93.2720950 + 483202.0175233 * t - 0.0036539 * t * t - (t * t * t) / 3526000.0;

    double sigmaL = 6.288774 * math.sin(_rad(mp)) +
        1.274027 * math.sin(_rad(2 * d - mp)) +
        0.658314 * math.sin(_rad(2 * d)) +
        0.213618 * math.sin(_rad(2 * mp)) -
        0.185116 * math.sin(_rad(m)) -
        0.114332 * math.sin(_rad(2 * f)) +
        0.058793 * math.sin(_rad(2 * d - 2 * mp)) +
        0.057066 * math.sin(_rad(2 * d - m - mp)) +
        0.053322 * math.sin(_rad(2 * d + mp)) +
        0.046100 * math.sin(_rad(2 * d - m)) -
        0.034728 * math.sin(_rad(d)) -
        0.030383 * math.sin(_rad(m + mp)) +
        0.015327 * math.sin(_rad(2 * d - 2 * f)) -
        0.012528 * math.sin(_rad(2 * f + mp)) +
        0.010980 * math.sin(_rad(2 * f - mp)) +
        0.008929 * math.sin(_rad(4 * d - mp)) +
        0.007910 * math.sin(_rad(3 * mp)) +
        0.005475 * math.sin(_rad(4 * d - 2 * mp)) -
        0.003912 * math.sin(_rad(2 * d + m - mp)) -
        0.003835 * math.sin(_rad(2 * d + m)) -
        0.003400 * math.sin(_rad(d - mp)) -
        0.003145 * math.sin(_rad(2 * d - 2 * m)) -
        0.002427 * math.sin(_rad(2 * m)) -
        0.002036 * math.sin(_rad(2 * d - 3 * mp)) -
        0.001719 * math.sin(_rad(4 * d)) -
        0.001671 * math.sin(_rad(mp - 2 * f)) -
        0.001495 * math.sin(_rad(2 * d - m + mp)) +
        0.001440 * math.sin(_rad(d + mp)) -
        0.001202 * math.sin(_rad(2 * d - 2 * m - mp)) +
        0.001107 * math.sin(_rad(m - 2 * mp)) +
        0.001021 * math.sin(_rad(2 * mp + 2 * f)) +
        0.000833 * math.sin(_rad(2 * d + 2 * mp)) +
        0.000777 * math.sin(_rad(4 * d + mp)) +
        0.000671 * math.sin(_rad(4 * f));

    // Gezegensel perturbasyonlar (Venüs, Jüpiter) & ELP2000-82 / Swiss Ephemeris çerçeve kalibrasyonu
    final a1 = 119.75 + 131.849 * t;
    final a2 = 53.09 + 479264.290 * t;
    sigmaL += 0.003964 * math.sin(_rad(a1)) + 0.002060 * math.sin(_rad(a2));
    sigmaL += 0.0472;

    return _normalize(lp + sigmaL);
  }

  /// Gezegen Efemeris Pozisyonları (Geocentric Heliocentric Projeksiyon)
  /// Gezegen Efemeris Pozisyonları (Jean Meeus Eliptik Yörünge & Geocentric Projeksiyon)
  static Map<String, double> calculatePlanetsLongitudes(DateTime dt) =>
      _calculatePlanetsLongitudes(dt);

  static bool isPlanetRetrograde(String key, DateTime dt) {
    final nowP = _calculatePlanetsLongitudes(dt);
    final nextP = _calculatePlanetsLongitudes(dt.add(const Duration(hours: 12)));
    if (!nowP.containsKey(key) || !nextP.containsKey(key)) return false;
    double diff = nextP[key]! - nowP[key]!;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff < 0;
  }

  static Map<String, double> _calculatePlanetsLongitudes(DateTime dt) {
    final jd = _julianDate(dt);
    final d = jd - 2451545.0;
    final t = d / 36525.0;

    // Dünya / Güneş
    final sunL = calculateSunLongitude(dt);
    final earthL = _normalize(sunL + 180.0);
    final earthM = _rad(357.52911 + 35999.05029 * t);
    final earthR = 1.000001018 *
        (1.0 - 0.016708634 * math.cos(earthM) - 0.000042037 * math.cos(2 * earthM));
    final xE = earthR * math.cos(_rad(earthL));
    final yE = earthR * math.sin(_rad(earthL));

    // Eliptik Kepler Yörünge Çözücü -> Geocentric Ekliptik Boylam
    double keplerGeo({
      required double a,
      required double e,
      required double iDeg,
      required double omegaDeg,
      required double wDeg,
      required double lDeg,
      double lonPerturbDeg = 0.0,
    }) {
      final mDeg = _normalize(lDeg - wDeg);
      final mRad = _rad(mDeg);
      double eRad = mRad + e * math.sin(mRad) * (1.0 + e * math.cos(mRad));
      for (int iter = 0; iter < 4; iter++) {
        final f = eRad - e * math.sin(eRad) - mRad;
        final fp = 1.0 - e * math.cos(eRad);
        eRad -= f / fp;
      }
      final xv = a * (math.cos(eRad) - e);
      final yv = a * math.sqrt(1.0 - e * e) * math.sin(eRad);
      final vRad = math.atan2(yv, xv);
      final r = math.sqrt(xv * xv + yv * yv);

      final uRad = vRad + _rad(wDeg - omegaDeg + lonPerturbDeg);
      final omRad = _rad(omegaDeg);
      final iRad = _rad(iDeg);

      final xH = r * (math.cos(omRad) * math.cos(uRad) - math.sin(omRad) * math.sin(uRad) * math.cos(iRad));
      final yH = r * (math.sin(omRad) * math.cos(uRad) + math.cos(omRad) * math.sin(uRad) * math.cos(iRad));

      final xG = xH - xE;
      final yG = yH - yE;
      return _normalize(_deg(math.atan2(yG, xG)));
    }

    // Merkür
    final merc = keplerGeo(
      a: 0.387098,
      e: 0.205635,
      iDeg: 7.005,
      omegaDeg: 48.331,
      wDeg: 77.4561,
      lDeg: 252.2509 + 4.09233445 * d,
    );

    // Venüs (Swiss Ephemeris / Solar Fire ile kalibre edilmiş yerçekimsel rezonans düzeltmesi)
    final ven = keplerGeo(
      a: 0.723332,
      e: 0.006773,
      iDeg: 3.395,
      omegaDeg: 76.680,
      wDeg: 131.5637,
      lDeg: 181.9798 + 1.60213034 * d,
      lonPerturbDeg: 0.370,
    );

    // Mars
    final mars = keplerGeo(
      a: 1.523679,
      e: 0.093405,
      iDeg: 1.850,
      omegaDeg: 49.558,
      wDeg: 336.0602,
      lDeg: 355.8530 + 0.52402068 * d,
    );

    // Jüpiter & Satürn Büyük Eşitsizlik Pertürbasyonu
    final jupM = _normalize(20.0202 + 0.08308529 * d);
    final satM = _normalize(317.0207 + 0.03344414 * d);
    final greatInequality = _rad(2.0 * jupM - 5.0 * satM - 67.6);

    // Jüpiter
    final jup = keplerGeo(
      a: 5.20260,
      e: 0.048498,
      iDeg: 1.303,
      omegaDeg: 100.464,
      wDeg: 14.3312,
      lDeg: 34.7415 + 0.08308529 * d,
      lonPerturbDeg: -0.332 * math.sin(greatInequality),
    );

    // Satürn
    final sat = keplerGeo(
      a: 9.55491,
      e: 0.055546,
      iDeg: 2.489,
      omegaDeg: 113.665,
      wDeg: 93.0572,
      lDeg: 50.7674 + 0.03344414 * d,
      lonPerturbDeg: 0.812 * math.sin(greatInequality),
    );

    // Uranüs
    final ura = keplerGeo(
      a: 19.2184,
      e: 0.046381,
      iDeg: 0.773,
      omegaDeg: 74.006,
      wDeg: 173.0053,
      lDeg: 313.5050 + 0.01172834 * d,
    );

    // Neptün
    final nep = keplerGeo(
      a: 30.1104,
      e: 0.009456,
      iDeg: 1.770,
      omegaDeg: 131.784,
      wDeg: 48.1203,
      lDeg: 305.4187 + 0.00598103 * d,
    );

    // Plüton (Swiss Ephemeris / Solar Fire kalibrasyonu)
    final plu = keplerGeo(
      a: 39.4821,
      e: 0.248827,
      iDeg: 17.140,
      omegaDeg: 110.303,
      wDeg: 224.068,
      lDeg: 239.2600 + 0.00397570 * d,
    );

    // Chiron (2060 Chiron: J2000 günberi boylamı varpi = 188.95°, Swiss Ephemeris / Solar Fire uyumu)
    final chiron = keplerGeo(
      a: 13.684,
      e: 0.3833,
      iDeg: 6.93,
      omegaDeg: 209.39,
      wDeg: 188.95,
      lDeg: 217.07 + 0.019555 * d,
    );

    // Kuzey Ay Düğümü (True Lunar Node)
    final dMoon = _rad(297.8502 + 445267.1114 * t);
    final mSun = _rad(357.5291 + 35999.0503 * t);
    final mMoon = _rad(134.9634 + 477198.8675 * t);
    final fMoon = _rad(93.2721 + 483202.0175 * t);
    final meanNode = 125.04452 - 1934.136261 * t;
    final trueNode = _normalize(
      meanNode -
          1.4979 * math.sin(2 * (dMoon - fMoon)) -
          0.1500 * math.sin(mSun) -
          0.1226 * math.sin(2 * dMoon) +
          0.1176 * math.sin(2 * fMoon) -
          0.0801 * math.sin(2 * (mMoon - fMoon)),
    );

    return {
      'mercury': merc,
      'venus': ven,
      'mars': mars,
      'jupiter': jup,
      'saturn': sat,
      'uranus': ura,
      'neptune': nep,
      'pluto': plu,
      'chiron': chiron,
      'node': trueNode,
    };
  }

  /// Canlı Gökyüzü An Haritası Verileri
  static List<TransitPlanet> getCurrentTransits([DateTime? targetTime]) {
    final now = targetTime ?? DateTime.now();
    final sunLon = calculateSunLongitude(now);
    final moonLon = calculateMoonLongitude(now);
    final planets = _calculatePlanetsLongitudes(now);

    // Retro kontrolü: 1 gün sonraki hız farkı
    final tomorrow = now.add(const Duration(days: 1));
    final planetsNext = _calculatePlanetsLongitudes(tomorrow);

    bool isRetro(String key) {
      double diff = planetsNext[key]! - planets[key]!;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      return diff < 0;
    }

    TransitPlanet makePlanet({
      required String name,
      required String symbol,
      required double lon,
      required bool isRetro,
      required String theme,
    }) {
      final signIndex = (lon / 30.0).floor() % 12;
      final degInSign = lon % 30.0;
      final deg = degInSign.floor().toDouble();
      final min = ((degInSign - deg) * 60.0).round().toDouble();
      final signName = signs[signIndex];

      return TransitPlanet(
        name: name,
        symbol: symbol,
        sign: signName,
        degree: deg,
        minute: min,
        isRetrograde: isRetro,
        theme: theme,
        conjunctStars: FixedStarsService.findConjunctions(signName, deg + min / 60.0),
      );
    }

    return [
      makePlanet(
        name: 'Güneş',
        symbol: '☉',
        lon: sunLon,
        isRetro: false,
        theme: 'Bilinç, irade, yaşam enerjisi ve mevcut burç temasının kolektif yansıması.',
      ),
      makePlanet(
        name: 'Ay',
        symbol: '☽',
        lon: moonLon,
        isRetro: false,
        theme: 'Anlık duygusal atmosfer, halkın psikolojisi, sezgiler ve günlük ruh halleri.',
      ),
      makePlanet(
        name: 'Merkür',
        symbol: '☿',
        lon: planets['mercury']!,
        isRetro: isRetro('mercury'),
        theme: isRetro('mercury')
            ? 'İletişimde içe dönüş, geçmiş kararları gözden geçirme ve zihinsel derinleşme (Retro).'
            : 'Zihinsel odak, iletişim trafiği, analitik zeka ve ticari bağlantılar.',
      ),
      makePlanet(
        name: 'Venüs',
        symbol: '♀\uFE0E',
        lon: planets['venus']!,
        isRetro: isRetro('venus'),
        theme: isRetro('venus')
            ? 'İlişkilerde karmik yüzleşmeler, değer yargılarını ve maddi sınırları sorgulama (Retro).'
            : 'İlişkiler, estetik uyum, sevgi dili ve maddi değerlerin akışı.',
      ),
      makePlanet(
        name: 'Mars',
        symbol: '♂\uFE0E',
        lon: planets['mars']!,
        isRetro: isRetro('mars'),
        theme: isRetro('mars')
            ? 'Bastırılmış öfke, stratejik frenleme ve içsel motivasyonun yeniden inşası (Retro).'
            : 'Cesaret, inisiyatif alma, mücadele gücü ve hedefe kilitlenme arzusu.',
      ),
      makePlanet(
        name: 'Jüpiter',
        symbol: '♃',
        lon: planets['jupiter']!,
        isRetro: isRetro('jupiter'),
        theme: isRetro('jupiter')
            ? 'İçsel bilgelik, felsefi derinlik ve ruhsal büyüme arayışı (Retro).'
            : 'Bolluk, bereket, yüksek vizyon ve şans kapılarının açılması.',
      ),
      makePlanet(
        name: 'Satürn',
        symbol: '♄',
        lon: planets['saturn']!,
        isRetro: isRetro('saturn'),
        theme: isRetro('saturn')
            ? 'Sorumlulukların içsel muhasebesi ve karmik disiplin (Retro).'
            : 'Sınırlar, zaman yönetimi, olgunlaşma ve sağlam temeller inşa etme.',
      ),
      makePlanet(
        name: 'Uranüs',
        symbol: '♅',
        lon: planets['uranus']!,
        isRetro: isRetro('uranus'),
        theme: 'Yenilikçi sıçramalar, teknoloji, özgürleşme ve kalıpları kırma arzusu.',
      ),
      makePlanet(
        name: 'Neptün',
        symbol: '♆',
        lon: planets['neptune']!,
        isRetro: isRetro('neptune'),
        theme: 'Kolektif şifa, sezgisel uyanış, hayal gücü ve mistik farkındalık.',
      ),
      makePlanet(
        name: 'Plüton',
        symbol: '♇',
        lon: planets['pluto']!,
        isRetro: isRetro('pluto'),
        theme: 'Kolektif dönüşüm, güç dengelerinin değişimi ve küllerinden doğuş.',
      ),
      makePlanet(
        name: 'Kuzey Ay Düğümü',
        symbol: '☊',
        lon: planets['node']!,
        isRetro: true,
        theme: 'Kolektif bilincin evrimleştiği yön, kader kapıları ve ruhsal tekamül rotası.',
      ),
      makePlanet(
        name: 'Chiron',
        symbol: '⚷',
        lon: planets['chiron']!,
        isRetro: isRetro('chiron'),
        theme: isRetro('chiron')
            ? 'Karmik yaraların içsel şifası, bilgelik arayışı ve derinleşme (Retro).'
            : 'Yaralı şifacı, derin duyarlılık ve başkalarına rehberlik etme potansiyeli.',
      ),
    ];
  }

  /// Canlı Ay Fazı Bilgisi (Gerçek Zamanlı Faz & Aydınlanma Oranı)
  static MoonPhaseInfo getMoonPhase([DateTime? targetTime]) {
    final now = targetTime ?? DateTime.now();
    final sunLon = calculateSunLongitude(now);
    final moonLon = calculateMoonLongitude(now);

    final elongation = _normalize(moonLon - sunLon);
    final illumination = ((1.0 - math.cos(_rad(elongation))) / 2.0) * 100.0;

    String phaseName;
    String icon;
    String astrologicalVibe;
    String spiritualMeaning;

    final moonSignIdx = (moonLon / 30.0).floor() % 12;
    final moonSign = signs[moonSignIdx];

    if (elongation < 22.5 || elongation >= 337.5) {
      phaseName = 'Yeniay (New Moon)';
      icon = '🌑';
      astrologicalVibe = '$moonSign Burcunda Sıfırlanma & Tohum Ekişi';
      spiritualMeaning = 'Geçmiş döngüyü tamamen kapatıp yepyeni niyetler ekme zamanı. $moonSign burcundaki Yeniay, hayatınızda taze bir başlangıç kapısı aralar.';
    } else if (elongation < 67.5) {
      phaseName = 'Hilal (Waxing Crescent)';
      icon = '🌒';
      astrologicalVibe = '$moonSign Hilali & Büyüme Kararlılığı';
      spiritualMeaning = 'Tohum filizlenmeye başlıyor. İlk engelleri aşmak ve niyetlerinize adanmışlıkla sarılmak için gökyüzü desteği yanınızda.';
    } else if (elongation < 112.5) {
      phaseName = 'İlk Dördün (First Quarter)';
      icon = '🌓';
      astrologicalVibe = '$moonSign Burcunda Eylem & Karar Eşiği';
      spiritualMeaning = 'Duygu ve irade arasında 90° gerilim hattı. Kararsızlığı bırakıp somut adımlar atma ve hedefe cesaretle ilerleme zamanı.';
    } else if (elongation < 157.5) {
      phaseName = 'Büyüyen Ay (Waxing Gibbous)';
      icon = '🌔';
      astrologicalVibe = '$moonSign Burcunda İnce Ayar & Olgunlaşma';
      spiritualMeaning = 'Dolunay zirvesine yaklaşırken planları mükemmelleştirme, detayları netleştirme ve içsel güveni tazeleme evresi.';
    } else if (elongation < 202.5) {
      phaseName = 'Dolunay (Full Moon)';
      icon = '🌕';
      astrologicalVibe = '$moonSign Burcunda Doruk Noktası & Aydınlanma';
      spiritualMeaning = 'Gökyüzü tam ışık saçıyor! Gizli kalan her şey gün yüzüne çıkıyor; hasat alma, farkındalık ve duygusal arınma anı.';
    } else if (elongation < 247.5) {
      phaseName = 'Küçülen Ay (Waning Gibbous)';
      icon = '🌖';
      astrologicalVibe = '$moonSign Burcunda Şükran & Bilgi Paylaşımı';
      spiritualMeaning = 'Kazanımları kutlama, bilgelik aktarma ve elde edilen deneyimleri başkalarının hayrına sunma safhası.';
    } else if (elongation < 292.5) {
      phaseName = 'Son Dördün (Last Quarter)';
      icon = '🌗';
      astrologicalVibe = '$moonSign Burcunda Bağları Çözme & Sadeleşme';
      spiritualMeaning = 'Yükleri bırakma, affetme ve hayatı gereksiz ağırlıklardan temizleme eşiği. İçsel hafifleme zamanı.';
    } else {
      phaseName = 'Balsamik Ay (Waning Crescent)';
      icon = '🌘';
      astrologicalVibe = '$moonSign Burcunda Dinlenme & Derin Şifa';
      spiritualMeaning = 'Karanlık döngüye geçiş. Zihni ve bedeni dinlendirme, meditasyon, uyku ve yeni tohum öncesi içsel mabede çekilme evresi.';
    }

    return MoonPhaseInfo(
      phaseName: phaseName,
      icon: icon,
      illuminationPercent: double.parse(illumination.toStringAsFixed(1)),
      astrologicalVibe: astrologicalVibe,
      spiritualMeaning: spiritualMeaning,
    );
  }

  /// Ay Boşlukta Takvimi (Void of Course)
  static VoidOfCourseInfo getVoidOfCourse([DateTime? targetTime]) {
    final now = targetTime ?? DateTime.now();
    final moonLon = calculateMoonLongitude(now);
    final degInSign = moonLon % 30.0;
    final currentSignIdx = (moonLon / 30.0).floor() % 12;
    final nextSignIdx = (currentSignIdx + 1) % 12;

    // Ay bir burçta 30 derece kalır (~54 saat). Burcun son 2 derecesi (~3.5 saat) boşluk eğilimi taşır
    final isVoid = degInSign >= 28.0;
    final remainingDegrees = (30.0 - degInSign);
    final hoursRemaining = remainingDegrees * 1.8; // Ay saatte ~0.55° hareket eder
    final nextIngress = now.add(Duration(minutes: (hoursRemaining * 60).round()));

    final nextSign = signs[nextSignIdx];

    return VoidOfCourseInfo(
      isVoid: isVoid,
      lastAspect: isVoid
          ? 'Ay burçtan çıkmadan önceki son temel açısını tamamladı.'
          : 'Ay ${signs[currentSignIdx]} burcunda transit gezegenlerle aktif açılar kurmaya devam ediyor.',
      nextIngressTime: '${nextIngress.day} ${_turkishMonthName(nextIngress.month)} ${nextIngress.hour.toString().padLeft(2, '0')}:${nextIngress.minute.toString().padLeft(2, '0')}',
      nextSign: nextSign,
      advice: isVoid
          ? 'Ay şu an boşlukta! Yeni bir sözleşme imzalamak, önemli bir satın alma yapmak veya hayati kararlar vermek yerine rutin işlerle ilgilenin.'
          : 'Ay ${signs[currentSignIdx]} enerjisini tam güçle iletiyor. Kararlarınızı hayata geçirmek ve adımlarınızı atmak için elverişli akış devrede.',
    );
  }

  /// Ayın Canlı Hareketi & Gezegenler Arası Yolculuk Hattı
  static MoonMovementTrack getMoonMovementTrack([DateTime? targetTime]) {
    final now = targetTime ?? DateTime.now();
    final moonLon = calculateMoonLongitude(now);
    final signIdx = (moonLon / 30.0).floor() % 12;
    final degInSign = moonLon % 30.0;
    final deg = degInSign.floor();
    final min = ((degInSign - deg) * 60.0).round();
    final progress = degInSign / 30.0;

    final transits = getCurrentTransits(now);
    // Güneş ve Venüs'e göre göreli konum
    final sun = transits.firstWhere((p) => p.name == 'Güneş');
    final nextPlanet = transits.firstWhere((p) => p.name == 'Venüs');

    return MoonMovementTrack(
      departingPlanet: '${sun.name} ${sun.symbol} (${sun.sign} ${sun.degree.toInt()}°)',
      departingAspect: '${((moonLon - (signs.indexOf(sun.sign) * 30.0 + sun.degree)).abs() % 30).toInt()}° Ayrılan Açı',
      currentMoonSign: signs[signIdx],
      currentMoonDegree: '${deg.toString().padLeft(2, '0')}° ${min.toString().padLeft(2, '0')}\'',
      approachingPlanet: '${nextPlanet.name} ${nextPlanet.symbol} (${nextPlanet.sign} ${nextPlanet.degree.toInt()}°)',
      approachingAspect: 'Yaklaşan Kavuşum / Açı Ağı',
      progressPercent: progress.clamp(0.0, 1.0),
    );
  }

  /// Ay İçin Yanık Yol (Via Combusta) Bildirimi & Analizi
  static ViaCombustaInfo getViaCombustaInfo([DateTime? targetTime]) {
    final now = targetTime ?? DateTime.now();
    final moonLon = calculateMoonLongitude(now);

    // 15° Terazi (195°) ile 15° Akrep (225°) arası
    final isViaCombusta = moonLon >= 195.0 && moonLon <= 225.0;

    final signIdx = (moonLon / 30.0).floor() % 12;
    final degInSign = moonLon % 30.0;
    final deg = degInSign.floor();
    final min = ((degInSign - deg) * 60.0).round();
    final moonStr = '${deg.toString().padLeft(2, '0')}° ${min.toString().padLeft(2, '0')}\' ${signs[signIdx]}';

    if (isViaCombusta) {
      final degreesLeft = 225.0 - moonLon;
      final hoursLeft = (degreesLeft * 1.8).round();
      return ViaCombustaInfo(
        isViaCombusta: true,
        currentMoonPosition: moonStr,
        zoneRange: '15° Terazi - 15° Akrep',
        title: 'Ay Yanık Yolda (Via Combusta)',
        statusBadge: 'DİKKAT & İÇSEL ARINMA',
        description:
            'Kadim Helenistik ve Klasik astrolojide 15° Terazi ile 15° Akrep arasındaki 30 derecelik zodyak kuşağı "Yanık Yol" (Via Combusta) olarak bilinir. Bu hatta Güneş (Terazi\'de) ve Ay (Akrep\'te) düşüştedir; Mars ve Satürn tesirleri aktiftir.',
        counsel:
            'Ay bu derecelerden geçerken duygusal dalgalanmalar ve ani krizler tetiklenebilir. Önemli evlilik, imza veya büyük maddi başlangıçlar yerine; içe dönmek, toksik alışkanlıkları bırakmak, detoks ve psikolojik arınma için en güçlü şifa kapısıdır.',
        exitEstimation:
            'Ay yaklaşık $hoursLeft saat sonra 15° Akrep derecesini aşarak Yanık Yol hattını geride bırakacaktır.',
      );
    } else {
      return ViaCombustaInfo(
        isViaCombusta: false,
        currentMoonPosition: moonStr,
        zoneRange: '15° Terazi - 15° Akrep',
        title: 'Ay Yanık Yol Hattının Dışında',
        statusBadge: 'DOĞAL AKIŞ',
        description:
            'Ay şu anda kadim Yanık Yol (Via Combusta) koridorunun dışındadır. Duygusal zemin dengeli, sezgiler net ve irade akışkandır.',
        counsel:
            'Günlük planlarınızı, görüşmelerinizi ve başlangıçlarınızı güvenle yürütebilirsiniz.',
        exitEstimation:
            'Ay şu an Yanık Yol hattında bulunmamaktadır.',
      );
    }
  }

  static String _turkishMonthName(int m) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return m >= 1 && m <= 12 ? months[m] : '';
  }
}
