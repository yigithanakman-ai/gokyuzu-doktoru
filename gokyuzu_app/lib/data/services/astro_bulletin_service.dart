import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'eclipses_service.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';
import 'predictive_astrology_service.dart';
import 'astrology_engine.dart';
import 'aspects_service.dart';
import 'app_translation_service.dart';

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

/// Transit Ay'ın Natal Gezegenlere Yaptığı Açı Modeli
class PersonalTransitAspect {
  final String aspectName; // 'Kavuşum (0°)', 'Üçgen (120°)', 'Kare (90°)', 'Sekstil (60°)', 'Karşıt (180°)'
  final String aspectSymbol; // '☌', '△', '□', '⚹', '☍'
  final double aspectDegree;
  final String natalPlanet; // 'Güneş', 'Ay', 'Merkür', 'Venüs', 'Mars', 'Jüpiter', 'Satürn', 'Uranüs', 'Neptün', 'Plüton', 'Chiron', 'Kuzey Düğüm', 'Yükselen (ASC)', 'Tepe Noktası (MC)'
  final String natalPlanetSign;
  final String natalPlanetDegree;
  final double orb;
  final String orbStr;
  final bool isHarmonious; // true: Üçgen, Sekstil; false: Kare, Karşıt; null: Kavuşum
  final String interpretation;
  final String strategicTip;

  const PersonalTransitAspect({
    required this.aspectName,
    required this.aspectSymbol,
    required this.aspectDegree,
    required this.natalPlanet,
    required this.natalPlanetSign,
    required this.natalPlanetDegree,
    required this.orb,
    required this.orbStr,
    required this.isHarmonious,
    required this.interpretation,
    required this.strategicTip,
  });
}

/// Kişiselleştirilmiş Günlük Astro Bülten Modeli (Transit Ay & Natal Placidus Ev + Açı Sentezi)
class PersonalizedDailyBulletin {
  final String sign; // Koç, Boğa...
  final String signSymbol;
  final String signElement;
  final DateTime date;
  final String dateStr;
  final String transitMoonSign;
  final String transitMoonSymbol;
  final String transitMoonDegree; // e.g. "14°28'"
  final String transitMoonFormatted; // e.g. "14°28' Koç"
  final double transitMoonLongitude;
  final int natalHouse; // 1..12 (derece hesabı ile Placidus ev)
  final String natalHouseName; // e.g. "11. Ev"
  final String natalHouseTheme; // e.g. "Gelecek Hedefleri, Sosyal Çevre & Vizyonlar"
  final String natalHouseDescription;
  final String natalHouseCuspRange; // e.g. "12°20' Balık - 22°14' Koç"
  final List<PersonalTransitAspect> activeAspects;
  final String compiledDailySynthesis;
  final String dailyTheme;
  final String dailyFocus;
  final String dailyLuckyHours;
  final String dailyCompatibleSign;
  final int cosmicEnergyScore;
  final bool isPersonalChart;

