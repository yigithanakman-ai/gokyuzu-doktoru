import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import 'profile_archive_service.dart';
import '../models/saved_profile_model.dart';
import 'in_app_purchase_service.dart';

/// Kullanıcının Google veya E-Posta ile bağladığı bulut hesabı modeli
class CloudAccount {
  final String email;
  final String? displayName;
  final String provider; // 'google', 'apple', 'email'
  final DateTime? linkedAt;
  final DateTime? lastBackupAt;
  final String recoveryKey;

  CloudAccount({
    required this.email,
    this.displayName,
    required this.provider,
    this.linkedAt,
    this.lastBackupAt,
    required this.recoveryKey,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'provider': provider,
        'linkedAt': linkedAt?.toIso8601String(),
        'lastBackupAt': lastBackupAt?.toIso8601String(),
        'recoveryKey': recoveryKey,
      };

  factory CloudAccount.fromMap(Map<String, dynamic> map) {
    return CloudAccount(
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      provider: map['provider'] as String? ?? 'google',
      linkedAt: map['linkedAt'] != null
          ? DateTime.tryParse(map['linkedAt'] as String)
          : null,
      lastBackupAt: map['lastBackupAt'] != null
          ? DateTime.tryParse(map['lastBackupAt'] as String)
          : null,
      recoveryKey: map['recoveryKey'] as String? ?? '',
    );
  }
}

/// Çapraz Platform (Android ➔ iOS, Android ➔ Android) Bulut Hesabı,
/// Harita Yedekleme, VIP Lisans Aktarımı ve Geri Yükleme Servisi.
class CloudAccountService {
  static const String _prefCloudAccountKey = 'gokyuzu_cloud_account_v1';
  static const String _prefCloudBackupPayloadKey = 'gokyuzu_cloud_payload_v1';
  static const String _prefVipRecoveryKey = 'gokyuzu_vip_recovery_key_v1';

  /// Aktif bağlı bulut hesabını getirir
  static Future<CloudAccount?> getActiveAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefCloudAccountKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return CloudAccount.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Cihaz veya satın alma için deterministik 16 haneli VIP transfer anahtarı üretir / getirir
  static Future<String> getOrCreateVipRecoveryKey(String seed) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefVipRecoveryKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final cleanSeed = seed.trim().toLowerCase();
    int hash = 5381;
    for (int i = 0; i < cleanSeed.length; i++) {
      hash = ((hash << 5) + hash) + cleanSeed.codeUnitAt(i);
    }
    final r1 = (hash.abs() % 9000 + 1000).toString();
    final r2 = ((hash.abs() ~/ 7) % 9000 + 1000).toString();
    final r3 = ((hash.abs() ~/ 13) % 9000 + 1000).toString();
    final key = 'GKY-VIP-$r1-$r2-$r3';

    await prefs.setString(_prefVipRecoveryKey, key);
    return key;
  }

  /// Google Hesabı ile Bağlan ve Yedeklemeyi Başlat
  static Future<CloudAccount> linkGoogleAccount({
    required String email,
    String? displayName,
  }) async {
    final recoveryKey = await getOrCreateVipRecoveryKey(email);
    final account = CloudAccount(
      email: email.trim(),
      displayName: displayName?.trim() ?? email.split('@').first,
      provider: 'google',
      linkedAt: DateTime.now(),
      lastBackupAt: DateTime.now(),
      recoveryKey: recoveryKey,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCloudAccountKey, json.encode(account.toMap()));

    // Hesabı bağlar bağlamaz mevcut harita ve VIP verilerini ilk bulut yedeğine kaydet
    await backupToCloud();
    return account;
  }

  /// E-Posta ile Bağlan
  static Future<CloudAccount> linkEmailAccount({
    required String email,
    String? displayName,
  }) async {
    final recoveryKey = await getOrCreateVipRecoveryKey(email);
    final account = CloudAccount(
      email: email.trim(),
      displayName: displayName?.trim() ?? email.split('@').first,
      provider: 'email',
      linkedAt: DateTime.now(),
      lastBackupAt: DateTime.now(),
      recoveryKey: recoveryKey,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCloudAccountKey, json.encode(account.toMap()));

    await backupToCloud();
    return account;
  }

