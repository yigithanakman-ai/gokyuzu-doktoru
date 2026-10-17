import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class ReferralService {
  static const String _keyUsedReferral = 'user_has_redeemed_referral';
  static const String _keyFreePdfGift = 'user_has_free_pdf_gift';
  static const String _keyInvitedCount = 'user_invited_count';
  static const String _keyVipGiftExpiry = 'vip_gift_expiry_timestamp';

  /// Kullanıcıya özel davet kodunu oluşturur
  static String generateReferralCode(UserProfile profile) {
    final cleanName = profile.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final namePart = cleanName.isEmpty ? 'YILDIZ' : (cleanName.length > 6 ? cleanName.substring(0, 6) : cleanName);
    final signPart = profile.sunSign.substring(0, 2).toUpperCase();
    return 'GOK-$namePart-$signPart';
  }

  /// Paylaşım için davet metni
  static String getShareMessage(String code) {
    return '✨ Gökyüzü Yapay Zeka Astroloji uygulamasını indir, davet kodum "$code" ile 10 Sayfalık Kapsamlı Doğum Haritası Raporu hediye kazan! 🪐 https://gokyuzuastroloji.com/app?ref=$code';
  }

  /// Kullanıcının davet kodu girip girmediğini kontrol eder
  static Future<bool> hasRedeemedReferral() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUsedReferral) ?? false;
  }

  /// Kullanıcının ücretsiz PDF hediyesi hakkı olup olmadığını kontrol eder
  static Future<bool> hasFreePdfGift() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFreePdfGift) ?? false;
  }

  /// Davet kodunu uygular (Davet edilen kullanıcıya PDF hediyesi tanımlar)
  static Future<Map<String, dynamic>> redeemCode({
    required String code,
    required UserProfile currentProfile,
  }) async {
    final myCode = generateReferralCode(currentProfile);
    final clean = code.trim().toUpperCase();

    if (clean.isEmpty) {
      return {'success': false, 'message': 'Lütfen geçerli bir davet kodu giriniz.'};
    }

    if (clean == myCode) {
      return {'success': false, 'message': 'Kendi davet kodunuzu kullanamazsınız.'};
    }

    final prefs = await SharedPreferences.getInstance();
    final alreadyRedeemed = prefs.getBool(_keyUsedReferral) ?? false;
    if (alreadyRedeemed) {
      return {'success': false, 'message': 'Daha önce bir davet kodu kullandınız.'};
    }

    // Başarılı kullanım: 10 Sayfalık Doğum Haritası PDF hediyesi tanımla
    await prefs.setBool(_keyUsedReferral, true);
    await prefs.setBool(_keyFreePdfGift, true);

    return {
      'success': true,
      'message': 'Tebrikler! Davet kodu onaylandı. 10 Sayfalık Kapsamlı Doğum Haritası PDF Raporunuz hesabınıza hediye olarak tanımlandı! 🎁',
    };
  }

  /// Bir arkadaş davet edildiğinde davet edene 3 Günlük VIP tanımlar
  static Future<void> recordSuccessfulInvite() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyInvitedCount) ?? 0;
    await prefs.setInt(_keyInvitedCount, count + 1);

    // 3 Günlük VIP süresini uzat veya başlat
    final now = DateTime.now();
    final currentExpiryMs = prefs.getInt(_keyVipGiftExpiry) ?? 0;
    final currentExpiry = DateTime.fromMillisecondsSinceEpoch(currentExpiryMs);

    final baseTime = currentExpiry.isAfter(now) ? currentExpiry : now;
    final newExpiry = baseTime.add(const Duration(days: 3));

    await prefs.setInt(_keyVipGiftExpiry, newExpiry.millisecondsSinceEpoch);
    await StorageService.setVipTier(VipTier.silver);
  }

  /// Toplam davet edilen arkadaş sayısını getirir
  static Future<int> getInvitedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInvitedCount) ?? 0;
  }

  /// Kalan hediye VIP gününü kontrol eder
  static Future<int> getRemainingVipGiftDays() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_keyVipGiftExpiry) ?? 0;
    if (expiryMs == 0) return 0;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    final now = DateTime.now();
    if (expiry.isBefore(now)) return 0;
    return expiry.difference(now).inDays + 1;
  }
}
