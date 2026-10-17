import 'package:flutter/material.dart';
import '../models/saved_profile_model.dart';
import 'storage_service.dart';
import 'astrology_engine.dart';
import '../../presentation/widgets/platinum_multiprofile_upsell_sheet.dart';

/// Gökyüzü Doktoru — VIP Platinum Çoklu Profil & Bağlam Servisi (Context Switcher)
/// Uygulamanın tümünün (Solar Return, Progress, Numeroloji, 10 Sayfalık PDF vb.)
/// seçili olan aktif profile göre hesaplanmasını yönetir.
class ActiveProfileService {
  static final ValueNotifier<UserProfile?> activeProfileNotifier = ValueNotifier<UserProfile?>(null);

  /// Aktif profili döner. Eğer özel bir profil seçilmemişse ana kullanıcı profilini döner.
  static UserProfile getEffectiveProfile(UserProfile mainProfile) {
    return activeProfileNotifier.value ?? mainProfile;
  }

  /// Aktif olan profilin ana hesap sahibi olup olmadığını kontrol eder
  static bool isMainProfileActive(UserProfile mainProfile) {
    final current = activeProfileNotifier.value;
    if (current == null) return true;
    return current.name == mainProfile.name && current.birthDate == mainProfile.birthDate;
  }

  /// Profil değiştirme isteği
  /// Sadece VIP Platinum üyeler serbestçe profil değiştirebilir.
  /// Platinum olmayan kullanıcılara +1 PDF Hediye teşvikli upsell modalı açılır.
  static Future<bool> switchProfile({
    required BuildContext context,
    required SavedProfile targetSavedProfile,
    required UserProfile mainProfile,
  }) async {
    final tier = await StorageService.getVipTier();
    final isPlatinum = (tier == VipTier.platinum);

    if (!isPlatinum) {
      if (context.mounted) {
        showPlatinumMultiProfileUpsellSheet(
          context,
          targetProfileName: targetSavedProfile.fullName,
        );
      }
      return false;
    }

    // Platinum kullanıcı için profili UserProfile formatına dönüştür ve hesapla
    final parsedDate = targetSavedProfile.birthDate;
    final birthDateStr =
        '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
    final tp = targetSavedProfile.birthTime.split(':');
    final hour = tp.isNotEmpty ? (int.tryParse(tp[0]) ?? 12) : 12;
    final minute = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;

    final chart = AstrologyEngine.calculateChart(
      name: targetSavedProfile.fullName,
      birthDate: parsedDate,
      birthTime: TimeOfDay(hour: hour, minute: minute),
      city: targetSavedProfile.birthCity.isEmpty ? 'İstanbul' : targetSavedProfile.birthCity,
      country: targetSavedProfile.birthCountry.isEmpty ? 'Türkiye' : targetSavedProfile.birthCountry,
    );

    final newActiveProfile = UserProfile(
      name: targetSavedProfile.fullName,
      birthDate: birthDateStr,
      birthTime: targetSavedProfile.birthTime,
      birthCity: targetSavedProfile.birthCity,
      birthCountry: targetSavedProfile.birthCountry,
      sunSign: chart.sunSign.split(' ').first,
      moonSign: chart.moonSign.split(' ').first,
      risingSign: chart.risingSign.split(' ').first,
      gender: targetSavedProfile.gender,
      language: mainProfile.language,
      isVip: true,
      rawChart: chart.rawChart,
    );

    activeProfileNotifier.value = newActiveProfile;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: Color(0xFFFFD700)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aktif Harita Değiştirildi: ${targetSavedProfile.fullName}\nTüm analizler ve PDF bu profile göre hesaplanıyor.',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1633),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return true;
  }

  /// Ana profile geri dönme
  static void resetToMainProfile(BuildContext context, UserProfile mainProfile) {
    activeProfileNotifier.value = null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Asıl profilinize dönüldü: ${mainProfile.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E244D),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
