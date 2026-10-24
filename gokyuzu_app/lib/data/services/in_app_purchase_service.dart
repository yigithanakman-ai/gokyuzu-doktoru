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
    // Resmi Gökyüzü Doktoru ID'leri
    platinumYearId,
    platinumMonthId,
    goldMonthId,
    silverMonthId,

    // Yaygın Gökyüzü Doktoru varyasyonları
    'gokyuzu_vip_platinum',
    'gokyuzu_vip_gold',
    'gokyuzu_vip_silver',
    'gokyuzu_vip',
    'gokyuzu_vip_yearly',
    'gokyuzu_vip_monthly',
    'gokyuzu_vip_year',
    'gokyuzu_vip_month',
    'gokyuzudoktoru_vip',
    'gokyuzudoktoru_vip_yearly',
    'gokyuzudoktoru_vip_monthly',
    'gokyuzudoktoru_platinum',
    'gokyuzudoktoru_gold',
    'gokyuzudoktoru_silver',
    'gokyuzu_platinum_year',
    'gokyuzu_platinum_month',
    'gokyuzu_gold_month',
    'gokyuzu_silver_month',

    // Genel VIP & Abonelik anahtarları
    'vip_yearly',
    'vip_monthly',
    'vip_yillik',
    'vip_aylik',
    'vip_year',
    'vip_month',
    'vip_platinum',
    'vip_gold',
    'vip_silver',
    'vip_platinum_year',
    'vip_platinum_month',
    'vip_gold_month',
    'vip_silver_month',
    'vip_sub',
    'vip_subscription',
    'vip_membership',
    'vip',
    'platinum_year',
    'platinum_month',
    'gold_month',
    'silver_month',
    'platinum',
    'gold',
    'silver',
    'subscription_yearly',
    'subscription_monthly',
    'premium_yearly',
    'premium_monthly',
    'premium',

    // Diğer test projelerindeki referans ID'ler (Rune Yard, Dream Yard vb.)
    'rune_yard_vip',
    'dream_yard_vip',
    'runeyard_vip',
    'dreamyard_vip',

    // Paket adı formatında ID'ler
    'com.gokyuzudoktoru.vip',
    'com.gokyuzudoktoru.gokyuzu_app.vip',
    'com.gokyuzudoktoru.gokyuzu_app.platinum_year',
    'com.gokyuzudoktoru.gokyuzu_app.platinum_month',
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

      _subscription?.cancel();
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseStream,
        onDone: () => _subscription?.cancel(),
        onError: (err) {
          debugPrint('[InAppPurchaseService] Satın alma dinleyici hatası: $err');
        },
      );

      // BillingClient bağlantısını kurana kadar 3 defa dene
      for (int i = 0; i < 3; i++) {
        try {
          isAvailable = await _inAppPurchase.isAvailable();
          if (isAvailable) break;
        } catch (_) {}
        await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
      }

      if (isAvailable) {
        await loadProducts();
      }
    } catch (e) {
      debugPrint('[InAppPurchaseService] Başlatma hatası: $e');
    }
  }

  /// Google Play / App Store'dan ürün fiyat ve detaylarını çeker
  Future<void> loadProducts() async {
    if (kIsWeb) return;
    if (!isAvailable) {
      for (int i = 0; i < 3; i++) {
        try {
          isAvailable = await _inAppPurchase.isAvailable();
          if (isAvailable) break;
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 300));
      }
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
    if (products.isEmpty) return null;

    // 1. Birebir ID eşleşmesi
    for (final p in products) {
      if (p.id == productId) return p;
    }

    // 2. Paket tipine göre alternatif ID eşleşmesi
    final aliases = <String>[];
    if (productId == platinumYearId) {
      aliases.addAll([
        'gokyuzu_vip_platinum_year', 'gokyuzu_vip_yearly', 'gokyuzu_vip_year',
        'vip_yearly', 'vip_yillik', 'vip_year', 'platinum_year', 'vip_platinum_year',
        'gokyuzudoktoru_vip_yearly', 'gokyuzu_vip', 'rune_yard_vip', 'dream_yard_vip', 'vip'
      ]);
    } else if (productId == platinumMonthId) {
      aliases.addAll([
        'gokyuzu_vip_platinum_month', 'gokyuzu_vip_monthly', 'gokyuzu_vip_month',
        'vip_monthly', 'vip_aylik', 'vip_month', 'platinum_month', 'vip_platinum_month',
        'gokyuzudoktoru_vip_monthly', 'gokyuzu_vip', 'rune_yard_vip', 'dream_yard_vip', 'vip'
      ]);
    } else if (productId == goldMonthId) {
      aliases.addAll([
        'gokyuzu_vip_gold_month', 'vip_gold_month', 'gold_month', 'gokyuzu_vip_gold',
        'vip_gold', 'gokyuzu_gold_month', 'vip_monthly', 'gokyuzu_vip'
      ]);
    } else if (productId == silverMonthId) {
      aliases.addAll([
        'gokyuzu_vip_silver_month', 'vip_silver_month', 'silver_month', 'gokyuzu_vip_silver',
        'vip_silver', 'gokyuzu_silver_month', 'vip_monthly', 'gokyuzu_vip'
      ]);
    }

    for (final alias in aliases) {
      for (final p in products) {
        if (p.id == alias) return p;
      }
    }

    // 3. İsimde year / month filtrelemesi
    final isYearlyReq = productId.contains('year') || productId.contains('yillik');
    for (final p in products) {
      final pid = p.id.toLowerCase();
      if (isYearlyReq && (pid.contains('year') || pid.contains('yillik') || pid.contains('12m'))) {
        return p;
      }
      if (!isYearlyReq && (pid.contains('month') || pid.contains('aylik') || pid.contains('1m'))) {
        return p;
      }
    }

    // 4. Eğer Play Console'da en az 1 aktif abonelik tanımlanmışsa (örn. Rune Yard gibi tek VIP abonelik) onu kullan
    return products.first;
  }

  /// Kullanıcı paket seçtiğinde ("Hemen Abone Ol" veya "Seç") doğrudan
  /// YEREL GOOGLE PLAY ÖDEME ALT PENCERESİNİ (BillingClient.launchBillingFlow) başlatır.
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

    // 1. Google Play'den dönen gerçek bir ProductDetails varsa doğrudan satın alma akışını başlat
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
    }

    // 2. Eğer products listesi henüz dönmediyse ama kullanıcı tıkladıysa:
    // Doğrudan hedef productId ile dinamik ProductDetails oluşturup Google Play Billing akışını dene
    try {
      final fallbackProduct = ProductDetails(
        id: productId,
        title: 'Gökyüzü Doktoru VIP',
        description: 'Gökyüzü Doktoru VIP Abonelik Paketi',
        price: '₺',
        rawPrice: 0.0,
        currencyCode: 'TRY',
      );
      final fallbackParam = PurchaseParam(productDetails: fallbackProduct);
      final launched = await _inAppPurchase.buyNonConsumable(purchaseParam: fallbackParam);
      if (launched) return true;
    } catch (e) {
      debugPrint('[InAppPurchaseService] Fallback buyNonConsumable hatası: $e');
    }

    return false;
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
