import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/active_profile_service.dart';
import '../../data/services/profile_archive_service.dart';
import '../../data/services/ad_service.dart';
import '../screens/archive_screen.dart';

class ActiveProfileBar extends StatelessWidget {
  final UserProfile mainProfile;
  final VoidCallback onProfileChanged;

  const ActiveProfileBar({
    super.key,
    required this.mainProfile,
    required this.onProfileChanged,
  });

  void _showProfilePicker(BuildContext context) async {
    final profiles = await ProfileArchiveService.getProfiles();
    final tier = await StorageService.getVipTier();
    final isPlatinum = (tier == VipTier.platinum);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF141122),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.starlightGold, width: 1.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.switch_account_rounded, color: AppColors.starlightGold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Aktif Harita Bağlamı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPlatinum
                          ? AppColors.starlightGold.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPlatinum ? AppColors.starlightGold : Colors.white24,
                      ),
                    ),
                    child: Text(
                      isPlatinum ? '👑 PLATINUM AKTİF' : '🔒 PLATINUM AYRICALIĞI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPlatinum ? AppColors.starlightGold : Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Seçtiğiniz kişinin haritası anasayfa, solar return, transitler ve 10 sayfalık PDF için anında aktifleşir.',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 16),

              // Ana Hesap Sahibi Profili
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: ActiveProfileService.isMainProfileActive(mainProfile)
                        ? AppColors.starlightGold
                        : Colors.white12,
                  ),
                ),
                tileColor: ActiveProfileService.isMainProfileActive(mainProfile)
                    ? AppColors.starlightGold.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04),
                leading: CircleAvatar(
                  backgroundColor: AppColors.pastelLavender.withValues(alpha: 0.2),
                  child: const Icon(Icons.person_rounded, color: AppColors.pastelLavender),
                ),
                title: Text(
                  '${mainProfile.name} (Asıl Profil)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                ),
                subtitle: Text(
                  '${mainProfile.birthCity} • ${mainProfile.sunSign} / Yükselen ${mainProfile.risingSign}',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
                trailing: ActiveProfileService.isMainProfileActive(mainProfile)
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.starlightGold)
                    : null,
                onTap: () {
                  ActiveProfileService.resetToMainProfile(context, mainProfile);
                  Navigator.of(ctx).pop();
                  onProfileChanged();
                },
              ),
              const SizedBox(height: 10),

              // Kayıtlı Haritalar Listesi
              if (profiles.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Kayıtlı Aile & Danışan Haritaları',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ),
                ...profiles.map((p) {
                  final isCurrentActive =
                      ActiveProfileService.activeProfileNotifier.value?.name == p.fullName;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isCurrentActive ? AppColors.starlightGold : Colors.white12,
                        ),
                      ),
                      tileColor: isCurrentActive
                          ? AppColors.starlightGold.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.04),
                      leading: CircleAvatar(
                        backgroundColor: p.gender == 'Kadın'
                            ? const Color(0xFFFF7675).withValues(alpha: 0.2)
                            : const Color(0xFF74B9FF).withValues(alpha: 0.2),
                        child: Text(
                          p.gender == 'Kadın' ? '♀\uFE0E' : '♂\uFE0E',
                          style: TextStyle(
                            color: p.gender == 'Kadın' ? const Color(0xFFFF7675) : const Color(0xFF74B9FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        p.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        '${p.birthCity} • ${p.sunSign} / Yükselen ${p.risingSign}',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                      trailing: isCurrentActive
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.starlightGold)
                          : (isPlatinum
                              ? const Icon(Icons.touch_app_rounded, color: Colors.white30, size: 18)
                              : const Icon(Icons.lock_outline_rounded, color: AppColors.starlightGold, size: 18)),
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final switched = await ActiveProfileService.switchProfile(
                          context: context,
                          targetSavedProfile: p,
                          mainProfile: mainProfile,
                        );
                        if (switched) {
                          onProfileChanged();
                        }
                      },
                    ),
                  );
                }),
              ],

              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.starlightGold,
                  side: const BorderSide(color: AppColors.starlightGold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ArchiveScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Yeni Kişi / Danışan Haritası Ekle'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: ActiveProfileService.activeProfileNotifier,
      builder: (context, activeProf, _) {
        final isCustomProfileActive = activeProf != null;
        final current = activeProf ?? mainProfile;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isCustomProfileActive
                ? const Color(0xFF281C3D)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCustomProfileActive
                  ? AppColors.starlightGold.withValues(alpha: 0.8)
                  : Colors.white12,
              width: isCustomProfileActive ? 1.4 : 1.0,
            ),
            boxShadow: isCustomProfileActive
                ? [
                    BoxShadow(
                      color: AppColors.starlightGold.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isCustomProfileActive
                      ? AppColors.starlightGold.withValues(alpha: 0.25)
                      : AppColors.pastelLavender.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCustomProfileActive ? Icons.stars_rounded : Icons.person_outline_rounded,
                  size: 16,
                  color: isCustomProfileActive ? AppColors.starlightGold : AppColors.pastelLavender,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isCustomProfileActive
                              ? '👑 AKTİF DANIŞAN / KİŞİ:'
                              : 'AKTİF HARİTA:',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w900,
                            color: isCustomProfileActive ? AppColors.starlightGold : Colors.white60,
                          ),
                        ),
                        if (isCustomProfileActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.starlightGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIP PLATINUM',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      current.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '☀️ ${current.sunSign} • 🌅 Yükselen ${current.risingSign}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Harita Değiştir veya Sıfırla Butonu
              if (isCustomProfileActive) ...[
                IconButton(
                  tooltip: 'Asıl Profile Dön',
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () {
                    ActiveProfileService.resetToMainProfile(context, mainProfile);
                    onProfileChanged();
                  },
                ),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCustomProfileActive
                      ? AppColors.starlightGold
                      : Colors.white.withValues(alpha: 0.12),
                  foregroundColor: isCustomProfileActive ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => AdService.registerActionAndShowInterstitial(
                  onDone: () => _showProfilePicker(context),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: isCustomProfileActive ? Colors.black : AppColors.starlightGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCustomProfileActive ? 'Değiştir' : 'Harita Seç',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
