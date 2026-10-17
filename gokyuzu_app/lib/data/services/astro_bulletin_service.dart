import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'eclipses_service.dart';
import 'sky_transits_service.dart';

/// Gökyüzü Olayı veya Gezegen Açısı Modeli
class AstroBulletinEvent {
  final String id;
  final String title;
  final String category; // 'Yeniay', 'Dolunay', 'Güneş Tutulması', 'Ay Tutulması', 'Majör Açı'
  final DateTime dateTime;
  final List<String> bodies; // Yalnızca: Merkür, Venüs, Mars, Jüpiter, Satürn, Uranüs, Neptün, Plüton, Ay Düğümleri, Chiron
  final String? aspectType; // 'Kavuşum (0°)', 'Sekstil (60°)', 'Kare (90°)', 'Üçgen (120°)', 'Karşıt (180°)'
  final String degreeAndSign;
  final String description;
  final String strategicAdvice;
  final int impactLevel; // 1-5 yıldız

  AstroBulletinEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.bodies,
    this.aspectType,
    required this.degreeAndSign,
    required this.description,
    required this.strategicAdvice,
    this.impactLevel = 4,
  });

  bool get isPassed => DateTime.now().isAfter(dateTime);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'dateTime': dateTime.toIso8601String(),
        'bodies': bodies,
        'aspectType': aspectType,
        'degreeAndSign': degreeAndSign,
        'description': description,
        'strategicAdvice': strategicAdvice,
        'impactLevel': impactLevel,
      };

  factory AstroBulletinEvent.fromJson(Map<String, dynamic> json) =>
      AstroBulletinEvent(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        category: json['category'] ?? '',
        dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
        bodies: List<String>.from(json['bodies'] ?? []),
        aspectType: json['aspectType'],
        degreeAndSign: json['degreeAndSign'] ?? '',
        description: json['description'] ?? '',
        strategicAdvice: json['strategicAdvice'] ?? '',
        impactLevel: json['impactLevel'] ?? 3,
      );
}

/// Burç Yorumu Modeli (Günlük ve Haftalık)
class ZodiacBulletin {
  final String sign; // Koç, Boğa...
  final String symbol;
  final String element;
  final String dailyTheme;
  final String dailyFocus;
  final String dailyLuckyHours;
  final String dailyCompatibleSign;
  final String weeklyOverview;
  final String weeklyLove;
  final String weeklyCareer;
  final String weeklyHealth;
  final Map<String, int> weeklyProbabilities; // 'Kariyer & İlerleme': 85, vb.

  const ZodiacBulletin({
    required this.sign,
    required this.symbol,
    required this.element,
    required this.dailyTheme,
    required this.dailyFocus,
    required this.dailyLuckyHours,
    required this.dailyCompatibleSign,
    required this.weeklyOverview,
    required this.weeklyLove,
    required this.weeklyCareer,
    required this.weeklyHealth,
    required this.weeklyProbabilities,
  });
}

/// Haftalık Kozmik Gökyüzü Özeti & Olasılık Dağılımı Modeli
class WeeklyCosmicSummary {
  final String weekTitle;
  final String dateRange;
  final int cosmicEnergyScore; // 0 - 100
  final String weeklyHeadline;
  final String weeklyStrategy;
  final List<String> highlightAspects;
  final Map<String, int> probabilities; // 'Yeni Başlangıçlar', 'Sözleşme/İmza', 'İlişki Uyumu', 'Finansal Fırsat'

  const WeeklyCosmicSummary({
    required this.weekTitle,
    required this.dateRange,
    required this.cosmicEnergyScore,
    required this.weeklyHeadline,
    required this.weeklyStrategy,
    required this.highlightAspects,
    required this.probabilities,
  });
}

/// Astro Bülten Servisi
/// Kurallar:
/// 1. Her ayın 1'inde o ayın gökyüzü olayları ve majör açıları listelenir.
/// 2. Gezegen açıları SADECE 10 gök cismi arasında hesaplanır:
///    Merkür, Venüs, Mars, Jüpiter, Satürn, Uranüs, Neptün, Plüton, Ay Düğümleri, Chiron
/// 3. Geocentric & Placidus sistemine ve SkyTransitsService astronomik efemeris motoruna %100 sadıktır.
/// 4. Olay gerçekleştiğinde (zamanı geçtiğinde) LİSTEDEN VE HAFIZADAN OTOMATİK SİLİNİR (Auto-Purge).
/// 5. 12 burç için günlük ve haftalık yorumlar, haftalık olasılıklar sunulur.
class AstroBulletinService {
  static const String _kPurgedEventsKey = 'astro_bulletin_purged_ids_v3';
  static const String _kCachedEventsKey = 'astro_bulletin_cached_events_v3';

  /// Yalnızca izin verilen 10 gök cismi
  static const List<String> allowedBodies = [
    'Merkür',
    'Venüs',
    'Mars',
    'Jüpiter',
    'Satürn',
    'Uranüs',
    'Neptün',
    'Plüton',
    'Ay Düğümleri',
    'Chiron',
  ];

  // ==========================================
  // 1. AYIN GÖKYÜZÜ OLAYLARI & AÇILARI (AUTO-PURGE)
  // ==========================================