  const PersonalizedDailyBulletin({
    required this.sign,
    required this.signSymbol,
    required this.signElement,
    required this.date,
    required this.dateStr,
    required this.transitMoonSign,
    required this.transitMoonSymbol,
    required this.transitMoonDegree,
    required this.transitMoonFormatted,
    required this.transitMoonLongitude,
    required this.natalHouse,
    required this.natalHouseName,
    required this.natalHouseTheme,
    required this.natalHouseDescription,
    required this.natalHouseCuspRange,
    required this.activeAspects,
    required this.compiledDailySynthesis,
    required this.dailyTheme,
    required this.dailyFocus,
    required this.dailyLuckyHours,
    required this.dailyCompatibleSign,
    required this.cosmicEnergyScore,
    this.isPersonalChart = true,
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

  static const Map<String, String> signSymbols = {
    'Koç': '♈', 'Boğa': '♉', 'İkizler': '♊', 'Yengeç': '♋',
    'Aslan': '♌', 'Başak': '♍', 'Terazi': '♎', 'Akrep': '♏',
    'Yay': '♐', 'Oğlak': '♑', 'Kova': '♒', 'Balık': '♓',
  };

  static const Map<String, String> signElements = {
    'Koç': 'Ateş', 'Boğa': 'Toprak', 'İkizler': 'Hava', 'Yengeç': 'Su',
    'Aslan': 'Ateş', 'Başak': 'Toprak', 'Terazi': 'Hava', 'Akrep': 'Su',
    'Yay': 'Ateş', 'Oğlak': 'Toprak', 'Kova': 'Hava', 'Balık': 'Su',
  };

  static const Map<int, (String, String, String)> _placidusHouseMetadata = {
    1: (
      'Kişisel Benlik, Yaşam Enerjisi & Yeni Başlangıçlar',
      'Transit Ay haritanızın 1. evinden geçerken duygusal odağınız doğrudan kendi benliğinize, beden enerjinize ve kişisel kararlarınıza yönelir. Dış dünyaya karşı kendinizi daha görünür kılmak ve yeni niyetler başlatmak için güçlü bir kozmik etki altındasınız.',
      'Kendi ihtiyaçlarınızı ertelemeyin. İnisiyatif alın ve sezgilerinize güvenerek ilk adımı cesaretle atın.',
    ),
    2: (
      'Maddi Kaynaklar, Bütçe Yönetimi & Özdeğer',
      'Transit Ay 2. evinizi aydınlatırken finansal kararlar, birikimler, kişisel yeteneklerin maddi karşılığı ve güvenlik arayışı ön plana çıkar. Duygusal tatmini sağlam ve somut temeller üzerinde ararsınız.',
      'Dürtüsel harcamalardan kaçının; bütçe planlaması yapın ve sahip olduğunuz öz yeteneklerin kıymetini bilin.',
    ),
    3: (
      'Zihinsel Odak, İletişim Trafiği & Yakın Çevre',
      'Transit Ay 3. evinizden geçerken zihinsel merakınız artar; yazışmalar, aramalar, görüşmeler, kardeşler/yakın dostlarla diyaloglar ve kısa yolculuklar hız kazanır. Fikir alışverişi ve bilgi üretimi oldukça akıcıdır.',
      'Önemli fikirlerinizi not alın; yapıcı ve net bir dille iletişim kurarak görüşmelerinizi başarıyla sonuçlandırın.',
    ),
    4: (
      'Yuva, Aile Kökleri & İçsel Huzur Sığınağı',
      'Transit Ay 4. evinizi (Dip Noktası / IC aksı) tetiklerken iç dünyanıza çekilme, sevdiklerinizle ev ortamında vakit geçirme ve duygusal köklerinizi güçlendirme ihtiyacı duyarsınız. Dinlenmek ve enerjinizi tazelemek için ideal bir gündür.',
      'Evinizi düzenleyin, ailenize ve iç sesinize zaman ayırın; dış dünyanın gürültüsünden biraz uzaklaşarak şarj olun.',
    ),
    5: (
      'Aşk, Yaratıcılık, Yaşam Neşesi & Tutkular',
      'Transit Ay 5. evinizde dans ederken kalbiniz neşeyle dolar; romantizm, hobiler, sanatsal üretim, çocuklarla ilişkiler ve hayattan keyif alma arzusu zirveye çıkar. İçinizdeki çocuğu özgür bırakma vaktidir.',
      'Yeteneklerinizi sergilemekten çekinmeyin; partnerinize sevginizi gösterin ve size ilham veren yaratıcı uğraşlara vakit ayırın.',
    ),
    6: (
      'Günlük Rutinler, Sağlık, Verimlilik & Hizmet',
      'Transit Ay 6. evinizi düzenlerken çalışma ortamınızdaki ayrıntılar, yarım kalmış görevler, beslenme ve beden sağlığı odak noktası haline gelir. Hayatınızdaki pratik aksaklıkları optimize etmek için harika bir gündür.',
      'İşlerinizi öncelik sırasına koyun; sağlıklı beslenin ve bedeninize iyi gelecek hafif egzersizleri ihmal etmeyin.',
    ),
    7: (
      'İkili İlişkiler, Ortaklıklar, Evlilik & Diplomasi',
      'Transit Ay 7. evinizde (Alçalan / DSC aksı) ilerlerken birebir ilişkiler, partnerle diyaloglar, sözleşmeler ve ortaklaşa kararlar merkeze oturur. Karşı tarafın duygularını anlama ve ortak bir zeminde buluşma zamanıdır.',
      'Ben-sen dengesini koruyun; dinleyici olun, empati kurun ve uzlaşma gerektiren adımlarda adil davranın.',
    ),
    8: (
      'Ortaklaşa Finans, Sezgisel Simya & Derin Dönüşüm',
      'Transit Ay 8. evinizin derin sularında seyrederken gizli kalmış meseleler, psikolojik arınma, paylaşılan paralar (banka, kredi, prim) ve sezgisel uyanış yoğunlaşır. Yüzeysel olanı aşıp hakikate inme isteği baskındır.',
      'Korkularınızla yüzleşin; gereksiz duygusal yükleri bırakın ve içsel dönüşüm gücünüzü serbest bırakın.',
    ),
    9: (
      'Büyük Vizyon, Hayat Felsefesi, Eğitim & Seyahat',
      'Transit Ay 9. evinizi genişletirken ufkunuzu açacak yeni fikirler, yabancı kültürler, yüksek öğrenim, hukuki veya felsefi araştırmalar ve uzak seyahat planları ilham kaynağınız olur. Dar kalıplardan sıyrılma günüdür.',
      'Büyük resme odaklanın; vizyonunuzu genişletecek yeni bir kitap, eğitim veya seyahat planına odaklanın.',
    ),
    10: (
      'Kariyer, Toplumsal Görünürlük & Tepe Hedefler',
      'Transit Ay 10. evinizde (Tepe Noktası / MC aksı) parıldarken toplum önündeki duruşunuz, kariyer sorumluluklarınız ve yöneticilerle ilişkileriniz öne çıkar. Başarılarınızın ve yetkinliğinizin fark edilmesi için önemli bir penceredir.',
      'Disiplinli ve profesyonel bir duruş sergileyin; uzun vadeli hedefleriniz için stratejik inisiyatif alın.',
    ),
    11: (
      'Gelecek Vizyonları, Sosyal Çevre & Kolektif Hedefler',
      'Transit Ay 11. evinizi aktive ederken dostluklar, sosyal cemiyetler, ekip çalışmaları, idealler ve geleceğe dair umutlar kalbinizi ısıtır. Benzer vizyona sahip insanlarla bir araya gelmek motivasyonunuzu katlar.',
      'Dostlarınızla fikir alışverişi yapın; ekip ruhuna katkı verin ve geleceğe dair hayallerinizi somut projelere dönüştürün.',
    ),
    12: (
      'Bilinçaltı, Ruhsal Arınma & Perde Arkası Hazırlık',
      'Transit Ay 12. evinizin dingin limanında ilerlerken iç sesinizi dinleme, meditasyon, manevi teslimiyet, rüyaların rehberliği ve perde arkasında stratejik hazırlıklar yapma isteği ağır basar. Ruhunuzu dinlendirme fazıdır.',
      'Aceleci dışsal eylemlerden kaçının; sakin kalın, sezgilerinize kulak verin ve zihninizi dinlendirerek yeni döngüye hazırlanın.',
    ),
  };

  /// Kullanıcının Gerçek Doğum Haritası ve Güncel Gökyüzü Transit Ay Konumuna Göre
  /// Dinamik, Günlük, Ev ve Açı Bazlı Astro Bülten Üretici
  static PersonalizedDailyBulletin getPersonalizedDailyBulletin({
    required UserProfile profile,
    String? selectedSign,
    DateTime? customNow,
  }) {
    final now = customNow ?? DateTime.now();
    final utcNow = now.toUtc();
    final dateStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    // 1. Güncel Transit Ay Konumunu Astronomik Efemeris ile Hesapla
    final moonLon = SkyTransitsService.calculateMoonLongitude(utcNow);
    final normMoonLon = (moonLon % 360.0 + 360.0) % 360.0;
    final moonSignIdx = (normMoonLon / 30.0).floor() % 12;
    final transitMoonSign = SkyTransitsService.signs[moonSignIdx];
    final transitMoonSymbol = signSymbols[transitMoonSign] ?? '🌙';
    final degInSign = normMoonLon % 30.0;
    final deg = degInSign.floor();
    final min = ((degInSign - deg) * 60.0).floor();
    final transitMoonDegStr = "${deg.toString().padLeft(2, '0')}°${min.toString().padLeft(2, '0')}'";
    final transitMoonFormatted = "$transitMoonDegStr $transitMoonSign";

    // 2. Seçili Burç Kontrolü
    final userRising = profile.risingSign.trim();
    final userSun = profile.sunSign.trim();
    final targetSign = (selectedSign != null && selectedSign.isNotEmpty)
        ? selectedSign
        : (userRising.isNotEmpty ? userRising : (userSun.isNotEmpty ? userSun : 'Koç'));
    final signSymbol = signSymbols[targetSign] ?? '⭐';
    final signElement = signElements[targetSign] ?? 'Ateş';

    // Kullanıcının kendi haritası mı görüntüleniyor?
    final isPersonalChart = (selectedSign == null ||
        selectedSign == userRising ||
        selectedSign == userSun ||
        (userRising.isEmpty && userSun.isEmpty));

    // 3. Placidus Evini Derece Hesabıyla Belirle
    int natalHouse = 1;
    String cuspRange = '';
    Map<int, double> cusps = {};

    try {
      final placidusData = PredictiveAstrologyService.calculatePlacidusHouses(profile: profile);
      cusps = placidusData['cusps'] as Map<int, double>;

      if (isPersonalChart) {
        for (int h = 1; h <= 12; h++) {
          final start = cusps[h]!;
          final nextH = h == 12 ? 1 : h + 1;
          final end = cusps[nextH]!;
          final span = (end - start + 360.0) % 360.0;
          final diff = (normMoonLon - start + 360.0) % 360.0;
          if (diff < span) {
            natalHouse = h;
            break;
          }
        }
        final startFmt = PredictiveAstrologyService.formatLongitude(cusps[natalHouse]!, includeSymbol: true);
        final nextH = natalHouse == 12 ? 1 : natalHouse + 1;
        final endFmt = PredictiveAstrologyService.formatLongitude(cusps[nextH]!, includeSymbol: true);
        cuspRange = '$startFmt → $endFmt';
      } else {
        // Seçili farklı bir burç için Güneş evi (Solar Derived House)
        final targetIdx = SkyTransitsService.signs.indexOf(targetSign);
        if (targetIdx >= 0) {
          natalHouse = ((moonSignIdx - targetIdx + 12) % 12) + 1;
        }
        cuspRange = '$targetSign burcuna göre $natalHouse. Güneş Evi';
      }
    } catch (_) {
      // Güvenli fallback
      final ascIdx = SkyTransitsService.signs.indexOf(userRising.isNotEmpty ? userRising : 'Koç');
      natalHouse = ((moonSignIdx - (ascIdx >= 0 ? ascIdx : 0) + 12) % 12) + 1;
      cuspRange = 'Placidus Evi';
    }

    final houseMeta = _placidusHouseMetadata[natalHouse] ?? _placidusHouseMetadata[1]!;
    final natalHouseName = '$natalHouse. Ev';
    final natalHouseTheme = houseMeta.$1;
    final natalHouseDesc = houseMeta.$2;
    final natalHouseAdvice = houseMeta.$3;

    // 4. Doğum Haritası Gezegenleriyle Açıları Hesapla
    final activeAspects = <PersonalTransitAspect>[];

    try {
      final chart = AstrologyEngine.calculateChart(
        name: profile.name,
        dateStr: profile.birthDate,
        timeStr: profile.birthTime,
        city: profile.birthCity.isEmpty ? 'İstanbul' : profile.birthCity,
        country: profile.birthCountry.isEmpty ? 'Türkiye' : profile.birthCountry,
      );

      final bodiesToCheck = <String, (String, double)>{
        'Güneş': ('Güneş', chart.planets['sun']?.longitude ?? AspectsService.calculateAbsoluteLongitude(chart.sunSign, chart.sunFormatted)),
        'Ay': ('Ay', chart.planets['moon']?.longitude ?? AspectsService.calculateAbsoluteLongitude(chart.moonSign, chart.moonFormatted)),
        'Yükselen (ASC)': ('Yükselen (ASC)', chart.planets['ascendant']?.longitude ?? AspectsService.calculateAbsoluteLongitude(chart.risingSign, chart.risingFormatted)),
        'Tepe Noktası (MC)': ('Tepe Noktası (MC)', chart.planets['mc']?.longitude ?? 0.0),
        'Merkür': ('Merkür', chart.planets['mercury']?.longitude ?? 0.0),
        'Venüs': ('Venüs', chart.planets['venus']?.longitude ?? 0.0),
        'Mars': ('Mars', chart.planets['mars']?.longitude ?? 0.0),
        'Jüpiter': ('Jüpiter', chart.planets['jupiter']?.longitude ?? 0.0),
        'Satürn': ('Satürn', chart.planets['saturn']?.longitude ?? 0.0),
        'Uranüs': ('Uranüs', chart.planets['uranus']?.longitude ?? 0.0),
        'Neptün': ('Neptün', chart.planets['neptune']?.longitude ?? 0.0),
        'Plüton': ('Plüton', chart.planets['pluto']?.longitude ?? 0.0),
        'Chiron': ('Chiron', chart.planets['chiron']?.longitude ?? 0.0),
        'Kuzey Düğüm': ('Kuzey Düğüm', chart.planets['north_node']?.longitude ?? 0.0),
      };

      // Majör Açı Kuralları (Ay Transitleri için hassas orblar)
      final aspectRules = [
        (0.0, 'Kavuşum (0°)', '☌', 7.0, null),
        (60.0, 'Sekstil (60°)', '⚹', 5.0, true),
        (90.0, 'Kare (90°)', '□', 6.0, false),
        (120.0, 'Üçgen (120°)', '△', 6.0, true),
        (180.0, 'Karşıt (180°)', '☍', 7.0, false),
      ];

      for (final entry in bodiesToCheck.entries) {
        final planetName = entry.key;
        final planetLon = entry.value.$2;
        if (planetLon <= 0.0 && planetName != 'Güneş') continue;

        double diff = (normMoonLon - planetLon).abs() % 360.0;
        if (diff > 180.0) diff = 360.0 - diff;

        for (final rule in aspectRules) {
          final targetDeg = rule.$1;
          final aspName = rule.$2;
          final aspSymbol = rule.$3;
          final maxOrb = rule.$4;
          final isHarm = rule.$5;

          final orb = (diff - targetDeg).abs();
          if (orb <= maxOrb) {
            final orbDeg = orb.floor();
            final orbMin = ((orb - orbDeg) * 60.0).round();
            final orbStr = "$orbDeg°${orbMin.toString().padLeft(2, '0')}'";

            final planetSignIdx = (planetLon / 30.0).floor() % 12;
            final planetSign = SkyTransitsService.signs[planetSignIdx];
            final pDegInSign = (planetLon % 30.0).floor();
            final planetDegStr = "$pDegInSign° $planetSign";

            final (interp, tip) = _getTransitMoonAspectText(
              natalPlanet: planetName,
              aspectName: aspName,
              isHarmonious: isHarm ?? true,
            );

            activeAspects.add(
              PersonalTransitAspect(
                aspectName: aspName,
                aspectSymbol: aspSymbol,
                aspectDegree: targetDeg,
                natalPlanet: planetName,
                natalPlanetSign: planetSign,
                natalPlanetDegree: planetDegStr,
                orb: orb,
                orbStr: orbStr,
                isHarmonious: isHarm ?? (targetDeg == 0.0 ? true : false),
                interpretation: interp,
                strategicTip: tip,
              ),
            );
          }
        }
      }

      // En dar orb en başta (en güçlü aktif etki)
      activeAspects.sort((a, b) => a.orb.compareTo(b.orb));
    } catch (_) {}

    // 5. Kozmik Sentez Metnini Derle
    final buffer = StringBuffer();
    final clientName = profile.name.trim().isNotEmpty ? profile.name : 'Danışan';
    buffer.writeln('Sevgili $clientName, bugün ($dateStr) gökyüzünde Transit Ay, $transitMoonFormatted derecesinde seyrediyor ve haritanızın $natalHouseName ($natalHouseTheme) alanını aydınlatıyor.');
    buffer.writeln();
    buffer.writeln('🏠 **$natalHouseName Yaşam Alanı Dinamiği:**');
    buffer.writeln(natalHouseDesc);
    buffer.writeln();

    if (activeAspects.isNotEmpty) {
      buffer.writeln('🪐 **Transit Ay\'ın Natal Gezegenlerinize Yaptığı Geometrik Açılar:**');
      for (final a in activeAspects) {
        buffer.writeln('• ${a.aspectSymbol} **Transit Ay ${a.aspectName} Natal ${a.natalPlanet}** (${a.natalPlanetDegree}, Orb: ${a.orbStr}): ${a.interpretation}');
      }
    } else {
      buffer.writeln('🪐 **Açı Durumu:**');
      buffer.writeln('• 🌿 **Sakin & Dingin Kozmik Akış:** Transit Ay bugün doğum haritanızdaki majör gezegenlerle doğrudan sert veya bağlayıcı bir açı kurmuyor. Bu etki, $natalHouseName konularında dışsal çalkantılardan uzak, berrak bir odaklanma ve kendi ritminizi belirleme şansı tanıyor.');
    }
    buffer.writeln();
    buffer.writeln('🎯 **Günün Stratejik Rehberi:**');
    buffer.writeln(natalHouseAdvice);

    // 6. Şanslı Saatler ve Enerji Skoru
    int energyScore = 80;
    for (final a in activeAspects) {
      if (a.isHarmonious) {
        energyScore += 4;
      } else {
        energyScore -= 3;
      }
    }
    energyScore = energyScore.clamp(60, 98);

    // Ay burcuna göre uyumlu saatler ve burç
    final compatibleSigns = {
      'Koç': 'Yay', 'Boğa': 'Başak', 'İkizler': 'Kova', 'Yengeç': 'Balık',
      'Aslan': 'Koç', 'Başak': 'Boğa', 'Terazi': 'İkizler', 'Akrep': 'Yengeç',
      'Yay': 'Aslan', 'Oğlak': 'Boğa', 'Kova': 'Terazi', 'Balık': 'Akrep',
    };
    final luckyHoursBySign = {
      'Koç': '10:00 - 12:30', 'Boğa': '14:00 - 16:30', 'İkizler': '11:15 - 13:45',
      'Yengeç': '18:00 - 20:30', 'Aslan': '12:00 - 14:45', 'Başak': '09:00 - 11:30',
      'Terazi': '15:30 - 18:00', 'Akrep': '20:30 - 23:00', 'Yay': '13:00 - 15:30',
      'Oğlak': '08:30 - 11:00', 'Kova': '16:00 - 18:30', 'Balık': '19:30 - 22:00',
    };

    final dailyThemeStr = 'Transit Ay $transitMoonFormatted • $natalHouseName: $natalHouseTheme';
    final dailyFocusStr = natalHouseAdvice;
    final dailyLuckyHoursStr = luckyHoursBySign[transitMoonSign] ?? '11:00 - 14:00';
    final dailyCompSignStr = compatibleSigns[transitMoonSign] ?? 'Aslan';

    return PersonalizedDailyBulletin(
      sign: targetSign,
      signSymbol: signSymbol,
      signElement: signElement,
      date: now,
      dateStr: dateStr,
      transitMoonSign: transitMoonSign,
      transitMoonSymbol: transitMoonSymbol,
      transitMoonDegree: transitMoonDegStr,
      transitMoonFormatted: transitMoonFormatted,
      transitMoonLongitude: normMoonLon,
      natalHouse: natalHouse,
      natalHouseName: natalHouseName,
      natalHouseTheme: natalHouseTheme,
      natalHouseDescription: natalHouseDesc,
      natalHouseCuspRange: cuspRange,
      activeAspects: activeAspects,
      compiledDailySynthesis: buffer.toString(),
      dailyTheme: dailyThemeStr,
      dailyFocus: dailyFocusStr,
      dailyLuckyHours: dailyLuckyHoursStr,
      dailyCompatibleSign: dailyCompSignStr,
      cosmicEnergyScore: energyScore,
      isPersonalChart: isPersonalChart,
    );
  }

  /// Transit Ay ve Natal Gezegen Açılarının Özel Yorum Üreticisi
  static (String, String) _getTransitMoonAspectText({
    required String natalPlanet,
    required String aspectName,
    required bool isHarmonious,
  }) {
    if (natalPlanet == 'Güneş') {
      if (aspectName.contains('Kavuşum')) {
        return (
          'Bilinçaltı arzularınız ile yaşam hedefleriniz kusursuz bir uyum içinde. Duygularınızla mantığınız el ele veriyor; kendinize güveniniz tam.',
          'Yeni hedefler başlatmak ve kendinizi samimiyetle ortaya koymak için harika bir gün.',
        );
      } else if (isHarmonious) {
        return (
          'Duygusal berraklık, canlılık ve içsel huzur devrede. Otorite figürleriyle ve çevrenizle diyaloglarınız akıcı ve destekleyici ilerler.',
          'Önemli görüşmelerinizi planlayın; iradenizi rahatça kabul ettirebilirsiniz.',
        );
      } else {
        return (
          'İçsel istekleriniz ile mantığınız ve dış sorumluluklarınız arasında bir gerilim oluşabilir. Fevri kararlar almaktan veya ego savaşlarına girmekten kaçının.',
          'Karşı tarafı suçlamak yerine orta yolu bulun; duygusal iniş çıkışların geçici olduğunu bilin.',
        );
      }
    }

    if (natalPlanet == 'Ay') {
      if (isHarmonious) {
        return (
          'Kendi ruhsal doğanızla tam bir rezonans içindesiniz. Sezgileriniz son derece berrak, sevdiklerinizle şefkat dolu bağlar kurabilirsiniz.',
          'İç sesinizi dinleyin; duygusal şifalanma ve dinlenme için ideal zaman.',
        );
      } else {
        return (
          'Duygusal hassasiyet, geçmişe özlem veya alınganlıklar tetiklenebilir. Olayları kişisel algılamamaya özen gösterin.',
          'Duygularınızı bastırmayın ama fevri tepkiler vermeden önce derin bir nefes alın.',
        );
      }
    }

    if (natalPlanet == 'Merkür') {
      if (isHarmonious) {
        return (
          'Zihniniz ile kalbiniz aynı dili konuşuyor. İletişimde zarafet, ikna kabiliyeti ve yazışmalarda başarı hakim.',
          'Önemli sözleşmeler, sunumlar ve açık diyaloglar için bu pencereyi değerlendirin.',
        );
      } else {
        return (
          'Zihinsel sabırsızlık ve hislerin mantığın önüne geçmesi yanlış anlaşılmalara yol açabilir.',
          'Sözlerinizi tartarak söyleyin; e-postaları göndermeden önce iki kez kontrol edin.',
        );
      }
    }

    if (natalPlanet == 'Venüs') {
      if (isHarmonious) {
        return (
          'Günün en tatlı ve bereketli açılarından biri! Aşk hayatınızda cazibe, sanatsal ilham ve finansal fırsatlar kapınızı çalabilir.',
          'Romantik buluşmalar planlayın, güzellik ve sanat uğraşlarına vakit ayırın.',
        );
      } else {
        return (
          'İlişkilerde beklentilerin karşılanmaması veya tatminsizlik oluşabilir. Duygusal boşlukları anlık lüks harcamalarla doldurmaktan kaçının.',
          'Finansal harcamalarınızda ölçülü olun; sevgiyi talep etmek yerine şeffafça paylaşın.',
        );
      }
    }

    if (natalPlanet == 'Mars') {
      if (isHarmonious) {
        return (
          'Yüksek yaşam ateşi, cesaret ve kararlılık devrede. Zorlu işleri tamamlamak ve engelleri aşmak için gereken enerjiye fazlasıyla sahipsiniz.',
          'Ertelediğiniz projeleri bitirmek ve fiziksel spora zaman ayırmak için kullanın.',
        );
      } else {
        return (
          'Duygusal sabırsızlık, fevri çıkışlar ve tartışma potansiyeli yüksek. Aceleci eylemler sakarlıklara veya kırıcı sözlere yol açabilir.',
          'Trafikte sakin kalın; gergin enerjinizi spor ve yoğun üretime kanalize edin.',
        );
      }
    }

    if (natalPlanet == 'Jüpiter') {
      if (isHarmonious) {
        return (
          'Kozmik şans, ferahlık, iyimserlik ve manevi genişleme rüzgarı! Hayatınıza bereketli yeni kapıların açıldığı özel bir gün.',
          'Cesur niyetler belirleyin; paylaşın, cömert olun ve evrenin sunduğu fırsatları kucaklayın.',
        );
      } else {
        return (
          'Aşırı iyimserlik, abartılı vaatler veya gereksiz masraflara meyilli olabilirsiniz. Realiteden kopmamak şarttır.',
          'Ölçülü davranın; büyük riskler almadan önce ayaklarınızın yere bastığından emin olun.',
        );
      }
    }

    if (natalPlanet == 'Satürn') {
      if (isHarmonious) {
        return (
          'Duygusal olgunluk, sabır, stratejik disiplin ve sorumlulukları layıkıyla yerine getirme gücü.',
          'Kalıcı yapılar inşa etmek ve geleceğinizi garantiye alacak adımları atmak için ideal gün.',
        );
      } else {
        return (
          'İçsel bir ağırlık, yalnızlık veya engellenmişlik hissi oluşabilir. Kendinizi acımasızca eleştirmekten vazgeçin.',
          'Sorumluluklarınızı sıraya koyun; adım adım ilerleyin ve dinlenmeyi ihmal etmeyin.',
        );
      }
    }

    if (natalPlanet == 'Uranüs') {
      if (isHarmonious) {
        return (
          'Sıra dışı ilhamlar, beklenmedik sürprizler ve özgürleştirici yenilikler! Zihniniz kalıpların ötesini görüyor.',
          'Farklı yaklaşımlar deneyin; rutinlerinizi kıracak heyecan verici adımlar atın.',
        );
      } else {
        return (
          'İçsel huzursuzluk, planların aniden değişmesi veya isyankar ruh hali. Esnek olmak günü kurtarır.',
          'Fevri köprüleri yıkmayın; değişimi akıllıca ve sakin bir şekilde karşılayın.',
        );
      }
    }

    if (natalPlanet == 'Neptün') {
      if (isHarmonious) {
        return (
          'Ruhsal derinlik, rüyaların bilgeliği, sanatsal ilham ve evrensel sevgi akışı. Kalbinizin antenleri sonuna kadar açık.',
          'Meditasyon yapın, dua edin ve ilham gerektiren yaratıcı işlerinize odaklanın.',
        );
      } else {
        return (
          'Dalgınlık, aşırı fedakarlık veya gerçeklerden kaçma eğilimi. Net olmayan vaatlere karşı temkinli olunmalıdır.',
          'Önemli kararlar almadan önce detayları netleştirin; sınırlarınızı koruyun.',
        );
      }
    }

    if (natalPlanet == 'Plüton') {
      if (isHarmonious) {
        return (
          'Muazzam bir psikolojik güç, karizma ve krizleri avantaja dönüştürme yetisi. Sezgisel bir detektör gibisiniz.',
          'Kökten değişim gerektiren sorunları masaya yatırın ve kararlılıkla çözün.',
        );
      } else {
        return (
          'Kıskançlık, takıntılar veya kontrol etme arzusu tetiklenebilir. Güç savaşlarına girmek enerjinizi tüketir.',
          'Akışa teslim olun; kontrol edemeyeceğiniz durumları serbest bırakın.',
        );
      }
    }

    if (natalPlanet == 'Chiron') {
      if (isHarmonious) {
        return (
          'Ruhsal şifalanma, eski yaraları sevgiyle sarma ve başkalarına ilham verici bir bilgelikle rehberlik etme fırsatı.',
          'Kendinize şefkat gösterin; affediciliğin getirdiği hafifliği deneyimleyin.',
        );
      } else {
        return (
          'Eski bir kırgınlık veya yetersizlik hissi yüzeye çıkabilir. Bu durum aslında kalıcı bir iyileşme davetidir.',
          'Yaralarınızı yargılamayın; kendinize karşı nazik ve anlayışlı olun.',
        );
      }
    }

    if (natalPlanet == 'Kuzey Düğüm') {
      return (
        'Kadersel karşılaşmalar ve ruhun tekamülüne hizmet eden fırsatlar devrede. Geleceğe doğru adım atıyorsunuz.',
        'Konfor alanınızdan çıkın; sizi büyüten ve vizyon katan yolları seçin.',
      );
    }

    if (natalPlanet.contains('ASC') || natalPlanet.contains('Yükselen')) {
      if (isHarmonious) {
        return (
          'Dış dünyada ışıldayan bir çekim gücü ve yüksek canlılık. Kendinizi rahatça ifade edebilir, dikkatleri üzerinize çekebilirsiniz.',
          'Görüşmelerde ve sosyal ortamlarda ön planda olun.',
        );
      } else {
        return (
          'Duygusal dalgalanmalarınızın dışarıdan fark edilmesi veya çevrenizle geçici sürtüşmeler yaşanabilir.',
          'Tepkilerinizi ölçülü tutun; kendinize dinlenme alanı yaratın.',
        );
      }
    }

    if (natalPlanet.contains('MC') || natalPlanet.contains('Tepe')) {
      if (isHarmonious) {
        return (
          'Kariyerinizde ve toplumsal hedeflerinizde duygusal zekanızı kullanarak takdir toplayacağınız bereketli bir etki.',
          'Yöneticilerinizle görüşün; projelerinizi cesaretle sunun.',
        );
      } else {
        return (
          'Kariyer sorumlulukları ile özel hayatın duygusal ihtiyaçları arasında denge kurma gerekliliği.',
          'İki alanı birbirinden ayırın; önceliklerinizi netleştirin.',
        );
      }
    }

    return (
      'Transit Ay ile $natalPlanet arasındaki bu açı, günün enerjisini daha odaklı ve hissedilir kılıyor.',
      'Dengeli kalın ve farkındalıkla hareket edin.',
    );
  }

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
