import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../models/birth_chart_model.dart';
import 'astrology_engine.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';
import 'app_translation_service.dart';

class AspectDefinition {
  final String name;
  final String shortName;
  final String symbol;
  final double degree;
  final double defaultOrb;
  final bool isMajor;
  final String category;
  final String nature;
  final Color color;
  final String description;
  final String psychologicalMeaning;
  final String gift;
  final String challenge;

  const AspectDefinition({
    required this.name,
    required this.shortName,
    required this.symbol,
    required this.degree,
    required this.defaultOrb,
    required this.isMajor,
    required this.category,
    required this.nature,
    required this.color,
    required this.description,
    required this.psychologicalMeaning,
    required this.gift,
    required this.challenge,
  });

  String get localizedName => AppTranslationService.tr(name);
  String get localizedShortName => AppTranslationService.tr(shortName);
  String get localizedCategory => AppTranslationService.tr(category);
  String get localizedNature => AppTranslationService.tr(nature);
  String get localizedDescription => AppTranslationService.tr(description);
  String get localizedPsychologicalMeaning => AppTranslationService.tr(psychologicalMeaning);
  String get localizedGift => AppTranslationService.tr(gift);
  String get localizedChallenge => AppTranslationService.tr(challenge);
}

class AspectHit {
  final String planetA;
  final String planetB;
  final String planetADegreeSign;
  final String planetBDegreeSign;
  final String aspectName;
  final String aspectSymbol;
  final double aspectDegree;
  final double orbValue;
  final String orbStr;
  final bool isMajor;
  final bool isTransit;
  final Color color;
  final String interpretation;

  const AspectHit({
    required this.planetA,
    required this.planetB,
    this.planetADegreeSign = '',
    this.planetBDegreeSign = '',
    required this.aspectName,
    required this.aspectSymbol,
    this.aspectDegree = 0.0,
    this.orbValue = 0.0,
    required this.orbStr,
    required this.isMajor,
    required this.isTransit,
    required this.color,
    required this.interpretation,
  });
}

class _BodyCoord {
  final String key;
  final String name;
  final String sign;
  final double degreeInSign;
  final double longitude;
  final String formattedShort;

  const _BodyCoord({
    required this.key,
    required this.name,
    required this.sign,
    required this.degreeInSign,
    required this.longitude,
    required this.formattedShort,
  });
}

class AspectsService {
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

