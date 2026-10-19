import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'storage_service.dart';

/// Akıllı Reklam & Monetizasyon Yöneticisi (Google AdMob Canlı Entegrasyonlu)
class AdService {
  // Resmi AdMob Uygulama Kimliği
  static const String appId = 'ca-app-pub-1133172251227471~4078534665';

  // Canlı Reklam Birim Kimlikleri (AdMob Üretim Ortamı)
  static const String liveRewardedAdId = 'ca-app-pub-1133172251227471/1704268715';
  static const String liveInterstitialAdId = 'ca-app-pub-1133172251227471/7656178404';

  // Google Resmi Test Reklam Birim Kimlikleri
  static const String testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';

  // Canlı/Test Akıllı Seçici (Canlı yayında gerçek reklam, geliştirmede test reklamı)
  static String get rewardedAdUnitId =>
      kReleaseMode ? liveRewardedAdId : testRewardedAdId;

  static String get interstitialAdUnitId =>
      kReleaseMode ? liveInterstitialAdId : testInterstitialAdId;

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoading = false;
  static int _tabSwitchCounter = 0;
  static DateTime? _lastAdShownTime;
  static DateTime? get lastAdShownTime => _lastAdShownTime;

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Geçiş reklamını arka planda önceden yükle (Hazır tut)
  static void preloadInterstitial({String? adUnitId}) {
    if (!_isMobile) return;
    if (_interstitialAd != null || _isInterstitialAdLoading) return;
    _isInterstitialAdLoading = true;
    final unitId = adUnitId ?? interstitialAdUnitId;

    try {
      InterstitialAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                preloadInterstitial(adUnitId: unitId);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                preloadInterstitial(adUnitId: unitId);
              },
            );
          },
          onAdFailedToLoad: (error) {
            _isInterstitialAdLoading = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (_) {
      _isInterstitialAdLoading = false;
    }
  }

  /// Müşteriyi boğmadan, her 4 sekme geçişinde 1 kez reklam gösterme kuralı
  static Future<bool> shouldShowTabInterstitial() async {
    if (!_isMobile) return false;
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

  /// Hazır reklam varsa göster, bittiğinde devam et
  static Future<void> showInterstitialIfReady({VoidCallback? onDone}) async {
    if (!_isMobile) {
      onDone?.call();
      return;
    }
    final isVip = await StorageService.isVipUnlocked();
    if (isVip) {
      onDone?.call();
      return;
    }

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitial();
          onDone?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitial();
          onDone?.call();
        },
      );
      try {
        await _interstitialAd!.show();
      } catch (_) {
        onDone?.call();
      }
    } else {
      preloadInterstitial();
      onDone?.call();
    }
  }

  /// Ödüllü reklam gösterimi (Kozmik Karar Pusulası +1 Hak vb. için)
  static Future<bool> showRewardedAd({required VoidCallback onRewardGranted}) async {
    if (!_isMobile) {
      onRewardGranted();
      return true;
    }

    try {
      bool rewardEarned = false;
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (rewardEarned) {
                  onRewardGranted();
                }
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                onRewardGranted();
              },
            );
            ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                rewardEarned = true;
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            onRewardGranted();
          },
        ),
      );
      return true;
    } catch (_) {
      onRewardGranted();
      return true;
    }
  }

  /// Reklam sayacını sıfırla
  static void resetCounter() {
    _tabSwitchCounter = 0;
  }
}
