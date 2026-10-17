import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../models/birth_chart_model.dart';
import 'app_translation_service.dart';
import 'aspects_service.dart';
import 'astrology_engine.dart';
import 'predictive_astrology_service.dart';
import 'storage_service.dart';

class EclipseLesson {
  final String title;
  final String subtitle;
  final String badge;
  final Color accentColor;
  final IconData icon;
  final List<String> bulletPoints;
  final String deepExplanation;
  final String astronomicalNote;

  const EclipseLesson({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.accentColor,
    required this.icon,
    required this.bulletPoints,
    required this.deepExplanation,
    required this.astronomicalNote,
  });
}

class EclipseEvent {
  final String id;
  final DateTime dateTimeTr; // Türkiye Saati (UTC+3)
  final String dateFormatted;
  final String timeFormatted;
  final bool isSolar; // true: Güneş Tutulması, false: Ay Tutulması
  final String subType; // Tam, Halkalı, Parçalı, Yarı Gölgeli
  final String sign;
  final int degree;
  final int minute;
  final String nodeName; // Kuzey Ay Düğümü (Rahu) / Güney Ay Düğümü (Ketu)
  final int sarosSeries;
  final String durationInfo;
  final String visibilityRegion;
  final String collectiveTheme;
  final String educationalLessonNote;

  const EclipseEvent({
    required this.id,
    required this.dateTimeTr,
    required this.dateFormatted,
    required this.timeFormatted,
    required this.isSolar,
    required this.subType,
    required this.sign,
    required this.degree,
    required this.minute,
    required this.nodeName,
    required this.sarosSeries,
    required this.durationInfo,
    required this.visibilityRegion,
    required this.collectiveTheme,
    required this.educationalLessonNote,
  });

  String get fullTypeTitle {
    final lang = AppTranslationService.currentLang;
    final sub = AppTranslationService.tr(subType);
    final type = isSolar
        ? (lang == 'en' ? 'Solar Eclipse' : (lang == 'ja' ? '日食' : 'Güneş Tutulması'))
        : (lang == 'en' ? 'Lunar Eclipse' : (lang == 'ja' ? '月食' : 'Ay Tutulması'));
    return '$sub $type';
  }

  String get degreeSignFormatted =>
      '${degree.toString().padLeft(2, '0')}°${minute.toString().padLeft(2, '0')}\' ${AppTranslationService.signName(sign)}';

  double get absoluteLongitude {
    final idx = AspectsService.zodiacSigns.indexOf(sign);
    final sIdx = idx >= 0 ? idx : 0;
    return (sIdx * 30.0) + degree + (minute / 60.0);
  }
}

class PersonalEclipseAspectTrigger {
  final String natalPlanetName;
  final String natalPlanetSignDegree;
  final String aspectName;
  final String aspectSymbol;
  final String orbFormatted;
  final Color color;
  final String triggerAdvice;

  const PersonalEclipseAspectTrigger({
    required this.natalPlanetName,
    required this.natalPlanetSignDegree,
    required this.aspectName,
    required this.aspectSymbol,
    required this.orbFormatted,
    required this.color,
    required this.triggerAdvice,
  });
}

class PersonalEclipseAnalysis {
  final EclipseEvent eclipse;
  final int activatedHouse;
  final int oppositeHouse;
  final String houseAxisTitle;
  final String personalHouseCounseling;
  final String sarosEchoMessage;
  final String strategicActionPlan;
  final List<PersonalEclipseAspectTrigger> natalTriggers;

  const PersonalEclipseAnalysis({
    required this.eclipse,
    required this.activatedHouse,
    required this.oppositeHouse,
    required this.houseAxisTitle,
    required this.personalHouseCounseling,
    required this.sarosEchoMessage,
    required this.strategicActionPlan,
    required this.natalTriggers,
  });
}

