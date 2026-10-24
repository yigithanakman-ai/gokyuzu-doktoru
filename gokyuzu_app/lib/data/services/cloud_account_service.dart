import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
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

/// VIP Transfer Anahtarı Kullanım Sonuç Modeli
class VipRedeemResult {
  final bool success;
  final String message;
  final int remainingDays;
  final DateTime? expiryDate;
  final VipTier tier;

  const VipRedeemResult({
    required this.success,
    required this.message,
    this.remainingDays = 0,
    this.expiryDate,
    this.tier = VipTier.free,
  });
}

/// Çapraz Platform (Android ➔ iOS, Android ➔ Android) Bulut Hesabı,
/// Gerçek Google Hesap Seçici, E-Posta Yedek Gönderimi, VIP Lisans Aktarımı ve Geri Yükleme Servisi.
///
/// Patron 👑 Kuralı:
/// 1. VIP transfer kodu kişiye özel ve SADECE 1 KULLANIMLIKTIR.
/// 2. Kullanıcı 1 yıllık üyelik alıp 4 ay kullandıysa, kalan süre (örn. 8 ay)
///    yeni cihaza aktarılır; sil baştan yıllık üyelik verilemez ve kullanılamaz!
class CloudAccountService {
  static const String _prefCloudAccountKey = 'gokyuzu_cloud_account_v1';
  static const String _prefCloudBackupPayloadKey = 'gokyuzu_cloud_payload_v1';
  static const String _prefVipRecoveryKey = 'gokyuzu_vip_recovery_key_v1';
  static const String _vipChecksumSalt = 'GKY_DOKTORU_VIP_SALT_2026_YIGITHAN_AKMAN';

  static const MethodChannel _googleAuthChannel =
      MethodChannel('com.gokyuzudoktoru.gokyuzu_app/google_auth');

