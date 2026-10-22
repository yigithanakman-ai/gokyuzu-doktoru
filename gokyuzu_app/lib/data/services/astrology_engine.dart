import 'package:flutter/material.dart';
import '../models/birth_chart_model.dart';
import '../models/brutal_truth_model.dart';
import '../models/daily_horoscope_model.dart';
import 'predictive_astrology_service.dart';
import 'sky_transits_service.dart';
import 'world_cities_service.dart';
import 'app_translation_service.dart';

class AstrologyEngine {
  static const List<String> zodiacSigns = [
    'Koç',
    'Boğa',
    'İkizler',
    'Yengeç',
    'Aslan',
    'Başak',
    'Terazi',
    'Akrep',
    'Yay',
    'Oğlak',
    'Kova',
    'Balık',
  ];

  static const Map<String, String> signElements = {
    'Koç': 'Ateş',
    'Boğa': 'Toprak',
    'İkizler': 'Hava',
    'Yengeç': 'Su',
    'Aslan': 'Ateş',
    'Başak': 'Toprak',
    'Terazi': 'Hava',
    'Akrep': 'Su',
    'Yay': 'Ateş',
    'Oğlak': 'Toprak',
    'Kova': 'Hava',
    'Balık': 'Su',
  };

  static const Map<String, String> signModalities = {
    'Koç': 'Öncü',
    'Boğa': 'Sabit',
    'İkizler': 'Değişken',
    'Yengeç': 'Öncü',
    'Aslan': 'Sabit',
    'Başak': 'Değişken',
    'Terazi': 'Öncü',
    'Akrep': 'Sabit',
    'Yay': 'Değişken',
    'Oğlak': 'Öncü',
    'Kova': 'Sabit',
    'Balık': 'Değişken',
  };

  static String _signFromLongitude(double lon) {
    double norm = lon % 360.0;
    if (norm < 0) norm += 360.0;
    final idx = (norm / 30.0).floor() % 12;
    return zodiacSigns[idx];
  }

  static String _formatPlanetDegree(double lon, {bool isRetrograde = false}) {
    double norm = lon % 360.0;
    if (norm < 0) norm += 360.0;
    int signIdx = (norm / 30.0).floor() % 12;
    final degInSign = norm % 30.0;
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
    final sign = zodiacSigns[signIdx];
    final degStr = deg.toString().padLeft(2, '0');
    final minStr = min.toString().padLeft(2, '0');
    return isRetrograde ? '$degStr°$minStr\' $sign (r)' : '$degStr°$minStr\' $sign';
  }

  // Güneş Burcu (Jean Meeus Efemeris Boylamına ve Tarihsel Saat Dilimine Göre)
  static String calculateSunSign(
    DateTime date, [
    TimeOfDay? time,
    String? city,
    String? country,
  ]) {
    final h = time?.hour ?? 12;
    final m = time?.minute ?? 0;
    final cityLoc = (city != null && city.isNotEmpty)
        ? WorldCitiesService.findCity(city, country)
        : const CityLocation(
            city: 'Datça',
            country: 'Türkiye',
            latitude: 36.7265,
            longitude: 27.6853,
            timezoneOffset: 3.0,
          );
    final effectiveOffset = PredictiveAstrologyService.getHistoricalUtcOffset(
      cityLoc: cityLoc,
      dt: date,
      hour: h,
      minute: m,
    );
    final dt = DateTime.utc(date.year, date.month, date.day, h, m)
        .subtract(Duration(minutes: (effectiveOffset * 60).round()));
    final sunLon = SkyTransitsService.calculateSunLongitude(dt);
    return _signFromLongitude(sunLon);
  }

  // Yükselen Burç (Astronomik RAMC, Tarihsel Yaz/Kış Saati & Ufuk Kesişimi)
  static String calculateRisingSign(
    DateTime date,
    TimeOfDay time, {
    double lat = 36.7265,
    double lon = 27.6853,
    double timezoneOffset = 3.0,
    String? city,
    String? country,
  }) {
    double effectiveLat = lat;
    double effectiveLon = lon;
    double effectiveOffset = timezoneOffset;
    if (city != null && city.isNotEmpty) {
      final cityLoc = WorldCitiesService.findCity(city, country);
      effectiveLat = cityLoc.latitude;
      effectiveLon = cityLoc.longitude;
      effectiveOffset = PredictiveAstrologyService.getHistoricalUtcOffset(
        cityLoc: cityLoc,
        dt: date,
        hour: time.hour,
        minute: time.minute,
      );
    } else if (country == null || country == 'Türkiye') {
      effectiveOffset = PredictiveAstrologyService.getHistoricalUtcOffset(
        cityLoc: CityLocation(
          city: 'Datça',
          country: 'Türkiye',
          latitude: effectiveLat,
          longitude: effectiveLon,
          timezoneOffset: timezoneOffset,
        ),
        dt: date,
        hour: time.hour,
        minute: time.minute,
      );
    }

    final utcDateTime = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).subtract(Duration(minutes: (effectiveOffset * 60).round()));

