import 'storage_service.dart';

/// Akıllı Reklam & Monetizasyon Yöneticisi (Google AdMob Uyumlu)
class AdService {
  static int _tabSwitchCounter = 0;
  static DateTime? _lastAdShownTime;

  // Google AdMob Test Birim Kimlikleri (Resmi Google Play Test ID'leri)
  static const String testAppOpenAdId = 'ca-app-pub-3940256099942544/3419835294';
  static const String testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';

  /// Müşteriyi boğmadan, her 4 sekme geçişinde 1 kez reklam gösterme kuralı
  static Future<bool> shouldShowTabInterstitial() async {
    final isVip = await StorageService.isVipUnlocked();
    if (isVip) return false; // VIP kullanıcılara %100 Reklamsız!

    _tabSwitchCounter++;
    
    // Her 4 sekme geçişinde bir tetiklenir (0, 1, 2, 3 serbest; 4'te reklam)
    if (_tabSwitchCounter >= 4) {
      _tabSwitchCounter = 0;
      _lastAdShownTime = DateTime.now();
      return true;
    }
    return false;
  }

  /// Uygulama açılışında kullanıcıyı sıkmamak için en az 10 dakika arayla gösterme kuralı
  static Future<bool> shouldShowAppOpenAd() async {
    final isVip = await StorageService.isVipUnlocked();
    if (isVip) return false;

    if (_lastAdShownTime == null) {
      _lastAdShownTime = DateTime.now();
      return true;
    }

    final diff = DateTime.now().difference(_lastAdShownTime!);
    if (diff.inMinutes >= 10) {
      _lastAdShownTime = DateTime.now();
      return true;
    }

    return false;
  }

  /// Reklam sayacını sıfırla
  static void resetCounter() {
    _tabSwitchCounter = 0;
  }
}
