import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'storage_service.dart';

/// Akıllı Reklam & Monetizasyon Yöneticisi (Google AdMob Canlı Entegrasyonlu)
class AdService {
  // Resmi AdMob Uygulama Kimliği
  static const String appId = 'ca-app-pub-1133172251227471~4078534665';

  // Canlı Reklam Birim Kimlikleri (AdMob Üretim Ortamı - Doğrudan Canlı İstek)
  static const String liveRewardedAdId = 'ca-app-pub-1133172251227471/1704268715';
  static const String liveInterstitialAdId = 'ca-app-pub-1133172251227471/7656178404';

  // TÜM İSTEKLER DOĞRUDAN CANLI HESABA GÖNDERİLİR (Test ID'leri AdMob panelinde İstek: 0 yapar!)
  static String get rewardedAdUnitId => liveRewardedAdId;
  static String get interstitialAdUnitId => liveInterstitialAdId;

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoading = false;
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;
  static int _globalActionCounter = 0;
  static DateTime? _lastAdShownTime;
  static DateTime? get lastAdShownTime => _lastAdShownTime;

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Her 4 tıklama veya eylemde (Astro Bülten, Gezegen Saatleri, Pusula, Frekanslar, Arşiv vb.)
  /// geçiş reklamı gösterir. VIP kullanıcılara %100 Reklamsızdır.
  static Future<void> registerActionAndShowInterstitial({VoidCallback? onDone}) async {
    void finish() {
      final cb = onDone;
      if (cb != null) {
        onDone = null;
        cb();
      }
    }

    if (!_isMobile) {
      finish();
      return;
    }
    final isVip = await StorageService.isVipUnlocked();
    if (isVip) {
      finish();
      return;
    }

    _globalActionCounter++;
    if (_globalActionCounter >= 4) {
      _globalActionCounter = 0;
      _lastAdShownTime = DateTime.now();
      await showInterstitialIfReady(onDone: finish);
    } else {
      finish();
    }
  }

  /// Müşteriyi boğmadan, her 4 sekme geçişinde 1 kez reklam gösterme kuralı
  static Future<bool> shouldShowTabInterstitial() async {
    if (!_isMobile) return false;
    final isVip = await StorageService.isVipUnlocked();
    if (isVip) return false; // VIP kullanıcılara %100 Reklamsız!

    _globalActionCounter++;
    
    // Her 4 sekme/aksiyon geçişinde bir tetiklenir (0, 1, 2, 3 serbest; 4'te reklam)
    if (_globalActionCounter >= 4) {
      _globalActionCounter = 0;
      _lastAdShownTime = DateTime.now();
      return true;
    }
    return false;
  }

  /// Hazır reklam varsa göster, bittiğinde devam et
  static Future<void> showInterstitialIfReady({VoidCallback? onDone}) async {
    void finish() {
      final cb = onDone;
      if (cb != null) {
        onDone = null;
        cb();
      }
    }

    if (!_isMobile) {
      finish();
      return;
    }
    final isVip = await StorageService.isVipUnlocked();
    if (isVip) {
      finish();
      return;
    }

    if (_interstitialAd != null) {
      final ad = _interstitialAd!;
      _interstitialAd = null; // Tüketildi
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (adInstance) {
          adInstance.dispose();
          preloadInterstitial();
          finish();
        },
        onAdFailedToShowFullScreenContent: (adInstance, error) {
          debugPrint('AdMob: Interstitial gösterim hatası: ${error.message}');
          adInstance.dispose();
          preloadInterstitial();
          finish();
        },
      );
      try {
        await ad.show();
      } catch (e) {
        debugPrint('AdMob: Interstitial show exception: $e');
        preloadInterstitial();
        finish();
      }
    } else {
      // Önbellekte hazır değilse anlık canlı yükle ve doğrudan ekranda göster
      _isInterstitialAdLoading = true;
      try {
        await InterstitialAd.load(
          adUnitId: interstitialAdUnitId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              _isInterstitialAdLoading = false;
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (adInstance) {
                  adInstance.dispose();
                  preloadInterstitial();
                  finish();
                },
                onAdFailedToShowFullScreenContent: (adInstance, error) {
                  debugPrint('AdMob: Anlık Interstitial gösterim hatası: ${error.message}');
                  adInstance.dispose();
                  preloadInterstitial();
                  finish();
                },
              );
              ad.show();
            },
            onAdFailedToLoad: (error) {
              _isInterstitialAdLoading = false;
              debugPrint('AdMob: Anlık Interstitial yükleme hatası: ${error.message} (Kod: ${error.code})');
              finish();
            },
          ),
        );
      } catch (e) {
        _isInterstitialAdLoading = false;
        debugPrint('AdMob: Anlık Interstitial exception: $e');
        finish();
      }
    }
  }

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
            // Geçici ağ veya No-Fill durumunda 20 saniye sonra otomatik yeniden dene
            Future.delayed(const Duration(seconds: 20), () {
              if (_interstitialAd == null && !_isInterstitialAdLoading) {
                preloadInterstitial(adUnitId: unitId);
              }
            });
          },
        ),
      );
    } catch (_) {
      _isInterstitialAdLoading = false;
    }
  }

  /// Ödüllü video reklamı arka planda önceden yükle (Kullanıcı tıkladığı an hazır olsun)
  static void preloadRewarded({String? adUnitId}) {
    if (!_isMobile) return;
    if (_rewardedAd != null || _isRewardedAdLoading) return;
    _isRewardedAdLoading = true;
    final unitId = adUnitId ?? rewardedAdUnitId;

    try {
      RewardedAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdLoading = false;
            _rewardedAd = null;
            Future.delayed(const Duration(seconds: 20), () {
              if (_rewardedAd == null && !_isRewardedAdLoading) {
                preloadRewarded(adUnitId: unitId);
              }
            });
          },
        ),
      );
    } catch (_) {
      _isRewardedAdLoading = false;
    }
  }



  /// Ödüllü reklam gösterimi (Kozmik Karar Pusulası, Ay Fazı & Canlı Geçişler vb. için)
  static Future<bool> showRewardedAd({required VoidCallback onRewardGranted}) async {
    if (!_isMobile) {
      onRewardGranted();
      return true;
    }

    // 1. Eğer hazır önbellekte reklam varsa hemen göster
    if (_rewardedAd != null) {
      final adToShow = _rewardedAd!;
      _rewardedAd = null; // Tüketildi
      bool rewardEarned = false;

      adToShow.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          preloadRewarded(); // Bir sonraki reklam için hazırla
          if (rewardEarned) {
            onRewardGranted();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          preloadRewarded();
          onRewardGranted(); // Kullanıcı mağdur olmasın
        },
      );

      try {
        await adToShow.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            rewardEarned = true;
          },
        );
        return true;
      } catch (_) {
        preloadRewarded();
        onRewardGranted();
        return true;
      }
    }

    // 2. Önbellekte yoksa anlık yükle ve göster
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
                preloadRewarded();
                if (rewardEarned) {
                  onRewardGranted();
                }
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                preloadRewarded();
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
              debugPrint('AdMob: Rewarded yükleme hatası: ${error.message} (Kod: ${error.code}, Alan: ${error.domain})');
              preloadRewarded();
              onRewardGranted(); // Ağ hatası durumunda ödülü aç
            },
        ),
      );
      return true;
    } catch (_) {
      preloadRewarded();
      onRewardGranted();
      return true;
    }
  }

  /// Reklam sayacını sıfırla
  static void resetCounter() {
    _globalActionCounter = 0;
  }
}
