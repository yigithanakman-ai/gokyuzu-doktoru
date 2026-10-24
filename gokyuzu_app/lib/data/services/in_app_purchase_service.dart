import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'storage_service.dart';

class InAppPurchaseService {
  static final InAppPurchaseService instance = InAppPurchaseService._internal();
  InAppPurchaseService._internal();

  InAppPurchase? _iap;
  InAppPurchase get _inAppPurchase {
    try {
      return _iap ??= InAppPurchase.instance;
    } catch (_) {
      rethrow;
    }
  }

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Google Play ve Apple App Store Resmi Ürün & Abonelik Kimlikleri
  static const String platinumYearId = 'gokyuzu_vip_platinum_year';
  static const String platinumMonthId = 'gokyuzu_vip_platinum_month';
  static const String goldMonthId = 'gokyuzu_vip_gold_month';
  static const String silverMonthId = 'gokyuzu_vip_silver_month';

  static const Set<String> productIds = {
    platinumYearId,
    platinumMonthId,
    goldMonthId,
    silverMonthId,
  };

  /// Google Play Console'da tanımlanabilecek alternatif abonelik kimlikleri dahil tam sorgu kümesi
  static const Set<String> allQueryProductIds = {
    platinumYearId,
    platinumMonthId,
    goldMonthId,
    silverMonthId,
    'vip_yearly',
    'vip_monthly',
    'gokyuzu_vip_yearly',
    'gokyuzu_vip_monthly',
    'platinum_year',
    'platinum_month',
    'gold_month',
    'silver_month',
    'vip_yillik',
    'vip_aylik',
    'gokyuzu_vip',
  };

  bool isAvailable = false;
  List<ProductDetails> products = [];
  List<String> notFoundIds = [];
  bool isLoading = false;
  String? errorMessage;

  final StreamController<VipTier> _purchaseCompletedController =
      StreamController<VipTier>.broadcast();
  Stream<VipTier> get onPurchaseCompleted => _purchaseCompletedController.stream;

  /// Mağaza servisini ve satın alma dinleyicisini başlatır
  Future<void> initialize() async {
    try {
      if (kIsWeb) return;

      isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        debugPrint('[InAppPurchaseService] In-App Purchase bu cihazda aktif değil.');
        return;
      }

      _subscription?.cancel();
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseStream,
        onDone: () => _subscription?.cancel(),
        onError: (err) {
          debugPrint('[InAppPurchaseService] Satın alma dinleyici hatası: $err');
        },
      );