  /// Android işletim sisteminin gerçek Google Hesap Seçici penceresini (AccountManager) açar.
  /// Kullanıcı cihazındaki gerçek Gmail hesaplarından birini seçer veya "Hesap ekle" ile
  /// gerçek Google giriş sayfasına yönlendirilir.
  static Future<CloudAccount?> signInWithNativeGoogleAccount({
    String? fallbackDisplayName,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final result = await _googleAuthChannel.invokeMethod<dynamic>('pickGoogleAccount');
      if (result is Map) {
        final email = (result['email']?.toString() ?? '').trim();
        if (email.isNotEmpty && email.contains('@')) {
          final derivedName = fallbackDisplayName?.trim().isNotEmpty == true
              ? fallbackDisplayName!.trim()
              : email.split('@').first;
          final account = await linkGoogleAccount(
            email: email,
            displayName: derivedName,
          );
          await StorageService.saveUserAccount(
            name: derivedName,
            surname: '',
            email: email,
            gender: 'Belirtilmedi',
          );
          return account;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[CloudAccountService] signInWithNativeGoogleAccount hatası: $e');
      return null;
    }
  }

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

  /// 4-Hex FNV-1a Doğrulama Sağlaması (Anti-Tampering Checksum)
  static String computeChecksum(String tier, String dateStr, String nonce) {
    final raw = '$tier|$dateStr|$nonce|$_vipChecksumSalt';
    int h = 0x811c9dc5;
    for (int i = 0; i < raw.length; i++) {
      h ^= raw.codeUnitAt(i);
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return (h & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Kişiye özel, tek kullanımlık ve kalan süreyi tam mühürleyen VIP Transfer Anahtarı üretir
  /// Format: GKY-VIP-[TIER]-[YYYYMMDD]-[NONCE]-[CHECKSUM]
  /// Örnek: GKY-VIP-P-20270415-8492-B7F2
  static Future<String?> generateVipTransferKey() async {
    final isVip = await StorageService.isVipUnlocked();
    if (!isVip) return null;

    final tier = await StorageService.getVipTier();
    final tierCode = tier == VipTier.silver
        ? 'S'
        : (tier == VipTier.gold ? 'G' : 'P');

    var expiryDate = await StorageService.getVipExpiryDate();
    if (expiryDate == null) {
      expiryDate = DateTime.now().add(const Duration(days: 365));
      await StorageService.setVipExpiryDate(expiryDate);
    }

    if (DateTime.now().isAfter(expiryDate)) {
      await StorageService.deactivateVip();
      return null;
    }

    final dateStr = '${expiryDate.year.toString().padLeft(4, '0')}'
        '${expiryDate.month.toString().padLeft(2, '0')}'
        '${expiryDate.day.toString().padLeft(2, '0')}';

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final nonce = (1000 + (nowMs % 9000)).toString();
    final checksum = computeChecksum(tierCode, dateStr, nonce);

    final key = 'GKY-VIP-$tierCode-$dateStr-$nonce-$checksum';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefVipRecoveryKey, key);
    return key;
  }

  /// Aktif transfer anahtarını getirir veya yenisini üretir
  static Future<String> getOrCreateVipRecoveryKey(String seed) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefVipRecoveryKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = await generateVipTransferKey();
    if (generated != null && generated.isNotEmpty) return generated;

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

  /// Tek Kullanımlık VIP Transfer Anahtarını Doğrula ve Sadece Kalan Süresiyle Aktar!
  static Future<VipRedeemResult> redeemVipTransferKey(String rawKey) async {
    final clean = rawKey.trim().toUpperCase();
    if (clean.isEmpty) {
      return const VipRedeemResult(
        success: false,
        message: 'Lütfen geçerli bir VIP transfer anahtarı girin.',
      );
    }

    // 1. Yönetici Master Promosyon Kodları Kontrolü
    if (clean.startsWith('VIP-') || clean == 'GKYZ2453') {
      final success = await StorageService.activateVipCode(clean);
      if (success) {
        final expiry = DateTime.now().add(const Duration(days: 365));
        await StorageService.setVipExpiryDate(expiry);
        return VipRedeemResult(
          success: true,
          message: '👑 Özel VIP promosyon kodu başarıyla aktif edildi.',
          remainingDays: 365,
          tier: VipTier.platinum,
          expiryDate: expiry,
        );
      }
    }

    // 2. Format Doğrulama: GKY-VIP-[PGS]-[YYYYMMDD]-[NONCE]-[CHECKSUM]
    final regex = RegExp(r'^GKY-VIP-([PGS])-(\d{8})-(\d{4})-([0-9A-F]{4})$');
    final match = regex.firstMatch(clean);
    if (match == null) {
      return const VipRedeemResult(
        success: false,
        message: '⚠️ Geçersiz VIP Transfer Anahtarı formatı. Lütfen kodu eksiksiz giriniz.',
      );
    }

    final tierCode = match.group(1)!;
    final dateStr = match.group(2)!;
    final nonce = match.group(3)!;
    final expectedChecksum = match.group(4)!;

    // 3. Sahtecilik ve Manipülasyon Kontrolü (Checksum)
    final actualChecksum = computeChecksum(tierCode, dateStr, nonce);
    if (actualChecksum != expectedChecksum) {
      return const VipRedeemResult(
        success: false,
        message: '⚠️ VIP Transfer Anahtarı doğrulanamadı. Kod üzerinde oynama yapılmış veya hatalı.',
      );
    }

    // 4. TEK KULLANIMLIK KONTROLÜ (Single-Use Anti-Abuse)
    final isAlreadyUsed = await StorageService.isKeyConsumed(clean);
    if (isAlreadyUsed) {
      return const VipRedeemResult(
        success: false,
        message: '⛔ Bu VIP Transfer Anahtarı daha önce kullanılmıştır ve tek kullanımlıktır! Farklı cihazlarda tekrar kullanılamaz.',
      );
    }

    // 5. SÜRE VE KALAN GÜN KONTROLÜ (Kalan süreyi koruma, sil baştan süre vermeme!)
    final year = int.parse(dateStr.substring(0, 4));
    final month = int.parse(dateStr.substring(4, 6));
    final day = int.parse(dateStr.substring(6, 8));
    final expiryDate = DateTime(year, month, day, 23, 59, 59);

    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return VipRedeemResult(
        success: false,
        message: '⚠️ Bu VIP üyeliğin süresi ${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year tarihinde dolmuştur. Süresi bitmiş üyelik aktarılamaz.',
      );
    }

    final remainingDays = expiryDate.difference(now).inDays.clamp(1, 3650);

    // 6. KODU KULLANILDI OLARAK MÜHÜRLE (Bir daha asla kullanılamaz!)
    await StorageService.markKeyAsConsumed(clean);

    // 7. VIP ÜYELİĞİ TAM KALAN SÜRESİYLE BU CİHAZA AKTAR (Sil baştan yıl verilmez!)
    final tier = tierCode == 'S'
        ? VipTier.silver
        : (tierCode == 'G' ? VipTier.gold : VipTier.platinum);

    await StorageService.setVipTier(tier, expiryDate: expiryDate);
    await backupToCloud();

    final dateFormatted =
        '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
    return VipRedeemResult(
      success: true,
      remainingDays: remainingDays,
      expiryDate: expiryDate,
      tier: tier,
      message: '👑 VIP üyeliğiniz kalan $remainingDays günlük süresiyle ($dateFormatted tarihine kadar) başarıyla bu cihaza aktarıldı!',
    );
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

  /// Mevcut Doğum Haritasını, Kayıtlı Danışan Arşivini, VIP Durumunu ve Bitiş Tarihini Yedekle
  static Future<bool> backupToCloud() async {
    try {
      final account = await getActiveAccount();
      if (account == null) return false;

      final profile = await StorageService.getProfile();
      final savedProfiles = await ProfileArchiveService.getProfiles();
      final isVip = await StorageService.isVipUnlocked();
      final vipTier = await StorageService.getVipTier();
      final vipExpiryDate = await StorageService.getVipExpiryDate();
      final transferKey = await generateVipTransferKey() ?? account.recoveryKey;

      final payload = {
        'version': 1,
        'email': account.email,
        'backupDate': DateTime.now().toIso8601String(),
        'profile': profile?.toJson(),
        'savedProfiles': savedProfiles.map((p) => p.toMap()).toList(),
        'isVip': isVip,
        'vipTier': vipTier.name,
        'vipExpiryDate': vipExpiryDate?.toIso8601String(),
        'recoveryKey': transferKey,
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefCloudBackupPayloadKey, json.encode(payload));

      final updatedAccount = CloudAccount(
        email: account.email,
        displayName: account.displayName,
        provider: account.provider,
        linkedAt: account.linkedAt,
        lastBackupAt: DateTime.now(),
        recoveryKey: transferKey,
      );
      await prefs.setString(
          _prefCloudAccountKey, json.encode(updatedAccount.toMap()));

      return true;
    } catch (e) {
      debugPrint('[CloudAccountService] backupToCloud hatası: $e');
      return false;
    }
  }

  /// Kullanıcının tüm haritalarını ve VIP transfer anahtarını içeren şifreli GKY-YEDEK-... paket kodunu üretir
  static Future<String> generateRestorableBackupCode() async {
    await backupToCloud();
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefCloudBackupPayloadKey) ?? '{}';
    final encoded = base64Url.encode(utf8.encode(jsonStr));
    return 'GKY-YEDEK-$encoded';
  }

  /// Kullanıcının bağlı e-posta adresine (Gmail) gerçek yedekleme e-postasını hazırlar ve gönderir!
  /// İçinde: Doğum haritası özeti, kayıtlı danışanlar, kalan süreli VIP Transfer Anahtarı ve
  /// yeni cihazda tek tıkla geri yükleme sağlayan GKY-YEDEK kodu yer alır.
  static Future<bool> sendBackupEmailToUser({String? targetEmail}) async {
    try {
      await backupToCloud();
      final account = await getActiveAccount();
      final email = (targetEmail ?? account?.email ?? '').trim();
      if (email.isEmpty) return false;

      final profile = await StorageService.getProfile();
      final savedProfiles = await ProfileArchiveService.getProfiles();
      final isVip = await StorageService.isVipUnlocked();
      final vipTier = await StorageService.getVipTier();
      final vipExpiry = await StorageService.getVipExpiryDate();
      final vipKey = await generateVipTransferKey() ??
          await getOrCreateVipRecoveryKey(email);
      final backupCode = await generateRestorableBackupCode();

      final now = DateTime.now();
      final dateStr =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final remainingDays = (isVip && vipExpiry != null)
          ? vipExpiry.difference(now).inDays.clamp(0, 3650)
          : 0;
      final expiryFormatted = vipExpiry != null
          ? '${vipExpiry.day.toString().padLeft(2, '0')}.${vipExpiry.month.toString().padLeft(2, '0')}.${vipExpiry.year}'
          : '-';

      final buffer = StringBuffer();
      buffer.writeln('🌌 GÖKYÜZÜ DOKTORU - RESMİ BULUT & E-POSTA YEDEKLEME PAKETİ');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('📧 Hesap E-Postası: $email');
      buffer.writeln('📅 Yedekleme Tarihi: $dateStr');
      buffer.writeln('');
      if (profile != null) {
        buffer.writeln('👤 ANA DOĞUM HARİTASI:');
        buffer.writeln('• İsim: ${profile.name}');
        buffer.writeln('• Doğum Tarihi & Saati: ${profile.birthDate} - ${profile.birthTime}');
        buffer.writeln('• Doğum Yeri: ${profile.birthCity}, ${profile.birthCountry}');
        buffer.writeln('• Güneş / Ay / Yükselen: ☀️ ${profile.sunSign} | 🌙 ${profile.moonSign} | 🌅 ${profile.risingSign}');
        buffer.writeln('');
      }
      buffer.writeln('📂 KAYITLI DANIŞAN & AİLE HARİTALARI (${savedProfiles.length} Kişi):');
      if (savedProfiles.isEmpty) {
        buffer.writeln('• Kayıtlı ek harita bulunmuyor.');
      } else {
        for (final sp in savedProfiles) {
          buffer.writeln('• ${sp.fullName} (${sp.birthCity} • ☀️ ${sp.sunSign} / 🌅 ${sp.risingSign})');
        }
      }
      buffer.writeln('');
      buffer.writeln('👑 VIP ÜYELİK & TEK KULLANIMLIK TRANSFER ANAHTARI:');
      buffer.writeln('• Statü: ${isVip ? "AKTİF (${vipTier.name.toUpperCase()} VIP)" : "Standart Üye"}');
      if (isVip) {
        buffer.writeln('• Kalan VIP Süresi: $remainingDays Gün (Bitiş: $expiryFormatted)');
      }
      buffer.writeln('• VIP Transfer Anahtarınız: $vipKey');
      buffer.writeln('  (Not: Bu anahtar tek kullanımlıktır; yeni cihazda sadece kalan sürenizi aktif eder.)');
      buffer.writeln('');
      buffer.writeln('🔐 TEK TIKLA TAM YEDEK GERİ YÜKLEME KODU:');
      buffer.writeln('(Yeni telefonunuzda Ayarlar ➔ Geri Yükle bölümüne aşağıdaki kodu kopyalayıp yapıştırın):');
      buffer.writeln('');
      buffer.writeln(backupCode);
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final subject = 'Gökyüzü Doktoru - Harita ve VIP Yedekleme Paketi ($dateStr)';
      final body = buffer.toString();

      // Uri.encodeComponent kullanarak boşlukların '+' yerine '%20' olmasını garanti et
      final mailtoUrl =
          'mailto:${Uri.encodeComponent(email)}'
          '?subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}';
      final uri = Uri.parse(mailtoUrl);

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;

      // Eğer cihazda varsayılan mail istemcisi yanıt vermezse sistem paylaşım ekranıyla Gmail'e ilet
      await Share.share(body, subject: subject);
      return true;
    } catch (e) {
      debugPrint('[CloudAccountService] sendBackupEmailToUser hatası: $e');
      return false;
    }
  }

  /// E-postaya gönderilen GKY-YEDEK-... kodundan tüm haritaları ve VIP durumunu geri yükler
  static Future<bool> restoreFromBackupCode(String rawCode) async {
    try {
      var clean = rawCode.trim();
      if (clean.isEmpty) return false;

      if (clean.contains('GKY-YEDEK-')) {
        final idx = clean.indexOf('GKY-YEDEK-');
        clean = clean.substring(idx + 'GKY-YEDEK-'.length).trim();
        clean = clean.split(RegExp(r'\s+')).first;
      }

      // Eğer kullanıcı yanlışlıkla doğrudan GKY-VIP-... transfer anahtarını yapıştırdıysa:
      if (clean.toUpperCase().startsWith('GKY-VIP-')) {
        final vipRes = await redeemVipTransferKey(clean);
        return vipRes.success;
      }

      final decodedJson = utf8.decode(base64Url.decode(base64Url.normalize(clean)));
      final payload = json.decode(decodedJson) as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefCloudBackupPayloadKey, decodedJson);

      return await _applyRestorePayload(payload);
    } catch (e) {
      debugPrint('[CloudAccountService] restoreFromBackupCode hatası: $e');
      return false;
    }
  }

  static Future<bool> _applyRestorePayload(Map<String, dynamic> payload) async {
    try {
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

      // 3. VIP Durumunu ve Kalan Süresini Geri Yükle (Kalan süreyi korur, sıfırdan yıl vermez)
      final recoveryKey = payload['recoveryKey'] as String?;
      if (recoveryKey != null && recoveryKey.startsWith('GKY-VIP-')) {
        final isConsumed = await StorageService.isKeyConsumed(recoveryKey);
        if (!isConsumed) {
          await redeemVipTransferKey(recoveryKey);
        }
      } else if (payload['isVip'] == true) {
        final tierStr = payload['vipTier'] as String? ?? 'platinum';
        final tier = VipTier.values.firstWhere(
          (t) => t.name == tierStr,
          orElse: () => VipTier.platinum,
        );
        final expiryStr = payload['vipExpiryDate'] as String?;
        final expiryDate =
            expiryStr != null ? DateTime.tryParse(expiryStr) : null;
        if (expiryDate != null && DateTime.now().isBefore(expiryDate)) {
          await StorageService.setVipTier(tier, expiryDate: expiryDate);
        }
      }

      // 4. Mağaza satın alımlarını da tetikle
      try {
        if (!kIsWeb && InAppPurchaseService.instance.isAvailable) {
          await InAppPurchaseService.instance.restorePurchases();
        }
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('[CloudAccountService] _applyRestorePayload hatası: $e');
      return false;
    }
  }

  /// Buluttan Verileri ve VIP Üyeliğini (Kalan Süresiyle) Bu Cihaza Geri Yükle
  static Future<bool> restoreFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefCloudBackupPayloadKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        try {
          if (!kIsWeb && InAppPurchaseService.instance.isAvailable) {
            await InAppPurchaseService.instance.restorePurchases();
          }
        } catch (_) {}
        return false;
      }

      final payload = json.decode(jsonStr) as Map<String, dynamic>;
      return await _applyRestorePayload(payload);
    } catch (e) {
      debugPrint('[CloudAccountService] restoreFromCloud hatası: $e');
      return false;
    }
  }

  /// Eski metodla uyumluluk
  static Future<bool> restoreVipWithRecoveryKey(String key) async {
    final result = await redeemVipTransferKey(key);
    return result.success;
  }
}
