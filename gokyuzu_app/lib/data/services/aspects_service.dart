import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AspectDefinition {
  final String name;
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
}

class AspectHit {
  final String planetA;
  final String planetB;
  final String aspectName;
  final String aspectSymbol;
  final String orbStr;
  final bool isMajor;
  final bool isTransit;
  final Color color;
  final String interpretation;

  const AspectHit({
    required this.planetA,
    required this.planetB,
    required this.aspectName,
    required this.aspectSymbol,
    required this.orbStr,
    required this.isMajor,
    required this.isTransit,
    required this.color,
    required this.interpretation,
  });
}

class AspectsService {
  // All Major and Minor Aspects Encyclopedia
  static final List<AspectDefinition> allAspectDefinitions = [
    // --- MAJOR ASPECTS ---
    const AspectDefinition(
      name: 'Kavuşum (Conjunction)',
      symbol: '☌',
      degree: 0.0,
      defaultOrb: 8.0,
      isMajor: true,
      category: 'Majör Açı (0°)',
      nature: 'Odaklanmış / Güçlü Kaynaşma',
      color: AppColors.starlightGold,
      description:
          'İki gezegenin gökyüzünde aynı burç ve derece civarında buluşmasıdır. En güçlü açı formudur.',
      psychologicalMeaning:
          'İki farklı arketipsel enerjinin ayrılmaz biçimde birleşmesi. Birey bu iki gücü birbirinden bağımsız deneyimleyemez; biri tetiklendiğinde diğeri derhal devreye girer.',
      gift: 'Yüksek odaklanma, yoğun irade ve tek bir hedef doğrultusunda muazzam enerji akışı.',
      challenge: 'Gezegenlerin sınırlarını ayırt edememekten kaynaklanan körleşme ve sübjektiflik.',
    ),
    const AspectDefinition(
      name: 'Karşıt (Opposition)',
      symbol: '☍',
      degree: 180.0,
      defaultOrb: 8.0,
      isMajor: true,
      category: 'Majör Açı (180°)',
      nature: 'Kutupsallık & Yüzleşme',
      color: AppColors.savageRed,
      description:
          'İki gezegenin tam karşıt burç ve derecelerde bulunmasıdır. Zıt kutupların etkileşimidir.',
      psychologicalMeaning:
          'İçsel çatışma ve bu çatışmanın sıklıkla dış dünyaya (özellikle ilişkilere) projekte edilmesi. Karşıtlık, bireye kendisini başkasının aynasında görme fırsatı sunar.',
      gift: 'Geniş perspektif, objektiflik, ilişkilerde yüksek empati ve kutupları uzlaştırma bilgeliği.',
      challenge: 'Bir uçtan diğerine savrulma, ikilemde kalma ve dış dünyayı suçlama eğilimi.',
    ),
    const AspectDefinition(
      name: 'Üçgen (Trine)',
      symbol: '△',
      degree: 120.0,
      defaultOrb: 8.0,
      isMajor: true,
      category: 'Majör Açı (120°)',
      nature: 'Ahenk & Zahmetsiz Akış',
      color: AppColors.pastelMint,
      description:
          'Aynı elementteki iki burcun gezegenleri arasındaki 120 derecelik uyumlu açıdır.',
      psychologicalMeaning:
          'Doğuştan gelen yetenekler, akış hali ve rahat enerji transferi. Birey bu alanda çaba sarf etmeden başarı veya huzur bulur.',
      gift: 'Doğal yaratıcılık, yüksek şans, sezgisel kolaylık ve içsel sükunet.',
      challenge: 'Kolaylığa alışıp tembellik etmek, potansiyeli geliştirmek için yeterince çaba göstermemek.',
    ),
    const AspectDefinition(
      name: 'Kare (Square)',
      symbol: '□',
      degree: 90.0,
      defaultOrb: 7.0,
      isMajor: true,
      category: 'Majör Açı (90°)',
      nature: 'Dinamik Gerilim & Büyüme Motoru',
      color: AppColors.warningOrange,
      description:
          'Aynı nitelikteki (Öncü, Sabit veya Değişken) burçlar arasındaki 90 derecelik dik açıdır.',
      psychologicalMeaning:
          'İçsel sürtünme ve kriz enerjisi. Rahatlığa izin vermeyen bu açı, insanı eyleme geçmeye ve sorunları çözerek ustalaşmaya zorlar.',
      gift: 'Kararlılık, krizleri avantaja çevirme, dayanıklılık ve büyük başarılara imza atma gücü.',
      challenge: 'Kronik stres, öfke, içsel sabırsızlık ve gereksiz güç savaşları.',
    ),
    const AspectDefinition(
      name: 'Sekstil (Sextile)',
      symbol: '⚹',
      degree: 60.0,
      defaultOrb: 6.0,
      isMajor: true,
      category: 'Majör Açı (60°)',
      nature: 'Fırsat & İletişim Köprüsü',
      color: AppColors.pastelBlue,
      description:
          'Uyumlu elementler (Ateş-Hava veya Toprak-Su) arasındaki 60 derecelik işbirlikçi açıdır.',
      psychologicalMeaning:
          'Bilinçli çaba ile açığa çıkan fırsatlar. Üçgen gibi otomatik işlemez; birey adım attığında kapılar ardına kadar açılır.',
      gift: 'Zihinsel kıvraklık, işbirliği kurma yeteneği, sosyal köprüler ve pratik çözümler.',
      challenge: 'Harekete geçilmezse fırsatların fark edilmeden kaçırılması.',
    ),

    // --- MINOR ASPECTS ---
    const AspectDefinition(
      name: '150° Birleşmeyen (Quincunx / Inconjunct)',
      symbol: '⚻',
      degree: 150.0,
      defaultOrb: 3.0,
      isMajor: false,
      category: 'Minör Açı (150°)',
      nature: 'Uyumsuzluk & Sürekli Ayar Gereksinimi',
      color: AppColors.pastelLavender,
      description:
          'Ne elementi ne de niteliği uyuşan burçlar arasındaki 150 derecelik açıdır.',
      psychologicalMeaning:
          'Farklı dilleri konuşan iki parçanın bir arada yaşamaya çalışması. Genellikle psikosomatik sağlık konuları veya sürekli revizyon ihtiyacı olarak tezahür eder.',
      gift: 'Yüksek adaptasyon kabiliyeti, detaylı revizyon ustalığı ve esneklik.',
      challenge: 'Bitmeyen içsel huzursuzluk, bir türlü tatmin olamama ve bedensel gerginlik.',
    ),
    const AspectDefinition(
      name: 'Yarım Kare (Semisquare)',
      symbol: '∠',
      degree: 45.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (45°)',
      nature: 'Mikro Gerilim & Erken Uyarı',
      color: AppColors.pastelPink,
      description:
          '90 derecelik karenin yarısı olan 45 derecelik hafif gerilimli açıdır.',
      psychologicalMeaning:
          'Yüzeye çıkmamış içsel sürtünmeler. Olaylar patlak vermeden önce hissedilen hafif huzursuzluk hissi.',
      gift: 'Gelişmiş erken algı ve ince ayar yapabilme refleksi.',
      challenge: 'Sebepsiz gerginlik ve küçük pürüzlere takılma.',
    ),
    const AspectDefinition(
      name: 'Sesquiquadrate (Sesquiquadrate)',
      symbol: '⚼',
      degree: 135.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (135°)',
      nature: 'İnatçı Engel & Sabır Testi',
      color: AppColors.pastelPeach,
      description:
          'Bir kare ve bir yarım karenin birleşimi olan 135 derecelik sürtünmeli açıdır.',
      psychologicalMeaning:
          'Dış koşulların hedefleri geciktirmesi karşısında sabrı ve stratejiyi öğrenme alanı.',
      gift: 'Yüksek dayanıklılık ve karmaşık engelleri aşma disiplini.',
      challenge: 'İsyan etme, boşuna enerji harcama ve kontrolsüz inatçılık.',
    ),
    const AspectDefinition(
      name: 'Yarı Sekstil (Semisextile)',
      symbol: '⚺',
      degree: 30.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (30°)',
      nature: 'Komşu Burç Geçişi',
      color: AppColors.textSecondary,
      description:
          'Yan yana iki burç arasındaki 30 derecelik ince açıdır.',
      psychologicalMeaning:
          'Bir evreden diğerine geçerken edinilen küçük farkındalık adımları.',
      gift: 'Aşamalı büyüme ve detaylı entegrasyon yeteneği.',
      challenge: 'Komşu enerjilerin doğasındaki taban tabana zıtlığı yönetmekte zorlanma.',
    ),
    const AspectDefinition(
      name: 'Quintile (Beşlik Açı)',
      symbol: 'Q',
      degree: 72.0,
      defaultOrb: 2.0,
      isMajor: false,
      category: 'Minör Açı (72°)',
      nature: 'Yaratıcı Deha & Özel Yetenek',
      color: AppColors.pastelMint,
      description:
          '360 derecenin 5\'e bölünmesiyle elde edilen 72 derecelik zihinsel ve sanatsal açıdır.',
      psychologicalMeaning:
          'Orijinal düşünce, teknik ustalık ve sıra dışı ilham kanalları.',
      gift: 'Yenilikçi buluşlar, sanatsal incelik ve sıra dışı problem çözme zekası.',
      challenge: 'Sıradan günlük hayatın temposuna uyum sağlamakta zorlanma.',
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
    'Yükselen (ASC)',
    'Tepe Noktası (MC)',
  ];

  static const Map<String, String> planetSymbols = {
    'Güneş': '☉',
    'Ay': '☽',
    'Merkür': '☿',
    'Venüs': '♀',
    'Mars': '♂',
    'Jüpiter': '♃',
    'Satürn': '♄',
    'Uranüs': '♅',
    'Neptün': '♆',
    'Plüton': '♇',
    'Yükselen (ASC)': 'ASC',
    'Tepe Noktası (MC)': 'MC',
  };

  // Get Natal Aspects for User
  static List<AspectHit> getNatalAspects() {
    return const [
      AspectHit(
        planetA: 'Güneş',
        planetB: 'Ay',
        aspectName: 'Üçgen',
        aspectSymbol: '△',
        orbStr: '1°14\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.pastelMint,
        interpretation:
            'Güneş ile Ay arasındaki üçgen açı, bilinç ile bilinçaltı arasında kusursuz bir denge kurar. Kararlarınız duygularınızla çatışmaz; iç huzurunuz ve sezgisel özgüveniniz yüksektir.',
      ),
      AspectHit(
        planetA: 'Güneş',
        planetB: 'Merkür',
        aspectName: 'Kavuşum',
        aspectSymbol: '☌',
        orbStr: '2°05\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.starlightGold,
        interpretation:
            'Güneş ve Merkür kavuşumu (Merkür Kazimi / Combust hattı); keskin bir zeka, kendini ifade etmede güçlü hitabet ve entelektüel irade bahşeder.',
      ),
      AspectHit(
        planetA: 'Venüs',
        planetB: 'Mars',
        aspectName: 'Sekstil',
        aspectSymbol: '⚹',
        orbStr: '1°48\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.pastelPink,
        interpretation:
            'Venüs ile Mars arasındaki 60 derecelik sekstil; sosyal çekim gücü, estetik duyu, romantik zarafet ve sağlıklı eylem motivasyonu sağlar.',
      ),
      AspectHit(
        planetA: 'Mars',
        planetB: 'Jüpiter',
        aspectName: 'Kare',
        aspectSymbol: '□',
        orbStr: '2°30\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.warningOrange,
        interpretation:
            'Mars ile Jüpiter arasındaki 90 derecelik dinamik kare; yüksek hedefler ve büyük adımlar atma cesareti verir. Sabırsızlığa ve enerjiyi aşırı dağıtmaya dikkat edilmelidir.',
      ),
      AspectHit(
        planetA: 'Satürn',
        planetB: 'Plüton',
        aspectName: 'Karşıt',
        aspectSymbol: '☍',
        orbStr: '3°12\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.savageRed,
        interpretation:
            'Satürn ile Plüton karşıtlığı; zorluklar karşısında sarsılmaz bir irade, dayanıklılık ve krizlerden daha güçlü doğma kapasitesi getirir.',
      ),
      AspectHit(
        planetA: 'Güneş',
        planetB: 'Yükselen (ASC)',
        aspectName: '150° Quincunx',
        aspectSymbol: '⚻',
        orbStr: '0°45\'',
        isMajor: false,
        isTransit: false,
        color: AppColors.pastelLavender,
        interpretation:
            'Güneş ile ASC arasındaki 150 derecelik açı; içsel kimliğiniz ile dışarıya yansıttığınız imaj arasında sürekli bilinçli bir uyum ve denge kurma ihtiyacını gösterir.',
      ),
      AspectHit(
        planetA: 'Merkür',
        planetB: 'Satürn',
        aspectName: 'Sekstil',
        aspectSymbol: '⚹',
        orbStr: '1°20\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.pastelBlue,
        interpretation:
            'Merkür ile Satürn sekstili; sistemli düşünme, analitik disiplin, güvenilir sözler ve uzun vadeli stratejik planlama yeteneği sağlar.',
      ),
      AspectHit(
        planetA: 'Ay',
        planetB: 'Yükselen (ASC)',
        aspectName: 'Üçgen',
        aspectSymbol: '△',
        orbStr: '2°10\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.pastelMint,
        interpretation:
            'Ay ile Yükselen üçgeni; çevreye yansıyan sıcak bir empati, sevimli ve kabul gören bir aura ile duygusal zeka zenginliği kazandırır.',
      ),
      AspectHit(
        planetA: 'Uranüs',
        planetB: 'Tepe Noktası (MC)',
        aspectName: 'Üçgen',
        aspectSymbol: '△',
        orbStr: '1°05\'',
        isMajor: true,
        isTransit: false,
        color: AppColors.starlightGold,
        interpretation:
            'Uranüs ile MC arasındaki ahenk; kariyerde ve toplumsal hedeflerde yenilikçi, teknolojik ve vizyoner yaklaşımların hızla kabul görmesini sağlar.',
      ),
    ];
  }

  static String cleanPlanetName(String raw) {
    return raw
        .replaceAll('Transit ', '')
        .replaceAll('Natal ', '')
        .replaceAll(' (Transit)', '')
        .trim();
  }

  // Get Current Transit Aspects to Natal Chart (An Haritası Baz Alınarak)
  static List<AspectHit> getTransitAspects() {
    return const [
      AspectHit(
        planetA: 'Transit Güneş',
        planetB: 'Natal Merkür',
        aspectName: 'Kavuşum (Transit)',
        aspectSymbol: '☌',
        orbStr: '0°45\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.starlightGold,
        interpretation:
            'Canlı Terazi Güneşi natal Merkür\'ünüzü aydınlatıyor. İletişim, önemli sözleşmeler, anlaşmalar ve zihinsel projelerde netlik ve parlama dönemi.',
      ),
      AspectHit(
        planetA: 'Transit Ay',
        planetB: 'Natal Mars',
        aspectName: 'Üçgen (Transit)',
        aspectSymbol: '△',
        orbStr: '1°15\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.pastelMint,
        interpretation:
            'Akrep Ayı ile Mars arasındaki akıcı üçgen açı; sezgilerinizle eylemlerinizi kusursuz birleştiriyor. Hedeflerinize tutkuyla odaklanmak için harika bir an.',
      ),
      AspectHit(
        planetA: 'Transit Jüpiter',
        planetB: 'Natal Güneş',
        aspectName: 'Kavuşum (Transit)',
        aspectSymbol: '☌',
        orbStr: '1°10\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.starlightGold,
        interpretation:
            'Genişleme ve fırsat dönemi! Özgüvenin yükseldiği, yeni projelerin ön plana çıktığı ve şans faktörünün maksimum seviyede çalıştığı bir geçiş.',
      ),
      AspectHit(
        planetA: 'Transit Satürn',
        planetB: 'Natal Venüs',
        aspectName: 'Sekstil (Transit)',
        aspectSymbol: '⚹',
        orbStr: '0°55\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.pastelBlue,
        interpretation:
            'Finansal ve ilişkisel konularda kalıcı temeller atma zamanı. Ciddiyet, güven ve uzun vadeli sözleşmeler için oldukça verimli bir transit.',
      ),
      AspectHit(
        planetA: 'Transit Plüton',
        planetB: 'Natal Ay',
        aspectName: 'Kare (Transit)',
        aspectSymbol: '□',
        orbStr: '1°40\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.warningOrange,
        interpretation:
            'Derin psikolojik dönüşüm süreci. Eski alışkanlıkların ve duygusal bağımlılıkların arındırılmasıyla içsel bir güç uyanışı gerçekleşir.',
      ),
      AspectHit(
        planetA: 'Transit Uranüs',
        planetB: 'Natal Merkür',
        aspectName: 'Üçgen (Transit)',
        aspectSymbol: '△',
        orbStr: '1°25\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.pastelMint,
        interpretation:
            'Zihinsel aydınlanma ve ani dahiyane fikirler. Teknolojik atılımlar, yeni eğitimler ve yaratıcı çözümler için fevkalade akıcı bir etki.',
      ),
      AspectHit(
        planetA: 'Transit Neptün',
        planetB: 'Natal Mars',
        aspectName: 'Sekstil (Transit)',
        aspectSymbol: '⚹',
        orbStr: '2°05\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.pastelLavender,
        interpretation:
            'Eylemlerin sezgilerle hizalanması. Maneviyat, sanatsal projeler ve başkalarına yardım etme dürtüsünün eyleme dökülmesi dönemi.',
      ),
      AspectHit(
        planetA: 'Transit Mars',
        planetB: 'Natal Plüton',
        aspectName: 'Üçgen (Transit)',
        aspectSymbol: '△',
        orbStr: '1°30\'',
        isMajor: true,
        isTransit: true,
        color: AppColors.pastelMint,
        interpretation:
            'Yüksek dayanıklılık ve dönüştürücü irade. Zorlu engelleri kararlılıkla aşmak için güçlü bir kozmik destek.',
      ),
    ];
  }

  // Find Aspect Hit between Planet A and Planet B for the Grid Cell
  static AspectHit? findAspectInGrid(String pA, String pB, {bool includeTransits = false}) {
    final cleanA = cleanPlanetName(pA);
    final cleanB = cleanPlanetName(pB);

    if (includeTransits) {
      // First prioritize transit aspects to show on the live grid!
      final transits = getTransitAspects();
      for (final hit in transits) {
        final hitA = cleanPlanetName(hit.planetA);
        final hitB = cleanPlanetName(hit.planetB);
        if ((hitA == cleanA && hitB == cleanB) || (hitA == cleanB && hitB == cleanA)) {
          return hit;
        }
      }
    }

    // Default to natal aspect
    final natals = getNatalAspects();
    for (final hit in natals) {
      final hitA = cleanPlanetName(hit.planetA);
      final hitB = cleanPlanetName(hit.planetB);
      if ((hitA == cleanA && hitB == cleanB) || (hitA == cleanB && hitB == cleanA)) {
        return hit;
      }
    }
    return null;
  }
}