  /// Ayın aktif (zamanı henüz geçmemiş) gökyüzü olaylarını ve açılarını getirir.
  /// Gerçekleşmiş olaylar hafızadan ve cihaz saklama alanından tamamen temizlenir.
  static Future<List<AstroBulletinEvent>> getActiveMonthlyEvents({DateTime? customNow}) async {
    final now = customNow ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // 1. O ayın astronomik efemeris olay kataloğunu dinamik hesapla
    final allEventsForMonth = _generateMonthlyEvents(now.year, now.month);

    // 2. Hafızadan silinmiş / tamamlanmış ID'leri yükle
    final purgedIds = prefs.getStringList(_kPurgedEventsKey)?.toSet() ?? <String>{};

    // 3. Auto-Purge filtresi: Zamanı geçmiş olanları tespit et ve purgedIds'e ekle
    final newlyPurgedIds = <String>[];
    final activeEvents = <AstroBulletinEvent>[];

    for (final event in allEventsForMonth) {
      if (event.dateTime.isBefore(now)) {
        if (!purgedIds.contains(event.id)) {
          newlyPurgedIds.add(event.id);
        }
      } else {
        activeEvents.add(event);
      }
    }

    // 4. Hafızayı güncelle: Gerçekleşen olayları SharedPreferences'ta kayıt altına al
    if (newlyPurgedIds.isNotEmpty) {
      purgedIds.addAll(newlyPurgedIds);
      await prefs.setStringList(_kPurgedEventsKey, purgedIds.toList());
      debugPrint('[AstroBulletinService] Auto-Purge: ${newlyPurgedIds.length} gerçekleşen gökyüzü olayı hafızadan ve ekrandan silindi.');
    }

    // Tarihe göre artan sırala (en yakın olay en üstte)
    activeEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Aktif olayları kaydet
    final activeJsonList = activeEvents.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_kCachedEventsKey, activeJsonList);

