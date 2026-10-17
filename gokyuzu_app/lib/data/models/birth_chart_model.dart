class PlanetPosition {
  final String name;
  final String sign;
  final String formatted;
  final bool isRetrograde;
  final double? longitude;

  PlanetPosition({
    required this.name,
    required this.sign,
    required this.formatted,
    this.isRetrograde = false,
    this.longitude,
  });

  factory PlanetPosition.fromString(String name, String raw, [double? lon]) {
    final lower = raw.toLowerCase();
    final isRetro = lower.contains('(r)') || lower.contains('(retro)');
    final sign = BirthChartModel.normalizeSign(raw);
    return PlanetPosition(
      name: name,
      sign: sign,
      formatted: raw,
      isRetrograde: isRetro,
      longitude: lon,
    );
  }
}

class BirthChartModel {
  final String name;
  final String sunFormatted;
  final String moonFormatted;
  final String risingFormatted;
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final Map<String, PlanetPosition> planets;
  final Map<String, int> elements;
  final Map<String, int> modalities;
  final Map<String, dynamic> rawChart;

  BirthChartModel({
    required this.name,
    required this.sunFormatted,
    required this.moonFormatted,
    required this.risingFormatted,
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    required this.planets,
    required this.elements,
    required this.modalities,
    required this.rawChart,
  });

  String get ascendant => risingSign;

  static String _extractSign(String formatted) {
    final clean = formatted.replaceAll('(r)', '').trim();
    final parts = clean.split(' ');
    return parts.isNotEmpty ? parts.last : 'Koç';
  }

  factory BirthChartModel.fromJson(Map<String, dynamic> json) {
    final bigThree = json['big_three'] as Map<String, dynamic>? ?? {};
    final sunFmt = bigThree['sun']?.toString() ?? 'Koç';
    final moonFmt = bigThree['moon']?.toString() ?? 'Koç';
    final ascFmt = bigThree['ascendant']?.toString() ?? 'Koç';

    final sunSign = _extractSign(sunFmt);
    final moonSign = _extractSign(moonFmt);
    final risingSign = _extractSign(ascFmt);

    final rawChart = json['chart'] as Map<String, dynamic>? ?? {};
    final planetsMap = <String, PlanetPosition>{};

    final planetNamesTr = {
      'sun': 'Güneş',
      'moon': 'Ay',
      'ascendant': 'Yükselen (ASC)',
      'mercury': 'Merkür',
      'venus': 'Venüs',
      'mars': 'Mars',
      'jupiter': 'Jüpiter',
      'saturn': 'Satürn',
      'uranus': 'Uranüs',
      'neptune': 'Neptün',
      'pluto': 'Plüton',
      'chiron': 'Chiron',
      'north_node': 'Kuzey Ay Düğümü',
      'south_node': 'Güney Ay Düğümü',
      'mc': 'Tepe Noktası (MC)',
      'ic': 'Dip Noktası (IC)',
      'descendant': 'Alçalan (DSC)',
    };

    rawChart.forEach((key, val) {
      if (val != null) {
        final displayName = planetNamesTr[key] ?? key;
        planetsMap[key] = PlanetPosition.fromString(displayName, val.toString());
      }
    });

    // Element ve Nitelik Puanlaması:
    // ASC: 3, Güneş: 3, Ay: 3, Merkür: 1, Venüs: 1, Mars: 1, Jüpiter: 1, Satürn: 1, MC: 1
    // Geri kalan gösterge, gezegen, gezegenimsi ve asteroidler puan almaz (Toplam 15 puan).
    final elementsMap = calculateElementScores(planetsMap);
    final modalitiesMap = calculateModalityScores(planetsMap);

    return BirthChartModel(
      name: json['name']?.toString() ?? '',
      sunFormatted: sunFmt,
      moonFormatted: moonFmt,
      risingFormatted: ascFmt,
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      planets: planetsMap,
      elements: elementsMap,
      modalities: modalitiesMap,
      rawChart: rawChart,
    );
  }

  static const Map<String, String> signElements = {
    'Koç': 'Ateş', 'Aslan': 'Ateş', 'Yay': 'Ateş',
    'Boğa': 'Toprak', 'Başak': 'Toprak', 'Oğlak': 'Toprak',
    'İkizler': 'Hava', 'Terazi': 'Hava', 'Kova': 'Hava',
    'Yengeç': 'Su', 'Akrep': 'Su', 'Balık': 'Su',
    'Aries': 'Ateş', 'Leo': 'Ateş', 'Sagittarius': 'Ateş',
    'Taurus': 'Toprak', 'Virgo': 'Toprak', 'Capricorn': 'Toprak',
    'Gemini': 'Hava', 'Libra': 'Hava', 'Aquarius': 'Hava',
    'Cancer': 'Su', 'Scorpio': 'Su', 'Pisces': 'Su',
  };

