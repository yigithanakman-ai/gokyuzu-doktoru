import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum CosmicSeason {
  standard,
  halloween,
  newYear,
  valentines,
  springEquinox,
}

/// Gökyüzü Doktoru Otomatik Kozmik Takvim & Özel Günler Motoru
/// Tarih aralıklarına göre arka planda otomatik devreye girer veya demo modunda test edilebilir.
class CosmicThemeService {
  static final ValueNotifier<CosmicSeason> seasonNotifier = ValueNotifier<CosmicSeason>(_detectCurrentSeason());
  static CosmicSeason? _overrideSeason;

  /// Tarihsel olarak aktif sezonu belirler (Sıfır Manuel Takip Eforu)
  static CosmicSeason _detectCurrentSeason() {
    if (_overrideSeason != null) return _overrideSeason!;

    final now = DateTime.now();
    final m = now.month;
    final d = now.day;

    // 1. Cadılar Bayramı / Samhain (15 Ekim - 5 Kasım)
    if ((m == 10 && d >= 15) || (m == 11 && d <= 5)) {
      return CosmicSeason.halloween;
    }

    // 2. Kış Gündönümü & Yeni Yıl (20 Aralık - 5 Ocak)
    if ((m == 12 && d >= 20) || (m == 1 && d <= 5)) {
      return CosmicSeason.newYear;
    }

    // 3. Sevgililer Günü & Venüs Aşk Kapısı (10 Şubat - 16 Şubat)
    if (m == 2 && d >= 10 && d <= 16) {
      return CosmicSeason.valentines;
    }

    // 4. İlkbahar Ekinoksu & Astroloji Yeni Yılı (0° Koç: 19 Mart - 24 Mart)
    if (m == 3 && d >= 19 && d <= 24) {
      return CosmicSeason.springEquinox;
    }

    return CosmicSeason.standard;
  }

  /// Anlık aktif sezon
  static CosmicSeason get currentSeason => _overrideSeason ?? _detectCurrentSeason();

  /// Demo / Test için sezonu zorla ayarlar
  static void setOverrideSeason(CosmicSeason? season) {
    _overrideSeason = season;
    seasonNotifier.value = _overrideSeason ?? _detectCurrentSeason();
  }

  /// Aktif sezon Cadılar Bayramı mı?
  static bool get isHalloween => currentSeason == CosmicSeason.halloween;
  static bool get isNewYear => currentSeason == CosmicSeason.newYear;
  static bool get isValentines => currentSeason == CosmicSeason.valentines;
  static bool get isSpringEquinox => currentSeason == CosmicSeason.springEquinox;

  /// Sezon Rozet Başlığı
  static String get seasonBadgeText {
    switch (currentSeason) {
      case CosmicSeason.halloween:
        return '🎃 CADILAR BAYRAMI KOZMİK SEZONU';
      case CosmicSeason.newYear:
        return '🎄 YENİ YIL & KIŞ GÜNDÖNÜMÜ IŞILTISI';
      case CosmicSeason.valentines:
        return '💖 VENÜS AŞK & RUH EŞİ PORTALI';
      case CosmicSeason.springEquinox:
        return '🌸 İLKBAHAR EKİNOKSU & ASTRO YENİ YIL (0° KOÇ)';
      case CosmicSeason.standard:
        return '✨ CANLI GÖKYÜZÜ TRANSİTLERİ';
    }
  }

  /// Sezon Duyuru & Bilgilendirme Notu
  static String get seasonBannerSubtitle {
    switch (currentSeason) {
      case CosmicSeason.halloween:
        return 'Plüton & Lilith gölge benlik koridoru aktif. Gezegenler gizemli pelerinlerini giydi; derin sezgiler ve dönüşüm enerjisi dorukta!';
      case CosmicSeason.newYear:
        return 'Kozmik Yule döngüsü: Güneş altın tacını taktı. Yeni yıl hedeflerine gökyüzü ilahi koruma ve bereket saçıyor!';
      case CosmicSeason.valentines:
        return 'Venüs gökyüzünde ışıldıyor: Kalp çakrası ve kadersel ruh eşi frekansı en yüksek titreşimde.';
      case CosmicSeason.springEquinox:
        return 'Zodyak sıfırlandı! Doğanın ve ruhun uyanış döngüsüyle yeni başlangıçlar için altın kapı açıldı.';
      case CosmicSeason.standard:
        return 'Gökyüzü şu an jeosantrik Placidus koordinatlarında gerçek zamanlı akıyor.';
    }
  }

