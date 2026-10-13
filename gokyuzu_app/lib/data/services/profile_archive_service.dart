import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_profile_model.dart';
import 'storage_service.dart';

class ProfileArchiveResult {
  final bool success;
  final String? message;
  final bool requiresVip;

  const ProfileArchiveResult({
    required this.success,
    this.message,
    this.requiresVip = false,
  });
}

class ProfileArchiveService {
  static const String _keyProfiles = 'gokyuzu_saved_profiles_v1';
  static const int maxFreeProfiles = 3;
  static const int maxPinnedProfiles = 3;

  /// Kayıtlı tüm profilleri getirir (Önce sabitlenenler, sonra tarihe göre sıralı)
  static Future<List<SavedProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProfiles);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = json.decode(jsonStr);
      final profiles = list.map((e) => SavedProfile.fromMap(e)).toList();

      // Sıralama: Önce sabitlenenler (isPinned: true), sonra en yeni eklenenler
      profiles.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      return profiles;
    } catch (_) {
      return [];
    }
  }

  /// Yeni profil kaydetme veya güncelleme
  static Future<ProfileArchiveResult> saveProfile(SavedProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();
    final isVip = await StorageService.isVipUnlocked();

    final existingIndex = profiles.indexWhere((p) => p.id == profile.id);

    // Yeni profil ekleniyorsa ve kota dolmuşsa
    if (existingIndex == -1) {
      if (profiles.length >= maxFreeProfiles && !isVip) {
        return const ProfileArchiveResult(
          success: false,
          message:
              'Ücretsiz arşiv limitine (3 kişi) ulaştınız. Sınırsız harita kaydetmek için VIP üyeliğe geçiş yapabilirsiniz.',
          requiresVip: true,
        );
      }
      profiles.add(profile);
    } else {
      // Güncelleme
      profiles[existingIndex] = profile;
    }

    final rawList = profiles.map((p) => p.toMap()).toList();
    await prefs.setString(_keyProfiles, json.encode(rawList));

    return const ProfileArchiveResult(success: true);
  }

  /// Profil silme
  static Future<bool> deleteProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == id);
    final rawList = profiles.map((p) => p.toMap()).toList();
    return await prefs.setString(_keyProfiles, json.encode(rawList));
  }

  /// Profili sabitleme / yıldızlama (Pin)
  static Future<ProfileArchiveResult> togglePin(String id) async {
    final isVip = await StorageService.isVipUnlocked();
    if (!isVip) {
      return const ProfileArchiveResult(
        success: false,
        message:
            'Harita profillerini üst kısma sabitlemek ve yıldızlamak VIP üyelere özel ayrıcalıktır.',
        requiresVip: true,
      );
    }

    final profiles = await getProfiles();
    final targetIndex = profiles.indexWhere((p) => p.id == id);
    if (targetIndex == -1) {
      return const ProfileArchiveResult(
          success: false, message: 'Profil bulunamadı.');
    }

    final current = profiles[targetIndex];
    final newPinnedState = !current.isPinned;

    if (newPinnedState) {
      final pinnedCount = profiles.where((p) => p.isPinned).length;
      if (pinnedCount >= maxPinnedProfiles) {
        return const ProfileArchiveResult(
          success: false,
          message: 'En fazla $maxPinnedProfiles profili sabitleyebilirsiniz.',
        );
      }
    }

    profiles[targetIndex] = current.copyWith(isPinned: newPinnedState);
    final prefs = await SharedPreferences.getInstance();
    final rawList = profiles.map((p) => p.toMap()).toList();
    await prefs.setString(_keyProfiles, json.encode(rawList));

    return ProfileArchiveResult(
      success: true,
      message: newPinnedState ? 'Profil başa sabitlendi ⭐' : 'Sabitleme kaldırıldı',
    );
  }

  /// Doğum gününe kalan gün sayısını hesaplar
  static int getDaysUntilBirthday(DateTime birthDate) {
    final now = DateTime.now();
    DateTime nextBday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBday.isBefore(DateTime(now.year, now.month, now.day))) {
      nextBday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    return nextBday.difference(DateTime(now.year, now.month, now.day)).inDays;
  }
}