  // All Major and Minor Aspects Encyclopedia
  static final List<AspectDefinition> allAspectDefinitions = [
    // --- MAJOR ASPECTS ---
    const AspectDefinition(
      name: 'Kavuşum (Conjunction)',
      shortName: 'Kavuşum',
      symbol: '☌',
      degree: 0.0,
      defaultOrb: 8.0,
      isMajor: true,
      category: 'Majör Açı (0°)',
      nature: 'Odaklanmış Güç',
      color: AppColors.starlightGold,
      description:
          'İki gezegenin gökyüzünde aynı burç ve derece civarında (0°) buluşmasıdır. En güçlü ve doğrudan açı formudur.',
      psychologicalMeaning:
          'İki farklı arketipsel enerjinin ayrılmaz biçimde birleşmesi. Birey bu iki gücü birbirinden bağımsız deneyimleyemez; biri tetiklendiğinde diğeri derhal devreye girer.',
      gift: 'Yüksek odaklanma, yoğun irade ve tek bir hedef doğrultusunda muazzam enerji akışı.',
      challenge: 'Gezegenlerin sınırlarını ayırt edememekten kaynaklanan körleşme ve sübjektiflik.',
    ),
    const AspectDefinition(
      name: 'Karşıt (Opposition)',
      shortName: 'Karşıt',
      symbol: '☍',
      degree: 180.0,
      defaultOrb: 8.0,
      isMajor: true,
      category: 'Majör Açı (180°)',
      nature: 'Kutupsallık & Denge',
      color: AppColors.savageRed,
      description:
          'İki gezegenin tam karşıt burç ve derecelerde (180° mesafede, örn. Oğlak - Yengeç, Koç - Terazi) bulunmasıdır.',
      psychologicalMeaning:
          'İçsel kutupsallık ve bu gerilimin sıklıkla dış dünyaya veya ilişkilere projekte edilmesi. Karşıtlık, bireye kendisini başkasının aynasında görme ve iki zıt kutbu dengeleme fırsatı sunar.',
      gift: 'Geniş perspektif, objektiflik, ilişkilerde yüksek farkındalık ve kutupları uzlaştırma bilgeliği.',
      challenge: 'Bir uçtan diğerine savrulma, ikilemde kalma ve karşı tarafı suçlama eğilimi.',
    ),
    const AspectDefinition(
      name: 'Üçgen (Trine)',
      shortName: 'Üçgen',
      symbol: '△',
      degree: 120.0,
      defaultOrb: 7.5,
      isMajor: true,
      category: 'Majör Açı (120°)',
      nature: 'Ahenk & Akış',
      color: AppColors.pastelMint,
      description:
          'Aynı elementteki iki burcun gezegenleri arasındaki 120 derecelik uyumlu açıdır (örn. Ateş-Ateş, Toprak-Toprak).',
      psychologicalMeaning:
          'Doğuştan gelen yetenekler, akış hali ve rahat enerji transferi. Birey bu alanda doğal bir koruma, sezgi ve ustalık taşır.',
      gift: 'Doğal yaratıcılık, yüksek şans, sezgisel kolaylık ve içsel sükunet.',
      challenge: 'Kolaylığa alışıp rehavete kapılmak, potansiyeli daha ileri taşımak için çaba göstermemek.',
    ),
    const AspectDefinition(
      name: 'Kare (Square)',
      shortName: 'Kare',
      symbol: '□',
      degree: 90.0,
      defaultOrb: 7.5,
      isMajor: true,
      category: 'Majör Açı (90°)',
      nature: 'Dinamik Gerilim',
      color: AppColors.warningOrange,
      description:
          'Aynı nitelikteki (Öncü, Sabit veya Değişken) burçlar arasındaki 90 derecelik dik ve eylem odaklı açıdır.',
      psychologicalMeaning:
          'İçsel sürtünme ve gelişim motoru. Rahatlığa izin vermeyen bu açı, insanı somut adım atmaya ve engelleri aşarak ustalaşmaya zorlar.',
      gift: 'Kararlılık, krizleri avantaja çevirme, yüksek direnç ve kalıcı başarı inşa etme gücü.',
      challenge: 'Kronik stres, sabırsızlık, içsel çatışma ve gereksiz güç mücadeleleri.',
    ),
    const AspectDefinition(
      name: 'Sekstil (Sextile)',
      shortName: 'Sekstil',
      symbol: '⚹',
      degree: 60.0,
      defaultOrb: 6.0,
      isMajor: true,
      category: 'Majör Açı (60°)',
      nature: 'Fırsat & İşbirliği',
      color: AppColors.pastelBlue,
      description:
          'Birbiriyle uyumlu elementler (Ateş-Hava veya Toprak-Su) arasındaki 60 derecelik destekleyici açıdır.',
      psychologicalMeaning:
          'Bilinçli çaba ve iletişim ile açığa çıkan fırsatlar. Birey inisiyatif aldığında zihinsel ve sosyal kapılar hızla açılır.',
      gift: 'Zihinsel kıvraklık, işbirliği kurma yeteneği, sosyal köprüler ve pratik çözümler.',
      challenge: 'Harekete geçilmezse fırsatların değerlendirilmeden geçip gitmesi.',
    ),

    // --- MINOR ASPECTS ---
    const AspectDefinition(
      name: '150° Birleşmeyen (Quincunx)',
      shortName: '150° Quincunx',
      symbol: '⚻',
      degree: 150.0,
      defaultOrb: 3.0,
      isMajor: false,
      category: 'Minör Açı (150°)',
      nature: 'İnce Ayar & Uyum',
      color: AppColors.pastelLavender,
      description:
          'Ortak elementi veya niteliği bulunmayan burçlar arasındaki 150 derecelik adaptasyon açısıdır.',
      psychologicalMeaning:
          'Birbirinden çok farklı iki yaşam alanını aynı anda yönetme ve sürekli bilinçli kalibrasyon yapma ihtiyacı.',
      gift: 'Yüksek adaptasyon kabiliyeti, kriz çözme zekası ve detaylı revizyon ustalığı.',
      challenge: 'İçsel huzursuzluk, aşırı yüklenme ve sınırları koruyamama.',
    ),
    const AspectDefinition(
      name: 'Quintile (72° Beşlik)',
      shortName: '72° Quintile',
      symbol: 'Q',
      degree: 72.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (72°)',
      nature: 'Yaratıcı Deha',
      color: AppColors.pastelMint,
      description:
          '360 derecelik çemberin 5\'e bölünmesiyle elde edilen 72 derecelik özel yetenek ve sanatsal zeka açısıdır.',
      psychologicalMeaning:
          'Orijinal düşünce, teknik ustalık ve kalıpların dışına çıkan sıra dışı ilham kanalları.',
      gift: 'Yenilikçi buluşlar, sanatsal incelik ve özgün problem çözme yeteneği.',
      challenge: 'Sıradan rutinlere uyum sağlamakta zorlanma.',
    ),
    const AspectDefinition(
      name: 'Yarım Kare (45° Semisquare)',
      shortName: '45° Yarım Kare',
      symbol: '∠',
      degree: 45.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (45°)',
      nature: 'Mikro Tetikleyici',
      color: AppColors.pastelPink,
      description:
          '90 derecelik karenin yarısı olan 45 derecelik harekete geçirici minör açıdır.',
      psychologicalMeaning:
          'Yüzeye çıkmayı bekleyen içsel motivasyon ve küçük pürüzleri erkenden fark edip önlem alma refleksi.',
      gift: 'Gelişmiş erken algı, çeviklik ve hızlı müdahale yeteneği.',
      challenge: 'Küçük detaylara gereğinden fazla takılma ve huzursuzluk.',
    ),
    const AspectDefinition(
      name: 'Sesquiquadrate (135°)',
      shortName: '135° Sesquiquadrate',
      symbol: '⚼',
      degree: 135.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (135°)',
      nature: 'Sabır & Strateji',
      color: AppColors.pastelPeach,
      description:
          '90° kare ile 45° yarım karenin birleşimi olan 135 derecelik disiplin ve irade testi açısıdır.',
      psychologicalMeaning:
          'Hedeflere giderken karşılaşılan pürüzleri sabır, strateji ve soğukkanlılıkla aşma dersi.',
      gift: 'Yüksek dayanıklılık ve karmaşık engelleri yönetme disiplini.',
      challenge: 'İnatçılık, acelecilik ve enerjinin yanlış yöne savrulması.',
    ),
    const AspectDefinition(
      name: 'Yarı Sekstil (30° Semisextile)',
      shortName: '30° Yarı Sekstil',
      symbol: '⚺',
      degree: 30.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (30°)',
      nature: 'Komşu Burç Bağı',
      color: AppColors.textSecondary,
      description:
          'Yan yana komşu iki burç arasındaki 30 derecelik tamamlayıcı farkındalık açısıdır.',
      psychologicalMeaning:
          'Bir burcun dersini tamamlayıp bir sonraki burcun deneyimine geçerken kurulan ince zihinsel köprü.',
      gift: 'Aşamalı büyüme, gözlem gücü ve bilgiyi entegre etme yeteneği.',
      challenge: 'Komşu burçların farklı doğalarını dengelemekte kararsızlık.',
    ),
  ];