    final angles = PredictiveAstrologyService.calculateAscAndMc(
      utcDateTime: utcDateTime,
      latitude: effectiveLat,
      longitude: effectiveLon,
    );
    return _signFromLongitude(angles['asc']!);
  }

  // Ay Burcu (Jean Meeus ELP2000-82 Hassas Efemeris Döngüsü & Tarihsel Saat Dilimi)
  static String calculateMoonSign(
    DateTime date,
    TimeOfDay time, {
    double? timezoneOffset,
    String? city,
    String? country,
  }) {
    double effectiveOffset;
    if (timezoneOffset != null) {
      effectiveOffset = timezoneOffset;
    } else {
      final cityLoc = (city != null && city.isNotEmpty)
          ? WorldCitiesService.findCity(city, country)
          : const CityLocation(
              city: 'Datça',
              country: 'Türkiye',
              latitude: 36.7265,
              longitude: 27.6853,
              timezoneOffset: 3.0,
            );
      effectiveOffset = PredictiveAstrologyService.getHistoricalUtcOffset(
        cityLoc: cityLoc,
        dt: date,
        hour: time.hour,
        minute: time.minute,
      );
    }
    final utcDateTime = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).subtract(Duration(minutes: (effectiveOffset * 60).round()));
    final moonLon = SkyTransitsService.calculateMoonLongitude(utcDateTime);
    return _signFromLongitude(moonLon);
  }

  // Tam Doğum Haritası Hesaplayıcı (Geocentric, Placidus & Tarihsel Saat Dilimi Uyumlu)
  static BirthChartModel calculateChart({
    required String name,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    String? dateStr,
    String? timeStr,
    required String city,
    String? country,
  }) {
    DateTime resolvedDate = birthDate ?? DateTime(1995, 1, 1);
    if (birthDate == null && dateStr != null && dateStr.isNotEmpty) {
      if (dateStr.contains('-')) {
        final p = dateStr.split('-');
        if (p.length >= 3) {
          resolvedDate = DateTime(
            int.tryParse(p[0]) ?? 1995,
            int.tryParse(p[1]) ?? 1,
            int.tryParse(p[2]) ?? 1,
          );
        }
      } else if (dateStr.contains('.')) {
        final p = dateStr.split('.');
        if (p.length >= 3) {
          resolvedDate = DateTime(
            int.tryParse(p[2]) ?? 1995,
            int.tryParse(p[1]) ?? 1,
            int.tryParse(p[0]) ?? 1,
          );
        }
      }
    }

    TimeOfDay resolvedTime = birthTime ?? const TimeOfDay(hour: 12, minute: 0);
    if (birthTime == null && timeStr != null && timeStr.isNotEmpty) {
      final tp = timeStr.split(':');
      final h = tp.isNotEmpty ? (int.tryParse(tp[0]) ?? 12) : 12;
      final m = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;
      resolvedTime = TimeOfDay(hour: h, minute: m);
    }

    final cityLoc = WorldCitiesService.findCity(city, country);
    final utcOffset = PredictiveAstrologyService.getHistoricalUtcOffset(
      cityLoc: cityLoc,
      dt: resolvedDate,
      hour: resolvedTime.hour,
      minute: resolvedTime.minute,
    );

    final utcDateTime = DateTime.utc(
      resolvedDate.year,
      resolvedDate.month,
      resolvedDate.day,
      resolvedTime.hour,
      resolvedTime.minute,
    ).subtract(Duration(minutes: (utcOffset * 60).round()));

    final sunLon = SkyTransitsService.calculateSunLongitude(utcDateTime);
    final moonLon = SkyTransitsService.calculateMoonLongitude(utcDateTime);
    final angles = PredictiveAstrologyService.calculateAscAndMc(
      utcDateTime: utcDateTime,
      latitude: cityLoc.latitude,
      longitude: cityLoc.longitude,
    );
    final ascLon = angles['asc']!;
    final mcLon = angles['mc']!;
    final vertexLon = angles['vertex'] ?? ((ascLon + 210.0) % 360.0);
    final dscLon = (ascLon + 180.0) % 360.0;
    final icLon = (mcLon + 180.0) % 360.0;

    final pLons = SkyTransitsService.calculatePlanetsLongitudes(utcDateTime);
    final trueNorthNodeLon = pLons['true_node'] ?? pLons['node']!;
    final trueSouthNodeLon = (trueNorthNodeLon + 180.0) % 360.0;
    final meanNorthNodeLon = pLons['mean_node'] ?? trueNorthNodeLon;
    final meanSouthNodeLon = (meanNorthNodeLon + 180.0) % 360.0;

    PlanetPosition buildPos(String key, String label, double lon, {bool forceRetro = false, bool canRetro = true}) {
      final retro = forceRetro || (canRetro && SkyTransitsService.isPlanetRetrograde(key, utcDateTime));
      return PlanetPosition(
        name: label,
        sign: _signFromLongitude(lon),
        formatted: _formatPlanetDegree(lon, isRetrograde: retro),
        isRetrograde: retro,
        longitude: (lon % 360.0 + 360.0) % 360.0,
      );
    }

    final sunPos = buildPos('sun', 'Güneş', sunLon, canRetro: false);
    final moonPos = buildPos('moon', 'Ay', moonLon, canRetro: false);
    final ascPos = buildPos('ascendant', 'Yükselen (ASC)', ascLon, canRetro: false);
    final mercPos = buildPos('mercury', 'Merkür', pLons['mercury']!);
    final venPos = buildPos('venus', 'Venüs', pLons['venus']!);
    final marsPos = buildPos('mars', 'Mars', pLons['mars']!);
    final jupPos = buildPos('jupiter', 'Jüpiter', pLons['jupiter']!);
    final satPos = buildPos('saturn', 'Satürn', pLons['saturn']!);
    final uraPos = buildPos('uranus', 'Uranüs', pLons['uranus']!);
    final nepPos = buildPos('neptune', 'Neptün', pLons['neptune']!);
    final pluPos = buildPos('pluto', 'Plüton', pLons['pluto']!);
    final chiPos = buildPos('chiron', 'Chiron', pLons['chiron']!);
    final nnPos = buildPos('north_node', 'Kuzey Ay Düğümü (True)', trueNorthNodeLon, forceRetro: true);
    final snPos = buildPos('south_node', 'Güney Ay Düğümü (True)', trueSouthNodeLon, forceRetro: true);
    final trueNnPos = buildPos('true_north_node', 'Kuzey Ay Düğümü (True)', trueNorthNodeLon, forceRetro: true);
    final trueSnPos = buildPos('true_south_node', 'Güney Ay Düğümü (True)', trueSouthNodeLon, forceRetro: true);
    final meanNnPos = buildPos('mean_north_node', 'Kuzey Ay Düğümü (Mean)', meanNorthNodeLon, forceRetro: true);
    final meanSnPos = buildPos('mean_south_node', 'Güney Ay Düğümü (Mean)', meanSouthNodeLon, forceRetro: true);
    final mcPos = buildPos('mc', 'Tepe Noktası (MC)', mcLon, canRetro: false);
    final icPos = buildPos('ic', 'Dip Noktası (IC)', icLon, canRetro: false);
    final dscPos = buildPos('descendant', 'Alçalan (DSC)', dscLon, canRetro: false);
    final vertexPos = buildPos('vertex', 'Vertex (Vx)', vertexLon, canRetro: false);
    final lilithPos = buildPos('lilith', 'Kara Ay Lilith', pLons['lilith']!, canRetro: false);
    final ceresPos = buildPos('ceres', 'Ceres', pLons['ceres']!);
    final pallasPos = buildPos('pallas', 'Pallas', pLons['pallas']!);
    final junoPos = buildPos('juno', 'Juno', pLons['juno']!);
    final vestaPos = buildPos('vesta', 'Vesta', pLons['vesta']!);
    final amorPos = buildPos('amor', 'Amor', pLons['amor']!);
    final hekatePos = buildPos('hekate', 'Hekate', pLons['hekate']!);
    final isisPos = buildPos('isis', 'Isis', pLons['isis']!);

    final planetsMap = <String, PlanetPosition>{
      'sun': sunPos,
      'moon': moonPos,
      'ascendant': ascPos,
      'rising': ascPos,
      'mercury': mercPos,
      'venus': venPos,
      'mars': marsPos,
      'jupiter': jupPos,
      'saturn': satPos,
      'uranus': uraPos,
      'neptune': nepPos,
      'pluto': pluPos,
      'chiron': chiPos,
      'north_node': nnPos,
      'south_node': snPos,
      'true_north_node': trueNnPos,
      'true_south_node': trueSnPos,
      'mean_north_node': meanNnPos,
      'mean_south_node': meanSnPos,
      'mc': mcPos,
      'ic': icPos,
      'descendant': dscPos,
      'vertex': vertexPos,
      'lilith': lilithPos,
      'ceres': ceresPos,
      'pallas': pallasPos,
      'juno': junoPos,
      'vesta': vestaPos,
      'amor': amorPos,
      'hekate': hekatePos,
      'isis': isisPos,
    };

    final elementsCount = BirthChartModel.calculateElementScores(planetsMap);
    final modalitiesCount = BirthChartModel.calculateModalityScores(planetsMap);

    final rawChartData = <String, dynamic>{
      for (final entry in planetsMap.entries) entry.key: entry.value.formatted,
    };

    return BirthChartModel(
      name: name,
      sunFormatted: sunPos.formatted,
      moonFormatted: moonPos.formatted,
      risingFormatted: ascPos.formatted,
      sunSign: sunPos.sign,
      moonSign: moonPos.sign,
      risingSign: ascPos.sign,
      planets: planetsMap,
      elements: elementsCount,
      modalities: modalitiesCount,
      rawChart: rawChartData,
    );
  }

  // --- 3 KART: GÜNLÜK, SAMİMİ, MİZAHİ VE ANLAŞILIR DİL ---
  // --- 3 KART: GÜNLÜK, SAMİMİ, MİZAHİ VE ANLAŞILIR DİL ---
  static List<BrutalTruthModel> getBrutalTruths({
    required String name,
    required String sun,
    required String moon,
    required String ascendant,
    String? northNode,
    String gender = 'Erkek',
    String? mars,
    String? venus,
  }) {
    // Temiz burç adları
    final cleanSun = sun.split(' ').last;
    final cleanMoon = moon.split(' ').last;
    final cleanAsc = ascendant.split(' ').last;
    final cleanNorthNode = northNode != null && northNode.isNotEmpty
        ? northNode.replaceAll('(r)', '').trim().split(' ').last
        : null;

    final blindSpot = _getBlindSpot(name, cleanSun, cleanAsc);
    final relationshipIllusion = _getRelationshipIllusion(
      name: name,
      gender: gender,
      moon: cleanMoon,
      sun: cleanSun,
      mars: mars,
      venus: venus,
    );
    final soulTest = _getSoulTest(name, cleanNorthNode ?? cleanSun);

    return [
      BrutalTruthModel(id: 1, title: 'Psikolojik Kör Noktan', text: blindSpot),
      BrutalTruthModel(id: 2, title: 'İlişki Dinamikleri ve Projeksiyonların', text: relationshipIllusion),
      BrutalTruthModel(id: 3, title: 'Karmik Gelişim & Ruhun Sınavı', text: soulTest),
    ];
  }

  // 1. KART: Psikolojik Kör Noktan (Gölge Yönler & Farkındalık Alanı)
  static String _getBlindSpot(String name, String sun, String ascendant) {
    final Map<String, String> data = {
      'Koç': 'Doğum haritanızdaki Koç enerjisi; yüksek inisiyatif, cesaret ve doğrudan eyleme geçme gücü vadeder sevgili $name. Ancak bu yerleşimin psikolojik kör noktası; sabırsızlık, dinleme eşiğinin düşüklüğü ve her durumu bir mücadele veya rekabet alanı olarak algılama eğilimidir. Gerçek liderlik sadece hızla başlamak değil; sürecin olgunlaşmasına izin verecek stratejik sabrı gösterebilmektir.',
      'Boğa': 'Haritanızdaki Boğa aksı; sarsılmaz bir kararlılık, sadakat ve somut değer yaratma kabiliyeti taşır sevgili $name. Bununla birlikte gölge yönü; konfor alanına aşırı bağımlılık ve değişime karşı gösterilen katı dirençtir. Güvenlik arayışını bir savunma zırhına dönüştürmeden, hayatın sunduğu yeni olanaklara esneklikle yaklaşabilmek en büyük gelişim kapınızdır.',
      'İkizler': 'İkizler yerleşimi; kıvrak bir zeka, çok yönlü algı ve olağanüstü iletişim yeteneği sağlar sevgili $name. Ancak zihinsel hızınız, duygusal derinliğin önüne geçebilir. Rahatsız edici hislerle yüzleşmek yerine konuyu rasyonalize etme veya hızlıca yön değiştirme eğiliminiz, içsel huzursuzluk yaratabilir. Zihinsel dikkati derinleştirip dinginliği deneyimlemek gücünüzü pekiştirir.',
      'Yengeç': 'Haritanızdaki Yengeç etkisi; derin bir duygusal sezgi, koruyuculuk ve empati kapasitesi sunar sevgili $name. Bu konumun gölge tarafı ise; geçmiş deneyimlere aşırı tutunma ve kırgınlıkları içselleştirerek savunmacı bir kabuğa çekilme eğilimidir. Başkalarının sorumluluklarını üstlenip kendinizi ihmal etmek yerine, sağlıklı sınırlar koyarak öz-değerinizi korumalısınız.',
      'Aslan': 'Haritanızdaki Aslan enerjisi; doğal bir karizma, cömertlik ve üretken bir yaratıcılık barındırır sevgili $name. Psikolojik kör noktanız; dışsal onay ve takdir ihtiyacını öz-saygının önüne koyma riskidir. Görünür olamadığınızı hissettiğiniz anlarda gurur savunmalarına sığınmak yerine, değerinizin dış alkışlardan bağımsız olduğunu hatırlamak gerçek içsel gücünüzü açığa çıkarır.',
      'Başak': 'Başak yerleşimi; keskin bir muhakeme, analitik ustalık ve sistem kurma dehası kazandırır sevgili $name. Ancak bu potansiyelin kör noktası; aşırı özeleştiri, detaylarda kaybolarak büyük resmi kaçırma ve kusursuzluk arayışıyla eylemi erteleme tehlikesidir. Bütünün mükemmelliğinin küçük kusurların kabulünde yattığını görmek zihinsel yükünüzü hafifletecektir.',
      'Terazi': 'Terazi aksı; zarafet, adalet duygusu ve yüksek estetik kavrayış getirir sevgili $name. Gölge yönünüz ise; uyum ve huzuru koruma arzusuyla kendi gerçek isteklerinizi öteleme ve karar alma süreçlerinde yaşanan yıpratıcı tereddüttür. Sağlıklı çatışmaların sınırları güçlendirdiğini kabul edip net duruş sergilemek içsel dengenizi sağlar.',
      'Akrep': 'Haritanızdaki Akrep yerleşimi; olağanüstü bir psikolojik derinlik, dayanıklılık ve dönüştürücü güç taşır sevgili $name. Bununla birlikte kör noktanız; incinme korkusundan doğan savunmacı şüphecilik ve hayatı sürekli kontrol altında tutma arzusudur. Güven kapısını kontrollü bir teslimiyete açtığınızda, krizleri aşan bilgeliğiniz en büyük rehberiniz olur.',
      'Yay': 'Yay enerjisi; yüksek vizyon, yaşam coşkusu ve felsefi bir hakikat arayışı vadeder sevgili $name. Bu etkinin kör noktası; kısıtlamalara ve günlük sorumluluklara karşı tahammülsüzlük, detayları yüzeysel geçiştirme ve aşırı iyimserlikle riskleri küçümseme eğilimidir. Vizyonunuzu disiplinli bir odaklanmayla birleştirdiğinizde hedefleriniz kalıcı başarılara dönüşür.',
      'Oğlak': 'Oğlak aksı; muazzam bir sorumluluk bilinci, stratejik sabır ve zirveye ulaşma iradesi verir sevgili $name. Psikolojik kör noktanız; başarısızlık kaygısıyla duygusal ihtiyaçları bastırma ve hayatı yalnızca yerine getirilmesi gereken görevlerden ibaret görme yanılgısıdır. Kendi kırılganlığınıza şefkat göstermek ve süreci kutlamak olgunluğunuzu taçlandırır.',
      'Kova': 'Kova yerleşimi; vizyoner bir özgünlük, hümanist bir adalet anlayışı ve geleceği okuma sezgisi kazandırır sevgili $name. Ancak gölge tarafınız; duygusal bağlarda mesafeli kalma, entelektüel üstünlük zırhı ardına saklanma ve bireysel samimiyetten çekinme eğilimidir. Akıl ile kalp arasındaki köprüyü kurduğunuzda fikirleriniz gerçek bir ilhama dönüşür.',
      'Balık': 'Haritanızdaki Balık etkisi; sınırsız bir şefkat, sanatsal ilham ve evrensel bir algı derinliği sunar sevgili $name. Bu yerleşimin kör noktası; somut gerçekliklerin zorlukları karşısında hayal dünyasına kaçma ve sınır çizememekten kaynaklanan duygusal tükeniştir. Ayaklarınızı yere sağlam basarak sezgilerinizi pratik dünyaya demirlemek en büyük gücünüzdür.',
    };

    return data[ascendant] ?? data[sun] ?? 'Doğum haritanızdaki temel akslar, kendinize olan dürüstlüğünüzü korudukça en büyük rehberiniz haline gelecektir sevgili $name.';
  }

  // 2. KART: İlişkilerdeki Yanılgın (Cinsiyete Göre: Kadınlarda Mars/Güneş, Erkeklerde Venüs/Ay)
  static String _getRelationshipIllusion({
    required String name,
    required String gender,
    required String moon,
    required String sun,
    String? mars,
    String? venus,
  }) {
    final cleanMars = (mars != null && mars.isNotEmpty)
        ? mars.replaceAll('(r)', '').trim().split(' ').last
        : sun;
    final cleanVenus = (venus != null && venus.isNotEmpty)
        ? venus.replaceAll('(r)', '').trim().split(' ').last
        : moon;

    if (gender == 'Kadın') {
      return _getFemaleRelationshipIllusion(name, cleanMars, sun);
    } else if (gender == 'Hermafrodit / Diğer') {
      return _getIntersexRelationshipIllusion(name, cleanVenus, cleanMars);
    } else {
      // Erkek haritası: Venüs ve Ay üzerinden
      return _getMaleRelationshipIllusion(name, cleanVenus, moon);
    }
  }

  // Kadın Haritalarında İlişkideki Yanılgı (Mars & Güneş - İçsel Eril Projeksiyonu)
  static String _getFemaleRelationshipIllusion(String name, String mars, String sun) {
    final Map<String, String> data = {
      'Koç': 'Bir kadın haritasında Mars ve Güneş hattı, aşktaki eril çekim alanını ve yanılgılarını belirler sevgili $name. Mars Koç etkisiyle aşkta fazla iddialı, rekabetçi ve fethetmeyi seven partnerlere kapılabiliyorsun. Yanılgın ise, ilk günkü fırtına sakinleştiğinde bunu hemen sıkıcı sanıp bağdan şüphe etmek. Gerçek aşk, yangının yerini güvenli bir yol arkadaşlığına bıraktığı an başlar.',
      'Boğa': 'Sevgili $name, kadın haritanda Mars Boğa etkisi partnerinde sarsılmaz bir kale ve sonsuz sadakat aratır. Yanılgın, partnerini aşırı konfor alanına hapsetmeye çalışmak ya da değişmeyen rutinleri sevginin tek kanıtı saymak olabilir. Biraz nefes aldırıp esnek kaldığında ilişkinin çok daha bereketli aktığını göreceksin.',
      'İkizler': 'Sevgili $name, haritandaki Mars İkizler ve Güneş hattı zihinsel kıvraklığa, esprilere ve tatlı dilli erkeklere kolayca çekildiğini gösteriyor. Yanılgın ise, kelimelerine hayran olduğun kişilerin duygusal derinlik veya istikrar gösterememesi karşısında hayal kırıklığına uğramak. Sevginin sohbetle başlayıp tutarlılıkla büyüdüğünü hatırla.',
      'Yengeç': 'Sevgili $name, kadın haritanda Mars Yengeç enerjisi sana koruyucu, şefkatli bir liman aratır. Fakat yanılgın, partnerine aşık olmak yerine ona annelik yapmaya kalkmak ve karşılık alamayınca içten içe kırılıp sessizce küsmek olabilir. İhtiyaçlarını tatlı dille açıkça konuştuğunda kırgınlıklar hızla sevgiye dönüşür.',
      'Aslan': 'Sevgili $name, haritandaki Mars Aslan hattı sahnesi olan, gururlu ve karizmatik erkek profillerine çekildiğini gösterir. Yanılgın, partnerinin egosunu beslerken kendi ışığının gölgede kaldığını hissettiğinde gurur savaşına girmek olabilir. İki tarafın da eşit parladığı bir denge kurduğunda aşk senin en büyük neşen olur.',
      'Başak': 'Sevgili $name, Mars Başak yerleşimiyle partnerinin çalışkan, tertipli ve her şeyi çözen biri olmasını beklersin. Yanılgın ise, partnerini sürekli bir revizyon projesi gibi görüp eleştirmek ya da en ufak kusurda soğumak olabilir. Bırak karşındaki insan biraz kusurlu kalsın; aşk o kusurların içinde filizlenir.',
      'Terazi': 'Sevgili $name, kadın haritanda Mars Terazi etkisi seni romantik, kibar ve nazik profillere çeker. Yanılgın, sırf huzursuzluk çıkmasın ya da yalnız kalmayasın diye kendi sınırlarından taviz vermek ve pasif kalan partnerleri idare etmeye çalışmak olabilir. Net bir duruş sergilediğinde hak ettiğin değeri doğal olarak görürsün.',
      'Akrep': 'Sevgili $name, Mars Akrep yerleşimi ilişkilerde tutkulu, derin ve gizemli partnerlere çekilmene yol açar. Yanılgın ise, incinmekten öyle korkmandır ki partnerini gizli testlere tabi tutar, dedektiflik yapar ve ilişkiyi krizlerle sınarsın. Güven kapısını yavaşça araladığında aradığın o ruhani derinliği bulacaksın.',
      'Yay': 'Sevgili $name, Mars Yay hattı seni özgür, vizyoner ve eğlenceli partnerlere çeker. Yanılgın, bağlanmayı özgürlüğün sonu gibi gören ya da geleceğe dair somut adım atmayan kişilere gereğinden fazla tolerans göstermek olabilir. Ortak hedeflere doğru birlikte koşabileceğin bir partner seçtiğinde huzur bulacaksın.',
      'Oğlak': 'Sevgili $name, kadın haritanda Mars Oğlak etkisi seni güçlü, saygın, kariyer sahibi ve olgun partnerlere yöneltir. Yanılgın, aşkı bir şirket ortaklığı veya görev listesi gibi yaşayıp duyguları göstermeyi zayıflık sanmak olabilir. Gardını indirip sıcaklığını paylaştığında ilişkin gerçek bir yuvaya dönüşür.',
      'Kova': 'Sevgili $name, Mars Kova hattı seni marjinal, entelektüel ve arkadaş canlısı partnerlere çeker. Yanılgın, aşırı duygusal yakınlık anlarında buz gibi mantıkçı kalıp partnerinin sarılma ve şefkat ihtiyacını yok saymak olabilir. Kalpten kalbe bağ kurmaya izin verdiğinde aradığın gerçek yoldaşlığı bulursun.',
      'Balık': 'Sevgili $name, kadın haritanda Mars Balık etkisi seni sanatçı ruhlu, yaralı veya kurtarılmaya muhtaç partnerlere çeker. Yanılgın, kurban-kurtarıcı tuzağına düşüp sınır çizememek ve kendi ihtiyaçlarını unutmaktır. Sınırlarını koruyarak sevdiğinde gerçek bir masal yaşayabilirsin.',
    };

    return data[mars] ?? 'İlişkilerinde partnerini değil, kendi korkularını yönetmeye çalışıyorsun sevgili $name.';
  }

  // Erkek Haritalarında İlişkideki Yanılgı (Venüs & Ay - İçsel Dişil Projeksiyonu)
  static String _getMaleRelationshipIllusion(String name, String venus, String moon) {
    final Map<String, String> data = {
      'Koç': 'Bir erkek haritasında Venüs ve Ay hattı, aşkta neyi arzuladığını ve nerede yanılgıya düştüğünü belirler sevgili $name. Venüs Koç enerjisiyle ilk baştaki heyecan ve fethetme arzusunu aşk zannedebiliyorsun. İlişki sakinleşip güvenli bir rotaya girdiğinde hemen sıkıldığını düşünmek senin en büyük yanılgın. Gerçek bağ, heyecanın yerini derin bir sadakate bıraktığı yerde başlar.',
      'Boğa': 'Sevgili $name, erkek haritanda Venüs Boğa yerleşimiyle partnerini sahiplenmeyi ve ona konforlu bir dünya sunmayı seversin. Yanılgın ise, sevgiyle kontrol etmeyi karıştırmak ve karşındakinin bağımsız hareketlerine gereksiz alınmak olabilir. Güven verdikçe ve özgür bıraktıkça aşkın daha da güçlenecektir.',
      'İkizler': 'Sevgili $name, Venüs İkizler etkisiyle zeki, esprili ve konuşkan kadınlara kapılırsın. Yanılgın, derin duygusal meseleler açıldığında hemen konuyu espriye vurup yüzeyselleşmek ya da çabuk sıkılıp mesajlara geç dönmek olabilir. Biraz durup duyguların ağırlığını paylaştığında karşındakiyle sarsılmaz bir bağ kuracaksın.',
      'Yengeç': 'Sevgili $name, erkek haritanda Venüs ve Ay hattı derin bir aidiyet ve şefkat arar. Yanılgın ise, partnerine aşık olmak yerine ona annelik misyonu yüklemek ve neye kırıldığını söylemeden surat asarak karşı tarafın tahmin etmesini beklemektir. Duygularını tatlı dille açıkça konuştuğunda ilişkin rayına oturur.',
      'Aslan': 'Sevgili $name, Venüs Aslan yerleşimiyle partnerinin göz alıcı, gurur duyulacak bir kraliçe olmasını istersin. Yanılgın, ilişkide sürekli senin alkışlanmanı ve senin havanın basılmasını beklemek olabilir. Partnerine de aynı cömertlikle sahne verdiğinde aradığın gerçek aşkı bulursun.',
      'Başak': 'Sevgili $name, Venüs Başak etkisiyle partnerinin hayatını kolaylaştırmaya çalışırsın. Yanılgın ise, sevmek yerine karşındakini sürekli eğitmek, kusurlarını düzeltmeye çalışmak ve romantizmi bir denetim sürecine çevirmektir. İnsanları tatlı kusurlarıyla sevmeyi öğrendiğinde huzur bulacaksın.',
      'Terazi': 'Sevgili $name, Venüs Terazi hattı romantizm, estetik ve uyum arayışını simgeler. Yanılgın, sırf huzursuzluk çıkmasın ya da yalnız kalmayasın diye sana hiç uymayan kişilere gereğinden fazla taviz vermek olabilir. Kendi sınırlarını net çizdiğinde aşk hayatın çok daha sağlıklı dengelenir.',
      'Akrep': 'Sevgili $name, erkek haritanda Venüs Akrep yerleşimi tutkulu ve ölümüne sadık bir bağ arar. Yanılgın, incinmekten korktuğun için aşırı şüphecilik yapmak, gizli testler uygulamak ve partnerini baskıyla bunaltmaktır. Güven kapısını araladığında aradığın o derin ruh bağını bulacaksın.',
      'Yay': 'Sevgili $name, Venüs Yay etkisiyle neşeli, özgür ve maceracı kadınlara çekilirsin. Yanılgın, bağlanmayı bir pranga gibi görüp iş ciddiye bindiğinde kaçacak delik aramak olabilir. Birlikte dünyayı keşfedebileceğin bir partnerle bağlanmanın en büyük özgürlük olduğunu göreceksin.',
      'Oğlak': 'Sevgili $name, Venüs Oğlak yerleşimiyle ilişkilerde güvenilir ve sağlam bir limansın. Yanılgın ise duygularını açmayı bir zayıflık sayıp romantizmi bir iş anlaşması gibi soğuk yaşamak olabilir. Gardını indirip sıcaklığını gösterdiğinde sevginin gücünü hissedeceksin.',
      'Kova': 'Sevgili $name, Venüs Kova hattı fikir yoldaşlığı ve dostluk temelli aşkı arar. Yanılgın, duygusal anlarda aşırı mantık yapıp karşındakinin sarılma ve teselli ihtiyacını analizlerle savuşturmaktır. Mantığı bir kenara bırakıp kalpten sarıldığında aşkın çiçek açar.',
      'Balık': 'Sevgili $name, Venüs Balık yerleşimiyle sonsuz bir romantizm ve fedakarlık potansiyelin var. Yanılgın, partnerini kafandaki o kusursuz peri masalına oturtup sıradan insan hallerini görünce derin hayal kırıklığına uğramaktır. İnsanları gerçek halleriyle sevmeyi öğrendiğinde gerçek masal başlar.',
    };

    return data[venus] ?? 'İlişkilerinde partnerini değil, kendi korkularını yönetmeye çalışıyorsun sevgili $name.';
  }

  // Hermafrodit / Diğer (Eril ve Dişil Kutupsallığın Bütünleşik Dengesi)
  static String _getIntersexRelationshipIllusion(String name, String venus, String mars) {
    return 'Sevgili $name, haritanda eril (Mars $mars) ve dişil (Venüs $venus) enerjilerin benzersiz bir dengesi var. İlişkilerdeki en büyük yanılgın, kendi içindeki bu zengin kutupsallığı tek bir partnerin tek başına tamamlamasını beklemek olabilir. Dışarıdan onay aramak yerine kendi içsel ahengine güvendiğinde, ilişkilerin en saf ve dönüştürücü formuna ulaşacaktır.';
  }

  // 3. KART: Ruhunun Asıl Sınavı (Kuzey Ay Düğümü - Karakter ve Psikolojik Olgunlaşma Yolu)
  // Kesinlikle dogma, din veya ölüm konularına girmeden; psikolojik tekamül ve hayat amacı.
  static String _getSoulTest(String name, String nodeSign) {
    final Map<String, String> data = {
      'Koç': 'Kuzey Ay Düğümün Koç\'ta sevgili $name. Senin bu hayattaki en büyük sınavın: Kendi isteklerinin arkasında durabilmek ve "Önce ben" diyebilmek. Sürekli herkesi memnun etmeye, çatışma çıkmasın diye kendi hayallerinden taviz vermeye çok alışıksın. Ama senin asıl büyüme yolun, başkalarının onayını beklemeden tek başına adım atabilme cesaretini göstermekten geçiyor. Ne istediğini net söyle, korkma kimse senden uzaklaşmaz.',
      'Boğa': 'Kuzey Ay Düğümün Boğa\'da sevgili $name. Ruhunun bu hayattaki asıl sınavı: İçsel dinginliği ve basitliğin güzelliğini bulmak. Sürekli bir kriz, gizem ya da fırtına aramak yerine; hayatı sakin, güvenli ve üretken yaşamayı öğrenmelisin. Her şey bir güç savaşı olmak zorunda değil. Kendi değerini dışarıdaki onaylara değil, ürettiğin somut güzelliklere ve iç huzuruna bağladığında hayatın rayına oturacak.',
      'İkizler': 'Kuzey Ay Düğümün İkizler\'de sevgili $name. Senin bu hayattaki sınavın: Büyük nutuklar atmak yerine gerçekten dinlemeyi öğrenmek. Her şeyi zaten biliyormuş gibi davranma tuzağından çıkıp, bir meraklı öğrenci gibi yaklaşmalısın hayata. Karmaşık felsefelere dalmak yerine günlük hayatın küçük detaylarına odaklan, insanları yargılamadan dinle. Bazen en büyük bilgelik, basit bir soruda ve içten bir sohbette gizlidir.',
      'Yengeç': 'Kuzey Ay Düğümün Yengeç\'te sevgili $name. Ruhunun asıl sınavı: O taş gibi sert kabuğu indirip duygularını yaşamaya izin vermek. Hayatı sadece görevler, sorumluluklar ve başarı grafiğinden ibaret sanma alışkanlığını kırmalısın. İhtiyacın olan şey daha fazla unvan ya da başarı değil; kendine ve sevdiklerine şefkat göstermek, kırılganlığını zayıflık değil insanlık olarak görebilmektir.',
      'Aslan': 'Kuzey Ay Düğümün Aslan\'da sevgili $name. Senin bu hayattaki sınavın: Sahnenin ortasına geçip kendi özgün ışığını çekinmeden parlatmak. Kalabalıkların veya grupların arkasına saklanıp "benim için fark etmez" tavrını bir kenara bırak. Kalbinin neyle coştuğunu keşfet, yaratıcılığına güven ve içindeki çocuğu neşeyle sergile. Kendi liderliğini sahiplenmekten çekinme.',
      'Başak': 'Kuzey Ay Düğümün Başak\'ta sevgili $name. Ruhunun sınavı: Hayaller ve kurban rolünden sıyrılıp günlük hayatın pratik gerçeklerine odaklanmak. Belirsizlikler içinde kaybolup "kader kısmet" demek yerine, hayatını adım adım organize etmeyi ve somut çözümler üretmeyi öğrenmelisin. Kendi sınırlarını çizmek, bedenine iyi bakmak ve faydalı bir düzen kurmak sana en büyük huzuru getirecek.',
      'Terazi': 'Kuzey Ay Düğümün Terazi\'de sevgili $name. Bu hayattaki sınavın: "Tek başıma da yaparım" inadından çıkıp paylaşmayı ve gerçek iş birliğini öğrenmek. Sürekli bir yarış veya savunma halinde olmak yerine, karşınızdakinin penceresinden bakabilmek senin olgunlaşma anahtarın. Köprüleri yıkmak yerine diplomasi ve nezaketle bağlar kurduğunda hayatın çok daha bereketli akacak.',
      'Akrep': 'Kuzey Ay Düğümün Akrep\'te sevgili $name. Ruhunun sınavı: Konfor alanının ve maddiyatın sahte güvenliğine saplanıp kalmaktan vazgeçmek. Değişimden, dönüşümden ve derinleşmekten korkma. Bazen eskimiş şeyleri bırakmak ve kontrolü serbest bırakmak gerekir. Yüzeysel rahatlığı değil, duygusal cesareti ve içsel dönüşümü seçtiğinde gerçek gücünü keşfedeceksin.',
      'Yay': 'Kuzey Ay Düğümün Yay\'da sevgili $name. Senin bu hayattaki sınavın: Dedikodular, anlık detaylar ve bilgi kirliliği arasında boğulmaktan çıkıp büyük resmi görebilmek. Kendi hayat vizyonunu, inançlarını ve hedeflerini belirle. Sürekli "acaba hangisi" diye zihinsel kararsızlık yaşamak yerine, bir yöne inanarak cesurca yola çık.',
      'Oğlak': 'Kuzey Ay Düğümün Oğlak\'ta sevgili $name. Ruhunun bu hayattaki asıl sınavı: Duygusal sığınaklara veya alınganlıklara kaçmak yerine, kendi hayatının olgun kaptanı olmak. "Beni korusunlar, sahip çıksınlar" refleksini geride bırakıp; hedeflerini adım adım inşa eden, kendi ayakları üzerinde dimdik duran o saygın yetişkini ortaya çıkarma vaktin geldi. Disiplin, sabır ve duygusal bağımsızlık senin en parlak hazinen.',
      'Kova': 'Kuzey Ay Düğümün Kova\'da sevgili $name. Senin sınavın: Kişisel ego ve sürekli alkış alma ihtiyacını aşıp, toplumsal bir amaca veya kolektif iyiliğe katkı sağlamak. "Sadece benim dediklerim" merkezinden çıkıp, herkesle eşit ve adil dostluklar kurabilmelisin. Bireysel parlamaktan ziyade bir ekibin, insanlığın parçası olduğunu hissettiğinde gerçek doyum bulacaksın.',
      'Balık': 'Kuzey Ay Düğümün Balık\'ta sevgili $name. Ruhunun bu hayattaki sınavı: Aşırı eleştiri, kontrol takıntısı ve her şeyi mükemmel yapma kaygısını serbest bırakmak. Hayat bir kontrol tablosu değil; bazen akışa güvenmek, affetmek ve mantığın ötesindeki sezgilerine kulak vermek gerekir. Kusurları kabullenip şefkatle yaklaştığında ruhun derin bir nefes alacak.',
    };

    return data[nodeSign] ?? 'Ruhunun asıl gücü, kendi potansiyelini kabul edip cesaretle yola çıktığın gün parlayacak $name.';
  }

  static String _extractSignName(String raw) {
    final cleaned = raw.replaceAll('(r)', '').trim();
    if (cleaned.isEmpty) return 'Koç';
    return cleaned.split(' ').last;
  }

  // Günlük Gerçek Zamanlı Transit Yorumu (Günün Enerjisi)
  static DailyHoroscopeModel getDailyHoroscope({
    required String name,
    required String targetSign,
    String? sunSign,
    String? moonSign,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final cleanAsc = _extractSignName(targetSign);
    final cleanSun = _extractSignName(sunSign ?? targetSign);
    final cleanMoon = _extractSignName(moonSign ?? targetSign);

    final formattedName = name.trim().isEmpty
        ? 'Danışan'
        : (name.startsWith('i') || name.startsWith('İ')
            ? 'İ${name.substring(1)}'
            : name.startsWith('ı') || name.startsWith('I')
                ? 'I${name.substring(1)}'
                : '${name[0].toUpperCase()}${name.substring(1)}');

    final transits = SkyTransitsService.getCurrentTransits();
    TransitPlanet? findBody(String bodyName) {
      for (final b in transits) {
        if (b.name == bodyName) return b;
      }
      return null;
    }

    final tSun = findBody('Güneş');
    final tMoon = findBody('Ay');
    final tMercury = findBody('Merkür');
    final tVenus = findBody('Venüs');
    final tMars = findBody('Mars');
    final tJupiter = findBody('Jüpiter');

    final moonPhase = SkyTransitsService.getMoonPhase();
    final voc = SkyTransitsService.getVoidOfCourse();
    final viaCombusta = SkyTransitsService.getViaCombustaInfo();

    final transitSunSign = tSun?.sign ?? 'Koç';
    final transitSunDeg = tSun?.degree ?? 15;
    final transitMoonSign = tMoon?.sign ?? 'Boğa';
    final transitMoonDeg = tMoon?.degree ?? 12;

    int signHouse(String ascSign, String target) {
      final aIdx = zodiacSigns.indexOf(ascSign);
      final tIdx = zodiacSigns.indexOf(target);
      if (aIdx < 0 || tIdx < 0) return 1;
      return ((tIdx - aIdx + 12) % 12) + 1;
    }

    final sunHouse = signHouse(cleanAsc, transitSunSign);
    final moonHouse = signHouse(cleanAsc, transitMoonSign);
    final lang = AppTranslationService.currentLang;

    final Map<int, String> houseThemes = lang == 'ja'
        ? const {
            1: '第1ハウス (個人の存在感、バイタリティ、新たな始まり)',
            2: '第2ハウス (物質的資源、財務管理、自己価値)',
            3: '第3ハウス (コミュニケーション、身近な環境、合意、知的好奇心)',
            4: '第4ハウス (家庭、家族、ルーツ、心の基盤)',
            5: '第5ハウス (愛、創造性、モチベーション、自己表現)',
            6: '第6ハウス (日々のルーティン、義務、健康維持)',
            7: '第7ハウス (対人関係、パートナーシップ、交渉)',
            8: '第8ハウス (共有資産、変革、深い心理的洞察)',
            9: '第9ハウス (長期的なビジョン、哲学、高等教育、探求)',
            10: '第10ハウス (キャリア、社会的地位、大きな達成)',
            11: '第11ハウス (未来の計画、友情、グループ活動)',
            12: '第12ハウス (潜在意識、精神的休息、舞台裏の準備)',
          }
        : lang == 'en'
            ? const {
                1: '1st House (personal presence, physical energy and new beginnings)',
                2: '2nd House (material resources, financial management and self-worth)',
                3: '3rd House (communication, close environment, agreements and mental focus)',
                4: '4th House (home, family, roots and emotional foundation)',
                5: '5th House (love, creativity, motivation and joyful expression)',
                6: '6th House (daily routines, responsibilities and wellness)',
                7: '7th House (partnerships, close relationships and diplomacy)',
                8: '8th House (shared resources, crisis management and transformation)',
                9: '9th House (long-range vision, wisdom, education and higher perspectives)',
                10: '10th House (career, public reputation and core milestones)',
                11: '11th House (future ambitions, social networks and collaborative efforts)',
                12: '12th House (subconscious, spiritual rest and behind-the-scenes reflection)',
              }
            : const {
                1: '1. eviniz (bireysel duruş, fiziksel enerji ve yeni başlangıçlar)',
                2: '2. eviniz (maddi kaynaklar, bütçe yönetimi ve öz değer)',
                3: '3. eviniz (iletişim, yakın çevre, anlaşmalar ve zihinsel trafik)',
                4: '4. eviniz (ev, aile, kökler ve içsel güvenlik alanı)',
                5: '5. eviniz (aşk, yaratıcılık, motivasyon ve keyif alanı)',
                6: '6. eviniz (günlük çalışma düzeni, sorumluluklar ve sağlık)',
                7: '7. eviniz (ikili ilişkiler, ortaklıklar ve açık muhataplar)',
                8: '8. eviniz (finansal paylaşımlar, kriz yönetimi ve derin dönüşüm)',
                9: '9. eviniz (uzak hedefler, vizyon, eğitim ve hukuki/akademik konular)',
                10: '10. eviniz (kariyer, toplumsal statü ve görünür hedefler)',
                11: '11. eviniz (gelecek projeleri, sosyal çevre ve ekip çalışmaları)',
                12: '12. eviniz (bilinçaltı, ruhsal dinlenme ve perde arkası hazırlıklar)',
              };

    final Map<int, String> moonHouseAdvice = lang == 'ja'
        ? const {
            1: '本日は感情的なニーズと自分自身の優先順位が前面に出ます。明確な自己表現が運気を拓きます。',
            2: '経済的な基盤と価値あるものに焦点を当てることが安定をもたらします。着実な選択が吉です。',
            3: '情報伝達や対話が活性化します。戦略的かつ明晰に思考を伝えることが有利に働きます。',
            4: '家庭や安心できる居場所を整え、内なる静寂を取り戻すのに最適なタイミングです。',
            5: '創造的な意欲や心躍る交流が、今日のあなたを輝かせる最大のエネルギー源となります。',
            6: '日頃の業務を整理し、細部を丁寧に整え、身体のケアに配慮するのに適した日です。',
            7: '対人関係において相手への共感と公平なバランスを保つことが、円滑な進展をもたらします。',
            8: '共有の財政や深く掘り下げたい専門分野に関して、鋭い直感と洞察力が発揮されます。',
            9: '視野を広げる学びや将来の展望を描くことで、大きな精神的高揚と前進が得られます。',
            10: 'キャリアや公の場において、きめ細やかな配慮と知性を発揮し存在感を示せます。',
            11: '志を同じくする友人やネットワークから、有益な刺激や支援を受け取れる兆しです。',
            12: '少しペースを落とし、直感に耳を傾けながら舞台裏で準備を進めることが最高の成果を生みます。',
          }
        : lang == 'en'
            ? const {
                1: 'Your emotional needs and personal priorities take center stage today; express your boundaries with clear confidence.',
                2: 'Focusing on your financial stability and personal assets brings grounding; prudent decisions are favored.',
                3: 'Your communication and networking traffic is brisk; express your insights with calm strategic clarity.',
                4: 'Matters regarding home, family and inner sanctuary become prominent; give yourself time to recharge.',
                5: 'Creative vitality, romantic warmth and pleasurable activities serve as your chief source of inspiration today.',
                6: 'An ideal day to streamline daily workflows, handle pending details and nurture your physical well-being.',
                7: 'Balancing mutual empathy with clear perspective plays a vital role in all one-on-one relationships today.',
                8: 'Your intuition regarding shared investments, financial arrangements or deep emotional shifts is razor sharp.',
                9: 'Gaining fresh perspective through study, future travel or broader conceptual thinking uplifts your spirit.',
                10: 'Applying emotional intelligence within your professional sphere helps you make a meaningful, noticeable impact.',
                11: 'Positive developments and collaborative support from your social circle and long-term allies are highlighted.',
                12: 'Slowing your pace, gathering strength and planning quietly behind the scenes yields exceptional rewards today.',
              }
            : const {
                1: 'Bugün duygusal ihtiyaçlarınız ve kişisel öncelikleriniz ön planda; dış dünyaya net bir duruş sergileyebilirsiniz.',
                2: 'Finansal güvenliğiniz ve sahip olduğunuz değerler üzerine odaklanmak, harcamalarda sağlamcı davranmak kazandıracaktır.',
                3: 'Telefon trafiğiniz, yazışmalarınız ve kısa görüşmeleriniz hızlanıyor; fikirlerinizi stratejik biçimde ifade edin.',
                4: 'Ev ve aile içi konular, yaşam alanınızı düzenleme veya içsel huzura çekilme ihtiyacınız bugün belirginleşiyor.',
                5: 'Yaratıcı enerjiniz, romantik paylaşımlar ve size neşe veren uğraşlar bugün ruhunuzu besleyen ana kaynak olacak.',
                6: 'Günlük iş akışınızı organize etmek, yarım kalan detayları toparlamak ve beden sağlığınıza özen göstermek için ideal bir gün.',
                7: 'Partnerinizle veya iş ortaklarınızla empati ve denge kurmak, bugün ilişkilerinizde kilit rol oynuyor.',
                8: 'Ortaklaşa paralar, banka/vergi işleri veya psikolojik olarak derinleştiğiniz konularda sezgileriniz oldukça keskin.',
                9: 'Ufkunuzu genişletecek yeni bir bilgi, eğitim, seyahat planı veya uzun vadeli vizyon çalışması bugün size iyi gelecek.',
                10: 'Kariyerinizde ve üstlerinizle ilişkilerinizde duygusal zekanızı kullanarak dikkat çekici bir adım atabilirsiniz.',
                11: 'Dostlarınız, sosyal çevreniz ve gelecek hedeflerinizle ilgili konularda destekleyici gelişmeler yaşanabilir.',
                12: 'Biraz yavaşlamak, enerjinizi toplamak ve sezgilerinizi dinleyerek perde arkasında plan yapmak bugün çok daha verimli.',
              };

    final sunHouseDesc = houseThemes[sunHouse] ?? '$sunHouse. House';
    final moonHouseDesc = houseThemes[moonHouse] ?? '$moonHouse. House';
    final moonAdvice = moonHouseAdvice[moonHouse] ?? '';

    final retroPlanets = <String>[];
    for (final p in [tMercury, tVenus, tMars, tJupiter]) {
      if (p != null && p.isRetrograde) {
        retroPlanets.add('${AppTranslationService.planetName(p.name)} (${AppTranslationService.signName(p.sign)})');
      }
    }

    final buffer = StringBuffer();
    if (lang == 'ja') {
      buffer.write(
        '親愛なる $formattedName 様、本日 ($dateStr) の天空では太陽が${AppTranslationService.signName(transitSunSign)}の$transitSunDeg°を運行し、アセンダント${AppTranslationService.signName(cleanAsc)}チャートの$sunHouseDescを照らしています。',
      );
      buffer.write(
        ' トランジットの月は${AppTranslationService.signName(transitMoonSign)} ($transitMoonDeg°) を「${AppTranslationService.tr(moonPhase.phaseName)}」フェーズ (輝面比 ${moonPhase.illuminationPercent.toInt()}%) で運行し、本日の焦点を$moonHouseDescのテーマへと向けています。$moonAdvice ',
      );

      if (tMercury != null && tVenus != null && tMars != null) {
        buffer.write(
          '\n\n天空のコミュニケーションと行動ライン: 水星${AppTranslationService.signName(tMercury.sign)} (${tMercury.degree.toInt()}°)${tMercury.isRetrograde ? " [逆行]" : ""}、金星${AppTranslationService.signName(tVenus.sign)} (${tVenus.degree.toInt()}°)、火星${AppTranslationService.signName(tMars.sign)} (${tMars.degree.toInt()}°) の組み合わせが、ネイタル太陽 (${AppTranslationService.signName(cleanSun)}) および月 (${AppTranslationService.signName(cleanMoon)}) と調和し、思考の明晰さと戦略的バランスをもたらします。',
        );
      }

      if (retroPlanets.isNotEmpty) {
        buffer.write(
          ' 現在天界で逆行中の ${retroPlanets.join(", ")} の影響により、新規の契約や性急な決断は細部を二重に確認することが賢明です。',
        );
      }

      if (voc.isVoid) {
        buffer.write(
          '\n\n⚠️ ボイドタイム警告: ${AppTranslationService.tr(voc.advice)} (${AppTranslationService.signName(voc.nextSign)} への移行: ${voc.nextIngressTime})',
        );
      } else if (viaCombusta.isViaCombusta) {
        buffer.write(
          '\n\n🔥 ビア・コンブスタ (燃焼の道) 留意事項: 月が天秤座から蠍座へと向かう繊細な度数を通過しているため、感情的な反応を急がず冷静さを保つことが大きな恩恵をもたらします。',
        );
      }
    } else if (lang == 'en') {
      buffer.write(
        'Dear $formattedName, today ($dateStr) the Sun is advancing at $transitSunDeg° of ${AppTranslationService.signName(transitSunSign)}, illuminating your $sunHouseDesc in your Ascendant ${AppTranslationService.signName(cleanAsc)} chart. ',
      );
      buffer.write(
        'Transit Moon is traveling through ${AppTranslationService.signName(transitMoonSign)} ($transitMoonDeg°) in the "${AppTranslationService.tr(moonPhase.phaseName)}" phase (${moonPhase.illuminationPercent.toInt()}% illumination), shifting your focus today to your $moonHouseDesc. $moonAdvice ',
      );

      if (tMercury != null && tVenus != null && tMars != null) {
        buffer.write(
          '\n\nSky Communication & Action Line: The combination of Mercury in ${AppTranslationService.signName(tMercury.sign)} (${tMercury.degree.toInt()}°)${tMercury.isRetrograde ? " [Retro]" : ""}, Venus in ${AppTranslationService.signName(tVenus.sign)} (${tVenus.degree.toInt()}°) and Mars in ${AppTranslationService.signName(tMars.sign)} (${tMars.degree.toInt()}°) interacts with your natal Sun in ${AppTranslationService.signName(cleanSun)} and natal Moon in ${AppTranslationService.signName(cleanMoon)}, empowering both clarity and strategic balance.',
        );
      }

      if (retroPlanets.isNotEmpty) {
        buffer.write(
          ' Due to active planetary retrogrades (${retroPlanets.join(", ")}), it is advisable to double-check agreements and key details.',
        );
      }

      if (voc.isVoid) {
        buffer.write(
          '\n\n⚠️ Moon Void of Course Alert: ${AppTranslationService.tr(voc.advice)} (Next ingress to ${AppTranslationService.signName(voc.nextSign)}: ${voc.nextIngressTime})',
        );
      } else if (viaCombusta.isViaCombusta) {
        buffer.write(
          '\n\n🔥 Via Combusta Note: The Moon is traversing delicate degrees between Libra and Scorpio; staying poised and composed provides immense protection and advantage.',
        );
      }
    } else {
      buffer.write(
        'Sevgili $formattedName, bugün ($dateStr) gökyüzünde Güneş $transitSunSign burcunun $transitSunDeg° derecesinde ilerleyerek yükselen $cleanAsc haritanızda $sunHouseDesc alanını aydınlatıyor. ',
      );
      buffer.write(
        'Transit Ay ise $transitMoonSign burcunda ($transitMoonDeg°) ve "${moonPhase.phaseName}" fazında (%${moonPhase.illuminationPercent.toInt()} aydınlanma) seyahat ederek bugün odağınızı $moonHouseDesc konularına taşıyor. $moonAdvice ',
      );

      if (tMercury != null && tVenus != null && tMars != null) {
        buffer.write(
          '\n\nGökyüzü İletişim ve Eylem Hattı: Merkür ${tMercury.sign} (${tMercury.degree.toInt()}°)${tMercury.isRetrograde ? " [Retro]" : ""}, Venüs ${tVenus.sign} (${tVenus.degree.toInt()}°) ve Mars ${tMars.sign} (${tMars.degree.toInt()}°) kombinasyonu; natal $cleanSun Güneş ve $cleanMoon Ay doğanızla etkileşime girerek kararlarınızda hem zihinsel netlik hem de stratejik denge kurmanızı destekliyor.',
        );
      }

      if (retroPlanets.isNotEmpty) {
        buffer.write(
          ' Gökyüzünde aktif olan ${retroPlanets.join(", ")} retrosu nedeniyle yeni imzalar ve ani kararlar öncesinde detayları iki kez kontrol etmeniz önemli.',
        );
      }

      if (voc.isVoid) {
        buffer.write(
          '\n\n⚠️ Ay Boşlukta Uyarısı: ${voc.advice} (${voc.nextSign} geçişi: ${voc.nextIngressTime})',
        );
      } else if (viaCombusta.isViaCombusta) {
        buffer.write(
          '\n\n🔥 Via Combusta (Yanık Yol) Notu: Ay bugün Terazi-Akrep geçişindeki hassas derecelerde ilerlediği için duygusal tepkilerde aceleci olmamak ve soğukkanlılığı korumak büyük avantaj sağlar.',
        );
      }
    }

    return DailyHoroscopeModel(
      date: dateStr,
      text: buffer.toString(),
    );
  }
}