  static const Map<String, String> signModalities = {
    'Koç': 'Öncü', 'Yengeç': 'Öncü', 'Terazi': 'Öncü', 'Oğlak': 'Öncü',
    'Boğa': 'Sabit', 'Aslan': 'Sabit', 'Akrep': 'Sabit', 'Kova': 'Sabit',
    'İkizler': 'Değişken', 'Başak': 'Değişken', 'Yay': 'Değişken', 'Balık': 'Değişken',
    'Aries': 'Öncü', 'Cancer': 'Öncü', 'Libra': 'Öncü', 'Capricorn': 'Öncü',
    'Taurus': 'Sabit', 'Leo': 'Sabit', 'Scorpio': 'Sabit', 'Aquarius': 'Sabit',
    'Gemini': 'Değişken', 'Virgo': 'Değişken', 'Sagittarius': 'Değişken', 'Pisces': 'Değişken',
  };

  /// Her türlü formatlanmış metinden burç adını hatasız ve büyük/küçük harf duyarsız ayrıştırır
  static String normalizeSign(String raw) {
    if (raw.trim().isEmpty) return 'Koç';
    final cleaned = raw
        .replaceAll('(r)', '')
        .replaceAll('(R)', '')
        .replaceAll('(retro)', '')
        .replaceAll('(Retro)', '')
        .replaceAll(RegExp(r'[^a-zA-ZçğıöşüÇĞİÖŞÜ\s]'), ' ')
        .trim();

    final tokens = cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    for (final token in tokens.reversed) {
      for (final entry in signElements.keys) {
        if (token.toLowerCase() == entry.toLowerCase()) {
          return entry;
        }
      }
    }
    return 'Koç';
  }

  /// Element Dengesi Puanlaması:
  /// ASC: 3, Güneş: 3, Ay: 3 | Merkür: 1, Venüs: 1, Mars: 1, Jüpiter: 1, Satürn: 1, MC: 1
  /// Toplam: 15 Puan. Geri kalan hiçbir gösterge hesaba katılmaz!
  static Map<String, int> calculateElementScores(Map<String, PlanetPosition> planets) {
    final scores = {'Ateş': 0, 'Toprak': 0, 'Hava': 0, 'Su': 0};

    void addPoint(String? sign, int points) {
      if (sign == null || sign.isEmpty) return;
      final clean = normalizeSign(sign);
      final elem = signElements[clean];
      if (elem != null) {
        scores[elem] = (scores[elem] ?? 0) + points;
      }
    }

    addPoint(planets['ascendant']?.sign, 3);
    addPoint(planets['sun']?.sign, 3);
    addPoint(planets['moon']?.sign, 3);

    addPoint(planets['mercury']?.sign, 1);
    addPoint(planets['venus']?.sign, 1);
    addPoint(planets['mars']?.sign, 1);
    addPoint(planets['jupiter']?.sign, 1);
    addPoint(planets['saturn']?.sign, 1);
    addPoint(planets['mc']?.sign, 1);

    return scores;
  }

  /// Nitelik Dengesi Puanlaması:
  /// ASC: 3, Güneş: 3, Ay: 3 | Merkür: 1, Venüs: 1, Mars: 1, Jüpiter: 1, Satürn: 1, MC: 1
  /// Toplam: 15 Puan.
  static Map<String, int> calculateModalityScores(Map<String, PlanetPosition> planets) {
    final scores = {'Öncü': 0, 'Sabit': 0, 'Değişken': 0};

    void addPoint(String? sign, int points) {
      if (sign == null || sign.isEmpty) return;
      final clean = normalizeSign(sign);
      final mod = signModalities[clean];
      if (mod != null) {
        scores[mod] = (scores[mod] ?? 0) + points;
      }
    }

    addPoint(planets['ascendant']?.sign, 3);
    addPoint(planets['sun']?.sign, 3);
    addPoint(planets['moon']?.sign, 3);

    addPoint(planets['mercury']?.sign, 1);
    addPoint(planets['venus']?.sign, 1);
    addPoint(planets['mars']?.sign, 1);
    addPoint(planets['jupiter']?.sign, 1);
    addPoint(planets['saturn']?.sign, 1);
    addPoint(planets['mc']?.sign, 1);

    return scores;
  }
}