class EclipsesService {
  // --- 1. DERS NİTELİĞİNDE TUTULMALAR AKADEMİSİ (EĞİTİM BÖLÜMÜ) ---
  static const List<EclipseLesson> masterclassLessons = [
    EclipseLesson(
      title: '1. Tutulmaların Astronomik ve Astrolojik Mekanizması',
      subtitle: 'Ekliptik Düzlem, Ay Yörüngesi (5°09\') ve Ay Düğümleri (Rahu & Ketu)',
      badge: 'TEMEL MEKANİZMA 🌌',
      accentColor: AppColors.starlightGold,
      icon: Icons.public_rounded,
      bulletPoints: [
        'Her Yeniayda Güneş Tutulması, her Dolunayda Ay Tutulması olmamasının sebebi; Ay\'ın Dünya etrafındaki yörüngesinin, Dünya\'nın Güneş etrafındaki yörüngesine (Ekliptik) göre 5° 09\' eğik olmasıdır.',
        'Bu iki yörünge düzleminin kesiştiği iki matematiksel ve elektromanyetik noktaya Ay Düğümleri (Kuzey Ay Düğümü / Rahu - Caput Draconis ve Güney Ay Düğümü / Ketu - Cauda Draconis) denir.',
        'Güneş Tutulması Sınırı (Solar Eclipse Limit): Yeniay, Ay Düğümlerine en fazla 18° 31\' (kesin sınır 15° 21\') yakınlıkta gerçekleştiğinde Güneş Tutulması meydana gelir.',
        'Ay Tutulması Sınırı (Lunar Eclipse Limit): Dolunay, Ay Düğümlerine en fazla 12° 15\' (kesin sınır 9° 30\') yakınlıkta gerçekleştiğinde Ay Tutulması meydana gelir.',
      ],
      deepExplanation:
          'Astrolojide tutulmalar gökyüzünün "kozmik vites değişimleri" ve kadersel hızlandırıcılarıdır. Normal bir Yeniay veya Dolunay 28 günlük bir döngüyü yönetirken, Ay Düğümleriyle hizalanan bir tutulma 6 ay ile 1,5 yıl arasında çalışan kadersel kapıları açar veya kapatır. Kuzey Ay Düğümü (Rahu) tarafındaki tutulmalar geleceğe yönelik büyümeyi, yeni fırsatları ve cesur atılımları; Güney Ay Düğümü (Ketu) tarafındaki tutulmalar ise geçmişten gelen karmik yüklerin bırakılmasını, arınmayı ve tamamlanmayı simgeler.',
      astronomicalNote:
          'Astronomik Not: Güneş ve Ay Düğümlerinin kavuşumu yılda iki kez "Tutulma Mevsimi" (Eclipse Season) oluşturur. İki tutulma mevsimi arasında yaklaşık 173.3 gün (bir Drakonik Yılın yarısı) vardır.',
    ),
    EclipseLesson(
      title: '2. Güneş Tutulması Türleri: Tam, Halkalı, Parçalı ve Hibrit',
      subtitle: 'Yeniay Enerjisinin Kadersel Başlangıçlara Dönüşümü (Umbra, Antumbra & Penumbra)',
      badge: 'GÜNEŞ TUTULMALARI ☀️',
      accentColor: AppColors.warningOrange,
      icon: Icons.wb_sunny_rounded,
      bulletPoints: [
        'Tam Güneş Tutulması (Total Solar Eclipse): Ay, Dünya\'ya yeterince yakındır (Perigee / Yerberi) ve Güneş diskini %100 kapatır. Dünya üzerine tam gölge (Umbra) düşer. Astrolojik olarak en güçlü tutulmadır; eski bir kimliği veya dönemi tamamen kapatıp sıfırdan kadersel bir sayfa açar.',
        'Halkalı Güneş Tutulması (Annular Solar Eclipse - Ateş Çemberi): Ay, eliptik yörüngesinde Dünya\'ya en uzak noktadadır (Apogee / Yeröte). Görünür çapı Güneş\'ten küçük kaldığı için Güneş\'in etrafında parlak bir "Ateş Çemberi" (Antumbra) kalır. Astrolojik olarak otorite, ego ve kurulu düzenin sınavdan geçmesini; eski çerçevenin içinde yeni bir bilinç çekirdeği kurmayı anlatır.',
        'Parçalı Güneş Tutulması (Partial Solar Eclipse): Dünya\'ya yalnızca Ay\'ın yarı gölgesi (Penumbra) düşer ve Güneş\'in bir kısmı örtülür. Astrolojik olarak gerçekleştiği ev konularında kademeli bir uyanış, yeni bir yön arayışı ve stratejik revizyon getirir.',
        'Hibrit (Melez) Güneş Tutulması (Hybrid Solar Eclipse): Dünya\'nın küresel eğriliği nedeniyle tutulma hattının bazı bölgelerinde Halkalı, merkez bölgelerinde ise Tam tutulma olarak gözlenir. Çok nadirdir; krizleri ani sıçramaya dönüştüren çift doğalı eşikleri temsil eder.',
      ],
      deepExplanation:
          'Güneş Tutulmaları daima Yeniay fazında gerçekleşir ve "Dışsal Olayları, Yeni Başlangıçları, Otorite Figürlerini ve Yaşam Yönünü" tetikler. Klasik astrolojide Batlamyus (Ptolemy) kuralına göre: Bir Güneş tutulmasının tam örtülme süresi kaç saat sürüyorsa, etkileri o kadar yıl (ortalama 1,5 ila 3,5 yıl) boyunca kademeli olarak çalışır.',
      astronomicalNote:
          'Astronomik Not: Güneş, Ay\'dan yaklaşık 400 kat daha büyüktür; ancak Güneş Dünya\'ya Ay\'dan yaklaşık 400 kat daha uzaktır. Bu muazzam kozmik oran sayesinde gökyüzünde ikisi de yaklaşık 0.5° (30 yay dakikası) görünür çapa sahiptir.',
    ),
    EclipseLesson(
      title: '3. Ay Tutulması Türleri: Tam (Kanlı Ay), Parçalı ve Yarı Gölgeli',
      subtitle: 'Dolunay Enerjisinin Duygusal Zirve, Yüzleşme ve Hasat Etkisi',
      badge: 'AY TUTULMALARI 🌕',
      accentColor: AppColors.pastelPink,
      icon: Icons.nightlight_round,
      bulletPoints: [
        'Tam Ay Tutulması (Total Lunar Eclipse - Kanlı Ay): Dünya, Güneş ile Ay\'ın tam ortasına girer ve Ay tamamen Dünya\'nın tam gölge konisine (Umbra) gömülür. Dünya atmosferinden kırılan kızıl güneş ışınları (Rayleigh saçılması) Ay\'ı bakır-kızıl renge boyar. Astrolojik olarak bastırılmış duyguların patlamasını, gizli gerçeklerin ortaya çıkmasını ve geri dönüşü olmayan duygusal/ilişkisel kararları simgeler.',
        'Parçalı Ay Tutulması (Partial Lunar Eclipse): Ay diskinin yalnızca bir bölümü Dünya\'nın Umbra (tam gölge) konisinden geçer. Astrolojik olarak hayatınızda hangi alışkanlığın, ilişkinin veya ortaklığın budanması gerektiğini somut olaylarla gösterir.',
        'Yarı Gölgeli Ay Tutulması (Penumbral Lunar Eclipse): Ay, Dünya\'nın merkez gölgesine girmeden yalnızca dış yarı gölge (Penumbra) alanından geçer. Gözle fark edilmesi zordur; astrolojik olarak dışsal krizlerden ziyade derin psikolojik aydınlanmaları, rüyaları ve içsel kararları tetikler.',
      ],
      deepExplanation:
          'Ay Tutulmaları daima Dolunay fazında gerçekleşir. Güneş ve Ay birbirine 180° karşıt açıdadır. Bu yüzden Ay tutulmaları "İlişkileri, Duygusal Güvenliği, Bilinçaltını, Aileyi ve Sonuçlanmaları/Hasadı" yönetir. Güneş tutulması tohumu eker; Ay tutulması ise o tohumun meyvesini görünür kılar ve süresi dolan bağları hayatımızdan temizler.',
      astronomicalNote:
          'Astronomik Not: Bir Ay tutulmasında her 1 saatlik tutulma süresi, klasik astrolojide yaklaşık 1 aylık yoğun duygusal ve toplumsal etki süresine karşılık gelir (etki penceresi tutulmadan 1 ay önce başlar ve 6 aya kadar yayılır).',
    ),
    EclipseLesson(
      title: '4. Saros Döngüleri: 18 Yıl 11 Gün 8 Saatlik Kozmik Saat',
      subtitle: 'Babil/Keldani Astronomlarının Keşfettiği Tutulma Aileleri ve Karmik Yankı',
      badge: 'SAROS DÖNGÜSÜ ⏳',
      accentColor: AppColors.pastelMint,
      icon: Icons.autorenew_rounded,
      bulletPoints: [
        'Saros Periyodu (6585.321 gün = 18 Yıl 11 Gün 8 Saat): Güneş, Ay ve Ay Düğümlerinin birbirine göre neredeyse birebir aynı geometriye geri döndüğü muazzam astronomik döngüdür.',
        'Üçlü Harmoni: 223 Sinodik Ay (Yeniay-Yeniay: 29.53 gün) ≈ 242 Drakonik Ay (Düğüm-Düğüm: 27.21 gün) ≈ 239 Anomalistik Ay (Yerberi-Yerberi: 27.55 gün). Bu üç döngü 18 yıl 11 gün 8 saatte milimetrik olarak çakışır.',
        '8 Saatlik Fark ve Exeligmos (54 Yıl 34 Gün): Döngünün sonundaki 8 saatlik (0.32 gün) küsurat nedeniyle Dünya kendi ekseni etrafında 1/3 tur (120°) döner. Bu yüzden aynı Saros serisinin bir sonraki tutulması 120° batıda gerçekleşir. Tam 3 Saros döngüsü (54 yıl 1 ay) sonra tutulma aynı coğrafyaya geri döner!',
        'Saros Ailesinin Ömrü: Her Saros serisi Kuzey veya Güney kutbundan küçük bir parçalı tutulma olarak doğar, yüzyıllar içinde merkeze kayarak Tam/Halkalı tutulmalar üretir ve 1226 ila 1550 yıl (yaklaşık 70-85 tutulma) sonunda karşı kutupta sönümlenir.',
      ],
      deepExplanation:
          'Bireysel doğum haritası analizinde Saros döngüsü altın değerindedir! Bugün yaşadığınız bir tutulmadan tam 18 yıl 11 gün geriye gittiğinizde (örneğin 2026 yılındaki tutulmalar için 2008 yılına, 2027 yılı için 2009 yılına baktığınızda), hayatınızda hangi ana temaların, taşınmaların, ilişki veya kariyer kırılmalarının yaşandığını görürsünüz. Aynı Saros ailesi 18 yıl sonra aynı burç eksenini bir üst bilinç oktavında yeniden uyandırır.',
      astronomicalNote:
          'Klasik Kural: Tek sayılı Güneş Saros serileri (örn. Saros 121, 131) Kuzey Ay Düğümü\'nde gerçekleşir ve Kuzey kutbundan Güney\'e iner. Çift sayılı Güneş Saros serileri (örn. Saros 126, 136) Güney kutbundan Kuzey\'e yükselir.',
    ),
    EclipseLesson(
      title: '5. Doğum Haritasında Tutulmalar Nasıl Okunur? (Derece, Ev ve Tetikleyiciler)',
      subtitle: 'Natal Gezegen Kavuşumları, Kareler ve Mars/Satürn Tetiklemeleri',
      badge: 'HARİTA OKUMA 🧭',
      accentColor: AppColors.pastelLavender,
      icon: Icons.explore_rounded,
      bulletPoints: [
        '1. Ev ve Karşıt Aks Yasası: Tutulma yalnız başına çalışmaz; düştüğü ev ile tam karşısındaki evi (180° aksını) birlikte çalıştırır (örn. 1. Ev - 7. Ev Ben/Biz aksı, 2. Ev - 8. Ev Kazanç/Ortak Paylaşım aksı, 4. Ev - 10. Ev Yuva/Kariyer aksı).',
        '2. Derece Hassasiyeti (Orb ±3° - ±5°): Bir tutulma doğum haritanızdaki Güneş, Ay, Yükselen (ASC), Tepe Noktası (MC) veya kişisel bir gezegeninizle ±5° (özellikle ±2°) içinde Kavuşum (0°), Karşıt (180°) veya Kare (90°) açı yapıyorsa, o yıl hayatınızda kadersel bir dönüm noktası yaşanır.',
        '3. Doğum Öncesi Tutulma (Prenatal Eclipse - Syzygy): Doğumunuzdan hemen önce gerçekleşen son Güneş ve Ay tutulmasının burcu ve derecesi, ruhunuzun bu enkarnasyona getirdiği kolektif misyonu gösterir. Transit bir tutulma Prenatal Tutulma derecenize değdiğinde hayatınızın ana virajları alınır.',
        '4. Tutulma Tetikleyicileri (Eclipse Triggers): Tutulmanın gerçekleştiği gün olay hemen patlak vermeyebilir. Tutulma derecesinin üzerinden transit Mars veya transit Güneş geçtiğinde (veya 90°/180° açı yaptığında) tutulmanın vaat ettiği somut olay tetiklenir!',
      ],
      deepExplanation:
          'Astrolojik danışmanlıkta tutulmalar korkulacak gökyüzü olayları değil, hayatımızda tıkanmış enerjileri açan kozmik ameliyatlardır. Direnç göstermek yerine tutulmanın düştüğü evin temalarında proaktif sorumluluk almak, süreci en yüksek hayrınıza çevirmenizi sağlar.',
      astronomicalNote:
          'Sabit Yıldız Etkisi: Kraliyet yıldızları (Regulus 0° Başak, Aldebaran 10° İkizler, Antares 10° Yay, Fomalhaut 4° Balık) veya Algol/Spica üzerinde gerçekleşen tutulmalar hem bireysel hem de dünya astrolojisinde (Mundane) çok daha güçlü izler bırakır.',
    ),
  ];

