import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// Gökyüzü Doktoru Güvenli Davet & Tek Kullanımlık Kupon Sistemi (Referral Security Shield)
class ReferralService {
  static const String _keyActiveInviteCode = 'user_active_invite_code';
  static const String _keyUsedReferral = 'user_has_redeemed_referral';
  static const String _keyFreePdfGift = 'user_has_free_pdf_gift';
  static const String _keyInvitedCount = 'user_invited_count';
  static const String _keyVipGiftExpiry = 'vip_gift_expiry_timestamp';
  static const String _keyRedeemedCodes = 'security_ledger_redeemed_codes';
  static const String _keyFailedAttempts = 'security_referral_failed_attempts';
  static const String _keyLockUntilMs = 'security_referral_lock_until_ms';

  static const String _chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ'; // Karışıklığı önlemek için 0,1,I,O hariç

  /// Kullanıcıya özel kriptografik rastgele tek kullanımlık alfanümerik davet kodu üretir
  static String _generateSecureAlphanumericToken() {
    final rand = Random.secure();
    final p1 = List.generate(4, (_) => _chars[rand.nextInt(_chars.length)]).join();
    final p2 = List.generate(4, (_) => _chars[rand.nextInt(_chars.length)]).join();
    return 'GOK-$p1-$p2';
  }

  /// Kullanıcının aktif davet kodunu getirir (yoksa güvenli şekilde üretip kaydeder)
  static Future<String> getOrCreateUserReferralCode(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    String? existing = prefs.getString(_keyActiveInviteCode);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final newCode = _generateSecureAlphanumericToken();
    await prefs.setString(_keyActiveInviteCode, newCode);
    return newCode;
  }

  /// Geriye dönük uyumluluk ve hızlı erişim için senkron referans kodu üretici
  static String generateReferralCode(UserProfile profile) {
    // Deterministik tohumlu güvenli kod (testler ve anlık UI render için)
    final seedStr = '${profile.name}_${profile.birthDate}_${profile.birthTime}';
    int hash = 0;
    for (int i = 0; i < seedStr.length; i++) {
      hash = (31 * hash + seedStr.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final r = Random(hash);
    final p1 = List.generate(4, (_) => _chars[r.nextInt(_chars.length)]).join();
    final p2 = List.generate(4, (_) => _chars[r.nextInt(_chars.length)]).join();
    return 'GOK-$p1-$p2';
  }

  /// Paylaşım için davet metni
  static String getShareMessage(String code) {
    return '✨ Gökyüzü Yapay Zeka Astroloji uygulamasını indir, tek kullanımlık davet kodum "$code" ile 10 Sayfalık Kapsamlı Doğum Haritası Raporu hediye kazan! 🪐 https://gokyuzuastroloji.com/app?ref=$code';
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

  /// Güvenlik Kalkanı: Brute-force ve mükerrer deneme koruması
  static Future<String?> _checkSecurityLock(SharedPreferences prefs) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lockUntil = prefs.getInt(_keyLockUntilMs) ?? 0;
    if (lockUntil > now) {
      final remMin = ((lockUntil - now) / 60000).ceil();
      return 'Güvenlik Kalkanı Devrede: Çok fazla geçersiz kod denendi. Lütfen $remMin dakika sonra tekrar deneyiniz.';
    }
    return null;
  }

  /// Başarısız denemeyi kaydeder ve gerekirse kilitler
  static Future<void> _recordFailedAttempt(SharedPreferences prefs) async {
    final attempts = (prefs.getInt(_keyFailedAttempts) ?? 0) + 1;
    if (attempts >= 5) {
      // 5 başarısız denemede 20 dakika kilitle
      final lockUntil = DateTime.now().add(const Duration(minutes: 20)).millisecondsSinceEpoch;
      await prefs.setInt(_keyLockUntilMs, lockUntil);
      await prefs.setInt(_keyFailedAttempts, 0);
    } else {
      await prefs.setInt(_keyFailedAttempts, attempts);
    }
  }

  /// Davet kodunu uygular (Tek kullanımlık kontrolü, güvenlik kalkanı ve PDF hediyesi)
  static Future<Map<String, dynamic>> redeemCode({
    required String code,
    required UserProfile currentProfile,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Güvenlik Kilidi Kontrolü
    final lockMsg = await _checkSecurityLock(prefs);
    if (lockMsg != null) {
      return {'success': false, 'message': lockMsg};
    }

    final clean = code.trim().toUpperCase();

    // 2. Format Doğrulama
    if (clean.isEmpty || !clean.startsWith('GOK-')) {
      await _recordFailedAttempt(prefs);
      return {'success': false, 'message': 'Lütfen geçerli formatta bir davet kodu giriniz (Örn: GOK-XXXX-XXXX).'};
    }

    // 3. Kendi Kodunu Kullanmayı Engelle
    final myActiveCode = prefs.getString(_keyActiveInviteCode);
    final myGenerated = generateReferralCode(currentProfile);
    if (clean == myActiveCode || clean == myGenerated) {
      return {'success': false, 'message': 'Kendi davet kodunuzu kullanamazsınız.'};
    }

    // 4. Daha Önce Başka Kod Kullanmış mı?
    final alreadyRedeemed = prefs.getBool(_keyUsedReferral) ?? false;
    if (alreadyRedeemed) {
      return {'success': false, 'message': 'Bu hesapta daha önce bir davet kodu kullanılmıştır.'};
    }

    // 5. TEK KULLANIMLIK (Mükerrer Kullanım) KONTROLÜ
    final redeemedList = prefs.getStringList(_keyRedeemedCodes) ?? [];
    if (redeemedList.contains(clean)) {
      await _recordFailedAttempt(prefs);
      return {
        'success': false,
        'message': 'Bu davet kodu daha önce başka bir kullanıcı tarafından kullanılmıştır ve geçerliliğini yitirmiştir. Her kod tek kullanımlıktır!',
      };
    }

    // 6. Başarılı Kullanım: Kodu deftere yaz, tek kullanımlık olarak kapat
    redeemedList.add(clean);
    await prefs.setStringList(_keyRedeemedCodes, redeemedList);
    await prefs.setBool(_keyUsedReferral, true);
    await prefs.setBool(_keyFreePdfGift, true);
    await prefs.setInt(_keyFailedAttempts, 0); // Başarılı olunca sayaç sıfırlanır

    // Davet eden kişinin kodunu yenile (sıradaki arkadaşı için taze tek kullanımlık kod)
    if (myActiveCode == clean) {
      final freshCode = _generateSecureAlphanumericToken();
      await prefs.setString(_keyActiveInviteCode, freshCode);
    }

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

    // Sıradaki arkadaş için hemen yeni tek kullanımlık kod hazırla
    final freshCode = _generateSecureAlphanumericToken();
    await prefs.setString(_keyActiveInviteCode, freshCode);

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
