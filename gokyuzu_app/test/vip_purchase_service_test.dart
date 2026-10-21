import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gokyuzu_app/data/services/in_app_purchase_service.dart';
import 'package:gokyuzu_app/data/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('InAppPurchaseService Tests', () {
    test('Official product IDs are properly defined', () {
      expect(InAppPurchaseService.platinumYearId, 'gokyuzu_vip_platinum_year');
      expect(InAppPurchaseService.platinumMonthId, 'gokyuzu_vip_platinum_month');
      expect(InAppPurchaseService.goldMonthId, 'gokyuzu_vip_gold_month');
      expect(InAppPurchaseService.silverMonthId, 'gokyuzu_vip_silver_month');
      expect(InAppPurchaseService.productIds.length, 4);
    });

    test('VIP Tier storage and activation works for admin master code', () async {
      // By default, not VIP
      final initialVip = await StorageService.isVip();
      expect(initialVip, false);

      // Patron admin code unlocks platinum
      final activated = await StorageService.activateVipCode('gkyz2453');
      expect(activated, true);

      final isVipNow = await StorageService.isVip();
      expect(isVipNow, true);

      final tier = await StorageService.getVipTier();
      expect(tier, VipTier.platinum);
    });

    test('Invalid admin code does not unlock VIP', () async {
      final activated = await StorageService.activateVipCode('yanlis_kod_123');
      expect(activated, false);

      final isVip = await StorageService.isVip();
      expect(isVip, false);
    });
  });
}