  // --- 2. 2026 - 2030 TAM TUTULMA TAKVİMİ (ASTRONOMİK NASA EFEMERİS VERİLERİ) ---
  static final List<EclipseEvent> upcomingEclipsesCatalog = [
    // 2026 TUTULMALARI
    EclipseEvent(
      id: '2026_01_solar',
      dateTimeTr: DateTime(2026, 2, 17, 15, 12),
      dateFormatted: '17 Şubat 2026',
      timeFormatted: '15:12 TSİ',
      isSolar: true,
      subType: 'Halkalı (Annular)',
      sign: 'Kova',
      degree: 28,
      minute: 49,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 121,
      durationInfo: 'Halkalı Süre: 2 dk 20 sn',
      visibilityRegion: 'Antarktika, Güney Afrika, Güney Amerika Güneyi',
      collectiveTheme:
          '28° Kova\'daki Ateş Çemberi tutulması; teknoloji, yapay zeka, toplumsal özgürlükler, sosyal ağlar ve gelecek vizyonunda yeni bir çağın kapısını aralıyor. Eski otorite kalıplarının kırılıp kolektif ve yenilikçi sistemlerin kurulmasını tetikler.',
      educationalLessonNote:
          'Kova burcunun son (Anaretik 28°-29°) derecelerinde gerçekleştiği için kararları hızlandıran, uzun süredir beklenen özgürleşme adımlarını aniden gündeme getiren bir Kuzey Düğüm tutulmasıdır.',
    ),
    EclipseEvent(
      id: '2026_02_lunar',
      dateTimeTr: DateTime(2026, 3, 3, 14, 33),
      dateFormatted: '3 Mart 2026',
      timeFormatted: '14:33 TSİ',
      isSolar: false,
      subType: 'Tam (Kanlı Ay)',
      sign: 'Başak',
      degree: 12,
      minute: 53,
      nodeName: 'Güney Ay Düğümü (Ketu)',
      sarosSeries: 133,
      durationInfo: 'Tam Tutulma: 58 dk (Toplam: 5 sa 39 dk)',
      visibilityRegion: 'Asya, Avustralya, Pasifik, Amerika Kıtası',
      collectiveTheme:
          '12° Başak Tam Ay Tutulması; iş hayatı, sağlık sistemleri, günlük düzen, hizmet sektörü ve verimlilik alanlarında büyük bir arınma ve hasat getiriyor. İşlevini yitirmiş rutinleri, aşırı mükemmeliyetçiliği ve yıpratıcı çalışma koşullarını bırakma zamanı.',
      educationalLessonNote:
          'Güney Ay Düğümü (Ketu) yönündeki bu Tam Ay Tutulması, ruhsal ve bedensel detoks, sadeleşme ve "kontrolü bırakıp akışa güvenme" dersini vurgular.',
    ),
    EclipseEvent(
      id: '2026_03_solar',
      dateTimeTr: DateTime(2026, 8, 12, 20, 46),
      dateFormatted: '12 Ağustos 2026',
      timeFormatted: '20:46 TSİ',
      isSolar: true,
      subType: 'Tam (Total)',
      sign: 'Aslan',
      degree: 20,
      minute: 1,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 126,
      durationInfo: 'Tam Örtülme: 2 dk 18 sn',
      visibilityRegion: 'Avrupa (İspanya, İzlanda), Kuzey Kutbu, Kuzey Afrika (Türkiye\'den akşamüstü kısmi)',
      collectiveTheme:
          '20° Aslan Tam Güneş Tutulması; özgüven, liderlik, yaratıcılık, aşk, sahne ve kalbin gerçek arzularını ortaya koyma konusunda muazzam bir kadersel başlangıç enerjisi taşıyor. Kendi hayatınızın başrolüne geçme çağrısıdır.',
      educationalLessonNote:
          'Avrupa\'dan da izlenecek olan bu Tam Güneş Tutulması, Kuzey Ay Düğümü desteğinde cesaret edenlerin, yeteneklerini sergileyenlerin ve kalpten adım atanların hızla yükseleceğini gösterir.',
    ),
    EclipseEvent(
      id: '2026_04_lunar',
      dateTimeTr: DateTime(2026, 8, 28, 7, 13),
      dateFormatted: '28 Ağustos 2026',
      timeFormatted: '07:13 TSİ',
      isSolar: false,
      subType: 'Parçalı (Partial)',
      sign: 'Balık',
      degree: 4,
      minute: 54,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 138,
      durationInfo: 'Parçalı Süre: 3 sa 18 dk (%93 örtülme)',
      visibilityRegion: 'Avrupa, Afrika, Amerika Kıtası, Doğu Pasifik',
      collectiveTheme:
          '04° Balık Parçalı Ay Tutulması (Kraliyet Yıldızı Fomalhaut hattında!); maneviyat, sanatsal ilham, şefkat, rüyalar ve kolektif bilinçaltında derin bir uyanış yaratıyor. İdealizm ile gerçeklik arasındaki dengeyi kurma ve ruhsal şifalanma dönemidir.',
      educationalLessonNote:
          '4° Balık derecesi Kraliyet Yıldızı Fomalhaut ile kavuşumdadır; etik, dürüst ve manevi ideallerden sapmadan ilerleyenlere kalıcı ilham ve koruma vadeder.',
    ),

    // 2027 TUTULMALARI
    EclipseEvent(
      id: '2027_01_solar',
      dateTimeTr: DateTime(2027, 2, 6, 19, 0),
      dateFormatted: '6 Şubat 2027',
      timeFormatted: '19:00 TSİ',
      isSolar: true,
      subType: 'Halkalı (Annular)',
      sign: 'Kova',
      degree: 17,
      minute: 37,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 131,
      durationInfo: 'Halkalı Süre: 7 dk 51 sn',
      visibilityRegion: 'Güney Amerika (Şili, Arjantin), Batı ve Güney Afrika',
      collectiveTheme:
          '17° Kova Halkalı Güneş Tutulması; bilimsel projeler, ekip çalışmaları, sosyal çevrenin yenilenmesi ve bağımsızlık hedeflerinde 2026\'da atılan tohumları kurumsal bir yapıya kavuşturuyor.',
      educationalLessonNote:
          '7 dakika 51 saniyelik uzun halkalı süresiyle, Kova burcunun temsil ettiği entelektüel özgürlük ve gelecek vizyonunda uzun vadeli (7+ yıl) etkiler bırakır.',
    ),
    EclipseEvent(
      id: '2027_02_lunar',
      dateTimeTr: DateTime(2027, 2, 21, 2, 13),
      dateFormatted: '21 Şubat 2027',
      timeFormatted: '02:13 TSİ',
      isSolar: false,
      subType: 'Yarı Gölgeli (Penumbral)',
      sign: 'Başak',
      degree: 2,
      minute: 5,
      nodeName: 'Güney Ay Düğümü (Ketu)',
      sarosSeries: 143,
      durationInfo: 'Yarı Gölgeli Süre: 4 sa 05 dk',
      visibilityRegion: 'Türkiye, Avrupa, Afrika, Asya, Amerika',
      collectiveTheme:
          '02° Başak Yarı Gölgeli Ay Tutulması (Regulus yakınında); iş ve sağlık düzeninde son rötuşları yapma, zihinsel dağınıklığı toplama ve pratik çözümler üretme farkındalığı getiriyor.',
      educationalLessonNote:
          'Türkiye\'den de gece boyunca gözlenecek bu tutulma, Başak-Balık aksındaki son temizlik ve düzenleme halkalarından biridir.',
    ),
    EclipseEvent(
      id: '2027_03_lunar',
      dateTimeTr: DateTime(2027, 7, 18, 19, 3),
      dateFormatted: '18 Temmuz 2027',
      timeFormatted: '19:03 TSİ',
      isSolar: false,
      subType: 'Yarı Gölgeli (Penumbral)',
      sign: 'Oğlak',
      degree: 25,
      minute: 7,
      nodeName: 'Güney Ay Düğümü (Ketu)',
      sarosSeries: 110,
      durationInfo: 'Yarı Gölgeli Süre: 1 sa 18 dk',
      visibilityRegion: 'Asya, Avustralya, Pasifik, Doğu Afrika',
      collectiveTheme:
          '25° Oğlak Yarı Gölgeli Ay Tutulması; 2028\'de tam olarak başlayacak Yengeç-Oğlak tutulma serisinin ilk habercisidir! Kariyer sorumlulukları, toplumsal statü ve aile-iş dengesinde ilk sinyalleri verir.',
      educationalLessonNote:
          'Saros 110 serisinin son halkalarından olan bu tutulma, yeni bir aksın (Yengeç-Oğlak) uyanışını müjdeler.',
    ),
    EclipseEvent(
      id: '2027_04_solar',
      dateTimeTr: DateTime(2027, 8, 2, 13, 7),
      dateFormatted: '2 Ağustos 2027',
      timeFormatted: '13:07 TSİ',
      isSolar: true,
      subType: 'Tam (Total)',
      sign: 'Aslan',
      degree: 9,
      minute: 55,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 136,
      durationInfo: 'Tam Örtülme: 6 dk 23 sn (21. Yüzyılın En Güçlülerinden!)',
      visibilityRegion: 'İspanya, Kuzey Afrika, Mısır (Luksor), Suudi Arabistan (Türkiye\'den yüksek oranlı parçalı)',
      collectiveTheme:
          '09° Aslan Tam Güneş Tutulması; 6 dakika 23 saniyelik olağanüstü tam örtülme süresiyle yüzyılın en görkemli tutulmalarından biridir! Liderlik, öz-değer, yaratıcı projeler ve kalpten gelen hedeflerde 6 yıla yayılan dev bir sıçrama enerjisi taşır.',
      educationalLessonNote:
          'Efsanevi Saros 136 ailesine ait bu tutulma, Ay\'ın Dünya\'ya çok yakın (Perigee) olduğu anda gerçekleştiği için son derece uzun ve güçlü bir Tam Tutulma üretir.',
    ),
    EclipseEvent(
      id: '2027_05_lunar',
      dateTimeTr: DateTime(2027, 8, 17, 10, 4),
      dateFormatted: '17 Ağustos 2027',
      timeFormatted: '10:04 TSİ',
      isSolar: false,
      subType: 'Yarı Gölgeli (Penumbral)',
      sign: 'Kova',
      degree: 24,
      minute: 2,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 148,
      durationInfo: 'Yarı Gölgeli Süre: 3 sa 39 dk',
      visibilityRegion: 'Kuzey ve Güney Amerika, Pasifik',
      collectiveTheme:
          '24° Kova Yarı Gölgeli Ay Tutulması; sosyal ağlar, dostluklar ve gelecek planlarında duygusal netleşme ve vizyon bütünleşmesi sağlar.',
      educationalLessonNote:
          'Aslan Güneş tutulmasından 15 gün sonra gerçekleşerek bireysel yaratıcılığı (Aslan) kolektif faydayla (Kova) birleştirir.',
    ),

    // 2028 TUTULMALARI
    EclipseEvent(
      id: '2028_01_lunar',
      dateTimeTr: DateTime(2028, 1, 12, 7, 13),
      dateFormatted: '12 Ocak 2028',
      timeFormatted: '07:13 TSİ',
      isSolar: false,
      subType: 'Parçalı (Partial)',
      sign: 'Yengeç',
      degree: 21,
      minute: 27,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 115,
      durationInfo: 'Parçalı Süre: 56 dk',
      visibilityRegion: 'Avrupa, Kuzey ve Güney Amerika, Batı Afrika',
      collectiveTheme:
          '21° Yengeç Parçalı Ay Tutulması; ev, yuva, aile, kökler, gayrimenkul ve duygusal güvenlik konularında güçlü kararları ve koruyucu adımları gündeme getirir.',
      educationalLessonNote:
          'Yengeç-Oğlak aksının 2028 yılındaki ana aktivasyonlarından biridir.',
    ),
    EclipseEvent(
      id: '2028_02_solar',
      dateTimeTr: DateTime(2028, 1, 26, 18, 8),
      dateFormatted: '26 Ocak 2028',
      timeFormatted: '18:08 TSİ',
      isSolar: true,
      subType: 'Halkalı (Annular)',
      sign: 'Kova',
      degree: 6,
      minute: 13,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 141,
      durationInfo: 'Halkalı Süre: 10 dk 27 sn',
      visibilityRegion: 'Güney Amerika, İspanya, Portekiz, Kuzeybatı Afrika',
      collectiveTheme:
          '06° Kova Halkalı Güneş Tutulması (10 dk 27 sn süreli dev Ateş Çemberi!); Kova-Aslan serisinin kapanış tacı olarak özgürlük, teknoloji ve kolektif ideallerde kalıcı bir temel bırakır.',
      educationalLessonNote:
          '10 dakikayı aşan halkalı süresiyle modern dönemin en uzun Ateş Çemberi tutulmalarından biridir.',
    ),
    EclipseEvent(
      id: '2028_03_lunar',
      dateTimeTr: DateTime(2028, 7, 6, 21, 20),
      dateFormatted: '6 Temmuz 2028',
      timeFormatted: '21:20 TSİ',
      isSolar: false,
      subType: 'Parçalı (Partial)',
      sign: 'Oğlak',
      degree: 14,
      minute: 58,
      nodeName: 'Güney Ay Düğümü (Ketu)',
      sarosSeries: 120,
      durationInfo: 'Parçalı Süre: 2 sa 21 dk (Türkiye\'den net gözlenecek!)',
      visibilityRegion: 'Türkiye, Avrupa, Afrika, Asya, Avustralya',
      collectiveTheme:
          '14° Oğlak Parçalı Ay Tutulması; kariyer hedefleri, kurumsal yapılar ve sorumluluklarda fazlalıkları eleyip gerçek ustalığa odaklanma zamanı.',
      educationalLessonNote:
          'Türkiye\'de akşam saatlerinde (21:20 TSİ) gökyüzünde çıplak gözle net biçimde izlenebilecek önemli bir Ay tutulmasıdır.',
    ),
    EclipseEvent(
      id: '2028_04_solar',
      dateTimeTr: DateTime(2028, 7, 22, 5, 56),
      dateFormatted: '22 Temmuz 2028',
      timeFormatted: '05:56 TSİ',
      isSolar: true,
      subType: 'Tam (Total)',
      sign: 'Yengeç',
      degree: 29,
      minute: 50,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 146,
      durationInfo: 'Tam Örtülme: 5 dk 10 sn',
      visibilityRegion: 'Avustralya (Sidney), Yeni Zelanda, Güneydoğu Asya',
      collectiveTheme:
          '29°50\' Yengeç (Anaretik Derece!) Tam Güneş Tutulması; aile, vatan, yuva, ebeveynlik ve aidiyet konularında kadersel bir tamamlanma ve yepyeni bir başlangıç kapısı açar.',
      educationalLessonNote:
          '29° Anaretik derecede gerçekleşen Tam Güneş Tutulmaları, ilgili burcun tüm karmik derslerini özetleyen ve ani sıçramalar yaptıran nadir gökyüzü olaylarıdır.',
    ),
    EclipseEvent(
      id: '2028_05_lunar',
      dateTimeTr: DateTime(2028, 12, 31, 19, 52),
      dateFormatted: '31 Aralık 2028',
      timeFormatted: '19:52 TSİ',
      isSolar: false,
      subType: 'Tam (Kanlı Ay)',
      sign: 'Yengeç',
      degree: 10,
      minute: 35,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 125,
      durationInfo: 'Tam Tutulma: 1 sa 11 dk (Türkiye\'den Yılbaşı Gecesi gözlenecek!)',
      visibilityRegion: 'Türkiye, Avrupa, Afrika, Asya, Avustralya',
      collectiveTheme:
          '10° Yengeç Tam Ay Tutulması (Yılbaşı gecesi Sirius yıldızı yakınında!); duygusal şifalanma, aile bağlarının güçlenmesi ve yüksek koruma enerjisiyle yeni bir yıla giriş.',
      educationalLessonNote:
          '14° Yengeç\'teki Sirius sabit yıldızına yakın gerçekleşen bu yılbaşı Tam Ay Tutulması Türkiye\'den baştan sona izlenebilecektir.',
    ),

    // 2029 - 2030 SEÇKİN TUTULMALARI
    EclipseEvent(
      id: '2029_01_solar',
      dateTimeTr: DateTime(2029, 6, 12, 7, 22),
      dateFormatted: '12 Haziran 2029',
      timeFormatted: '07:22 TSİ',
      isSolar: true,
      subType: 'Parçalı (Partial)',
      sign: 'İkizler',
      degree: 21,
      minute: 24,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 118,
      durationInfo: 'Parçalı Güneş Tutulması',
      visibilityRegion: 'Kuzey Avrupa, Kuzey Amerika, Arktik',
      collectiveTheme:
          '21° İkizler Parçalı Güneş Tutulması; İkizler-Yay bilgi, eğitim, medya, ticaret ve uluslararası iletişim aksını resmen başlatıyor.',
      educationalLessonNote:
          '2029-2030 döneminde Ay Düğümlerinin İkizler-Yay eksenine geçişiyle zihinsel ve akademik devrimleri tetikler.',
    ),
    EclipseEvent(
      id: '2029_02_lunar',
      dateTimeTr: DateTime(2029, 6, 26, 6, 22),
      dateFormatted: '26 Haziran 2029',
      timeFormatted: '06:22 TSİ',
      isSolar: false,
      subType: 'Tam (Kanlı Ay)',
      sign: 'Oğlak',
      degree: 5,
      minute: 2,
      nodeName: 'Güney Ay Düğümü (Ketu)',
      sarosSeries: 130,
      durationInfo: 'Tam Tutulma: 1 sa 42 dk (Merkezi Tam Tutulma!)',
      visibilityRegion: 'Amerika Kıtası, Batı Avrupa, Batı Afrika',
      collectiveTheme:
          '05° Oğlak Tam Ay Tutulması; 1 saat 42 dakikalık dev süresiyle kariyer, devlet yapıları ve uzun vadeli hedeflerde büyük bir sonuçlanma getirir.',
      educationalLessonNote:
          'Ay\'ın Dünya gölgesinin tam merkezinden geçtiği ender Merkezi (Central) Tam Ay Tutulmalarından biridir.',
    ),
    EclipseEvent(
      id: '2030_01_solar',
      dateTimeTr: DateTime(2030, 6, 1, 9, 29),
      dateFormatted: '1 Haziran 2030',
      timeFormatted: '09:29 TSİ',
      isSolar: true,
      subType: 'Halkalı (Annular)',
      sign: 'İkizler',
      degree: 10,
      minute: 47,
      nodeName: 'Kuzey Ay Düğümü (Rahu)',
      sarosSeries: 128,
      durationInfo: 'Halkalı Süre: 5 dk 21 sn (TÜRKİYE\'DEN TAM HALKALI İZLENECEK!)',
      visibilityRegion: 'TÜRKİYE (Marmara, İstanbul, Karadeniz hattı!), Yunanistan, Kuzey Afrika, Rusya, Japonya',
      collectiveTheme:
          '10° İkizler Halkalı Güneş Tutulması (Kraliyet Yıldızı Aldebaran üzerinde ve Türkiye hattından geçiyor!); iletişim, ticaret, ulaşım, eğitim ve sözleşmelerde dürüstlük ve vizyon sınavıyla gelen tarihi bir dönemeç.',
      educationalLessonNote:
          '1 Haziran 2030 sabahı İstanbul, Trakya ve Karadeniz hattından doğrudan "Ateş Çemberi" olarak izlenecek olan, Aldebaran Kraliyet Yıldızı kavuşumlu tarihi tutulmadır!',
    ),
  ];

