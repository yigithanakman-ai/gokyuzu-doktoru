import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'astrology_engine.dart';
import 'planetary_hours_service.dart';
import 'sky_transits_service.dart';
import 'storage_service.dart';

enum CompassAnswerType {
  affirmative, // Harekete Geç (Yeşil)
  neutral, // Bekle & Gözlemle (Sarı)
  cautious, // Dikkat & İçe Dön (Kırmızı)
}

class CompassConsultationResult {
  final CompassAnswerType answerType;
  final String title;
  final String summary;
  final String astrologicalInsight;
  final String timingRecommendation;
  final int cosmicScore; // 0 - 100
  final double needleAngleDegrees; // İbre açısı
  final String category;
  final String legalDisclaimer;

  const CompassConsultationResult({
    required this.answerType,
    required this.title,
    required this.summary,
    required this.astrologicalInsight,
    required this.timingRecommendation,
    required this.cosmicScore,
    required this.needleAngleDegrees,
    required this.category,
    required this.legalDisclaimer,
  });
}

/// Kozmik Karar Pusulası & Gökyüzü Danışmanı
class CosmicCompassService {
  static const String legalNotice =
      '⚠️ YASAL UYARI & SORUMLULUK REDDİ: Kozmik Karar Pusulası, gökyüzü transitleri ve klasik astrolojik sembolizme dayalı sezgisel bir rehberlik ve eğlence aracıdır. Asla mutlak kesinlik içermez; tüm kararlar ve sonuçlar kişinin kendi özgür iradesi ve sorumluluğundadır. Tıbbi teşhis ve tedavi, fiziksel/ruhsal sağlık, hukuki uyuşmazlıklar veya finansal yatırım kararlarınız için lütfen uzman hekimlere, yetkili avukatlara ve lisanslı uzmanlara başvurunuz.';

  /// Kullanıcının hak durumunu kontrol eder (Ücretsiz: Günde 1, Silver: Haftada 12, Gold: Haftada 15, Platinum: Sınırsız)
  static Future<Map<String, dynamic>> checkQuotaStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final vipTier = await StorageService.getVipTier();
    final isVip = await StorageService.isVip();
    final now = DateTime.now();
    final todayKey = 'compass_usage_${now.year}_${now.month}_${now.day}';
    final weekKey = 'compass_week_${now.year}_${now.weekday}';

    if (vipTier == VipTier.platinum) {
      return {
        'canAsk': true,
        'remaining': 999,
        'tier': 'Platinum VIP',
        'isUnlimited': true,
      };
    }

    if (vipTier == VipTier.gold) {
      final used = prefs.getInt(weekKey) ?? 0;
      final maxWeekly = 15;
      final remaining = max(0, maxWeekly - used);
      return {
        'canAsk': remaining > 0,
        'remaining': remaining,
        'tier': 'Gold VIP',
        'isUnlimited': false,
        'period': 'haftalık',
      };
    }

    if (vipTier == VipTier.silver || isVip) {
      final used = prefs.getInt(weekKey) ?? 0;
      final maxWeekly = 12;
      final remaining = max(0, maxWeekly - used);
      return {
        'canAsk': remaining > 0,
        'remaining': remaining,
        'tier': 'Silver VIP',
        'isUnlimited': false,
        'period': 'haftalık',
      };
    }

    // Ücretsiz Üye: Günde 1 soru hakkı + günde en fazla 1 ödüllü reklamla +1 hak kazanabilme
    final usedToday = prefs.getInt(todayKey) ?? 0;
    final bonusAds = prefs.getInt('${todayKey}_bonus') ?? 0;
    final maxFreeDaily = 1 + min(1, bonusAds);
    final remaining = max(0, maxFreeDaily - usedToday);
    final canWatchAd = bonusAds < 1;

