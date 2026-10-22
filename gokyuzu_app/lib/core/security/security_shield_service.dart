import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Gökyüzü Doktoru — Siber Güvenlik, Anti-Tamper & API Koruma Kalkanı
class SecurityShieldService {
  static const String _prefDailyCountKey = 'sec_api_daily_count';
  static const String _prefDailyDateKey = 'sec_api_daily_date';
  static const String _prefMonthlyCountKey = 'sec_api_monthly_count';
  static const String _prefMonthlyMonthKey = 'sec_api_monthly_month';

  // Standart Güvenlik Sınırları (Sıradan kullanıcı asla takılmaz, bot/kötü niyetli istekler anında engellenir)
  static const int defaultDailyQuota = 50;
  static const int defaultMonthlyQuota = 350;

  /// Şifrelenmiş (XOR Maskeli) API Uç Noktalarını bellekte dinamik çözer
  /// Böylece tersine mühendislikle APK içi string taramasında ("http", "api" vb.) uç noktalar görünmez.
  static String resolveMaskedEndpoint(List<int> bytes, int maskKey) {
    final decoded = List<int>.generate(bytes.length, (i) => bytes[i] ^ maskKey);
    return utf8.decode(decoded);
  }

  /// Aylık ve Günlük API İstek Kotası Kontrolü (Rate Limiter)
  /// Cihaz başı aylık kotayı aşan kötü niyetli veya otomatik istekleri engeller.
  static Future<bool> canMakeApiRequest({
    int maxDaily = defaultDailyQuota,
    int maxMonthly = defaultMonthlyQuota,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final currentMonthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      // Günlük kontrol
      final lastDate = prefs.getString(_prefDailyDateKey) ?? '';
      int dailyCount = prefs.getInt(_prefDailyCountKey) ?? 0;
      if (lastDate != todayStr) {
        dailyCount = 0;
        await prefs.setString(_prefDailyDateKey, todayStr);
      }

      // Aylık kontrol
      final lastMonth = prefs.getString(_prefMonthlyMonthKey) ?? '';
      int monthlyCount = prefs.getInt(_prefMonthlyCountKey) ?? 0;
      if (lastMonth != currentMonthStr) {
        monthlyCount = 0;
        await prefs.setString(_prefMonthlyMonthKey, currentMonthStr);
      }

      if (dailyCount >= maxDaily || monthlyCount >= maxMonthly) {
        return false; // Kota aşıldı
      }

      // Kotayı artır ve kaydet
      await prefs.setInt(_prefDailyCountKey, dailyCount + 1);
      await prefs.setInt(_prefMonthlyCountKey, monthlyCount + 1);
      return true;
    } catch (_) {
      // Hata anında güvenli tarafta kalıp izin ver
      return true;
    }
  }

  /// Uygulama bütünlük ve paket doğrulama kontrolü (Anti-Clone)
  static bool verifyAppIntegrity(String currentPackageName) {
    const validPackage = 'com.gokyuzudoktoru.gokyuzu_app';
    return currentPackageName == validPackage;
  }
}