  /// Şu andan itibaren gerçekleşecek ilk (sıradaki) tutulmayı döndürür.
  static EclipseEvent getNextUpcomingEclipse([DateTime? referenceTime]) {
    final now = referenceTime ?? DateTime.now();
    for (final ec in upcomingEclipsesCatalog) {
      if (ec.dateTimeTr.isAfter(now)) {
        return ec;
      }
    }
    return upcomingEclipsesCatalog.last;
  }

  /// İçinde bulunulan yıl ve gelecek yılın tutulmalarını döndürür (VIP Danışmanlık için).
  static List<EclipseEvent> getCurrentAndNextYearEclipses([DateTime? referenceTime]) {
    final now = referenceTime ?? DateTime.now();
    final currentYear = now.year;
    final nextYear = currentYear + 1;
    final filtered = upcomingEclipsesCatalog
        .where((e) =>
            e.dateTimeTr.year == currentYear || e.dateTimeTr.year == nextYear)
        .toList();
    if (filtered.isNotEmpty) return filtered;
    return upcomingEclipsesCatalog.take(8).toList();
  }

  // --- 3. VIP KİŞİSEL TUTULMA DANIŞMANLIĞI MOTORU (HARİTA ÜZERİNDEKİ ETKİLER) ---
  static const Map<int, Map<String, String>> _houseCounselingData = {
    1: {
      'axis': '1. Ev (Benlik & Duruş) — 7. Ev (İlişkiler & Ortaklıklar) Aksı',
      'solar':
          'Bu Güneş Tutulması doğrudan 1. Evinizde (Yükselen burç alanınızda) gerçekleşiyor! Hayatınızda fiziksel görünümünüzden kişisel hedeflerinize, dış dünyaya sunduğunuz kimlikten yaşam rotanıza kadar yepyeni ve kadersel bir sayfa açılıyor. Önümüzdeki 6 ay boyunca kendi inisiyatifinizi elinize alacak, "Ben kimim ve ne istiyorum?" sorusuna cesur adımlarla yanıt vereceksiniz.',
      'lunar':
          'Bu Ay Tutulması 1. Evinizde duygusal bir zirve ve tamamlanma yaratıyor. İlişkilerinizde ve kişisel duruşunuzda kendinizi geri plana attığınız konuları fark edip net sınırlar çizeceğiniz bir dönemdesiniz. Sağlığınıza, bedeninize ve bireysel önceliklerinize sahip çıkma vakti.',
      'plan':
          'Stratejik Tavsiye: Yeni bir imaj, kişisel girişim veya uzun süredir ertelediğiniz bireysel bir kararı başlatmak için gökyüzü arkanızda. İlişkilerde (7. ev) dengeyi korurken kendi merkezimizden ödün vermeyin.',
    },
    2: {
      'axis': '2. Ev (Finans & Öz-Değer) — 8. Ev (Ortak Paylaşımlar & Dönüşüm) Aksı',
      'solar':
          'Bu Güneş Tutulması 2. Evinizde yeni bir finansal dönemi ve gelir kapısını başlatıyor! Önümüzdeki 6 aylık süreçte kazanç modelinizi yenileyebilir, yeteneklerinizi somut gelire dönüştürebilir veya önemli bir yatırım/bütçe kararı alabilirsiniz. Kendi öz-değerinize verdiğiniz önem doğrudan maddi bereketinize yansıyacaktır.',
      'lunar':
          'Bu Ay Tutulması 2. Evinizde maddi kaynaklarınız, harcamalarınız ve bütçe dengeniz üzerinde bir netleşme ve hasat getiriyor. Verimsiz bir gelir-gider alışkanlığını sonlandırıp finansal güvenliğinizi sağlamlaştıracak somut kararlar alabilirsiniz.',
      'plan':
          'Stratejik Tavsiye: Spekülatif riskler yerine somut üretim ve öz-yeteneklerinize yatırım yapın. 8. ev aksındaki borç/alacak ve vergi dengesini disiplinle yönetin.',
    },
    3: {
      'axis': '3. Ev (İletişim, Zihin & Eğitim) — 9. Ev (Uzmanlık & Uzak Vizyon) Aksı',
      'solar':
          'Bu Güneş Tutulması 3. Evinizde zihinsel projeler, ticari anlaşmalar, eğitimler, dijital medya veya yakın çevre/kardeş gündemlerinde yepyeni bir başlangıç enerjisi açığa çıkarıyor! Yeni bir sözleşme imzalama, araç/teknoloji yenileme veya ses getirecek bir projeyi duyurma fırsatı doğabilir.',
      'lunar':
          'Bu Ay Tutulması 3. Evinizde yürüttüğünüz bir eğitimin, yazışmanın, ticari görüşmenin veya yakın çevre ilişkinizin sonuçlanmasını sağlıyor. Zihinsel yüklerden arınıp hangi fikrin gerçekten uygulanabilir olduğunu netleştireceksiniz.',
      'plan':
          'Stratejik Tavsiye: Sözleşmelerde ve resmi imzalarda detayları dikkatle inceleyin; fikirlerinizi somut projelere ve eğitime dönüştürmekten çekinmeyin.',
    },
    4: {
      'axis': '4. Ev (Ev, Yuva & Aile Kökleri) — 10. Ev (Kariyer & Statü) Aksı',
      'solar':
          'Bu Güneş Tutulması haritanızın en dip noktası olan 4. Evde (IC alanında) gerçekleşiyor! Ev değişimi, taşınma, gayrimenkul alım-satımı, ev içi yenilenme veya aile/ebeveyn gündemlerinde kadersel bir başlangıç kapıda. İçsel güvenliğinizi ve kendi yuvanızı sağlam temeller üzerine kuracağınız bir 6 aylık dönem.',
      'lunar':
          'Bu Ay Tutulması 4. Evinizde ailevi bir gündemin, mülk konusunun veya geçmişten taşınan duygusal bir meselenin nihai çözüme kavuşmasını sağlıyor. Köklerinizle barışıp ev-kariyer (4-10) dengesini yeniden kuracaksınız.',
      'plan':
          'Stratejik Tavsiye: Yaşam alanınızı ve aile içi sorumlulukları yapılandırırken kariyer hedeflerinizle (10. ev) iç huzurunuz arasındaki dengeyi koruyun.',
    },
    5: {
      'axis': '5. Ev (Aşk, Yaratıcılık & Çocuklar) — 11. Ev (Gelecek & Sosyal Çevre) Aksı',
      'solar':
          'Bu Güneş Tutulması 5. Evinizde kalbinizi coşturacak yepyeni bir dönemi başlatıyor! Romantik hayatınızda kadersel bir tanışma, mevcut ilişkide heyecan verici bir yenilenme, çocuklarla ilgili sevindirici bir gelişme veya yaratıcı/sanatsal bir projenin sahneye çıkması gündeme gelebilir.',
      'lunar':
          'Bu Ay Tutulması 5. Evinizde aşk hayatınız, hobileriniz veya çocuklarla ilgili konularda önemli bir netleşme ve duygusal farkındalık getiriyor. Kalbinizi gerçekten beslemeyen yüzeysel gündemleri geride bırakıp gerçek neşenize odaklanacaksınız.',
      'plan':
          'Stratejik Tavsiye: Yaratıcı yeteneklerinizi görünür kılın ve kalbinizin sesine güvenin; finansal spekülasyonlarda ise aşırı riskten kaçının.',
    },
    6: {
      'axis': '6. Ev (Çalışma Düzeni, Hizmet & Sağlık) — 12. Ev (Ruhsal Dinlenme) Aksı',
      'solar':
          'Bu Güneş Tutulması 6. Evinizde günlük çalışma ortamınızı, mesleki projelerinizi, birlikte çalıştığınız ekibi ve sağlık/beslenme rutinlerinizi yeniliyor! Yeni bir iş düzenine geçmek, çalışma verimliliğinizi artırmak ve bedeninize şifa verecek sağlıklı alışkanlıklar başlatmak için güçlü bir 6 aylık süreç.',
      'lunar':
          'Bu Ay Tutulması 6. Evinizde sizi yoran iş yüklerini, verimsiz görevleri veya ihmal ettiğiniz sağlık/uyku detaylarını görünür kılıyor. Bedensel ve zihinsel sınırlarınızı koruyarak çalışma temponuzu sadeleştirme zamanı.',
      'plan':
          'Stratejik Tavsiye: Sağlık kontrollerinizi ve beslenme düzeninizi önceliklendirin; iş yerinde her yükü tek başınıza üstlenmek yerine sistemli görev dağılımı yapın.',
    },
    7: {
      'axis': '7. Ev (Evlilik, Partnerlik & Sözleşmeler) — 1. Ev (Bireysel Kimlik) Aksı',
      'solar':
          'Bu Güneş Tutulması 7. Evinizde (Alçalan / DSC alanında) ikili ilişkiler, evlilik, uzun vadeli partnerlikler ve resmi iş ortaklıklarında kadersel bir yeni dönem başlatıyor! Hayatınıza uzun vadeli bir partner/ortak girebilir veya mevcut ilişkinizde resmi bir adım (sözleşme, evlilik, yeni ortak karar) atılabilir.',
      'lunar':
          'Bu Ay Tutulması 7. Evinizde ilişkiler ve ortaklıklar alanında büyük bir ayna tutuyor. Sağlıklı ve güçlü bağlar bir üst seviyeye taşınırken, dengesiz veya yıpratıcı ortaklıkların gerçek yüzü netleşerek tamamlanma evresine giriyor.',
      'plan':
          'Stratejik Tavsiye: İkili ilişkilerde ve hukuki/ticari sözleşmelerde açık iletişim kurun; "Ben" (1. ev) ve "Biz" (7. ev) dengesini adil biçimde inşa edin.',
    },
    8: {
      'axis': '8. Ev (Ortak Finans, Kriz Yönetimi & Dönüşüm) — 2. Ev (Kişisel Gelir) Aksı',
      'solar':
          'Bu Güneş Tutulması 8. Evinizde ortaklaşa kazançlar, eş/ortak gelirleri, kredi, vergi, miras, sigorta ve derin psikolojik dönüşüm alanlarında yeni bir sayfa açıyor! Finansal bir yapılandırma yapmak ve ruhsal olarak küllerinizden daha güçlü doğmak için 6 aylık dönüştürücü bir koridordasınız.',
      'lunar':
          'Bu Ay Tutulması 8. Evinizde uzun süredir devam eden bir borç, kredi, alacak-verecek veya psikolojik bağlılık konusunun kapanmasını ve sonuçlanmasını sağlıyor. Korkularınızla yüzleşip içsel gücünüzü geri kazanacaksınız.',
      'plan':
          'Stratejik Tavsiye: Banka, kredi ve ortaklı finansal işlemlerde şeffaf ve planlı hareket edin; eski psikolojik yükleri bırakarak yenilenmeye izin verin.',
    },
    9: {
      'axis': '9. Ev (Yüksek Vizyon, Akademi, Hukuk & Yurt Dışı) — 3. Ev (Yakın Çevre) Aksı',
      'solar':
          'Bu Güneş Tutulması 9. Evinizde ufkunuzu genişletecek kadersel kapılar açıyor! Yurt dışı bağlantılı işler, uluslararası ticaret, akademik eğitim, yayıncılık, medya veya hukuki bir süreçte yepyeni bir başlangıç yapabilirsiniz. Hayata bakış açınız ve vizyonunuz büyüyor.',
      'lunar':
          'Bu Ay Tutulması 9. Evinizde devam eden bir akademik çalışmanın, hukuki dosyanın, vize/seyahat planının veya yayıncılık projesinin nihai sonuca ulaşmasını sağlıyor.',
      'plan':
          'Stratejik Tavsiye: Uzun vadeli vizyonunuza, yabancı dil/akademik gelişiminize ve uluslararası bağlantılara cesurca yatırım yapın.',
    },
    10: {
      'axis': '10. Ev (Kariyer Zirvesi, Statü & Toplum Önü) — 4. Ev (Ev & Kökler) Aksı',
      'solar':
          'Bu Güneş Tutulması haritanızın en tepe noktası olan 10. Evde (MC / Kariyer ve Statü alanında) gerçekleşiyor! Mesleki hayatınızda terfi, yeni bir unvan, kendi işinizi kurma, sektörel değişim veya toplumsal statünüzü yükseltecek kadersel bir başlangıç dönemi. Önümüzdeki 6-12 ay boyunca emeğiniz görünür bir otoriteye dönüşecek.',
      'lunar':
          'Bu Ay Tutulması 10. Evinizde kariyer hedefleriniz, üstlerle ilişkileriniz ve toplumsal duruşunuzda büyük bir hasat ve netleşme getiriyor. Uzun süredir emek verdiğiniz bir projenin ödülünü alabilir veya artık size hizmet etmeyen bir kariyer rotasını tamamlayabilirsiniz.',
      'plan':
          'Stratejik Tavsiye: Profesyonel hedeflerinizde sorumluluk almaktan çekinmeyin; toplum önündeki itibarınızı disiplinli ve ilkeli adımlarla taçlandırın.',
    },
    11: {
      'axis': '11. Ev (Gelecek Projeleri, Sosyal Çevre & İdealler) — 5. Ev (Yaratıcılık) Aksı',
      'solar':
          'Bu Güneş Tutulması 11. Evinizde sosyal çevrenizi, dahil olduğunuz ekip ve organizasyonları, büyük gelecek hayallerinizi ve kariyerden elde ettiğiniz gelirleri yeniliyor! Vizyoner insanlarla tanışacağınız, güçlü network bağlantıları kuracağınız ve uzun vadeli ideallerinizi başlatacağınız bir dönem.',
      'lunar':
          'Bu Ay Tutulması 11. Evinizde arkadaşlıklarınız, sosyal gruplarınız ve gelecek hedefleriniz arasında doğal bir eleme ve netleşme sağlıyor. Hangi dostlukların ve hangi hedeflerin sizinle geleceğe yürüyeceğini net biçimde göreceksiniz.',
      'plan':
          'Stratejik Tavsiye: Tek başınıza mücadele etmek yerine doğru ekiplerle ve vizyoner topluluklarla iş birliği kurun.',
    },
    12: {
      'axis': '12. Ev (Bilinçaltı, Ruhsal Arınma & Perde Arkası) — 6. Ev (Günlük Düzen) Aksı',
      'solar':
          'Bu Güneş Tutulması 12. Evinizde derin bir ruhsal uyanış, bilinçaltı şifalanması ve perde arkasında yürütülen stratejik hazırlıklar dönemini başlatıyor! Önümüzdeki 6 ay boyunca sezgileriniz ve rüyalarınız olağanüstü güçlenirken, bir sonraki büyük yaşam döngünüz için enerjinizi toplayıp gizli hazırlıklarınızı tamamlayacaksınız.',
      'lunar':
          'Bu Ay Tutulması 12. Evinizde gizli kalmış konuların aydınlanmasını, bilinçaltı korkuların ve geçmişten taşınan karmik yüklerin serbest bırakılmasını sağlıyor. Ruhsal ve zihinsel bir arınma ile derin bir iç huzura kavuşacaksınız.',
      'plan':
          'Stratejik Tavsiye: Büyük projeleri herkese anlatmadan önce perde arkasında olgunlaştırın; meditasyon, terapi, sanat ve uyku düzeninize özen gösterin.',
    },
  };