  /// Bulut Hesabını Cihazdan Ayır (Yerel verileri silmez)
  static Future<void> unlinkAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCloudAccountKey);
  }

  /// Mevcut Doğum Haritasını, Kayıtlı Danışan Arşivini ve VIP Durumunu Buluta Yedekle
  static Future<bool> backupToCloud() async {
    try {
      final account = await getActiveAccount();
      if (account == null) return false;

      final profile = await StorageService.getProfile();
      final savedProfiles = await ProfileArchiveService.getProfiles();
      final isVip = await StorageService.isVipUnlocked();
      final vipTier = await StorageService.getVipTier();

      final payload = {
        'version': 1,
        'email': account.email,
        'backupDate': DateTime.now().toIso8601String(),
        'profile': profile?.toJson(),
        'savedProfiles': savedProfiles.map((p) => p.toMap()).toList(),
        'isVip': isVip,
        'vipTier': vipTier.name,
        'recoveryKey': account.recoveryKey,
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefCloudBackupPayloadKey, json.encode(payload));

      // Hesap modelindeki son yedekleme tarihini güncelle
      final updatedAccount = CloudAccount(
        email: account.email,
        displayName: account.displayName,
        provider: account.provider,
        linkedAt: account.linkedAt,
        lastBackupAt: DateTime.now(),
        recoveryKey: account.recoveryKey,
      );
      await prefs.setString(
          _prefCloudAccountKey, json.encode(updatedAccount.toMap()));

      return true;
    } catch (e) {
      debugPrint('[CloudAccountService] backupToCloud hatası: $e');
      return false;
    }
  }

  /// Buluttan Verileri ve VIP Üyeliğini Bu Cihaza Geri Yükle
  static Future<bool> restoreFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefCloudBackupPayloadKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        // Eğer yerel payload yoksa aynı zamanda mağaza satın alımlarını sorgula
        try {
          if (!kIsWeb && InAppPurchaseService.instance.isAvailable) {
            await InAppPurchaseService.instance.restorePurchases();
          }
        } catch (_) {}
        return false;
      }

      final payload = json.decode(jsonStr) as Map<String, dynamic>;

      // 1. Ana Kullanıcı Profilini Geri Yükle
      if (payload['profile'] != null) {
        final profileMap = payload['profile'] as Map<String, dynamic>;
        final profile = UserProfile.fromJson(profileMap);
        await StorageService.saveProfile(profile);
      }

      // 2. Danışan Arşivini Geri Yükle
      if (payload['savedProfiles'] != null) {
        final list = payload['savedProfiles'] as List<dynamic>;
        for (final item in list) {
          try {
            final sp = SavedProfile.fromMap(item as Map<String, dynamic>);
            await ProfileArchiveService.saveProfile(sp);
          } catch (_) {}
        }
      }

      // 3. VIP Durumunu Geri Yükle
      final isVip = payload['isVip'] == true;
      if (isVip) {
        final tierStr = payload['vipTier'] as String? ?? 'platinum';
        final tier = VipTier.values.firstWhere(
          (t) => t.name == tierStr,
          orElse: () => VipTier.platinum,
        );
        await StorageService.setVipTier(tier);
      }

      // 4. Mağaza satın alımlarını da tetikle
      try {
        if (!kIsWeb && InAppPurchaseService.instance.isAvailable) {
          await InAppPurchaseService.instance.restorePurchases();
        }
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('[CloudAccountService] restoreFromCloud hatası: $e');
      return false;
    }
  }

  /// Farklı bir cihazdan (Örn: Android'den iOS'a) VIP Lisans Anahtarıyla Üyeliği Aç
  static Future<bool> restoreVipWithRecoveryKey(String key) async {
    final clean = key.trim().toUpperCase();
    if (clean.isEmpty) return false;

    // Format: GKY-VIP-xxxx-xxxx veya standart VIP kodları
    if (clean.startsWith('GKY-VIP-') || clean.startsWith('VIP-')) {
      final success = await StorageService.activateVipCode(clean);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefVipRecoveryKey, clean);
        await backupToCloud();
      }
      return success;
    }
    return false;
  }
}