  // Planets list for Aspect Matrix Grid
  static const List<String> matrixPlanets = [
    'Güneş',
    'Ay',
    'Merkür',
    'Venüs',
    'Mars',
    'Jüpiter',
    'Satürn',
    'Uranüs',
    'Neptün',
    'Plüton',
    'Kuzey Ay Düğümü',
    'Chiron',
    'Yükselen (ASC)',
    'Tepe Noktası (MC)',
  ];

  static const Map<String, String> planetSymbols = {
    'Güneş': '☉',
    'Ay': '☽',
    'Merkür': '☿',
    'Venüs': '♀\uFE0E',
    'Mars': '♂\uFE0E',
    'Jüpiter': '♃',
    'Satürn': '♄',
    'Uranüs': '♅',
    'Neptün': '♆',
    'Plüton': '♇',
    'Kuzey Ay Düğümü': '☊',
    'Chiron': '⚷',
    'Yükselen (ASC)': 'ASC',
    'Tepe Noktası (MC)': 'MC',
  };

  static const Map<String, String> _keyToDisplayName = {
    'sun': 'Güneş',
    'moon': 'Ay',
    'mercury': 'Merkür',
    'venus': 'Venüs',
    'mars': 'Mars',
    'jupiter': 'Jüpiter',
    'saturn': 'Satürn',
    'uranus': 'Uranüs',
    'neptune': 'Neptün',
    'pluto': 'Plüton',
    'north_node': 'Kuzey Ay Düğümü',
    'chiron': 'Chiron',
    'ascendant': 'Yükselen (ASC)',
    'mc': 'Tepe Noktası (MC)',
  };

  static double parseDegreeInSign(String formatted) {
    final match = RegExp(r"(\d+)°(?:(\d+)')?").firstMatch(formatted);
    if (match != null) {
      final d = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      final m = double.tryParse(match.group(2) ?? '0') ?? 0.0;
      return d + (m / 60.0);
    }
    return 15.0;
  }