  /// Kullanıcının doğum haritasına göre içinde bulunulan ve gelecek yılın tutulmalarını analiz eder.
  static List<PersonalEclipseAnalysis> analyzePersonalEclipses({
    required UserProfile profile,
    BirthChartModel? chart,
  }) {
    final resolvedChart = chart ??
        AstrologyEngine.calculateChart(
          name: profile.name,
          dateStr: profile.birthDate,
          timeStr: profile.birthTime,
          city: profile.birthCity.isEmpty ? 'İstanbul' : profile.birthCity,
          country:
              profile.birthCountry.isEmpty ? 'Türkiye' : profile.birthCountry,
        );

    final ascSign = resolvedChart.risingSign.replaceAll('(r)', '').trim().split(' ').last;
    final ascIdx = AspectsService.zodiacSigns.indexOf(ascSign);
    final safeAscIdx = ascIdx >= 0 ? ascIdx : 0;

    final eclipses = getCurrentAndNextYearEclipses();
    final results = <PersonalEclipseAnalysis>[];

    const planetLabels = {
      'sun': 'Natal Güneş',
      'moon': 'Natal Ay',
      'ascendant': 'Yükselen (ASC)',
      'mc': 'Tepe Noktası (MC)',
      'mercury': 'Natal Merkür',
      'venus': 'Natal Venüs',
      'mars': 'Natal Mars',
      'jupiter': 'Natal Jüpiter',
      'saturn': 'Natal Satürn',
      'uranus': 'Natal Uranüs',
      'neptune': 'Natal Neptün',
      'pluto': 'Natal Plüton',
      'north_node': 'Kuzey Ay Düğümü',
      'chiron': 'Natal Chiron',
    };

    Map<int, double> cusps = {};
    try {
      final placidusData = PredictiveAstrologyService.calculatePlacidusHouses(profile: profile);
      final rawCusps = placidusData['cusps'];
      if (rawCusps is Map<int, double>) {
        cusps = rawCusps;
      }
    } catch (_) {}

    for (final ec in eclipses) {
      int houseNum = 1;
      if (cusps.length == 12) {
        final ecLon = ec.absoluteLongitude;
        for (int h = 1; h <= 12; h++) {
          final hStart = cusps[h]!;
          final nextH = h == 12 ? 1 : h + 1;
          final hEnd = cusps[nextH]!;
          final span = ((hEnd - hStart) % 360.0 + 360.0) % 360.0;
          final diff = ((ecLon - hStart) % 360.0 + 360.0) % 360.0;
          if (diff < span) {
            houseNum = h;
            break;
          }
        }
      } else {
        final ecSignIdx = AspectsService.zodiacSigns.indexOf(ec.sign);
        final safeEcIdx = ecSignIdx >= 0 ? ecSignIdx : 0;
        houseNum = ((safeEcIdx - safeAscIdx + 12) % 12) + 1;
      }
      final oppHouse = ((houseNum - 1 + 6) % 12) + 1;

      final houseData = _houseCounselingData[houseNum] ?? _houseCounselingData[1]!;
      final axisTitle = houseData['axis']!;
      final baseCounseling = ec.isSolar ? houseData['solar']! : houseData['lunar']!;
      final actionPlan = houseData['plan']!;

      // Natal Gezegen Tetiklemelerini Hesapla (0°, 180°, 90°, 120°, 60° ±5° orb)
      final triggers = <PersonalEclipseAspectTrigger>[];
      final ecLon = ec.absoluteLongitude;

      for (final entry in planetLabels.entries) {
        final p = resolvedChart.planets[entry.key];
        if (p == null) continue;
        final pLon = AspectsService.calculateAbsoluteLongitude(p.sign, p.formatted);
        final pDeg = AspectsService.parseDegreeInSign(p.formatted).floor();

        double diff = (ecLon - pLon).abs() % 360.0;
        if (diff > 180.0) diff = 360.0 - diff;

        String? aspName;
        String? aspSymbol;
        Color? aspColor;
        double? orb;
        String? advice;

        if (diff <= 5.5) {
          aspName = 'Kavuşum (0°)';
          aspSymbol = '☌';
          aspColor = AppColors.starlightGold;
          orb = diff;
          advice =
              'KADERSEL KAVUŞUM TETİĞİ: Tutulma doğrudan ${entry.value} ($pDeg° ${p.sign}) derecenizle kavuşuyor! Bu gezegenin temsil ettiği yaşam alanında yepyeni ve güçlü bir dönem başlıyor.';
        } else if ((diff - 180.0).abs() <= 5.5) {
          aspName = 'Karşıt (180°)';
          aspSymbol = '☍';
          aspColor = AppColors.savageRed;
          orb = (diff - 180.0).abs();
          advice =
              'KARŞIT AÇI FARKINDALIĞI: Tutulma ${entry.value} ($pDeg° ${p.sign}) konumunuza tam karşıt açı yapıyor. İlişkiler ve dış koşullar üzerinden önemli bir netleşme ve denge kurma eşiği.';
        } else if ((diff - 90.0).abs() <= 5.0) {
          aspName = 'Kare (90°)';
          aspSymbol = '□';
          aspColor = AppColors.warningOrange;
          orb = (diff - 90.0).abs();
          advice =
              'DİNAMİK KARE TETİĞİ: Tutulma ${entry.value} ($pDeg° ${p.sign}) yerleşiminizi 90° kare açıyla harekete geçiriyor. Ertelediğiniz kararları somut eyleme dökerek engelleri aşacağınız bir viraj.';
        } else if ((diff - 120.0).abs() <= 4.5) {
          aspName = 'Üçgen (120°)';
          aspSymbol = '△';
          aspColor = AppColors.pastelMint;
          orb = (diff - 120.0).abs();
          advice =
              'KORUYUCU ÜÇGEN DESTEĞİ: Tutulma ${entry.value} ($pDeg° ${p.sign}) derecenize 120° uyumlu üçgen açı gönderiyor. Beklediğiniz fırsatların ve desteklerin zahmetsizce akacağı şanslı bir etki.';
        } else if ((diff - 60.0).abs() <= 4.0) {
          aspName = 'Sekstil (60°)';
          aspSymbol = '⚹';
          aspColor = AppColors.pastelBlue;
          orb = (diff - 60.0).abs();
          advice =
              'FIRSAT SEKSTİLİ: Tutulma ${entry.value} ($pDeg° ${p.sign}) noktanıza 60° destekleyici açı yapıyor. Yeni bağlantılar ve girişimler için kapıları açan verimli bir enerji.';
        }

        if (aspName != null && orb != null && aspSymbol != null && aspColor != null && advice != null) {
          final d = orb.floor();
          final m = ((orb - d) * 60).round().clamp(0, 59);
          triggers.add(
            PersonalEclipseAspectTrigger(
              natalPlanetName: entry.value,
              natalPlanetSignDegree: '$pDeg° ${p.sign}',
              aspectName: aspName,
              aspectSymbol: aspSymbol,
              orbFormatted: "$d°${m.toString().padLeft(2, '0')}'",
              color: aspColor,
              triggerAdvice: advice,
            ),
          );
        }
      }

      final sarosEchoYear = ec.dateTimeTr.year - 18;
      final sarosEcho =
          'Saros ${ec.sarosSeries} Döngüsü Yankısı: Bu tutulmadan tam 18 yıl önce ($sarosEchoYear yılında) hayatınızda $houseNum. ev ve $oppHouse. ev konularında başlayan hikayeler, şimdi çok daha yüksek bir olgunluk ve bilinçle yeniden şekilleniyor.';

      results.add(
        PersonalEclipseAnalysis(
          eclipse: ec,
          activatedHouse: houseNum,
          oppositeHouse: oppHouse,
          houseAxisTitle: axisTitle,
          personalHouseCounseling: baseCounseling,
          sarosEchoMessage: sarosEcho,
          strategicActionPlan: actionPlan,
          natalTriggers: triggers,
        ),
      );
    }

    return results;
  }
}