  /// Sezona Özel Vurgu Rengi 1 (Primary Accent)
  static Color get primaryAccentColor {
    switch (currentSeason) {
      case CosmicSeason.halloween:
        return const Color(0xFFFF7518); // Balkabağı Turuncusu
      case CosmicSeason.newYear:
        return const Color(0xFFFFD700); // Altın Sarısı
      case CosmicSeason.valentines:
        return const Color(0xFFFF4081); // Mistik Aşk Pembesi
      case CosmicSeason.springEquinox:
        return const Color(0xFF00E676); // Canlı Bahar Yeşili
      case CosmicSeason.standard:
        return AppColors.starlightGold;
    }
  }

  /// Sezona Özel Vurgu Rengi 2 (Secondary Mystic Accent)
  static Color get secondaryAccentColor {
    switch (currentSeason) {
      case CosmicSeason.halloween:
        return const Color(0xFF9333EA); // Mistik Cadı Moru
      case CosmicSeason.newYear:
        return const Color(0xFF38BDF8); // Buz Mavisi Parıltı
      case CosmicSeason.valentines:
        return const Color(0xFFF43F5E); // Gül Kırmızısı
      case CosmicSeason.springEquinox:
        return const Color(0xFFF59E0B); // Ilık Güneş Sarısı
      case CosmicSeason.standard:
        return AppColors.pastelLavender;
    }
  }

  /// Gezegenlere Özel Sezonluk Kostüm & İkon Rozetleri
  static String? getPlanetCostumeEmoji(String planetKey) {
    final key = planetKey.toLowerCase().trim();
    switch (currentSeason) {
      case CosmicSeason.halloween:
        if (key.contains('pluto') || key.contains('plüton')) return '🧙‍♀️'; // Cadı şapkası
        if (key.contains('moon') || key.contains('ay')) return '🦇'; // Yarasa / Kanlı Ay
        if (key.contains('mars')) return '🎃'; // Balkabağı Savaşçısı
        if (key.contains('saturn') || key.contains('satürn')) return '🕸️'; // Örümcek Ağı
        if (key.contains('chiron') || key.contains('şiron')) return '🕯️'; // Mistik Mum
        if (key.contains('north_node') || key.contains('kuzey')) return '🔮'; // Kristal Küre
        if (key.contains('sun') || key.contains('güneş')) return '🍁'; // Sonbahar Yaprağı
        if (key.contains('rising') || key.contains('yükselen') || key.contains('asc')) return '👻'; // Hayalet
        return null;

      case CosmicSeason.newYear:
        if (key.contains('sun') || key.contains('güneş')) return '👑'; // Altın Yeni Yıl Tacı
        if (key.contains('moon') || key.contains('ay')) return '❄️'; // Kar Tanesi
        if (key.contains('jupiter') || key.contains('jüpiter')) return '🎁'; // Bolluk Hediyesi
        if (key.contains('venus') || key.contains('venüs')) return '⭐'; // Kutup Yıldızı
        if (key.contains('rising') || key.contains('yükselen') || key.contains('asc')) return '✨'; // Yılbaşı Parıltısı
        return null;

      case CosmicSeason.valentines:
        if (key.contains('venus') || key.contains('venüs')) return '💖'; // Aşk Kalbi
        if (key.contains('mars')) return '🏹'; // Eros Oku
        if (key.contains('moon') || key.contains('ay')) return '🌹'; // Gül
        if (key.contains('rising') || key.contains('yükselen') || key.contains('asc')) return '💘'; // Kalpli Ok
        return null;

      case CosmicSeason.springEquinox:
        if (key.contains('sun') || key.contains('güneş')) return '🌱'; // Filizlenme
        if (key.contains('venus') || key.contains('venüs')) return '🌸'; // Çiçek
        if (key.contains('mars')) return '⚡'; // Koç Atılımı
        if (key.contains('rising') || key.contains('yükselen') || key.contains('asc')) return '🪻'; // Bahar Çiçeği
        return null;

      case CosmicSeason.standard:
        return null;
    }
  }
}
