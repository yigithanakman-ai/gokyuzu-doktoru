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
  static Map<String, double> _calculatePlanetsLongitudes(DateTime dt) {
    final jd = _julianDate(dt);
    final d = jd - 2451545.0;
    final t = d / 36525.0;

    // Dünya / Güneş
    final sunL = calculateSunLongitude(dt);
    final earthL = _normalize(sunL + 180.0);
    final earthR = 1.00014 - 0.01671 * math.cos(_rad(357.529 + 0.98560028 * d));

    // Gezegen Geometrisi
    double helioToGeo(double lH, double rH) {
      final xH = rH * math.cos(_rad(lH));
      final yH = rH * math.sin(_rad(lH));
      final xE = earthR * math.cos(_rad(earthL));
      final yE = earthR * math.sin(_rad(earthL));
      final xG = xH - xE;
      final yG = yH - yE;
      return _normalize(_deg(math.atan2(yG, xG)));
    }

    // Merkür
    final mercLh = _normalize(252.25 + 4.0923344 * d);
    final merc = helioToGeo(mercLh, 0.387);

    // Venüs
    final venLh = _normalize(181.98 + 1.602130 * d);
    final ven = helioToGeo(venLh, 0.723);

    // Mars
    final marsLh = _normalize(355.43 + 0.524033 * d);
    final mars = helioToGeo(marsLh, 1.524);

    // Jüpiter
    final jupLh = _normalize(34.35 + 0.083085 * d);
    final jup = helioToGeo(jupLh, 5.204);

    // Satürn
    final satLh = _normalize(50.08 + 0.033444 * d);
    final sat = helioToGeo(satLh, 9.582);

    // Uranüs
    final uraLh = _normalize(314.06 + 0.011726 * d);
    final ura = helioToGeo(uraLh, 19.2);

    // Neptün
    final nepLh = _normalize(304.35 + 0.005981 * d);
    final nep = helioToGeo(nepLh, 30.05);

    // Plüton
    final pluLh = _normalize(238.93 + 0.003964 * d);
    final plu = helioToGeo(pluLh, 39.48);

    // Kuzey Ay Düğümü (Rahu - Mean Lunar Node)
    final node = _normalize(125.04452 - 1934.136261 * t);

    return {
      'mercury': merc,
      'venus': ven,
      'mars': mars,
      'jupiter': jup,
      'saturn': sat,
      'uranus': ura,
      'neptune': nep,
      'pluto': plu,
      'node': node,
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
        symbol: '♀',
        lon: planets['venus']!,
        isRetro: isRetro('venus'),
        theme: isRetro('venus')
            ? 'İlişkilerde karmik yüzleşmeler, değer yargılarını ve maddi sınırları sorgulama (Retro).'
            : 'İlişkiler, estetik uyum, sevgi dili ve maddi değerlerin akışı.',
      ),
      makePlanet(
        name: 'Mars',
        symbol: '♂',
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