      await loadProducts();
    } catch (e) {
      debugPrint('[InAppPurchaseService] Başlatma hatası: $e');
    }
  }

  /// Google Play / App Store'dan ürün fiyat ve detaylarını çeker
  Future<void> loadProducts() async {
    if (kIsWeb) return;
    if (!isAvailable) {
      try {
        isAvailable = await _inAppPurchase.isAvailable();
      } catch (_) {}
    }
    if (!isAvailable) return;

    isLoading = true;
    try {
      final response = await _inAppPurchase.queryProductDetails(allQueryProductIds);
      if (response.error != null) {
        errorMessage = response.error!.message;
        debugPrint('[InAppPurchaseService] Ürün sorgulama hatası: $errorMessage');
      }
      products = response.productDetails;
      notFoundIds = response.notFoundIDs;
      debugPrint(
        '[InAppPurchaseService] ${products.length} adet mağaza ürünü yüklendi: '
        '${products.map((p) => "${p.id} (${p.price})").join(", ")}',
      );
    } catch (e) {
      debugPrint('[InAppPurchaseService] loadProducts hatası: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Belirli bir paket için mağazadan yüklenen gerçek ürünü bulur
  ProductDetails? findMatchingProduct(String productId) {
    // 1. Birebir ID eşleşmesi
    for (final p in products) {
      if (p.id == productId) return p;
    }

    // 2. Paket tipine göre alternatif ID eşleşmesi
    final aliases = <String>[];
    if (productId == platinumYearId) {
      aliases.addAll(['vip_yearly', 'gokyuzu_vip_yearly', 'platinum_year', 'vip_yillik', 'gokyuzu_vip']);
    } else if (productId == platinumMonthId) {
      aliases.addAll(['vip_monthly', 'gokyuzu_vip_monthly', 'platinum_month', 'vip_aylik', 'gokyuzu_vip']);
    } else if (productId == goldMonthId) {
      aliases.addAll(['gold_month', 'vip_monthly', 'gokyuzu_vip_monthly']);
    } else if (productId == silverMonthId) {
      aliases.addAll(['silver_month', 'vip_monthly', 'gokyuzu_vip_monthly']);
    }

    for (final alias in aliases) {
      for (final p in products) {
        if (p.id == alias) return p;
      }
    }

    // 3. Eğer Play Console'da en az 1 aktif abonelik tanımlanmışsa onu kullan
    if (products.isNotEmpty) {
      return products.first;
    }

    return null;
  }

  /// Kullanıcı paket seçtiğinde ("Hemen Abone Ol" veya "Seç") doğrudan
  /// YEREL GOOGLE PLAY ÖDEME ALT PENCERESİNİ (BillingClient.launchBillingFlow) başlatır.
  /// ASLA harici 'Abonelikler' yönetim sayfasına (play.google.com/store/account/subscriptions) yönlendirmez!
  Future<bool> buySubscription(String productId, VipTier tier) async {
    errorMessage = null;

    if (!isAvailable) {
      await initialize();
    }

    if (!isAvailable) {
      errorMessage =
          'Google Play Faturalandırma Servisi (BillingClient) bu cihazda başlatılamadı. '
          'Lütfen cihazınızda Google Play Store hesabınızın açık olduğundan emin olun.';
      return false;
    }

    ProductDetails? matchingProduct = findMatchingProduct(productId);

    if (matchingProduct == null) {
      await loadProducts();
      matchingProduct = findMatchingProduct(productId);
    }

    if (matchingProduct != null) {
      late final PurchaseParam purchaseParam;
      if (!kIsWeb && Platform.isAndroid && matchingProduct is GooglePlayProductDetails) {
        purchaseParam = GooglePlayPurchaseParam(
          productDetails: matchingProduct,
          offerToken: matchingProduct.offerToken,
        );
      } else {
        purchaseParam = PurchaseParam(productDetails: matchingProduct);
      }

      return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      errorMessage =
          'Google Play Console üzerinde "$productId" kodlu abonelik paketi henüz etkinleştirilmemiş '
          'veya uygulama Google Play Kapalı Test kanalı yerine harici APK ile yüklenmiş.';
      return false;
    }
  }

  /// Satın alımları geri yükleme (App Store ve Google Play gereksinimi)
  Future<void> restorePurchases() async {
    if (!isAvailable) {
      await initialize();
    }
    if (!isAvailable) return;
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('[InAppPurchaseService] restorePurchases hatası: $e');
    }
  }

  void _onPurchaseStream(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      debugPrint('[InAppPurchaseService] Satın alma işlemi devam ediyor...');
    } else if (purchase.status == PurchaseStatus.error) {
      errorMessage = purchase.error?.message;
      debugPrint('[InAppPurchaseService] Satın alma hatası: ${purchase.error}');
    } else if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final tier = _mapProductIdToTier(purchase.productID);
      final isYearly = purchase.productID == platinumYearId ||
          purchase.productID.contains('year') ||
          purchase.productID.contains('yillik');
      final duration = isYearly ? const Duration(days: 365) : const Duration(days: 30);
      final existingExpiry = await StorageService.getVipExpiryDate();
      final base = (existingExpiry != null && existingExpiry.isAfter(DateTime.now()))
          ? existingExpiry
          : DateTime.now();
      final expiryDate = base.add(duration);
      await StorageService.setVipTier(tier, expiryDate: expiryDate);
      _purchaseCompletedController.add(tier);

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  VipTier _mapProductIdToTier(String productId) {
    if (productId == goldMonthId || productId.contains('gold')) {
      return VipTier.gold;
    }
    if (productId == silverMonthId || productId.contains('silver')) {
      return VipTier.silver;
    }
    return VipTier.platinum;
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseCompletedController.close();
  }
}