    return activeEvents;
  }

  /// Geocentric & Placidus efemeris motoru ile o ayın gerçek astronomik olaylarını hesaplar
  static List<AstroBulletinEvent> _generateMonthlyEvents(int year, int month) {
    final events = <AstroBulletinEvent>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // ----------------------------------------------------
    // A. TUTULMALAR: O ayda Güneş veya Ay Tutulması var mı?
    // ----------------------------------------------------
    final matchingEclipses = EclipsesService.upcomingEclipsesCatalog.where(
      (e) => e.dateTimeTr.year == year && e.dateTimeTr.month == month,
    );

    for (final ec in matchingEclipses) {
      events.add(
        AstroBulletinEvent(
          id: 'ecl_${ec.id}',
          title: '${ec.fullTypeTitle} 🌘 (${ec.sign})',
          category: ec.isSolar ? 'Güneş Tutulması' : 'Ay Tutulması',
          dateTime: ec.dateTimeTr,
          bodies: const ['Güneş', 'Ay'],
          degreeAndSign: '${ec.degree}°${ec.minute.toString().padLeft(2, '0')}\' ${ec.sign}',
          description: ec.collectiveTheme,
          strategicAdvice: ec.educationalLessonNote,
          impactLevel: 5,
        ),
      );
    }

    // ----------------------------------------------------
    // B. YENİAY VE DOLUNAY ASTRONOMİK TESPİTİ
    // ----------------------------------------------------
    double prevDiff = -1;
    DateTime? newMoonDt;
    DateTime? fullMoonDt;
    double newMoonSunLon = 0;
    double fullMoonMoonLon = 0;

    for (int h = 0; h <= daysInMonth * 24; h += 2) {
      final dt = DateTime(year, month, 1).add(Duration(hours: h));
      if (dt.month != month) break;
      final sl = SkyTransitsService.calculateSunLongitude(dt);
      final ml = SkyTransitsService.calculateMoonLongitude(dt);
      final diff = (ml - sl + 360.0) % 360.0;

      if (prevDiff >= 0) {
        // Yeniay: 0° boylam ayrışması (350° -> 10°)
        if (prevDiff > 340 && diff < 20 && newMoonDt == null) {
          newMoonDt = dt;
          newMoonSunLon = sl;
        }
        // Dolunay: 180° boylam ayrışması
        if (prevDiff < 180 && diff >= 180 && fullMoonDt == null) {
          fullMoonDt = dt;
          fullMoonMoonLon = ml;
        }
      }
      prevDiff = diff;
    }

    // Yeniay Ekle (Eğer tutulma ile çakışmıyorsa)
    if (newMoonDt != null) {
      final hasSolarEclipseOnDay = events.any(
        (e) => e.category == 'Güneş Tutulması' && e.dateTime.day == newMoonDt!.day,
      );
      if (!hasSolarEclipseOnDay) {
        final signIdx = (newMoonSunLon / 30.0).floor() % 12;
        final sign = SkyTransitsService.signs[signIdx];
        final deg = (newMoonSunLon % 30.0).floor();
        events.add(
          AstroBulletinEvent(
            id: 'lun_nm_${year}_${month}_${newMoonDt.day}',
            title: '$sign Yeniayı 🌑 (Tohum Ekişi)',
            category: 'Yeniay',
            dateTime: newMoonDt,
            bodies: const ['Güneş', 'Ay'],
            degreeAndSign: '$deg° $sign',
            description: '$sign burcundaki bu Yeniay, yeni niyet tohumları ekmek, zihinsel berraklık kazanmak ve hedefleri başlatmak için ideal bir kozmik penceredir.',
            strategicAdvice: 'Eski yükleri geride bırakın. $sign temalarında yeni hedefler ve ilişkiler için ilk adımı atın.',
            impactLevel: 5,
          ),
        );
      }
    }

    // Dolunay Ekle (Eğer tutulma ile çakışmıyorsa)
    if (fullMoonDt != null) {
      final hasLunarEclipseOnDay = events.any(
        (e) => e.category == 'Ay Tutulması' && e.dateTime.day == fullMoonDt!.day,
      );
      if (!hasLunarEclipseOnDay) {
        final signIdx = (fullMoonMoonLon / 30.0).floor() % 12;
        final sign = SkyTransitsService.signs[signIdx];
        final deg = (fullMoonMoonLon % 30.0).floor();
        events.add(
          AstroBulletinEvent(
            id: 'lun_fm_${year}_${month}_${fullMoonDt.day}',
            title: '$sign Dolunayı 🌕 (Hasat & Açığa Çıkış)',
            category: 'Dolunay',
            dateTime: fullMoonDt,
            bodies: const ['Güneş', 'Ay'],
            degreeAndSign: '$deg° $sign',
            description: '$sign burcundaki bu Dolunay, bilinçaltının aydınlanması, gizli kalmış durumların su yüzüne çıkışı ve başlatılan işlerin hasadını simgeler.',
            strategicAdvice: 'Aşırı duygusal ve fevri kararlardan kaçının. $sign aksındaki kutuplaşmaları sükunetle yönetin.',
            impactLevel: 5,
          ),
        );
      }
    }

    // ----------------------------------------------------
    // C. MAJÖR GEZEGEN AÇILARI (SADECE 10 GÖK CİSMİ)
    // ----------------------------------------------------
    const bodyKeys = [
      'mercury',
      'venus',
      'mars',
      'jupiter',
      'saturn',
      'uranus',
      'neptune',
      'pluto',
      'node',
      'chiron',
    ];

    const bodyDisplayNames = {
      'mercury': 'Merkür',
      'venus': 'Venüs',
      'mars': 'Mars',
      'jupiter': 'Jüpiter',
      'saturn': 'Satürn',
      'uranus': 'Uranüs',
      'neptune': 'Neptün',
      'pluto': 'Plüton',
      'node': 'Ay Düğümleri',
      'chiron': 'Chiron',
    };

    // Tüm ay günleri için gezegen koordinatlarını önceden hesapla (day 0 .. daysInMonth + 1)
    final dailyPlanetPositions = <int, Map<String, double>>{};
    for (int d = 0; d <= daysInMonth + 1; d++) {
      final sampleDay = d == 0 ? 1 : (d > daysInMonth ? daysInMonth : d);
      final sampleDt = DateTime.utc(year, month, sampleDay, 12, 0);
      dailyPlanetPositions[d] = SkyTransitsService.calculatePlanetsLongitudes(sampleDt);
    }

    // Majör açılar: Kavuşum (0°), Sekstil (60°), Kare (90°), Üçgen (120°), Karşıt (180°)
    final aspectDefinitions = [
      (0.0, 'Kavuşum (0°)', 5),
      (60.0, 'Sekstil (60°)', 4),
      (90.0, 'Kare (90°)', 5),
      (120.0, 'Üçgen (120°)', 4),
      (180.0, 'Karşıt (180°)', 5),
    ];

    final addedAspectSignatures = <String>{};

    for (int i = 0; i < bodyKeys.length; i++) {
      for (int j = i + 1; j < bodyKeys.length; j++) {
        final k1 = bodyKeys[i];
        final k2 = bodyKeys[j];
        final b1Name = bodyDisplayNames[k1]!;
        final b2Name = bodyDisplayNames[k2]!;

        for (int d = 1; d <= daysInMonth; d++) {
          final p1 = dailyPlanetPositions[d]![k1]!;
          final p2 = dailyPlanetPositions[d]![k2]!;
          double diff = (p1 - p2).abs() % 360.0;
          if (diff > 180.0) diff = 360.0 - diff;

          for (final asp in aspectDefinitions) {
            final targetAngle = asp.$1;
            final aspectName = asp.$2;
            final impact = asp.$3;
            final orb = (diff - targetAngle).abs();

            if (orb <= 1.5) {
              // Önceki ve sonraki gün orblarını kontrol ederek yerel minimumu (zirve gününü) bul
              final p1Prev = dailyPlanetPositions[d - 1]![k1]!;
              final p2Prev = dailyPlanetPositions[d - 1]![k2]!;
              double diffPrev = (p1Prev - p2Prev).abs() % 360.0;
              if (diffPrev > 180.0) diffPrev = 360.0 - diffPrev;
              final orbPrev = (diffPrev - targetAngle).abs();

              final p1Next = dailyPlanetPositions[d + 1]![k1]!;
              final p2Next = dailyPlanetPositions[d + 1]![k2]!;
              double diffNext = (p1Next - p2Next).abs() % 360.0;
              if (diffNext > 180.0) diffNext = 360.0 - diffNext;
              final orbNext = (diffNext - targetAngle).abs();

              if (orb <= orbPrev && orb <= orbNext) {
                final sig = '$k1-$k2-${targetAngle.toInt()}-$d';
                final pairSig = '$k1-$k2-${targetAngle.toInt()}';
                if (!addedAspectSignatures.contains(pairSig)) {
                  addedAspectSignatures.add(pairSig);

                  final sign1Idx = (p1 / 30.0).floor() % 12;
                  final sign2Idx = (p2 / 30.0).floor() % 12;
                  final sign1 = SkyTransitsService.signs[sign1Idx];
                  final sign2 = SkyTransitsService.signs[sign2Idx];
                  final deg1 = (p1 % 30.0).floor();
                  final deg2 = (p2 % 30.0).floor();

                  final eventDate = DateTime(year, month, d, 12, 0);

                  final (desc, advice) = _generateAspectInterpretation(
                    b1: b1Name,
                    b2: b2Name,
                    aspectType: aspectName,
                    sign1: sign1,
                    sign2: sign2,
                  );

                  events.add(
                    AstroBulletinEvent(
                      id: 'asp_${year}_${month}_$sig',
                      title: '$b1Name $aspectName $b2Name',
                      category: 'Majör Açı',
                      dateTime: eventDate,
                      bodies: [b1Name, b2Name],
                      aspectType: aspectName,
                      degreeAndSign: '${deg1.toString().padLeft(2, '0')}° $sign1 $b1Name - ${deg2.toString().padLeft(2, '0')}° $sign2 $b2Name',
                      description: desc,
                      strategicAdvice: advice,
                      impactLevel: impact,
                    ),
                  );
                }
              }
            }
          }
        }
      }
    }

    // Tarihe göre sırala
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return events;
  }

  /// Gezegen açıları için dinamik astrolojik yorum ve strateji üretici
  static (String, String) _generateAspectInterpretation({
    required String b1,
    required String b2,
    required String aspectType,
    required String sign1,
    required String sign2,
  }) {
    // Özel ikililer için yüksek çözünürlüklü yorumlar
    if ((b1 == 'Merkür' && b2 == 'Venüs') || (b1 == 'Venüs' && b2 == 'Merkür')) {
      if (aspectType.contains('Kavuşum')) {
        return (
          'İletişimde zarafet, tatlı dil, aşk itirafları ve diplomatik görüşmelerde muazzam bir cazibe akışı.',
          'Önemli mektuplar, romantik mesajlar, sanat çalışmaları ve uzlaşma gerektiren adımlar için harika bir gün.',
        );
      }
    }

    if ((b1 == 'Mars' && b2 == 'Plüton') || (b1 == 'Plüton' && b2 == 'Mars')) {
      if (aspectType.contains('Karşıt') || aspectType.contains('Kare')) {
        return (
          'Büyük irade sınavı, derin güç mücadeleleri, bastırılmış tutku veya öfkenin dışa vurumu.',
          'Güç savaşlarına girmek yerine bu yoğun enerjiyi spora, araştırmaya ve kararlı hedeflere kanalize edin.',
        );
      }
    }

    if ((b1 == 'Venüs' && b2 == 'Plüton') || (b1 == 'Plüton' && b2 == 'Venüs')) {
      if (aspectType.contains('Kare') || aspectType.contains('Karşıt')) {
        return (
          'İlişkilerde ve finansta tutku, kıskançlık, derin yüzleşmeler ve dönüştürücü kararlar.',
          'Kontrol etme arzusunu bırakın, şeffaf olun ve finansal spekülasyonlardan uzak durun.',
        );
      }
    }

    if ((b1 == 'Mars' && b2 == 'Satürn') || (b1 == 'Satürn' && b2 == 'Mars')) {
      if (aspectType.contains('Üçgen') || aspectType.contains('Sekstil')) {
        return (
          'Demir gibi bir irade, disiplin, stratejik sabır ve uzun soluklu işlerde sarsılmaz dayanıklılık.',
          'Ertelediğiniz zorlu projeleri bitirmek ve geleceğe kalıcı yapılar inşa etmek için kullanın.',
        );
      }
    }

    if ((b1 == 'Jüpiter' && b2 == 'Chiron') || (b1 == 'Chiron' && b2 == 'Jüpiter')) {
      return (
        'Ruhsal şifalanma, içsel bilgelik, acıları güce dönüştürme ve hayata güveni tazeleme döngüsü.',
        'Kendi yaralarınızı sararken başkalarına da ilham ve rehberlik olun.',
      );
    }

    // Genel Majör Açı Kalıpları
    if (aspectType.contains('Kavuşum')) {
      return (
        '$b1 ve $b2 gökyüzünde güçlerini birleştiriyor. Bu kavuşum, iki gezegenin temsil ettiği alanlarda yoğun yeni bir döngünün kapısını aralıyor.',
        'Enerjinizi tek bir kritik hedefe odaklayın; dağılmadan bilinçli adımlar atın.',
      );
    } else if (aspectType.contains('Sekstil')) {
      return (
        '$b1 ile $b2 arasında 60 derecelik uyumlu fırsat açısı devrede. İletişim, iş birlikleri ve yaratıcı çözümler akıcı bir şekilde ilerliyor.',
        'Kozmik fırsat pencerelerini değerlendirin; görüşmeler ve anlaşmalar için inisiyatif alın.',
      );
    } else if (aspectType.contains('Kare')) {
      return (
        '$b1 ile $b2 arasında 90 derecelik dinamik gerilim açısı etkin. İradeyi zorlayan, büyümeyi ve somut eylemi tetikleyen bir sınav.',
        'Dürtüsel tepkilerden kaçının. Gerilimi yapıcı bir disipline ve hedef odaklı çalışmaya dönüştürün.',
      );
    } else if (aspectType.contains('Üçgen')) {
      return (
        '$b1 ve $b2 arasında 120 derecelik kusursuz kozmik akış hakim. Şans, yeteneklerin parlaması ve zahmetsiz ilerleme vadediyor.',
        'Kozmik akışa güvenin. Yeteneklerinizi sergileyin, önemli adımları bu bereketli pencerede atın.',
      );
    } else {
      // Karşıt (180°)
      return (
        '$b1 ile $b2 gökyüzünde tam karşı karşıya gelerek kutuplaşma ve denge arayışı yaratıyor. İlişkilerde ve kararlarda objektiflik şarttır.',
        'Uçlara savrulmak yerine orta yolu bulun. Karşı tarafın bakış açısını dinleyerek içsel dengeyi koruyun.',
      );
    }
  }

  // ==========================================
  // 2. HAFTALIK KOZMİK ÖZET & OLASILIKLAR
  // ==========================================

  /// Bulunulan haftanın gökyüzü enerji analizi, stratejisi ve olasılık yüzdeleri
  static WeeklyCosmicSummary getWeeklySummary({DateTime? customNow}) {
    final now = customNow ?? DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final dateRangeStr =
        '${monday.day}.${monday.month.toString().padLeft(2, '0')} - ${sunday.day}.${sunday.month.toString().padLeft(2, '0')}.${sunday.year}';

    // Bu haftaya denk gelen gerçek astronomik olayları filtrele
    final monthEvents = _generateMonthlyEvents(now.year, now.month);
    final thisWeekEvents = monthEvents.where(
      (e) => e.dateTime.isAfter(monday.subtract(const Duration(hours: 12))) &&
             e.dateTime.isBefore(sunday.add(const Duration(hours: 24))),
    ).toList();

    final highlights = <String>[];
    for (final ev in thisWeekEvents.take(3)) {
      highlights.add('${ev.title} (${ev.degreeAndSign})');
    }

    if (highlights.isEmpty) {
      highlights.add('Kozmik Entegrasyon & İçsel Denge Aşaması');
      highlights.add('Doğum Haritası Potansiyellerini Harekete Geçirme');
      highlights.add('Stratejik Planlama ve Zihinsel Arınma');
    }

    return WeeklyCosmicSummary(
      weekTitle: 'Kozmik Haftalık Bülten & Olasılıklar',
      dateRange: dateRangeStr,
      cosmicEnergyScore: 84,
      weeklyHeadline: 'Geocentric Hassasiyetle Stratejik Kararlar ve Kozmik Uyum Haftası',
      weeklyStrategy:
          'Gökyüzündeki gerçek gezegen konumları zihinsel netliği ve stratejik kararlılığı destekliyor. İkili ilişkilerde fevri çıkışlardan kaçının, sezgilerinizi akılcı planlarla birleştirerek somut adımlar atın.',
      highlightAspects: highlights,
      probabilities: const {
        'Girişim & Proje Başlatma': 88,
        'Finansal / Ticari Fırsatlar': 76,
        'İkili İlişkilerde Uyum': 68,
        'Sezgisel / Ruhsal Farkındalık': 92,
        'Sözleşme & Anlaşma Başarısı': 82,
      },
    );
  }

  // ==========================================
  // 3. 12 BURÇ İÇİN GÜNLÜK & HAFTALIK YORUMLAR
  // ==========================================

  static const List<String> allSigns = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  static ZodiacBulletin getZodiacBulletin(String sign) {
    return _zodiacBulletins[sign] ?? _zodiacBulletins['Koç']!;
  }

  static const Map<String, ZodiacBulletin> _zodiacBulletins = {
    'Koç': ZodiacBulletin(
      sign: 'Koç',
      symbol: '♈',
      element: 'Ateş',
      dailyTheme: 'Liderlik ateşi ve inisiyatif alma gücü devrede.',
      dailyFocus: 'Kariyerde ertelediğiniz o kritik adımı atmak için gökyüzü sizi destekliyor.',
      dailyLuckyHours: '10:00 - 12:30',
      dailyCompatibleSign: 'Yay',
      weeklyOverview: 'Bu hafta enerjiniz tavan yapıyor. İkili ilişkilerde dengeyi kurarken kendi isteklerinizden ödün vermemeyi öğreneceksiniz. Hafta ortasında beklenmedik bir maddi fırsat doğabilir.',
      weeklyLove: 'Partnerinizle geleceğe dair ortak hedefler belirlemek bağınızı güçlendirir. Bekarlar için aniden alevlenen bir tanışma söz konusu.',
      weeklyCareer: 'Yeni projelerde liderlik koltuğu size teklif edilebilir. Cesur olun ancak detayları gözden kaçırmayın.',
      weeklyHealth: 'Baş ve boyun bölgesinde gerginlik hissedebilirsiniz; bol su tüketip açık hava yürüyüşleri yapın.',
      weeklyProbabilities: {
        'Kariyer Atılımı': 88,
        'Aşk & Tutku': 74,
        'Maddi Kazanç': 80,
        'Kişisel Farkındalık': 90,
      },
    ),
    'Boğa': ZodiacBulletin(
      sign: 'Boğa',
      symbol: '♉',
      element: 'Toprak',
      dailyTheme: 'Huzur, finansal denge ve sağlam temeller arayışı.',
      dailyFocus: 'Bütçe planlaması yapmak ve gereksiz harcamaları kısmak için ideal gün.',
      dailyLuckyHours: '14:00 - 16:00',
      dailyCompatibleSign: 'Başak',
      weeklyOverview: 'Venüs etkisiyle konfor alanınızı yeniden tasarlıyorsunuz. Maddi konularda sabrınızın meyvelerini toplayacağınız bir dönemdesiniz.',
      weeklyLove: 'Güven teması ilişkinizin merkezinde. Karşılıklı şeffaflık ilişkinizi bir üst seviyeye taşıyacak.',
      weeklyCareer: 'Yatırımlar ve birikimler konusunda uzman görüşü almak lehinize sonuçlar doğurur.',
      weeklyHealth: 'Boğaz bölgenizi koruyun; bitki çayları ve hafif esneme hareketleri iyi gelecektir.',
      weeklyProbabilities: {
        'Maddi İstikrar': 94,
        'İlişki Güveni': 85,
        'İç Huzur': 78,
        'Yaratıcılık': 70,
      },
    ),
    'İkizler': ZodiacBulletin(
      sign: 'İkizler',
      symbol: '♊',
      element: 'Hava',
      dailyTheme: 'Hızlı iletişim, zihinsel kıvraklık ve yeni bağlantılar.',
      dailyFocus: 'Önemli e-postaları yanıtlamak, toplantı ve sunumları gerçekleştirmek için mükemmel zaman.',
      dailyLuckyHours: '11:15 - 13:45',
      dailyCompatibleSign: 'Kova',
      weeklyOverview: 'Zihniniz adeta bir süper bilgisayar gibi çalışıyor. Çok sayıda fikir arasından en uygulanabilir olanına odaklanarak haftayı kazançlı kapatacaksınız.',
      weeklyLove: 'Entelektüel sohbetler kalbinizin kapılarını aralıyor. Birlikte seyahat planı yapmak ilişkinize taze bir nefes getirecek.',
      weeklyCareer: 'Medya, ticaret veya eğitimle ilgili konularda beklediğiniz haber bu hafta ulaşıyor.',
      weeklyHealth: 'Zihinsel yorgunluğu önlemek için ekran sürenizi sınırlandırmaya özen gösterin.',
      weeklyProbabilities: {
        'İletişim Başarısı': 95,
        'Ağ & Network Genişlemesi': 88,
        'Finansal Akış': 72,
        'Duygusal Denge': 65,
      },
    ),
    'Yengeç': ZodiacBulletin(
      sign: 'Yengeç',
      symbol: '♋',
      element: 'Su',
      dailyTheme: 'Duygusal güvenlik, aile bağları ve sezgisel derinlik.',
      dailyFocus: 'Evinizde huzurlu bir ortam yaratmak ve sevdiklerinizle kaliteli zaman geçirmek.',
      dailyLuckyHours: '18:00 - 20:30',
      dailyCompatibleSign: 'Balık',
      weeklyOverview: 'Kozmik etkiler kabuğunuzdan çıkıp duygularınızı özgürce ifade etmenizi fısıldıyor. Sezgilerinize kulak verin; onlar sizi asla yanıltmaz.',
      weeklyLove: 'Derin duygusal bağlar kuruluyor. Geçmiş kırgınlıkları affetmek aranızdaki tutkuyu canlandıracaktır.',
      weeklyCareer: 'Ekip çalışmalarında empati yeteneğiniz sayesinde arabulucu ve takdir edilen kişi olacaksınız.',
      weeklyHealth: 'Mide ve sindirim sisteminizi yoracak ağır yiyeceklerden uzak durun.',
      weeklyProbabilities: {
        'Sezgisel İsabet': 96,
        'Aile & Yuva Huzuru': 90,
        'İlişkilerde Şefkat': 86,
        'Maddi Bereket': 75,
      },
    ),
    'Aslan': ZodiacBulletin(
      sign: 'Aslan',
      symbol: '♌',
      element: 'Ateş',
      dailyTheme: 'Yaratıcı ışıltı, sahne alma isteği ve cömertlik.',
      dailyFocus: 'Kişisel vizyonunuzu sergilemek ve sanatsal projelere vakit ayırmak.',
      dailyLuckyHours: '12:00 - 15:00',
      dailyCompatibleSign: 'Koç',
      weeklyOverview: 'Güneşin ışığı üzerinizde! Karizmanızla girdiğiniz her ortamda fark ediliyorsunuz. Hafta sonuna doğru sürpriz bir kutlama veya seyahat gündeme gelecektir.',
      weeklyLove: 'Aşk hayatınızda romantizm dorukta. Jestler yapmaktan çekinmeyin.',
      weeklyCareer: 'Yaratıcı fikirleriniz yöneticileriniz tarafından tam not alacak. Takdir toplayacaksınız.',
      weeklyHealth: 'Kalp ve sırt sağlığınıza dikkat edin; duruş egzersizleri ve hafif kardiyo önerilir.',
      weeklyProbabilities: {
        'Sosyal Prestij': 92,
        'Aşk & Romantizm': 89,
        'Yaratıcı Üretim': 85,
        'Liderlik Gücü': 94,
      },
    ),
    'Başak': ZodiacBulletin(
      sign: 'Başak',
      symbol: '♍',
      element: 'Toprak',
      dailyTheme: 'Detaylarda ustalık, analitik zeka ve mükemmel düzen.',
      dailyFocus: 'Yarım kalmış işleri toparlamak, arşivleme ve detaylı analiz yapmak.',
      dailyLuckyHours: '09:00 - 11:30',
      dailyCompatibleSign: 'Boğa',
      weeklyOverview: 'Hayatınızın dağınık parçalarını kusursuz bir yapboz gibi birleştiriyorsunuz. Rutinlerinizi optimize etmek verimliliğinizi ikiye katlayacaktır.',
      weeklyLove: 'Eleştirel dili bir kenara bırakıp partnerinizin çabalarını takdir ettiğinizde sevgi katlanarak büyüyecek.',
      weeklyCareer: 'Hesap kitap, finans ve detaylı sözleşmelerde gözden kaçan bir noktayı yakalayarak günü kurtaracaksınız.',
      weeklyHealth: 'Bağırsak floranızı probiyotik gıdalarla destekleyin ve düzenli uykuya özen gösterin.',
      weeklyProbabilities: {
        'İş & Verimlilik': 96,
        'Analitik Çözüm': 94,
        'Detay Yakalama': 98,
        'İlişkisel Dinginlik': 72,
      },
    ),
    'Terazi': ZodiacBulletin(
      sign: 'Terazi',
      symbol: '♎',
      element: 'Hava',
      dailyTheme: 'Diplomasi, adalet, estetik ve zarafet arayışı.',
      dailyFocus: 'Anlaşmazlıkları tatlıya bağlamak ve sanatsal zevklerinize vakit ayırmak.',
      dailyLuckyHours: '15:30 - 17:30',
      dailyCompatibleSign: 'İkizler',
      weeklyOverview: 'İlişkiler aynanız niteliğinde. Kararsızlıklarınızı geride bırakıp kendi değerinizin farkına vardığınızda çevrenizdeki herkes size hayran kalacak.',
      weeklyLove: 'Uyum ve zarafet dolu bir hafta. Birlikte bir sanat etkinliğine katılmak bağınızı tazeleyecektir.',
      weeklyCareer: 'Ortaklıklar ve iş birliklerinde karlı sözleşmelere imza atabilirsiniz.',
      weeklyHealth: 'Böbrekler ve bel bölgenizi koruyun; yeterli sıvı tüketimi ihmal edilmemeli.',
      weeklyProbabilities: {
        'Diplomasi Başarısı': 93,
        'İlişki Uyumu': 90,
        'Estetik & Tasarım': 88,
        'Finansal Fırsat': 78,
      },
    ),
    'Akrep': ZodiacBulletin(
      sign: 'Akrep',
      symbol: '♏',
      element: 'Su',
      dailyTheme: 'Dönüşüm, derin sezgiler ve sarsılmaz odaklanma.',
      dailyFocus: 'Gizemli konuları araştırmak, stratejik planlar yapmak ve ruhsal arınma.',
      dailyLuckyHours: '21:00 - 23:30',
      dailyCompatibleSign: 'Yengeç',
      weeklyOverview: 'Küllerinizden yeniden doğuyorsunuz. Sizi geride tutan tüm eski korkuları ve toksik bağları koparıp atacak muazzam bir içsel güç sizde mevcut.',
      weeklyLove: 'Tutku ve sadakat tavan yapıyor. Gizli hiçbir şeyin kalmayacağı dürüst bir yüzleşme aşkınızı derinleştirecek.',
      weeklyCareer: 'Kriz anlarında soğukkanlılığınızla durumu lehinize çevireceksiniz. Gücünüzü gösterin.',
      weeklyHealth: 'Detoks suları, sauna ve derin nefes egzersizleri enerjinizi tazeleyecektir.',
      weeklyProbabilities: {
        'Dönüşüm Gücü': 98,
        'Stratejik İsabet': 94,
        'Tutku & Derinlik': 92,
        'Maddi Kazanım': 82,
      },
    ),
    'Yay': ZodiacBulletin(
      sign: 'Yay',
      symbol: '♐',
      element: 'Ateş',
      dailyTheme: 'Geniş vizyon, felsefi arayış ve keşfetme arzusu.',
      dailyFocus: 'Yabancı diller, akademik araştırmalar veya yeni seyahat rotaları belirlemek.',
      dailyLuckyHours: '13:00 - 15:30',
      dailyCompatibleSign: 'Aslan',
      weeklyOverview: 'Jüpiter şans rüzgarlarını arkanıza üflüyor. Sınırlarınızı genişletme arzunuz bu hafta sizi yepyeni ufuklara ve karlı fırsatlara taşıyacaktır.',
      weeklyLove: 'Özgürlük ihtiyacınızı dürüstçe paylaştığınızda partneriniz size saygı duyacaktır. Macera dolu buluşmalar planlayın.',
      weeklyCareer: 'Yurtdışı bağlantılı işler, yayıncılık veya eğitim alanında büyük bir atılım söz konusu.',
      weeklyHealth: 'Kalça ve uyluk kaslarınızı esnetin; açık hava sporları moralinizi yükseltir.',
      weeklyProbabilities: {
        'Kozmik Şans': 95,
        'Akademik / Vizyon': 91,
        'Seyahat & Keşif': 89,
        'İyimserlik': 96,
      },
    ),
    'Oğlak': ZodiacBulletin(
      sign: 'Oğlak',
      symbol: '♑',
      element: 'Toprak',
      dailyTheme: 'Kariyerde zirve hedefi, somut başarı ve sorumluluk.',
      dailyFocus: 'Uzun vadeli hedefleri planlamak ve finansal güvenliği pekiştirmek.',
      dailyLuckyHours: '08:30 - 11:00',
      dailyCompatibleSign: 'Boğa',
      weeklyOverview: 'Disiplin ve sabırla ördüğünüz kariyer duvarları meyvelerini veriyor. Otorite figürlerinin saygısını kazanacak somut başarılara imza atıyorsunuz.',
      weeklyLove: 'İlişkinizde güven ve ciddiyet ön planda. Geleceğe yönelik sağlam kararlar alabilirsiniz.',
      weeklyCareer: 'Zam, terfi veya yeni bir kurumsal sorumluluk kapınızı çalabilir. Hazırlıklı olun.',
      weeklyHealth: 'Kemik, eklem ve diş sağlığına dikkat; kalsiyum alımını destekleyin.',
      weeklyProbabilities: {
        'Kariyer Otoritesi': 96,
        'Finansal Sağlamlık': 92,
        'Uzun Vadeli Başarı': 94,
        'İlişkide Güven': 84,
      },
    ),
    'Kova': ZodiacBulletin(
      sign: 'Kova',
      symbol: '♒',
      element: 'Hava',
      dailyTheme: 'Özgün fikirler, teknolojik vizyon ve hümanist adımlar.',
      dailyFocus: 'Kalıpların dışına çıkmak, topluluk projelerine katılmak ve beyin fırtınası yapmak.',
      dailyLuckyHours: '16:00 - 18:30',
      dailyCompatibleSign: 'İkizler',
      weeklyOverview: 'Geleceği bugünden gören dahi zihninizle çevrenize ilham veriyorsunuz. Sıra dışı projeleriniz bu hafta beklenmedik destekçiler bulabilir.',
      weeklyLove: 'Önce dostluk, sonra aşk! Zihinsel olarak anlaştığınız biriyle kalbiniz aynı frekansta çarpabilir.',
      weeklyCareer: 'Yapay zeka, dijital projeler veya sivil toplum çalışmalarında öncü rol üstleneceksiniz.',
      weeklyHealth: 'Dolaşım sistemi ve bacak bölgesini rahatlatacak yürüyüşler yapın.',
      weeklyProbabilities: {
        'Yenilikçi Fikirler': 98,
        'Sosyal Dayanışma': 90,
        'Vizyoner Başarı': 94,
        'Duygusal Farkındalık': 75,
      },
    ),
    'Balık': ZodiacBulletin(
      sign: 'Balık',
      symbol: '♓',
      element: 'Su',
      dailyTheme: 'İlahi teslimiyet, sanat, rüyalar ve koşulsuz sevgi.',
      dailyFocus: 'Meditasyon yapmak, dua ve niyetlerle enerjinizi arındırmak.',
      dailyLuckyHours: '20:00 - 22:30',
      dailyCompatibleSign: 'Akrep',
      weeklyOverview: 'Neptün sezgilerinizi adeta bir radyo anteni gibi açıyor. Evrenin işaretlerini okumakta zorlanmayacaksınız. Sanatsal yeteneklerinizi açığa çıkarma vakti.',
      weeklyLove: 'Romantizmin ve ruh ikizi hissiyatının zirvesindesiniz. Kalbinizi aşka güvenle açın.',
      weeklyCareer: 'İlham gerektiren yaratıcı alanlarda mucizeler yaratacaksınız. Sezgileriniz ticarette de rehberiniz olsun.',
      weeklyHealth: 'Ayak sağlığınıza özen gösterin; ılık tuzlu su banyosu tüm günün yorgunluğunu alacaktır.',
      weeklyProbabilities: {
        'Ruhsal Farkındalık': 99,
        'Yaratıcı İlham': 95,
        'Romantik Büyü': 91,
        'Manevi Huzur': 94,
      },
    ),
  };
}