    return {
      'canAsk': remaining > 0,
      'remaining': remaining,
      'tier': 'Standart',
      'isUnlimited': false,
      'period': 'günlük',
      'canWatchAdForBonus': canWatchAd,
      'bonusAdsUsedToday': bonusAds,
    };
  }

  /// Soru hakkını düşürür
  static Future<void> consumeQuota() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = 'compass_usage_${now.year}_${now.month}_${now.day}';
    final weekKey = 'compass_week_${now.year}_${now.weekday}';

    final usedToday = prefs.getInt(todayKey) ?? 0;
    await prefs.setInt(todayKey, usedToday + 1);

    final usedWeek = prefs.getInt(weekKey) ?? 0;
    await prefs.setInt(weekKey, usedWeek + 1);
  }

  /// Reklam izleyince ücretsiz üyeye +1 hak ekler (Günde KESİNLİKLE EN FAZLA 1 KEZ İZLENİR)
  static Future<bool> addAdBonusQuota() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final bonusKey = 'compass_usage_${now.year}_${now.month}_${now.day}_bonus';
    final cur = prefs.getInt(bonusKey) ?? 0;
    if (cur >= 1) {
      return false; // Günlük 1 reklam limiti doldu
    }
    await prefs.setInt(bonusKey, cur + 1);
    return true;
  }

  /// Doğum haritası ve anlık gökyüzü enerjisine göre karar pusulasını çalıştırır
  static Future<CompassConsultationResult> consultCompass({
    required UserProfile profile,
    required String category, // 'Kariyer', 'İlişkiler', 'Finans', 'Kişisel'
    String? optionalQuestion,
  }) async {
    final liveChart = AstrologyEngine.calculateChart(
      name: profile.name,
      dateStr: profile.birthDate,
      timeStr: profile.birthTime,
      city: profile.birthCity,
      country: profile.birthCountry,
    );

    final moonPhaseInfo = SkyTransitsService.getMoonPhase();
    final moonPhase = moonPhaseInfo.phaseName;
    final isMoonVoid = SkyTransitsService.getVoidOfCourse().isVoid;
    final planetaryInfo = PlanetaryHoursService.calculatePlanetaryHours();
    final currentHour = planetaryInfo.currentHour;

    int score = 56;

    // Harita burç yöneticisi uyumu
    if (liveChart.sunSign == 'Aslan' && currentHour.planetName == 'Güneş') score += 12;
    if (liveChart.sunSign == 'Yengeç' && currentHour.planetName == 'Ay') score += 12;
    if ((liveChart.sunSign == 'Boğa' || liveChart.sunSign == 'Terazi') && currentHour.planetName == 'Venüs') score += 12;
    if ((liveChart.sunSign == 'Koç' || liveChart.sunSign == 'Akrep') && currentHour.planetName == 'Mars') score += 12;
    if ((liveChart.sunSign == 'İkizler' || liveChart.sunSign == 'Başak') && currentHour.planetName == 'Merkür') score += 12;
    if ((liveChart.sunSign == 'Yay' || liveChart.sunSign == 'Balık') && currentHour.planetName == 'Jüpiter') score += 12;
    if ((liveChart.sunSign == 'Oğlak' || liveChart.sunSign == 'Kova') && currentHour.planetName == 'Satürn') score += 12;

    // Ay Boşlukta durumu
    if (isMoonVoid) {
      score -= 14;
    }

    // Gezegen saatine göre uyum
    if (category == 'Finans' || category == 'Kariyer') {
      if (currentHour.planetName == 'Jüpiter' || currentHour.planetName == 'Güneş') score += 20;
      if (currentHour.planetName == 'Merkür') score += 14;
      if (currentHour.planetName == 'Mars') score += 6;
      if (currentHour.planetName == 'Satürn') score -= 8;
    } else if (category == 'İlişkiler') {
      if (currentHour.planetName == 'Venüs') score += 22;
      if (currentHour.planetName == 'Ay') score += 16;
      if (currentHour.planetName == 'Jüpiter') score += 14;
      if (currentHour.planetName == 'Mars') score -= 8; // Çatışma riski
      if (currentHour.planetName == 'Satürn') score -= 8; // Soğuma riski
    } else {
      if (currentHour.planetName == 'Güneş' || currentHour.planetName == 'Jüpiter') score += 18;
      if (currentHour.planetName == 'Merkür' || currentHour.planetName == 'Venüs') score += 12;
      if (currentHour.planetName == 'Ay') score += 10;
      if (currentHour.planetName == 'Satürn') score -= 8;
    }

    // Ay fazına göre puan
    if (moonPhase.contains('Büyüyen') || moonPhase.contains('İlk Dördün') || moonPhase.contains('Hilal')) {
      score += 12;
    } else if (moonPhase.contains('Dolunay')) {
      score += (category == 'İlişkiler' ? 6 : 4);
    } else if (moonPhase.contains('Küçülen') || moonPhase.contains('Balsamik')) {
      score -= 4; // Hafif içe dönüş
    }

    score = score.clamp(15, 96);

    CompassAnswerType answerType;
    String title;
    String summary;
    String astrologicalInsight;
    String timing;
    double angle;

    if (score >= 68) {
      answerType = CompassAnswerType.affirmative;
      title = 'HAREKETE GEÇ 🟢 (Kozmik Kapı Açık)';
      summary = 'Gökyüzü transitleri ve anlık gezegen saatleri niyetinizi güçlü bir rezonansla destekliyor.';
      astrologicalInsight =
          'Şu anda ${currentHour.planetName} saati hüküm sürüyor (${currentHour.title}). Ay enerjisi $moonPhase fazında ilerliyor ve niyetinizle uyumlu bir çekim frekansı oluşturuyor.';
      timing = 'Bugün saat ${currentHour.endFormatted}\'ye kadar atılacak adımlar için gökyüzü ilahi koruma ve bereket saçıyor.';
      // Üst Bölge (🟢 HAREKET): 0° etrafında (-10° ile +10° arası)
      angle = ((Random().nextDouble() * 20.0 - 10.0) + 360.0) % 360.0;
    } else if (score >= 42) {
      answerType = CompassAnswerType.neutral;
      title = 'BEKLE & GÖZLEMLE 🟡 (Zemin Henüz Netleşmedi)';
      summary = 'Durum henüz tam olgunlaşmamış. Fevri kararlar vermek yerine gelişmeleri birkaç saat uzaktan izleyin.';
      astrologicalInsight = isMoonVoid
          ? 'Ay şu an boşlukta seyrediyor. Klasik astrolojide Ay boşluktayken başlatılan işler havada kalabilir veya yön değiştirebilir.'
          : 'Gezegen saatinde ${currentHour.planetName} etkisi aktif. Zihinsel veya duygusal belirsizlikler dağılana kadar beklemek en yüksek faydanızadır.';
      timing = 'Özellikle saat ${currentHour.endFormatted} sonrasını ve Ay fazının sonraki açılarını beklemek enerjiyi daha berrak hale getirecektir.';
      // Sol Bölge (🟡 BEKLE): 270° etrafında (260° ile 280° arası)
      angle = 260.0 + (Random().nextDouble() * 20.0);
    } else {
      answerType = CompassAnswerType.cautious;
      title = 'DİKKAT / GERİ ÇEKİL 🔴 (Zorlayıcı Transit)';
      summary = 'Şu an doğrudan yüzleşme, imza atma veya büyük adımlar için uygun bir zamanlama değil. Dinlenin ve içe dönün.';
      astrologicalInsight =
          'Gökyüzünde ${currentHour.planetName} saatinin sert/sınayıcı frekansı devrede. Aceleci adımlar yanılsama veya dirençle karşılaşabilir.';
      timing = 'Kararınızı en az 24 saat erteleyin veya günün ilerleyen saatlerinde Jüpiter/Venüs saatini bekleyin.';
      // Alt Bölge (🔴 DİKKAT): 180° etrafında (170° ile 190° arası)
      angle = 170.0 + (Random().nextDouble() * 20.0);
    }

    return CompassConsultationResult(
      answerType: answerType,
      title: title,
      summary: summary,
      astrologicalInsight: astrologicalInsight,
      timingRecommendation: timing,
      cosmicScore: score,
      needleAngleDegrees: angle,
      category: category,
      legalDisclaimer: legalNotice,
    );
  }
}