  static int _signIndex(String sign) {
    final norm = BirthChartModel.normalizeSign(sign);
    final idx = zodiacSigns.indexWhere((z) => z.toLowerCase() == norm.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  static double calculateAbsoluteLongitude(String sign, String formatted) {
    final signIdx = _signIndex(sign);
    final deg = parseDegreeInSign(formatted);
    return (signIdx * 30.0 + deg) % 360.0;
  }

  static String _formatOrb(double orb) {
    final deg = orb.floor();
    final min = ((orb - deg) * 60).round().clamp(0, 59);
    return "$deg°${min.toString().padLeft(2, '0')}'";
  }

  static BirthChartModel _resolveDefaultChart({
    BirthChartModel? chart,
    UserProfile? profile,
  }) {
    if (chart != null) return chart;
    if (profile != null) {
      return AstrologyEngine.calculateChart(
        name: profile.name,
        dateStr: profile.birthDate,
        timeStr: profile.birthTime,
        city: profile.birthCity.isEmpty ? 'İstanbul' : profile.birthCity,
        country: profile.birthCountry.isEmpty ? 'Türkiye' : profile.birthCountry,
      );
    }
    return AstrologyEngine.calculateChart(
      name: 'Kullanıcı',
      dateStr: '1995-01-05',
      timeStr: '12:00',
      city: 'İstanbul',
      country: 'Türkiye',
    );
  }

  static List<_BodyCoord> _extractNatalCoords(BirthChartModel chart) {
    final result = <_BodyCoord>[];
    for (final entry in _keyToDisplayName.entries) {
      final p = chart.planets[entry.key];
      if (p == null) continue;
      final deg = parseDegreeInSign(p.formatted);
      final lon = p.longitude ?? calculateAbsoluteLongitude(p.sign, p.formatted);
      result.add(
        _BodyCoord(
          key: entry.key,
          name: entry.value,
          sign: p.sign,
          degreeInSign: deg,
          longitude: lon,
          formattedShort: '${deg.floor()}° ${p.sign}',
        ),
      );
    }
    return result;
  }

  static List<_BodyCoord> _extractTransitCoords() {
    final transits = SkyTransitsService.getCurrentTransits();
    final result = <_BodyCoord>[];
    for (final t in transits) {
      String displayName = t.name;
      if (displayName == 'Kuzey Düğüm') displayName = 'Kuzey Ay Düğümü';
      final signIdx = zodiacSigns.indexOf(t.sign);
      if (signIdx < 0) continue;
      final exactDeg = t.degree + (t.minute / 60.0);
      final lon = (signIdx * 30.0 + exactDeg) % 360.0;
      result.add(
        _BodyCoord(
          key: t.name.toLowerCase(),
          name: displayName,
          sign: t.sign,
          degreeInSign: exactDeg,
          longitude: lon,
          formattedShort: '${t.degree.floor()}° ${t.sign}',
        ),
      );
    }
    return result;
  }

  static AspectDefinition? _matchAspect(
    double lonA,
    double lonB, {
    bool isTransit = false,
    bool involveAngles = false,
  }) {
    double diff = (lonA - lonB).abs() % 360.0;
    if (diff > 180.0) diff = 360.0 - diff;

    AspectDefinition? bestDef;
    double bestOrb = 999.0;

    for (final def in allAspectDefinitions) {
      // Transitlerde kafa karışıklığını önlemek için majör açılar ve 150° quincunx önceliklidir
      if (isTransit && !def.isMajor && def.degree != 150.0) continue;

      double maxOrb = def.defaultOrb;
      if (isTransit) {
        maxOrb = def.isMajor ? 5.0 : 2.0;
      } else if (involveAngles && !def.isMajor) {
        maxOrb = 2.0;
      }

      final orb = (diff - def.degree).abs();
      if (orb <= maxOrb && orb < bestOrb) {
        bestOrb = orb;
        bestDef = def;
      }
    }
    return bestDef;
  }

  /// Kullanıcının gerçek doğum haritasındaki (Natal - Natal) açıları hesaplar.
  /// Örneğin Güneş Oğlak - Ay Yengeç ise gerçek boylam farkından (~180°) Karşıt Açı (☍) olarak döner.
  static List<AspectHit> getNatalAspects({
    BirthChartModel? chart,
    UserProfile? profile,
  }) {
    final resolved = _resolveDefaultChart(chart: chart, profile: profile);
    final coords = _extractNatalCoords(resolved);
    final hits = <AspectHit>[];

    for (int i = 0; i < coords.length; i++) {
      for (int j = i + 1; j < coords.length; j++) {
        final a = coords[i];
        final b = coords[j];

        // ASC ve MC arasındaki açı harita kadranı olduğu için sadece majör açılarda gösterilir
        final involveAngles = (a.key == 'ascendant' ||
            a.key == 'mc' ||
            b.key == 'ascendant' ||
            b.key == 'mc');

        double diff = (a.longitude - b.longitude).abs() % 360.0;
        if (diff > 180.0) diff = 360.0 - diff;

        final def = _matchAspect(
          a.longitude,
          b.longitude,
          isTransit: false,
          involveAngles: involveAngles,
        );
        if (def == null) continue;

        final orb = (diff - def.degree).abs();
        hits.add(
          AspectHit(
            planetA: a.name,
            planetB: b.name,
            planetADegreeSign: a.formattedShort,
            planetBDegreeSign: b.formattedShort,
            aspectName: def.shortName,
            aspectSymbol: def.symbol,
            aspectDegree: def.degree,
            orbValue: orb,
            orbStr: _formatOrb(orb),
            isMajor: def.isMajor,
            isTransit: false,
            color: def.color,
            interpretation: _buildNatalInterpretation(a, b, def, orb),
          ),
        );
      }
    }

    // Önce Majör açılar, sonra en dar orb (en güçlü etki) sırasıyla diz
    hits.sort((x, y) {
      if (x.isMajor != y.isMajor) return x.isMajor ? -1 : 1;
      return x.orbValue.compareTo(y.orbValue);
    });
    return hits;
  }

  /// Anlık Gökyüzü Transitlerinin (Transit Gezegenler) Kullanıcının Doğum Haritasına (Natal Gezegenler)
  /// yaptığı gerçek açıları ve güncel öngörü yorumlarını hesaplar.
  static List<AspectHit> getTransitAspects({
    BirthChartModel? chart,
    UserProfile? profile,
  }) {
    final resolved = _resolveDefaultChart(chart: chart, profile: profile);
    final natalCoords = _extractNatalCoords(resolved);
    final transitCoords = _extractTransitCoords();
    final hits = <AspectHit>[];

    for (final t in transitCoords) {
      for (final n in natalCoords) {
        double diff = (t.longitude - n.longitude).abs() % 360.0;
        if (diff > 180.0) diff = 360.0 - diff;

        final def = _matchAspect(
          t.longitude,
          n.longitude,
          isTransit: true,
        );
        if (def == null) continue;

        final orb = (diff - def.degree).abs();
        hits.add(
          AspectHit(
            planetA: 'Transit ${t.name}',
            planetB: 'Natal ${n.name}',
            planetADegreeSign: t.formattedShort,
            planetBDegreeSign: n.formattedShort,
            aspectName: '${def.shortName} (${def.degree.toInt()}°)',
            aspectSymbol: def.symbol,
            aspectDegree: def.degree,
            orbValue: orb,
            orbStr: _formatOrb(orb),
            isMajor: def.isMajor,
            isTransit: true,
            color: def.color,
            interpretation: _buildTransitInterpretation(t, n, def, orb),
          ),
        );
      }
    }

    hits.sort((x, y) => x.orbValue.compareTo(y.orbValue));
    return hits;
  }

  static String cleanPlanetName(String raw) {
    return raw
        .replaceAll('Transit ', '')
        .replaceAll('Natal ', '')
        .replaceAll(' (Transit)', '')
        .trim();
  }

  // Find Aspect Hit between Planet A and Planet B for the Grid Cell
  static AspectHit? findAspectInGrid(
    String pA,
    String pB, {
    bool includeTransits = false,
    BirthChartModel? chart,
    UserProfile? profile,
  }) {
    final cleanA = cleanPlanetName(pA);
    final cleanB = cleanPlanetName(pB);

    if (includeTransits) {
      final transits = getTransitAspects(chart: chart, profile: profile);
      for (final hit in transits) {
        final hitA = cleanPlanetName(hit.planetA);
        final hitB = cleanPlanetName(hit.planetB);
        if ((hitA == cleanA && hitB == cleanB) ||
            (hitA == cleanB && hitB == cleanA)) {
          return hit;
        }
      }
      return null;
    }

    final natals = getNatalAspects(chart: chart, profile: profile);
    for (final hit in natals) {
      final hitA = cleanPlanetName(hit.planetA);
      final hitB = cleanPlanetName(hit.planetB);
      if ((hitA == cleanA && hitB == cleanB) ||
          (hitA == cleanB && hitB == cleanA)) {
        return hit;
      }
    }
    return null;
  }

  static const Map<String, String> _planetArchetypes = {
    'Güneş': 'öz kimliğiniz, yaşam iradeniz ve otorite duruşunuz',
    'Ay': 'duygusal ihtiyaçlarınız, bilinçaltı güvenceniz ve içsel huzurunuz',
    'Merkür': 'zihinsel analiz gücünüz, iletişim tarzınız ve karar mekanizmanız',
    'Venüs': 'sevgi diliniz, ilişki değerleriniz, estetik algınız ve finansal çekiminiz',
    'Mars': 'eylem gücünüz, mücadele stratejiniz, cesaretiniz ve yaşam enerjiniz',
    'Jüpiter': 'büyüme vizyonunuz, bolluk-bereket kanalınız ve inanç sisteminiz',
    'Satürn': 'sorumluluk bilinciniz, sınavlarınız, disiplininiz ve kalıcı inşanız',
    'Uranüs': 'özgürlük dürtünüz, orijinalliğiniz ve ani uyanış potansiyeliniz',
    'Neptün': 'sezgisel derinliğiniz, hayal gücünüz ve ruhsal ilham kanalınız',
    'Plüton': 'küllerinden doğma gücünüz, psikolojik dönüşümünüz ve kriz yönetiminiz',
    'Kuzey Ay Düğümü': 'bu hayattaki kadersel büyüme rotanız ve tekamül hedefiniz',
    'Chiron': 'yaralı şifacı noktanız, derin duyarlılığınız ve bilgelik anahtarınız',
    'Yükselen (ASC)': 'dış dünyaya yansıttığınız persona, fiziksel duruşunuz ve ilk izleniminiz',
    'Tepe Noktası (MC)': 'kariyer zirveniz, toplumsal statünüz ve görünür başarı hedefleriniz',
  };

  static const Map<String, String> _planetArchetypesEn = {
    'Güneş': 'your core identity, life willpower, and authority stance',
    'Ay': 'your emotional needs, subconscious security, and inner peace',
    'Merkür': 'your mental analysis power, communication style, and decision-making',
    'Venüs': 'your love language, relational values, aesthetic sense, and financial attraction',
    'Mars': 'your drive for action, courage, resilience, and vital energy',
    'Jüpiter': 'your growth vision, abundance channel, and philosophy of life',
    'Satürn': 'your sense of responsibility, discipline, life lessons, and enduring mastery',
    'Uranüs': 'your urge for freedom, original genius, and sudden awakening potential',
    'Neptün': 'your intuitive depth, imagination, and spiritual inspiration',
    'Plüton': 'your regenerative power, psychological transformation, and crisis leadership',
    'Kuzey Ay Düğümü': 'your karmic growth trajectory and evolutionary life purpose',
    'Chiron': 'your wounded healer point, deep sensitivity, and key to wisdom',
    'Yükselen (ASC)': 'the persona you project, physical presence, and first impression',
    'Tepe Noktası (MC)': 'your career pinnacle, social standing, and life goals',
  };

  static const Map<String, String> _planetArchetypesJa = {
    'Güneş': '本質的な自己同一性、生きる意志、尊厳ある姿勢',
    'Ay': '感情的欲求、潜在意識の安心感、内なる平穏',
    'Merkür': '知的分析力、コミュニケーション手法、意思決定力',
    'Venüs': '愛情表現、人間関係の価値観、美意識、豊かさを引き寄せる力',
    'Mars': '行動力、困難を突破する勇気、バイタリティ',
    'Jüpiter': '拡大と発展のビジョン、豊かさの循環、信念体系',
    'Satürn': '責任感、人生の試練、自己規律、永続的な構築力',
    'Uranüs': '自由への渇望、独創的な才能、突発的な覚醒の力',
    'Neptün': '直観的な深み、豊かな想像力、霊的インスピレーション',
    'Plüton': '不死鳥のような再生力、深層心理の変容、危機管理能力',
    'Kuzey Ay Düğümü': '今世での宿命的な成長軌道と魂の進化の到達点',
    'Chiron': '傷ついた癒し手のポイント、繊細な感受性、智慧の鍵',
    'Yükselen (ASC)': '外の世界に示すペルソナ、身体的佇まい、第一印象',
    'Tepe Noktası (MC)': 'キャリアの頂点、社会的地位、目指すべき成果',
  };

  static String _buildNatalInterpretation(
    _BodyCoord a,
    _BodyCoord b,
    AspectDefinition def,
    double orb,
  ) {
    final lang = AppTranslationService.currentLang;
    final nameA = AppTranslationService.planetName(a.name);
    final nameB = AppTranslationService.planetName(b.name);
    final signA = AppTranslationService.signName(a.sign);
    final signB = AppTranslationService.signName(b.sign);
    final aspectShort = AppTranslationService.tr(def.shortName);
    final degStr = '${def.degree.toInt()}°';
    final orbStr = _formatOrb(orb);

    if (lang == 'en') {
      final archA = _planetArchetypesEn[a.name] ?? a.name;
      final archB = _planetArchetypesEn[b.name] ?? b.name;
      final degInfo = '$nameA ($signA) and $nameB ($signB) form an exact $degStr $aspectShort aspect with an orb of $orbStr.';

      if ((a.name == 'Güneş' && b.name == 'Ay') ||
          (a.name == 'Ay' && b.name == 'Güneş')) {
        if (def.degree == 180.0) {
          return '$degInfo Representing a Full Moon phase in your natal chart, this Sun-Moon opposition creates dynamic polarity and profound awareness between conscious will ($signA) and emotional security ($signB). Relationships serve as mirrors, offering extraordinary objectivity and wholeness when harmonized.';
        } else if (def.degree == 120.0 || def.degree == 60.0) {
          return '$degInfo This harmonious aspect between the Sun ($signA) and Moon ($signB) shows natural synchronization between conscious desires and emotional instincts, giving steady confidence and radiant vitality.';
        } else if (def.degree == 90.0) {
          return '$degInfo The 90° square between Sun ($signA) and Moon ($signB) provides internal drive and motivation to achieve. Creative friction pushes you past comfort zones to attain lasting success.';
        } else if (def.degree == 0.0) {
          return '$degInfo Carrying the seed energy of a New Moon, this Sun-Moon conjunction unites your vital drive and feelings in $signA, granting exceptional focus and pioneering willpower.';
        }
      }

      if (def.degree == 0.0) {
        return '$degInfo In your natal chart, $archA merges with $archB at a single center in $signA. These planetary powers work in unison, generating immense focus, magnetism, and impact.';
      } else if (def.degree == 180.0) {
        return '$degInfo A 180° opposition connects $archA in $signA with $archB in $signB across opposing horizons. This represents mastery of balance; unifying both sides yields strategic wisdom.';
      } else if (def.degree == 120.0) {
        return '$degInfo A flowing 120° trine links $archA in $signA and $archB in $signB, granting effortless creative flow and protective blessings in these life areas.';
      } else if (def.degree == 90.0) {
        return '$degInfo A dynamic 90° square between $archA in $signA and $archB in $signB acts as a prime catalyst for personal mastery and enduring achievement.';
      } else if (def.degree == 60.0) {
        return '$degInfo A 60° sextile opens proactive channels of communication and fertile opportunities between $archA in $signA and $archB in $signB.';
      } else if (def.degree == 150.0) {
        return '$degInfo A 150° quincunx between $archA in $signA and $archB in $signB invites continuous adaptability and intuitive fine-tuning across distinct modes of expression.';
      } else {
        return '$degInfo Working in your chart, this minor aspect (${AppTranslationService.tr(def.name)}) highlights nuanced perception, specialized talents, and strategic adaptability.';
      }
    } else if (lang == 'ja') {
      final archA = _planetArchetypesJa[a.name] ?? a.name;
      final archB = _planetArchetypesJa[b.name] ?? b.name;
      final degInfo = '$nameA ($signA) と $nameB ($signB) の間に、オーブ $orbStr で $degStr $aspectShort が形成されています。';

      if ((a.name == 'Güneş' && b.name == 'Ay') ||
          (a.name == 'Ay' && b.name == 'Güneş')) {
        if (def.degree == 180.0) {
          return '$degInfo 出生図における満月フェーズを象徴する太陽・月のオポジション（180度）は、意識的な意志（$signA）と感情の安心感（$signB）の間に高い客観性と強い引力をもたらします。対人関係の学びを通じて精神的な完成へと導かれます。';
        } else if (def.degree == 120.0 || def.degree == 60.0) {
          return '$degInfo 太陽（$signA）と月（$signB）の調和的アスペクトは、人生の目的と内なる感情が無理なく共鳴し、穏やかな自信と活力に恵まれることを示しています。';
        } else if (def.degree == 90.0) {
          return '$degInfo 太陽（$signA）と月（$signB）の90度スクエアは、現状を突破して偉大な成果を打ち立てるための強力な内発的動機と粘り強さを授けます。';
        } else if (def.degree == 0.0) {
          return '$degInfo 新月のエネルギーを宿す太陽と月の合（0度）は、$signAのテーマにおいて意志と感情をひとつに集約し、強力な推進力とカリスマ性を発揮します。';
        }
      }

      if (def.degree == 0.0) {
        return '$degInfo あなたの出生図において、$archAと$archBが$signAの星座でひとつに融合しています。2つの惑星エネルギーが強力に連携し、強い存在感を発揮します。';
      } else if (def.degree == 180.0) {
        return '$degInfo $signAの$archAと$signBの$archBが180度で向かい合っています。相反する二つの極を調和させる知恵を育み、深い戦略的洞察をもたらします。';
      } else if (def.degree == 120.0) {
        return '$degInfo $signAと$signBの間で、$archAと$archBが120度のトラインを形成。天賦の才能と恩恵が自然に循環し、スムーズな発展をサポートします。';
      } else if (def.degree == 90.0) {
        return '$degInfo $signAの$archAと$signBの$archBによる90度スクエアは、魂の成長を促すダイナミックな推進力であり、困難を確固たる実績へと変える力を与えます。';
      } else if (def.degree == 60.0) {
        return '$degInfo $signAと$signBを繋ぐ60度セクスタイルは、$archAと$archBの間に実りあるコミュニケーションと好機の架け橋を築きます。';
      } else if (def.degree == 150.0) {
        return '$degInfo $signAと$signBの150度クインカンクスは、異なる本質を持つエネルギー間で絶え間ない適応力と洗練された微調整を行う知恵を育みます。';
      } else {
        return '$degInfo この特別なマイナーアスペクト（${AppTranslationService.tr(def.name)}）は、繊細な直観力と独自の才能、有事の柔軟な戦略力を後押しします。';
      }
    }

    final archA = _planetArchetypes[a.name] ?? a.name;
    final archB = _planetArchetypes[b.name] ?? b.name;
    final degInfo =
        '${a.name} (${a.formattedShort}) ile ${b.name} (${b.formattedShort}) arasında ${_formatOrb(orb)} orb ile ${def.degree.toInt()}° ${def.shortName} açısı bulunuyor.';

    // Özel Güneş - Ay Kombinasyonları
    if ((a.name == 'Güneş' && b.name == 'Ay') ||
        (a.name == 'Ay' && b.name == 'Güneş')) {
      if (def.degree == 180.0) {
        return '$degInfo Doğum haritanızda Dolunay fazını temsil eden Güneş-Ay karşıtlığı; bilinçli iradeniz (${a.sign}) ile duygusal ihtiyaçlarınız (${b.sign}) arasında güçlü bir kutupsallık ve yüksek farkındalık yaratır. İlişkiler ve ortaklıklar hayatınızda ayna görevi görür; mantık ile duyguyu uzlaştırdığınızda muazzam bir objektiflik ve tamamlanma gücü kazanırsınız.';
      } else if (def.degree == 120.0 || def.degree == 60.0) {
        return '$degInfo Güneş (${a.sign}) ve Ay (${b.sign}) arasındaki bu uyumlu açı; istekleriniz ile duygusal doğanızın birbirini doğal biçimde desteklediğini gösterir. İçsel dengeniz, özgüveniniz ve yaşam enerjiniz akıcıdır.';
      } else if (def.degree == 90.0) {
        return '$degInfo Güneş (${a.sign}) ve Ay (${b.sign}) arasındaki 90° kare açı; içsel bir dinamizm ve kendini kanıtlama motivasyonu verir. Duygusal güvenlik arayışınız ile hedefleriniz arasındaki gerilim, sizi krizleri aşarak büyük başarılara ulaşmaya teşvik eder.';
      } else if (def.degree == 0.0) {
        return '$degInfo Yeniay enerjisi taşıyan Güneş-Ay kavuşumu; tüm yaşam enerjinizi ve duygusal odaklanmanızı ${a.sign} burcunun temalarında birleştirir. Başlatıcı, odaklanmış ve güçlü bir iradeye sahipsiniz.';
      }
    }

    if (def.degree == 0.0) {
      return '$degInfo Doğum haritanızda $archA ile $archB tek bir merkezde (${a.sign} burcunda) birleşiyor. Bu iki gezegen gücü hayatınızda ayrılmaz biçimde birlikte çalışır; odaklandığınız alanda yüksek irade, karizma ve güçlü bir etki alanı yaratır.';
    } else if (def.degree == 180.0) {
      return '$degInfo ${a.sign} burcundaki $archA ile tam karşısındaki ${b.sign} burcunda yer alan $archB arasında 180 derecelik karşıt açı yer alıyor. Bu yerleşim iki zıt kutbu dengeleme ustalığıdır; ilişkilerde ve dış dünyayla temaslarınızda her iki perspektifi birleştirdiğinizde büyük bir stratejik farkındalık elde edersiniz.';
    } else if (def.degree == 120.0) {
      return '$degInfo ${a.sign} ve ${b.sign} burçları üzerinden $archA ile $archB arasında 120 derecelik akıcı bir üçgen açı bulunuyor. Doğuştan gelen bu yetenek ve koruma kanalı, ilgili yaşam alanlarında zahmetsizce çözüm üretmenizi ve yaratıcı fırsatları kendinize çekmenizi sağlar.';
    } else if (def.degree == 90.0) {
      return '$degInfo ${a.sign} burcundaki $archA ile ${b.sign} burcundaki $archB arasındaki 90 derecelik kare açı, haritanızın en güçlü gelişim motorlarından biridir. Konfor alanında kalmanıza izin vermeyen bu dinamik gerilim, engelleri somut başarıya ve ustalığa dönüştürme iradesi verir.';
    } else if (def.degree == 60.0) {
      return '$degInfo ${a.sign} ve ${b.sign} burçları arasındaki 60 derecelik sekstil açı, $archA ile $archB arasında verimli bir iletişim ve fırsat köprüsü kurar. Bilinçli inisiyatif aldığınızda sosyal, zihinsel ve pratik kapıların hızla açıldığını deneyimlersiniz.';
    } else if (def.degree == 150.0) {
      return '$degInfo ${a.sign} ve ${b.sign} burçları arasındaki 150° Quincunx açısı; birbirinden farklı doğadaki $archA ile $archB arasında sürekli bilinçli bir denge, adaptasyon ve ince ayar yapma ustalığı kazandırır.';
    } else {
      return '$degInfo Haritanızda $archA ile $archB arasında çalışan bu özel minör açı (${def.name}), detayları fark etme, özgün çözümler geliştirme ve kriz anlarında esnek stratejiler kurma yeteneğinizi destekler.';
    }
  }

  static String _buildTransitInterpretation(
    _BodyCoord t,
    _BodyCoord n,
    AspectDefinition def,
    double orb,
  ) {
    final lang = AppTranslationService.currentLang;
    final tName = AppTranslationService.planetName(t.name);
    final nName = AppTranslationService.planetName(n.name);
    final tSign = AppTranslationService.signName(t.sign);
    final nSign = AppTranslationService.signName(n.sign);
    final aspectShort = AppTranslationService.tr(def.shortName);
    final degStr = '${def.degree.toInt()}°';
    final orbStr = _formatOrb(orb);

    if (lang == 'en') {
      final natalTheme = _planetArchetypesEn[n.name] ?? n.name;
      final header = 'Transiting $tName in $tSign forms an exact $degStr $aspectShort with your Natal $nName ($nSign) within $orbStr orb.';
      if (def.degree == 0.0) {
        return '$header This powerful transit conjunction initiates a brand-new cycle in $natalTheme. It is an opportune window to pioneer new plans and take decisive steps.';
      } else if (def.degree == 180.0) {
        return '$header Transiting $tName opposition brings illuminating clarity and mirror encounters in $natalTheme through partners and external realities. Maintaining inner equilibrium ensures lasting success.';
      } else if (def.degree == 120.0) {
        return '$header Transiting $tName trine sends flowing harmony and protective momentum into $natalTheme. Obstacles dissolve smoothly and support arrives naturally.';
      } else if (def.degree == 90.0) {
        return '$header Transiting $tName square activates dynamic energy in $natalTheme, urging you to overcome hesitation and assert strategic resolve. Planned focus turns pressure into breakthroughs.';
      } else if (def.degree == 60.0) {
        return '$header Transiting $tName sextile creates fertile connections, productive dialogues, and practical opportunities in $natalTheme. Active engagement unlocks helpful doorways.';
      } else {
        return '$header Transiting $tName forms an adjustment aspect (150° Quincunx) with Natal $nName, advising you to stay flexible and fine-tune your schedule in $natalTheme.';
      }
    } else if (lang == 'ja') {
      final natalTheme = _planetArchetypesJa[n.name] ?? n.name;
      final header = '現在運行中のトランジット$tName（$tSign）が出生図のネイタル$nName（$nSign）とオーブ$orbStrで$degStr $aspectShortを形成中。';
      if (def.degree == 0.0) {
        return '$header この強力なトランジット合（0度）は、$natalThemeの領域で新たな幕開けを告げています。眠っていた潜在能力を目覚めさせ、具体的な行動を起こす重要な好機です。';
      } else if (def.degree == 180.0) {
        return '$header トランジット$tNameのオポジション（180度）は、$natalThemeに関してパートナーシップや環境を通じて本質的な気づきをもたらします。中庸を保つことで長期的な安定が築かれます。';
      } else if (def.degree == 120.0) {
        return '$header トランジット$tNameのトライン（120度）は、$natalThemeに宇宙の調和と追い風を注いでいます。障害が自然に解消され、支援やチャンスを享受しやすい時期です。';
      } else if (def.degree == 90.0) {
        return '$header トランジット$tNameのスクエア（90度）は、$natalThemeにおける停滞を打破し、強い意志力と戦略的決断を促す躍動のエネルギーです。';
      } else if (def.degree == 60.0) {
        return '$header トランジット$tNameのセクスタイル（60度）は、$natalThemeにおいて実りある人脈や実用的な機会をもたらします。積極的な対話が幸運を呼び込みます。';
      } else {
        return '$header トランジット$tNameとネイタル$nNameの150度クインカンクスは、$natalThemeにおいて計画の微調整と心身の調和を心がけるべき好機であることを示しています。';
      }
    }

    final natalTheme = _planetArchetypes[n.name] ?? n.name;
    final header =
        'Gökyüzünde ${t.formattedShort} konumunda ilerleyen Transit ${t.name}, doğum haritanızdaki ${n.formattedShort} yerleşimli Natal ${n.name} ile ${_formatOrb(orb)} orb hassasiyetinde ${def.degree.toInt()}° ${def.shortName} açısı kuruyor.';

    if (def.degree == 0.0) {
      return '$header Bu güçlü transit kavuşumu, $natalTheme alanınızda yeni bir döngüyü başlatıyor. Gökyüzündeki ${t.name} enerjisi natal ${n.name} derecenizi doğrudan uyandırırken, odaklandığınız konularda somut adımlar atmak ve yeni kararları hayata geçirmek için kilit bir dönemdesiniz.';
    } else if (def.degree == 180.0) {
      return '$header Transit ${t.name} karşıtlığı, $natalTheme konularında ikili ilişkiler, ortaklıklar ve dış koşullar üzerinden önemli bir farkındalık ve yüzleşme getiriyor. Aşırı uçlara savrulmadan dengeyi koruduğunuzda bu süreç uzun vadeli netlik sağlayacaktır.';
    } else if (def.degree == 120.0) {
      return '$header Transit ${t.name} üçgeni, $natalTheme alanınıza gökyüzünden akıcı, koruyucu ve destekleyici bir rüzgar gönderiyor. Girişimlerinizde engellerin kolayca aşılması, beklediğiniz desteklerin gelmesi ve motivasyonunuzun yükselmesi için ideal bir transit penceresi.';
    } else if (def.degree == 90.0) {
      return '$header Transit ${t.name} karesi, $natalTheme konularında sizi harekete geçmeye, ertelediğiniz pürüzleri çözmeye ve stratejik irade göstermeye davet ediyor. Aceleci tepkiler yerine planlı adımlar attığınızda bu dinamik enerjiyi somut bir sıçramaya dönüştürebilirsiniz.';
    } else if (def.degree == 60.0) {
      return '$header Transit ${t.name} sekstili, $natalTheme alanınızda yeni bağlantılar, verimli görüşmeler ve pratik fırsatlar yaratıyor. Küçük bir adım veya doğru iletişimle kapıları lehinize açabileceğiniz destekleyici bir gökyüzü açısı.';
    } else {
      return '$header Transit ${t.name} ile Natal ${n.name} arasındaki 150° Quincunx etkileşimi, $natalTheme konularında günlük planlarınızı revize etmenizi, esnek kalmanızı ve sağlığınıza/enerji dengenize özen göstermenizi hatırlatıyor.';
    }
  }
}
