import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'storage_service.dart';

class InAppPurchaseService {
  static final InAppPurchaseService instance = InAppPurchaseService._internal();
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
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

  bool isAvailable = false;
  List<ProductDetails> products = [];
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
    if (!isAvailable) return;
    isLoading = true;
    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);
      if (response.error != null) {
        errorMessage = response.error!.message;
        debugPrint('[InAppPurchaseService] Ürün sorgulama hatası: $errorMessage');
      }
      products = response.productDetails;
      debugPrint('[InAppPurchaseService] ${products.length} adet mağaza ürünü yüklendi.');
    } catch (e) {
      debugPrint('[InAppPurchaseService] loadProducts hatası: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Kullanıcı paket seçtiğinde doğrudan mağaza içi satın alma oturumunu başlatır
  Future<bool> buySubscription(String productId, VipTier tier) async {
    if (!isAvailable) {
      await openStoreSubscriptionPage();
      return false;
    }

    ProductDetails? matchingProduct;
    for (final p in products) {
      if (p.id == productId) {
        matchingProduct = p;
        break;
      }
    }

    if (matchingProduct == null) {
      await loadProducts();
      for (final p in products) {
        if (p.id == productId) {
          matchingProduct = p;
          break;
        }
      }
    }

    if (matchingProduct != null) {
      final purchaseParam = PurchaseParam(productDetails: matchingProduct);
      return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Eğer Google Play Console'da ürünler henüz onay aşamasındaysa veya taslaktaysa,
      // doğrudan mağaza resmi abonelikler sekmesini aç
      await openStoreSubscriptionPage();
      return false;
    }
  }

  /// Satın alımları geri yükleme (App Store ve Google Play gereksinimi)
  Future<void> restorePurchases() async {
    if (!isAvailable) return;
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('[InAppPurchaseService] restorePurchases hatası: $e');
    }
  }

  /// Mağazanın resmi abonelik yönetim sayfasına yönlendirir
  static Future<void> openStoreSubscriptionPage() async {
    final url = Platform.isIOS
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions?package=com.gokyuzudoktoru.gokyuzu_app';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[InAppPurchaseService] openStoreSubscriptionPage hatası: $e');
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
      debugPrint('[InAppPurchaseService] Satın alma hatası: ${purchase.error}');
    } else if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final tier = _mapProductIdToTier(purchase.productID);
      await StorageService.setVipTier(tier);
      _purchaseCompletedController.add(tier);

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  VipTier _mapProductIdToTier(String productId) {
    switch (productId) {
      case platinumYearId:
      case platinumMonthId:
        return VipTier.platinum;
      case goldMonthId:
        return VipTier.gold;
      case silverMonthId:
        return VipTier.silver;
      default:
        return VipTier.platinum;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseCompletedController.close();
  }
}
