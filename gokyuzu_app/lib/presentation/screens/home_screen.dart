import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/daily_horoscope_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/sky_transits_service.dart';
import '../../data/services/lunar_mansions_service.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/cosmic_quotes_service.dart';
import '../widgets/big_three_badge.dart';
import '../widgets/glass_card.dart';
import 'chart_detail_screen.dart';
import 'onboarding_input_screen.dart';
import 'archive_screen.dart';
import 'cosmic_notes_screen.dart';
import 'profile_screen.dart';
import '../widgets/synastry_modal.dart';
import '../widgets/solar_return_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/pdf_report_service.dart';
import '../../data/services/predictive_astrology_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/app_translation_service.dart';
import 'numerology_screen.dart';
import '../widgets/lunar_return_modal.dart';
import '../widgets/rectification_modal.dart';
import '../widgets/astro_bulletin_section.dart';
import '../widgets/personal_eclipses_counseling_sheet.dart';
import '../../data/services/cosmic_theme_service.dart';
import '../widgets/cosmic_story_share_modal.dart';
import '../widgets/planetary_hours_modal.dart';
import '../widgets/cosmic_compass_modal.dart';
import '../widgets/referral_modal.dart';
import '../widgets/birthday_solar_return_modal.dart';
import '../widgets/cosmic_frequencies_modal.dart';
import '../../data/services/active_profile_service.dart';
import '../widgets/active_profile_bar.dart';
import '../widgets/interactive_bi_wheel_modal.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile profile;

  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyHoroscopeModel? _dailyHoroscope;
  bool _isLoading = true;
  String? _error;
  bool _isVipUnlocked = false;
  bool _isMoonPhaseUnlocked = false;
  bool _notificationsEnabled = false;

  String _capitalize(String raw) {
    if (raw.trim().isEmpty) return '';
    return raw.trim().split(RegExp(r'\s+')).map((w) {
      if (w.isEmpty) return '';
      String first;
      String rest = w.length > 1 ? w.substring(1).toLowerCase() : '';
      if (w.startsWith('i') || w.startsWith('İ')) {
        first = 'İ';
      } else if (w.startsWith('ı') || w.startsWith('I')) {
        first = 'I';
      } else {
        first = w[0].toUpperCase();
      }
      return '$first$rest';
    }).join(' ');
  }

  Future<void> _launchExternalUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: urlStr));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bağlantı panoya kopyalandı: $urlStr'),
              backgroundColor: const Color(0xFF2C1E4A),
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: urlStr));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı panoya kopyalandı: $urlStr'),
            backgroundColor: const Color(0xFF2C1E4A),
          ),
        );
      }
    }
  }

  UserProfile get _effectiveProfile => ActiveProfileService.getEffectiveProfile(widget.profile);

  @override
  void initState() {
    super.initState();
    ActiveProfileService.activeProfileNotifier.addListener(_onActiveProfileChanged);
    _checkVipStatus();
    _fetchDailyHoroscope();
    _initNotifications();
    _checkBirthdayCelebration();
  }

  @override
  void dispose() {
    ActiveProfileService.activeProfileNotifier.removeListener(_onActiveProfileChanged);
    super.dispose();
  }

  void _onActiveProfileChanged() {
    if (mounted) {
      setState(() {});
      _fetchDailyHoroscope();
    }
  }

  void _checkBirthdayCelebration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && BirthdaySolarReturnModal.isTodayUserBirthday(widget.profile)) {
        BirthdaySolarReturnModal.show(context, widget.profile);
      }
    });
  }

  Future<void> _initNotifications() async {
    final enabled = await NotificationService.isEnabled();
    final prompted = await NotificationService.hasPromptedUser();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
    if (enabled) {
      await NotificationService.syncDailyNotificationsIfEnabled(widget.profile);
    } else if (!prompted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showNotificationPermissionModal(context, isInitialPrompt: true);
        }
      });
    }
  }

  void _showNotificationPermissionModal(
    BuildContext context, {
    bool isInitialPrompt = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191528),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.starlightGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.starlightGold,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Günlük Kozmik Bildirimler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isInitialPrompt
                  ? 'Gün boyu gerçekleşen gökyüzü transitlerini, Ay fazı değişimlerini, Ay Boşlukta uyarılarını ve doğum haritanıza özel enerjileri cep telefonunuza bildirim olarak göndermemize izin verir misiniz?'
                  : (_notificationsEnabled
                      ? 'Günlük kozmik bildirimleriniz şu anda AKTİF. Her gün sabah 09:30, öğle 14:30 ve akşam 20:30 saatlerinde telefonunuza haritanıza özel gökyüzü bildirimleri iletilmektedir.'
                      : 'Bildirimlere izin vererek sabah 09:30, öğle 14:30 ve akşam 20:30 saatlerinde telefonunuza günlük transit ve Ay boşlukta bildirimleri gelmesini sağlayabilirsiniz.'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('☀️ 09:30 • Sabah Günün Transit & Yükselen Enerjisi',
                      style: TextStyle(fontSize: 11, color: AppColors.starlightGold)),
                  SizedBox(height: 4),
                  Text('🌙 14:30 • Gün Ortası Ay Fazı & Ay Boşlukta Uyarısı',
                      style: TextStyle(fontSize: 11, color: AppColors.pastelMint)),
                  SizedBox(height: 4),
                  Text('✨ 20:30 • Akşam Gece Gökyüzü & Yıldız Rehberi',
                      style: TextStyle(fontSize: 11, color: AppColors.pastelLavender)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_notificationsEnabled && !isInitialPrompt)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await NotificationService.disableNotifications();
                if (mounted) {
                  setState(() => _notificationsEnabled = false);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Günlük bildirimler kapatıldı.'),
                      backgroundColor: Color(0xFF2C1E4A),
                    ),
                  );
                }
              },
              child: const Text('Bildirimleri Kapat',
                  style: TextStyle(color: AppColors.savageRed, fontSize: 12)),
            )
          else
            TextButton(
              onPressed: () async {
                await NotificationService.markPrompted();
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Daha Sonra',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.notifications_active_rounded,
                size: 16, color: Colors.black87),
            label: Text(
              _notificationsEnabled && !isInitialPrompt
                  ? 'Şimdi Bildirim Gönder 🔔'
                  : 'Bildirimlere İzin Ver 🔔',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final granted = await NotificationService.requestPermissionAndEnable(
                widget.profile,
                sendImmediateConfirmation: true,
              );
              if (mounted) {
                setState(() => _notificationsEnabled = granted);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      granted
                          ? '🔔 Kozmik bildirimler aktif edildi! Telefonunuza anlık bildirim gönderildi.'
                          : '⚠️ Bildirim izni kapalı. Telefon ayarlarından Gökyüzü Doktoru bildirimlerine izin verebilirsiniz.',
                    ),
                    backgroundColor:
                        granted ? const Color(0xFF1D5A3A) : AppColors.savageRed,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCosmicSeasonPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13101E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.starlightGold, width: 1.2),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeSeason = CosmicThemeService.currentSeason;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.starlightGold.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('✨', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kozmik Sezon & Bayram Teması',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Uygulama atmosferi ve gezegen kostümlerini test edin',
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSeasonOptionTile(
                        ctx,
                        title: 'Otomatik Takvim (Sıfır Efor)',
                        subtitle: 'Tarihe göre bayram ve ekinoksları otomatik uygular',
                        emoji: '⚡',
                        season: null,
                        isSelected: CosmicThemeService.currentSeason == CosmicSeason.standard,
                      ),
                      _buildSeasonOptionTile(
                        ctx,
                        title: 'Cadılar Bayramı (Halloween Demosu)',
                        subtitle: 'Balkabakları, cadı şapkası, yarasalar ve mistik mor/turuncu',
                        emoji: '🎃',
                        season: CosmicSeason.halloween,
                        isSelected: activeSeason == CosmicSeason.halloween,
                        badgeText: 'CANLI DEMO',
                      ),
                      _buildSeasonOptionTile(
                        ctx,
                        title: 'Yeni Yıl & Kış Gündönümü',
                        subtitle: 'Altın kraliyet tacı, kar taneleri, hediye kutuları ve ışıltı',
                        emoji: '🎄',
                        season: CosmicSeason.newYear,
                        isSelected: activeSeason == CosmicSeason.newYear,
                      ),
                      _buildSeasonOptionTile(
                        ctx,
                        title: 'Sevgililer Günü & Venüs Kapısı',
                        subtitle: 'Aşk kalpleri, kırmızı güller ve ruh eşi frekansı',
                        emoji: '💖',
                        season: CosmicSeason.valentines,
                        isSelected: activeSeason == CosmicSeason.valentines,
                      ),
                      _buildSeasonOptionTile(
                        ctx,
                        title: 'İlkbahar Ekinoksu & 0° Koç Yeni Yılı',
                        subtitle: 'Bahar uyanışı, taze filizler ve canlandırıcı yeşil aura',
                        emoji: '🌸',
                        season: CosmicSeason.springEquinox,
                        isSelected: activeSeason == CosmicSeason.springEquinox,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSeasonOptionTile(
    BuildContext sheetContext, {
    required String title,
    required String subtitle,
    required String emoji,
    required CosmicSeason? season,
    required bool isSelected,
    String? badgeText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.starlightGold.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.starlightGold : Colors.white12,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: () {
          CosmicThemeService.setOverrideSeason(season);
          Navigator.of(sheetContext).pop();
          if (mounted) setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                season == null
                    ? '⚡ Kozmik Takvim Otomatik Moda Alındı.'
                    : '$emoji ${CosmicThemeService.seasonBadgeText} aktif edildi!',
              ),
              backgroundColor: CosmicThemeService.primaryAccentColor,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.starlightGold : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7518),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.starlightGold, size: 20)
            : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
      ),
    );
  }

  Future<void> _checkVipStatus() async {
    final vip = await StorageService.isVip();
    if (mounted) {
      setState(() {
        _isVipUnlocked = vip;
        if (vip) _isMoonPhaseUnlocked = true;
      });
    }
  }

  Future<void> _fetchDailyHoroscope() async {
    try {
      final prof = _effectiveProfile;
      final liveChart = AstrologyEngine.calculateChart(
        name: prof.name,
        dateStr: prof.birthDate,
        timeStr: prof.birthTime,
        city: prof.birthCity,
        country: prof.birthCountry,
      );
      final horoscope = await ApiService.getDailyHoroscope(
        name: prof.name,
        chart: {
          'sun': liveChart.sunSign,
          'moon': liveChart.moonSign,
          'ascendant': liveChart.ascendant,
        },
      );
      if (mounted) {
        setState(() {
          _dailyHoroscope = horoscope;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Yorum yüklenemedi: $e';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildCosmicActionCard({
    required String iconText,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(iconText, style: const TextStyle(fontSize: 20)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(AppTranslationService.tr('Profili Sıfırla?'),
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          AppTranslationService.tr(
            'Mevcut doğum haritanız ve kaydedilen profil bilgileriniz silinecektir. Devam etmek istiyor musunuz?',
          ),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppTranslationService.tr('İptal'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.savageRed,
            ),
            child: Text(AppTranslationService.tr('Sıfırla')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslationService.currentLangNotifier,
      builder: (context, currentLang, _) {
        return ValueListenableBuilder<CosmicSeason>(
          valueListenable: CosmicThemeService.seasonNotifier,
          builder: (context, season, _) {
            return Scaffold(
              backgroundColor: CosmicThemeService.scaffoldBackgroundColor,
              body: Container(
                decoration: BoxDecoration(gradient: CosmicThemeService.backgroundGradient),
                child: SafeArea(
                  child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslationService.tr('KOZMİK DOKTOR'),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.pastelLavender,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${AppTranslationService.tr('Merhaba')}, ${_capitalize(_effectiveProfile.name)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(profile: widget.profile),
                                  ),
                                );
                                _checkVipStatus();
                              },
                              onLongPress: () => _showCosmicSeasonPickerModal(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isVipUnlocked
                                      ? const Color(0xFFFFD700).withAlpha(35)
                                      : Colors.white.withAlpha(16),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isVipUnlocked
                                        ? const Color(0xFFFFD700).withAlpha(140)
                                        : Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isVipUnlocked
                                          ? Icons.stars_rounded
                                          : Icons.account_circle_outlined,
                                      size: 14,
                                      color: _isVipUnlocked
                                          ? const Color(0xFFFFD700)
                                          : AppColors.pastelLavender,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _isVipUnlocked
                                          ? AppTranslationService.tr('VIP Profil & Üyelik')
                                          : AppTranslationService.tr('Profil & Giriş / Kayıt'),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: _isVipUnlocked
                                            ? const Color(0xFFFFD700)
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: Colors.white54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(width: 4),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showLanguageSelectionSheet(context),
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withAlpha(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, size: 15, color: AppColors.starlightGold),
                          const SizedBox(width: 3),
                          Text(
                            AppTranslationService.currentLang.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    tooltip: AppTranslationService.tr('change_language'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showNotificationPermissionModal(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E5FF).withAlpha(25),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withAlpha(110),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        size: 19,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                    tooltip: AppTranslationService.tr('Gökyüzü Bildirimleri'),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(profile: widget.profile),
                        ),
                      );
                      _checkVipStatus();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isVipUnlocked
                            ? const Color(0xFFFFD700).withAlpha(35)
                            : Colors.white10,
                        border: Border.all(
                          color: _isVipUnlocked
                              ? const Color(0xFFFFD700).withAlpha(150)
                              : Colors.white24,
                        ),
                      ),
                      child: Icon(
                        _isVipUnlocked ? Icons.stars_rounded : Icons.person_rounded,
                        size: 20,
                        color: _isVipUnlocked
                            ? const Color(0xFFFFD700)
                            : AppColors.pastelLavender,
                      ),
                    ),
                    tooltip: AppTranslationService.tr('Profil & Üyelik İşlemleri'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // VIP Platinum Aktif Profil Seçici (Context Switcher)
              ActiveProfileBar(
                mainProfile: widget.profile,
                onProfileChanged: () {
                  setState(() {});
                  _fetchDailyHoroscope();
                },
              ),
              const SizedBox(height: 8),

              // 🔭 Canlı İnteraktif Çift Çark (Solar Fire Bi-Wheel)
              _buildCosmicActionCard(
                iconText: '🔭',
                title: AppTranslationService.tr('İnteraktif Çift Çark (Bi-Wheel)'),
                subtitle: AppTranslationService.tr('Natal & Canlı Transitler • Zaman Makinesi'),
                badgeText: 'SOLAR FIRE',
                badgeColor: const Color(0xFF00CEC9),
                gradientColors: [
                  const Color(0xFF00CEC9).withValues(alpha: 0.20),
                  const Color(0xFF6C5CE7).withValues(alpha: 0.16),
                ],
                borderColor: const Color(0xFF00CEC9).withValues(alpha: 0.5),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InteractiveBiWheelModal(natalProfile: _effectiveProfile),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Kozmik Sezon & Bayramlar Canlı Banner'ı (Sadece Özel Günlerde Otomatik Açılır)
              ValueListenableBuilder<CosmicSeason>(
                valueListenable: CosmicThemeService.seasonNotifier,
                builder: (context, season, _) {
                  if (season == CosmicSeason.standard) return const SizedBox.shrink();
                  final primary = CosmicThemeService.primaryAccentColor;
                  final secondary = CosmicThemeService.secondaryAccentColor;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.32),
                          secondary.withValues(alpha: 0.24),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.75),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.25),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CosmicThemeService.seasonBadgeText,
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CosmicThemeService.seasonBannerSubtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Big 3 Summary Badges (Canlı Astronomik Motor ile Senkronize)
              Builder(
                builder: (context) {
                  final liveChart = AstrologyEngine.calculateChart(
                    name: _effectiveProfile.name,
                    dateStr: _effectiveProfile.birthDate,
                    timeStr: _effectiveProfile.birthTime,
                    city: _effectiveProfile.birthCity,
                    country: _effectiveProfile.birthCountry,
                  );
                  final elemScores = liveChart.elements;
                  final fireScore = elemScores['Ateş'] ?? 0;
                  final earthScore = elemScores['Toprak'] ?? 0;
                  final airScore = elemScores['Hava'] ?? 0;
                  final waterScore = elemScores['Su'] ?? 0;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BigThreeBadge(
                              label: AppTranslationService.tr('sun'),
                              sign: AppTranslationService.signName(liveChart.sunSign),
                              accentColor: AppColors.starlightGold,
                              icon: Icons.wb_sunny_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BigThreeBadge(
                              label: AppTranslationService.tr('moon'),
                              sign: AppTranslationService.signName(liveChart.moonSign),
                              accentColor: AppColors.pastelLavender,
                              icon: Icons.nightlight_round,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BigThreeBadge(
                              label: AppTranslationService.tr('rising'),
                              sign: AppTranslationService.signName(liveChart.ascendant),
                              accentColor: AppColors.pastelPink,
                              icon: Icons.north_east_rounded,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppTranslationService.tr('elements_distribution')}:',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Flexible(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text('🔥 ${AppTranslationService.elementName('Ateş')} $fireScore',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.pastelPeach)),
                                  Text('🌿 ${AppTranslationService.elementName('Toprak')} $earthScore',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.pastelMint)),
                                  Text('💨 ${AppTranslationService.elementName('Hava')} $airScore',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.starlightGold)),
                                  Text('💧 ${AppTranslationService.elementName('Su')} $waterScore',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.pastelBlue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Sect (Gündüz / Gece Haritası) & Placidus Ev Sistemi Bilgi Satırı
              Builder(
                builder: (context) {
                  final placidusInfo = PredictiveAstrologyService.calculatePlacidusHouses(profile: widget.profile);
                  final isDay = placidusInfo['isDayChart'] as bool;
                  final sectName = placidusInfo['sectName'] as String;
                  final List<Map<String, dynamic>> interceptedList = List<Map<String, dynamic>>.from(placidusInfo['interceptedSigns']);

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDay
                          ? AppColors.starlightGold.withValues(alpha: 0.10)
                          : AppColors.pastelLavender.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDay
                            ? AppColors.starlightGold.withValues(alpha: 0.28)
                            : AppColors.pastelLavender.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 16,
                          color: isDay ? AppColors.starlightGold : AppColors.pastelLavender,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${AppTranslationService.tr(sectName)} • ${AppTranslationService.tr('Placidus Ev Sistemi')}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDay ? AppColors.starlightGold : AppColors.pastelLavender,
                            ),
                          ),
                        ),
                        if (interceptedList.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🔒 ${interceptedList.map((i) => i['sign']).join("-")}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // 📸 9:16 Instagram Story & WhatsApp Paylaşım Kartı
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 4),
                child: ElevatedButton.icon(
                  onPressed: () => CosmicStoryShareModal.show(context, widget.profile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.starlightGold.withValues(alpha: 0.15),
                    foregroundColor: AppColors.starlightGold,
                    side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.starlightGold, size: 20),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTranslationService.tr('📸 Instagram Story Kartı Oluştur (9:16)'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'YENİ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tam Doğum Günü & Solar Dönüş Kutlama Banner'ı (Sadece doğum gününde açılır)
              if (BirthdaySolarReturnModal.isTodayUserBirthday(widget.profile)) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.starlightGold.withValues(alpha: 0.35),
                        const Color(0xFFFF5470).withValues(alpha: 0.28),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.starlightGold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.starlightGold.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎂', style: TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslationService.tr('Güneş Dönüşün (Solar Return) Kutlu Olsun! ☀️'),
                              style: const TextStyle(
                                color: AppColors.starlightGold,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppTranslationService.tr('Bugün doğduğun gün! Yıllık Solar haritanı ve yeni yaş temalarını görmek için dokun.'),
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => BirthdaySolarReturnModal.show(context, widget.profile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.starlightGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Kutla 🎉',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Kozmik Güç Araçları (Gezegen Saatleri, Pusula, Davet Et, Frekanslar)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.starlightGold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          AppTranslationService.tr('KOZMİK REHBERLİK & ÖZEL ARAÇLAR'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.starlightGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCosmicActionCard(
                            iconText: '🪐',
                            title: AppTranslationService.tr('Gezegen Saatleri'),
                            subtitle: AppTranslationService.tr('24 Saat & Şans Vakti'),
                            badgeText: 'CANLI',
                            badgeColor: AppColors.starlightGold,
                            gradientColors: [
                              AppColors.starlightGold.withValues(alpha: 0.16),
                              const Color(0xFF6B4EE8).withValues(alpha: 0.14),
                            ],
                            borderColor: AppColors.starlightGold.withValues(alpha: 0.4),
                            onTap: () => PlanetaryHoursModal.show(context, widget.profile),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCosmicActionCard(
                            iconText: '🧭',
                            title: AppTranslationService.tr('Karar Pusulası'),
                            subtitle: AppTranslationService.tr('Transit Uyumlu Sezgisel Karar'),
                            badgeText: 'ORAKL',
                            badgeColor: AppColors.pastelMint,
                            gradientColors: [
                              AppColors.pastelMint.withValues(alpha: 0.16),
                              const Color(0xFF1E3A8A).withValues(alpha: 0.14),
                            ],
                            borderColor: AppColors.pastelMint.withValues(alpha: 0.4),
                            onTap: () => CosmicCompassModal.show(context, widget.profile),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCosmicActionCard(
                            iconText: '🎁',
                            title: AppTranslationService.tr('Davet Et Kazan'),
                            subtitle: AppTranslationService.tr('3 Gün VIP & 10 Sayfa PDF'),
                            badgeText: 'HEDİYE',
                            badgeColor: const Color(0xFFFF758F),
                            gradientColors: [
                              const Color(0xFFFF758F).withValues(alpha: 0.16),
                              const Color(0xFF7209B7).withValues(alpha: 0.14),
                            ],
                            borderColor: const Color(0xFFFF758F).withValues(alpha: 0.4),
                            onTap: () => ReferralModal.show(context, widget.profile),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCosmicActionCard(
                            iconText: '🎵',
                            title: AppTranslationService.tr('Gezegen Frekansları'),
                            subtitle: AppTranslationService.tr('Çakra & Ses Rehberi'),
                            badgeText: 'DERS',
                            badgeColor: const Color(0xFF9D4EDD),
                            gradientColors: [
                              const Color(0xFF9D4EDD).withValues(alpha: 0.16),
                              const Color(0xFF3A0CA3).withValues(alpha: 0.14),
                            ],
                            borderColor: const Color(0xFF9D4EDD).withValues(alpha: 0.4),
                            onTap: () => CosmicFrequenciesModal.show(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Access: Harita Arşivi, Doğum Günü & Profili Sıfırla (3 Eşit Buton)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                      ),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.starlightGold.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_shared_rounded,
                                size: 20, color: AppColors.starlightGold),
                            const SizedBox(height: 6),
                            Text(
                              AppTranslationService.tr('Harita Arşivi'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslationService.tr('Kayıtlılar'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.starlightGold.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CosmicNotesScreen()),
                      ),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.pastelMint.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cake_rounded,
                                size: 20, color: AppColors.pastelMint),
                            const SizedBox(height: 6),
                            Text(
                              AppTranslationService.tr('Doğum Günü'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslationService.tr('Hatırlatıcı'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.pastelMint.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _handleResetProfile,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.pastelLavender.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.pastelLavender.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded,
                                size: 20, color: AppColors.pastelLavender),
                            const SizedBox(height: 6),
                            Text(
                              AppTranslationService.tr('Profili Sıfırla'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslationService.tr('Yeni Harita'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.pastelLavender.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Daily Transit Section
              Text(
                AppTranslationService.tr('GÜNÜN KOZMİK YORUMU'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),

              _isLoading
                  ? const GlassCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            color: AppColors.pastelLavender,
                          ),
                        ),
                      ),
                    )
                  : _error != null
                      ? GlassCard(
                          child: Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.savageRed),
                            ),
                          ),
                        )
                      : GlassCard(
                          borderColor: AppColors.pastelPink.withValues(alpha: 0.4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslationService.tr('Günün Enerjisi'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppColors.pastelPink,
                                          fontSize: 18,
                                        ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _dailyHoroscope?.date ?? (currentLang == 'ja' ? '本日' : (currentLang == 'en' ? 'Today' : 'Bugün')),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.starlightGold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _dailyHoroscope?.text ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      height: 1.6,
                                      fontSize: 14.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
              const SizedBox(height: 16),

              // Günün Kozmik Motivasyon Sözü
              _buildDailyCosmicQuoteCard(),
              const SizedBox(height: 24),

              // Live Sky & Moon Transits Section
              _buildLiveSkyTransitsSection(),
              const SizedBox(height: 24),

              // Astro Bülten Section (12 Burç Yorumları, Aylık Takvim & Haftalık Özet)
              AstroBulletinSection(profile: _effectiveProfile),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                AppTranslationService.tr('DERİN İNCELEME & ANALİZ'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),

              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChartDetailScreen(profile: _effectiveProfile),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.pastelPeach.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.pie_chart_outline_rounded,
                                color: AppColors.pastelPeach,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTranslationService.tr('Tam Doğum Haritası'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppTranslationService.tr('12 Ev, Gezegen Dereceleri, Elementler'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 15, color: AppColors.pastelLavender),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () => _showVipConsultationModal(context),
                borderRadius: BorderRadius.circular(20),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  borderColor: AppColors.starlightGold.withValues(alpha: 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.starlightGold,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        AppTranslationService.tr('VIP Kozmik Danışmanlık'),
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.starlightGold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (_isVipUnlocked ? AppColors.pastelMint : AppColors.starlightGold).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: (_isVipUnlocked ? AppColors.pastelMint : AppColors.starlightGold).withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          _isVipUnlocked ? AppTranslationService.tr('AÇIK 👑') : AppTranslationService.tr('VIP ÖZEL 🔒'),
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: _isVipUnlocked ? AppColors.pastelMint : AppColors.starlightGold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    AppTranslationService.tr('Sinastri, Solar Return ve Özel Raporlar'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.stars_rounded,
                          size: 20, color: AppColors.starlightGold),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // KOZMİK NUMEROLOJİ & YAŞAM YOLU MATRİSİ KARTI (HERKESE AÇIK ✨)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NumerologyScreen(profile: _effectiveProfile),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  borderColor: AppColors.pastelLavender.withValues(alpha: 0.45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.pastelLavender.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.pastelLavender,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        AppTranslationService.tr('Kozmik Numeroloji Matrisi'),
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        AppTranslationService.tr('HERKESE AÇIK ✨'),
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.starlightGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    AppTranslationService.tr('Yaşam Yolu, Kader Sayısı ve 2026 Döngüsü'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 15, color: AppColors.pastelLavender),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Yiğithan Akman Social Media & Contact Hub
              GlassCard(
                padding: const EdgeInsets.all(18),
                borderColor: AppColors.pastelLavender.withValues(alpha: 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded,
                                  size: 18, color: AppColors.starlightGold),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppTranslationService.tr('YİĞİTHAN AKMAN İLE İLETİŞİM'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                    color: AppColors.starlightGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showSocialShareModal(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.pastelLavender
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.share_rounded,
                                    size: 13, color: AppColors.pastelLavender),
                                const SizedBox(width: 4),
                                Text(
                                  AppTranslationService.tr('Paylaş 📤'),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.pastelLavender,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Birebir astrolojik sorularınız, harita danışmanlığı ve güncel gökyüzü analizleri için takip edebilirsiniz:',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Direct links row (3 Eşit Buton)
                    Row(
                      children: [
                        // Instagram
                        Expanded(
                          child: InkWell(
                            onTap: () => _launchExternalUrl(
                                'https://instagram.com/yigithan.akman'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.pastelPink
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.pastelPink
                                        .withValues(alpha: 0.4)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_rounded,
                                      size: 20, color: AppColors.pastelPink),
                                  SizedBox(height: 6),
                                  Text(
                                    'Instagram',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // WhatsApp
                        Expanded(
                          child: InkWell(
                            onTap: () => _launchExternalUrl(
                                'https://wa.me/905522550810'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.pastelMint
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.pastelMint
                                        .withValues(alpha: 0.4)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      size: 20, color: AppColors.pastelMint),
                                  SizedBox(height: 6),
                                  Text(
                                    'WhatsApp',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Telegram
                        Expanded(
                          child: InkWell(
                            onTap: () => _launchExternalUrl(
                                'https://t.me/gokyuzudoktoru_destek_bot'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.pastelBlue
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.pastelBlue
                                        .withValues(alpha: 0.4)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.send_rounded,
                                      size: 20, color: AppColors.pastelBlue),
                                  SizedBox(height: 6),
                                  Text(
                                    'Telegram',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
            },
          );
        },
      );
  }

  // --- Social Media Sharing Modal ---
  void _showSocialShareModal(BuildContext context) {
    const storeUrl =
        'https://play.google.com/store/apps/details?id=com.gokyuzudoktoru.gokyuzu_app';
    const shareText =
        'Gökyüzü Doktoru ile Geocentric Placidus doğum haritamı ve gezegen yerleşimlerimi çıkardım! 🌌 Sen de kendi haritanı ve astrolojik analizlerini incelemek için uygulamayı indir: $storeUrl';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF13111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x33FFD166), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.share_rounded,
                    color: AppColors.starlightGold, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Haritanı & Uygulamayı Paylaş',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Astrolojik analizlerinizi ve Gökyüzü Doktoru uygulama bağlantısını arkadaşlarınızla paylaşın:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareAppButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Instagram',
                  color: AppColors.pastelPink,
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: shareText));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uygulama paylaşım linki panoya kopyalandı! 📸'),
                        backgroundColor: Color(0xFF2C1E4A),
                      ),
                    );
                    _launchExternalUrl(storeUrl);
                  },
                ),
                _buildShareAppButton(
                  icon: Icons.chat_bubble_rounded,
                  label: 'WhatsApp',
                  color: AppColors.pastelMint,
                  onTap: () {
                    final encoded = Uri.encodeComponent(shareText);
                    _launchExternalUrl('https://api.whatsapp.com/send?text=$encoded');
                  },
                ),
                _buildShareAppButton(
                  icon: Icons.send_rounded,
                  label: 'Telegram',
                  color: AppColors.pastelBlue,
                  onTap: () {
                    final encodedText = Uri.encodeComponent(shareText);
                    final encodedUrl = Uri.encodeComponent(storeUrl);
                    _launchExternalUrl('https://t.me/share/url?url=$encodedUrl&text=$encodedText');
                  },
                ),
                _buildShareAppButton(
                  icon: Icons.alternate_email_rounded,
                  label: 'X (Twitter)',
                  color: Colors.white,
                  onTap: () {
                    final encoded = Uri.encodeComponent(shareText);
                    _launchExternalUrl('https://twitter.com/intent/tweet?text=$encoded');
                  },
                ),
                _buildShareAppButton(
                  icon: Icons.copy_rounded,
                  label: 'Kopyala',
                  color: AppColors.starlightGold,
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: shareText));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uygulama mağaza bağlantısı panoya kopyalandı! 🌟'),
                        backgroundColor: Color(0xFF2C1E4A),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareAppButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // --- VIP Purchase / Payment Modal ---
  void _showPurchaseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF13111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x33FFD166), width: 1),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.starlightGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.starlightGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VIP KOZMİK ABONELİK PAKETLERİ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        Text(
                          Platform.isIOS
                              ? 'Apple App Store Güvencesiyle Resmi Abonelik'
                              : 'Google Play Store Güvencesiyle Resmi Abonelik',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // VIP Benefits Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.starlightGold.withValues(alpha: 0.15),
                          AppColors.pastelLavender.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.starlightGold.withValues(alpha: 0.35)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIP Üyelik Ayrıcalıkları:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        SizedBox(height: 10),
                        _BenefitRow('10 Sayfalık Kapsamlı Harita Kitapçığı (PDF İndirme)'),
                        _BenefitRow('Sınırsız Harita Arşivi & 3 Kişi Başa Sabitleme (Pinleme)'),
                        _BenefitRow('Kozmik Günlük (Astro-Journal) & Hatırlatıcılar'),
                        _BenefitRow('72 Kabala Meleği, Dekanlar, Çakralar & Sabit Yıldızlar'),
                        _BenefitRow('Sinastri, Lunar Return & Majör Yaşam Döngüleri'),
                        _BenefitRow('Secondary Progress (İlerletilmiş ASC), Solar Arc & Kabala Ağacı'),
                        _BenefitRow('%100 Reklamsız, Kesintisiz ve Hızlı Deneyim'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'VIP Üyelik Paketleri (Seviyeler & Haklar):',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Package 1: Platinum VIP (Yıllık Avantajlı)
                  _buildPackageOption(
                    title: 'Platinum VIP (Yıllık İndirimli)',
                    price: '4.199 ₺ / yıl',
                    period: '12 Ay Peşin (Aylık 10\$)',
                    badge: '%25 İNDİRİM 👑',
                    badgeColor: AppColors.starlightGold,
                    isHighlight: true,
                    subtitle: 'HER ŞEY AÇIK • Sınırsız PDF • Tüm Kozmik Modüller & İleri Öngörüler • Sıfır Reklam',
                    onTap: () => _showPaymentOptions(context, 'Platinum VIP (Yıllık)', VipTier.platinum),
                  ),
                  const SizedBox(height: 10),

                  // Package 2: Platinum VIP (Aylık)
                  _buildPackageOption(
                    title: 'Platinum VIP (Aylık)',
                    price: '459 ₺ / ay',
                    period: 'Aylık Abonelik (13\$)',
                    badge: 'TAM ERİŞİM 💎',
                    badgeColor: AppColors.starlightGold,
                    isHighlight: false,
                    subtitle: 'HER ŞEY AÇIK • Sınırsız PDF • Tüm Modüller & Derin Analizler • Sıfır Reklam',
                    onTap: () => _showPaymentOptions(context, 'Platinum VIP (Aylık)', VipTier.platinum),
                  ),
                  const SizedBox(height: 10),

                  // Package 3: Gold VIP (Aylık)
                  _buildPackageOption(
                    title: 'Gold VIP (Altın Paket)',
                    price: '319 ₺ / ay',
                    period: 'Aylık Abonelik (9\$)',
                    badge: 'EN POPÜLER ⭐',
                    badgeColor: AppColors.pastelMint,
                    isHighlight: false,
                    subtitle: 'Ayda 2 PDF • Sinastri, Lunar Return, Yaşam Döngüleri, Tam Harita Çarkı • Sıfır Reklam',
                    onTap: () => _showPaymentOptions(context, 'Gold VIP (Aylık)', VipTier.gold),
                  ),
                  const SizedBox(height: 10),

                  // Package 4: Silver VIP (Gümüş / Başlangıç)
                  _buildPackageOption(
                    title: 'Silver VIP (Gümüş Paket)',
                    price: '179 ₺ / ay',
                    period: 'Aylık Abonelik (5\$)',
                    badge: 'BAŞLANGIÇ 🌙',
                    badgeColor: AppColors.pastelLavender,
                    isHighlight: false,
                    subtitle: 'Ayda 1 PDF • Melekler, Dekanlar, Çakralar, Sabitler, Tam Harita & Anasayfa • Sıfır Reklam',
                    onTap: () => _showPaymentOptions(context, 'Silver VIP (Aylık)', VipTier.silver),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, String packageName, VipTier tier) {
    final storeName = Platform.isIOS ? 'Apple App Store' : 'Google Play Store';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1A2B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x33FFD166), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              children: [
                Icon(
                  Platform.isIOS ? Icons.apple_rounded : Icons.shop_two_rounded,
                  color: AppColors.starlightGold,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$storeName Abonelik Onayı',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seçilen Paket: $packageName',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.starlightGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Ödemeniz doğrudan $storeName hesabınıza tanımlı ödeme yöntemiyle (Kredi/Banka Kartı, Mobil Ödeme veya Mağaza Bakiyesi) güvenle gerçekleştirilir.\n'
                    '• Üçüncü taraf ödeme aracıları kullanılmaz; kart bilgileriniz yalnızca $storeName güvencesindedir.\n'
                    '• Aboneliğinizi dilediğiniz zaman $storeName > Abonelikler menüsünden iptal edebilirsiniz.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _initiateStorePurchase(context, packageName, tier);
                },
                icon: const Icon(Icons.verified_user_rounded,
                    size: 18, color: Colors.black87),
                label: Text(
                  '$storeName ile Abone Ol',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.starlightGold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showPromoCodeDialog(context, packageName, tier);
                },
                icon: const Icon(Icons.vpn_key_rounded,
                    size: 16, color: AppColors.pastelLavender),
                label: const Text(
                  'VIP Davet / Promosyon Kodu Kullan',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pastelLavender,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.pastelLavender.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _initiateStorePurchase(BuildContext context, String packageName, VipTier tier) {
    final storeName = Platform.isIOS ? 'App Store' : 'Google Play Store';
    final storeSubUrl = Platform.isIOS
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/apps/details?id=com.gokyuzudoktoru.gokyuzu_app';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_rounded,
                color: AppColors.starlightGold, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$storeName Ödeme Bağlantısı',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          '$packageName aboneliğiniz için $storeName uygulama içi satın alma (In-App Billing) oturumu başlatılıyor.\n\n'
          'Mağaza üzerinden aboneliğinizi tamamladığınızda VIP paketiniz hesabınıza otomatik tanımlanacaktır. Eğer özel davet/promosyon kodunuz varsa "Kod Gir" seçeneğini kullanabilirsiniz.',
          style: const TextStyle(
              color: Colors.white70, fontSize: 12.5, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showPromoCodeDialog(context, packageName, tier);
            },
            child: const Text('Promosyon Kodu Gir',
                style: TextStyle(color: AppColors.pastelLavender)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _launchExternalUrl(storeSubUrl);
            },
            child: Text('$storeName\'u Aç',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPromoCodeDialog(BuildContext context, String packageName, VipTier tier) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: AppColors.starlightGold, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'VIP Promosyon / Davet Kodu',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$packageName aktivasyonu için davet kodunuzu girin:',
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Promosyon Kodu',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (codeCtrl.text.trim().toLowerCase() == 'gkyz2453') {
                Navigator.of(ctx).pop();
                await StorageService.setVipTier(tier);
                if (mounted) {
                  setState(() {
                    _isVipUnlocked = true;
                    _isMoonPhaseUnlocked = true;
                  });
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 Tebrikler! $packageName başarıyla aktif edildi.'),
                      backgroundColor: const Color(0xFF1D5A3A),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Geçersiz promosyon kodu.'),
                    backgroundColor: AppColors.savageRed,
                  ),
                );
              }
            },
            child: const Text('Aktif Et',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption({
    required String title,
    required String price,
    required String period,
    required String badge,
    required Color badgeColor,
    required bool isHighlight,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlight
              ? AppColors.starlightGold.withValues(alpha: 0.12)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight
                ? AppColors.starlightGold
                : Colors.white12,
            width: isHighlight ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? 'Tüm VIP modüller, PDF raporlar ve analizler',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.starlightGold,
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.starlightGold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Main VIP Modal ---
  void _showVipConsultationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xFF13111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0x33FFD166), width: 1),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.starlightGold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppTranslationService.tr('VIP KOZMİK DANIŞMANLIK'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: AppColors.starlightGold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppTranslationService.tr('ÖZEL ERİŞİM 👑'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pastelMint,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppTranslationService.tr('İleri Düzey Modüller & Kişiye Özel Astrolojik Analizler'),
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // VIP Purchase & Discreet Activation Card (No raw code visible!)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.starlightGold.withValues(alpha: 0.15),
                        AppColors.pastelLavender.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.starlightGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_open_rounded,
                              size: 16, color: AppColors.starlightGold),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslationService.tr('VIP Ayrıcalıklarını Başlatın'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppTranslationService.tr('Tüm kozmik modüllere ve ileri düzey öngörülere tam erişim için VIP üyeliği başlatın.'),
                        style: const TextStyle(
                            fontSize: 11.5, height: 1.4, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      _isVipUnlocked
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.pastelMint
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.pastelMint
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      color: AppColors.pastelMint, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      AppTranslationService.tr('VIP ERİŞİMİNİZ AKTİF • TÜM MODÜLLER AÇIK 👑'),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.pastelMint,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showPurchaseModal(context),
                                icon: const Icon(Icons.workspace_premium_rounded,
                                    size: 17, color: Colors.black87),
                                label: Text(
                                  AppTranslationService.tr('VIP Abonelik Paketlerini İncele 👑'),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.starlightGold,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  elevation: 2,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.white10),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _buildVipModuleCard(
                      icon: Icons.brightness_medium_rounded,
                      color: AppColors.starlightGold,
                      title: 'Kadersel Tutulmalar & Harita Danışmanlığı',
                      badge: 'TÜM VIP KATMANLARI 🌑',
                      description:
                          'Bu yılın ve gelecek yılın Güneş & Ay tutulmalarının doğum haritanızdaki kadersel ev aksları, tetiklenen gezegenler ve 18 yıllık Saros döngü analizi.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Kadersel Tutulmalar & Harita Danışmanlığı',
                        requiredTier: VipTier.silver,
                        onAccessGranted: () => _showPersonalEclipsesCounselingDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.favorite_rounded,
                      color: AppColors.pastelPink,
                      title: 'Sinastri & İlişki Uyumu (Synastry)',
                      badge: 'GOLD & PLATINUM ⭐',
                      description:
                          'İki kişinin haritasının Placidus evler ve açılarla çakıştırılması. Güneş-Ay ruh bağı, Venüs-Mars tutku ve çekim dinamiği.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Sinastri & İlişki Uyumu',
                        requiredTier: VipTier.gold,
                        onAccessGranted: () => _showSynastryDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.wb_sunny_rounded,
                      color: AppColors.starlightGold,
                      title: 'Solar Return (Yıllık Öngörü Haritası)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          'Güneş\'in doğum anındaki tam derecesine döndüğü anın haritası. 1 yıllık dönemin yükselen burcu, kilit temaları ve dönüm noktaları.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Solar Return (Yıllık Öngörü)',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showSolarReturnDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.auto_graph_rounded,
                      color: AppColors.pastelLavender,
                      title: 'Secondary Progress (İkincil İlerletim)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          '1 Gün = 1 Yıl kuralı. İlerletilmiş Ay fazı, burç ve ev değişimleri; ruhun içsel psikolojik olgunlaşma ve evrim saati.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Secondary Progress (İkincil İlerletim)',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showSecondaryProgressDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.radar_rounded,
                      color: AppColors.pastelPeach,
                      title: 'Solar Arc Directions (Güneş Yayı Yönelimi)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          'Doğum haritasındaki tüm gezegenlerin Güneş hızıyla (yaklaşık 1° = 1 Yıl) ilerletilmesi. Somut dışsal olayları ve evlilik/kariyer piklerini tespit eder.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Solar Arc Directions',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showSolarArcDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.nightlight_round,
                      color: AppColors.pastelBlue,
                      title: 'Lunar Return (Aylık Ay Dönüşü Haritası)',
                      badge: 'GOLD & PLATINUM ⭐',
                      description:
                          'Ay\'ın doğum derecesine döndüğü anın haritası. Her 27.3 günde bir yenilenen duygusal hava durumu, ailevi odak ve ayın kritik günleri.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Lunar Return (Aylık Ay Dönüşü)',
                        requiredTier: VipTier.gold,
                        onAccessGranted: () => _showLunarReturnDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.schedule_rounded,
                      color: AppColors.starlightGold,
                      title: 'Firdaria (Klasik Gezegen Dönemleri)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          'Gündüz veya gece doğuşuna göre hayatın 75 yıllık dönemlerini yöneten ana ve alt gezegen yöneticileri (Al-Biruni ve Bonatti tekniği).',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Firdaria (Klasik Gezegen Dönemleri)',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showFirdariaDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.cached_rounded,
                      color: AppColors.pastelMint,
                      title: 'Yıllık Ev Profeksiyonu (Annual Profections)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          'Doğumdan itibaren her yaş bir evi aktive eder (Örn: 24 yaş = 1. Ev, 25 yaş = 2. Ev). Yılın Efendisi gezegen ve o yıl tetiklenen hayat alanları.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Yıllık Ev Profeksiyonu',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showProfectionDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.hourglass_full_rounded,
                      color: AppColors.warningOrange,
                      title: 'Zodiacal Releasing (Helenistik Burç Salımı)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          'Ruh ve Şans Noktası üzerinden hayatın 4 seviyeli kariyer ve yaşam zirvelerini, hazırlık evrelerini ve kriz geçişlerini gösteren antik yöntem.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Zodiacal Releasing',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showZodiacalReleasingDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.all_inclusive_rounded,
                      color: AppColors.pastelLavender,
                      title: 'Majör Gezegensel Yaşam Döngüleri',
                      badge: 'GOLD & PLATINUM ⭐',
                      description:
                          '29.5 Yaş Satürn Dönüşü, 12 Yıllık Jüpiter Fırsat Dönüşü, 42 Yaş Uranüs Karşıtlığı (Orta Yaş Eşiği) ve Chiron Yarası şifalanması.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Majör Gezegensel Yaşam Döngüleri',
                        requiredTier: VipTier.gold,
                        onAccessGranted: () => _showPlanetaryCyclesDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.access_time_filled_rounded,
                      color: AppColors.pastelLavender,
                      title: 'Rektifikasyon (Hassas Saat Doğrulama)',
                      badge: 'PLATINUM ÖZEL 👑',
                      description:
                          'Doğum saati net bilinmeyen haritalar için; geçmiş önemli tarihler üzerinden dakika düzeyinde doğum saati tespiti ve kalibrasyonu.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: 'Rektifikasyon Doğrulama',
                        requiredTier: VipTier.platinum,
                        onAccessGranted: () => _showRectificationDemo(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVipModuleCard(
                      icon: Icons.picture_as_pdf_rounded,
                      color: AppColors.pastelMint,
                      title: '10 Sayfalık Kapsamlı Harita Kitapçığı',
                      badge: 'TÜM VIP KATMANLARI 📄',
                      description:
                          'Tüm gezegen konumları, 12 ev, temel açılar, sabit yıldızlar, Chiron ve Ay Düğümleri analizini içeren dijital arşiv raporu.',
                      onTap: () => _handleVipModuleTap(
                        context: context,
                        moduleName: '10 Sayfalık Harita Kitapçığı',
                        requiredTier: VipTier.silver,
                        onAccessGranted: () => _showPdfReportDemo(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVipModuleCard({
    required IconData icon,
    required Color color,
    required String title,
    required String badge,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: color.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 18, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppTranslationService.tr(title),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    AppTranslationService.tr(badge),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppTranslationService.tr(description),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppTranslationService.tr('Modülü Başlat'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 13, color: color),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVipModuleTap({
    required BuildContext context,
    required String moduleName,
    required VipTier requiredTier,
    required VoidCallback onAccessGranted,
  }) async {
    final currentTier = await StorageService.getVipTier();
    if (currentTier == VipTier.free) {
      if (context.mounted) _showPurchaseModal(context);
      return;
    }

    if (requiredTier == VipTier.platinum && currentTier != VipTier.platinum) {
      if (context.mounted) {
        _showTierUpgradeModal(context, moduleName, 'Platinum VIP');
      }
      return;
    }

    if (requiredTier == VipTier.gold && currentTier == VipTier.silver) {
      if (context.mounted) {
        _showTierUpgradeModal(context, moduleName, 'Gold veya Platinum VIP');
      }
      return;
    }

    onAccessGranted();
  }

  void _showTierUpgradeModal(BuildContext context, String moduleName, String requiredTierName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.starlightGold, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$requiredTierName Ayrıcalığı',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '“$moduleName” modülü $requiredTierName paketine özeldir.',
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mevcut üyeliğinizi yükselterek bu derin astrolojik analiz aracına ve tüm gelişmiş öngörülere anında erişebilirsiniz.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showPurchaseModal(context);
            },
            child: const Text('Üyeliği Yükselt 👑', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- VIP Interactive Demo Sheets ---

  void _showPersonalEclipsesCounselingDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PersonalEclipsesCounselingSheet(profile: _effectiveProfile),
    );
  }

  void _showSynastryDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SynastryModalContent(profile: _effectiveProfile),
    );
  }

  void _showSolarReturnDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SolarReturnModalContent(profile: _effectiveProfile),
    );
  }

  void _showRectificationDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RectificationModalContent(
        profile: _effectiveProfile,
        onTimeSaved: () async {
          final updated = await StorageService.getProfile();
          if (updated != null && mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  bool _isGeneratingPdf = false;

  Future<void> _handleDownloadPdf(BuildContext modalCtx) async {
    if (!_isVipUnlocked) {
      Navigator.of(modalCtx).pop();
      _showVipConsultationModal(context);
      return;
    }

    final now = DateTime.now();
    final quotaKey = 'pdf_count_${now.year}_${now.month}';
    final prefs = await SharedPreferences.getInstance();
    final usedCount = prefs.getInt(quotaKey) ?? 0;
    final maxQuota = await StorageService.getMonthlyPdfAllowance();

    if (usedCount >= maxQuota) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Bu ayki 10 sayfalık PDF indirme kotanızı doldurdunuz ($usedCount/$maxQuota). Üyeliğinizi yükselterek kotanızı artırabilirsiniz.',
            ),
            backgroundColor: AppColors.savageRed,
          ),
        );
      }
      return;
    }

    setState(() => _isGeneratingPdf = true);
    try {
      final file = await PdfReportService.generate10PageBooklet(profile: _effectiveProfile);
      await prefs.setInt(quotaKey, usedCount + 1);

      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        if (modalCtx.mounted) Navigator.of(modalCtx).pop();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1B2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.pastelMint, width: 1.2),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.pastelMint),
                SizedBox(width: 8),
                Text('PDF Raporunuz Hazır! 📜', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '10 sayfalık kapsamlı kişiselleştirilmiş doğum haritası kitapçığınız başarıyla oluşturuldu, Masaüstünüze ve Belgeler klasörünüze kaydedildi.',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🖥️ Masaüstünüzde açıldı: ~/Desktop/Gokyuzu_Doktoru_...pdf',
                        style: TextStyle(color: AppColors.starlightGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📁 ${file.path}',
                        style: const TextStyle(color: AppColors.pastelMint, fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kalan Kota: ${maxQuota - (usedCount + 1)} indirme hakkı',
                  style: const TextStyle(color: AppColors.starlightGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  try {
                    if (Platform.isMacOS) {
                      Process.run('open', [file.path]);
                    }
                  } catch (_) {}
                },
                child: const Text('Raporu Aç 📄', style: TextStyle(color: AppColors.starlightGold, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tamam', style: TextStyle(color: AppColors.pastelMint, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ PDF oluşturulurken hata oluştu: $e'),
            backgroundColor: AppColors.savageRed,
          ),
        );
      }
    }
  }

  void _showPdfReportDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: '10 Sayfalık Kapsamlı Harita Kitapçığı',
        color: AppColors.pastelMint,
        icon: Icons.picture_as_pdf_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pastelMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_stories_rounded,
                    color: AppColors.pastelMint, size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kişiselleştirilmiş Kozmik Analiz (10 Sayfa)',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Baskıya ve dijital arşive hazır, vektörel yüksek çözünürlüklü 10 sayfalık detaylı harita kitapçığı.',
                        style: TextStyle(fontSize: 11.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Paket İndirme Kotaları Kutusu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.starlightGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.starlightGold.withValues(alpha: 0.35)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.download_done_rounded,
                        size: 16, color: AppColors.starlightGold),
                    SizedBox(width: 8),
                    Text(
                      'Aylık PDF İndirme Hakları & Kotaları:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.starlightGold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('• Silver VIP: Ayda 1 kez 10 sayfalık PDF indirme hakkı',
                    style: TextStyle(fontSize: 11.5, color: Colors.white)),
                SizedBox(height: 3),
                Text('• Gold VIP: Ayda 2 kez 10 sayfalık PDF indirme hakkı',
                    style: TextStyle(fontSize: 11.5, color: Colors.white)),
                SizedBox(height: 3),
                Text('• Platinum VIP: Ayda 3 kez 10 sayfalık PDF indirme hakkı',
                    style: TextStyle(fontSize: 11.5, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            '10 Sayfalık Kitapçık İçindekiler Tablosu:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          _buildDemoAspectItem(
            aspect: 'Bölüm 1 (Sayfa 1-2)',
            tag: 'Büyük Üçlü',
            desc: 'Güneş, Ay ve Yükselen Burcun derin psikolojik ve mizaç analizi.',
            color: AppColors.starlightGold,
          ),
          _buildDemoAspectItem(
            aspect: 'Bölüm 2 (Sayfa 3-5)',
            tag: '12 Yaşam Evi',
            desc: 'Placidus ev sistemine göre tüm yaşam alanları ve gezegen yerleşimleri.',
            color: AppColors.pastelPink,
          ),
          _buildDemoAspectItem(
            aspect: 'Bölüm 3 (Sayfa 6-7)',
            tag: 'Temel Açılar',
            desc: 'Kavuşum, üçgen, sekstil, kare ve karşıt açıların potansiyel ve gölge yönleri.',
            color: AppColors.pastelLavender,
          ),
          _buildDemoAspectItem(
            aspect: 'Bölüm 4 (Sayfa 8-9)',
            tag: 'Karmik Düğümler & Sabitler',
            desc: 'Kuzey/Güney Ay Düğümleri, Chiron şifası, Algol, Sirius, Regulus yıldız kavuşumları.',
            color: AppColors.pastelBlue,
          ),
          _buildDemoAspectItem(
            aspect: 'Bölüm 5 (Sayfa 10)',
            tag: 'Gezegen Saatleri & Şans Noktası',
            desc: 'Günün yöneticisi gezegen saati, Hermetik mizacı ve Pars Fortuna potansiyeli.',
            color: AppColors.pastelMint,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingPdf ? null : () => _handleDownloadPdf(ctx),
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.download_rounded, size: 20, color: Colors.black),
              label: Text(
                _isGeneratingPdf
                    ? '10 Sayfalık PDF Hazırlanıyor...'
                    : '10 Sayfalık Kitapçığı İndir (PDF) 📥',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelMint,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDemoSheet({
    required BuildContext ctx,
    required String title,
    required Color color,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      height: MediaQuery.of(ctx).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF13111C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFD166), width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAspectItem({
    required String aspect,
    required String tag,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  aspect,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- Günün Kozmik Motivasyon Sözü ---
  Widget _buildDailyCosmicQuoteCard() {
    final quote = CosmicQuotesService.getDailyQuote();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pastelLavender.withValues(alpha: 0.15),
            AppColors.starlightGold.withValues(alpha: 0.08),
            const Color(0xFF161226),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pastelLavender.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: AppColors.starlightGold, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppTranslationService.tr('GÜNÜN KOZMİK MOTİVASYONU'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.starlightGold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pastelLavender.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppTranslationService.tr(quote.category),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pastelLavender,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '“${quote.quote}”',
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '— ${quote.author} (${quote.title})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pastelPeach,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white10,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 14, color: AppColors.pastelMint),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppTranslationService.tr('Transit Teması:')} ${AppTranslationService.tr(quote.transitTheme)}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pastelMint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppTranslationService.tr(quote.practicalReflection),
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardedAdForMoonPhase(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _RewardedAdDialog(
          onRewardEarned: () {
            setState(() {
              _isMoonPhaseUnlocked = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    '🎉 Tebrikler! Günlük Ay Burcu, Fazı ve Canlı Gökyüzü Geçişleri kilidi açıldı.'),
                backgroundColor: Color(0xFF1D5A3A),
                duration: Duration(seconds: 3),
              ),
            );
          },
        );
      },
    );
  }

  // --- Live Sky & Moon Transits Section ---
  Widget _buildLiveSkyTransitsSection() {
    final isUnlocked = _isMoonPhaseUnlocked || _isVipUnlocked;

    if (!isUnlocked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.pastelLavender,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppTranslationService.tr('CANLI GÖKYÜZÜ & AY GEÇİŞLERİ'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      color: AppColors.pastelLavender,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.starlightGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 11, color: AppColors.starlightGold),
                    const SizedBox(width: 4),
                    Text(
                      AppTranslationService.tr('KİLİTLİ'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.starlightGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderColor: AppColors.pastelLavender.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.pastelLavender.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🌙', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslationService.tr('Günlük Ay Fazı & Canlı Transitler'),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppTranslationService.tr('Anlık Ay fazı, aydınlanma oranı, boşlukta takvimi, yanık yol uyarısı ve gezegen transitlerini görüntüleyin.'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRewardedAdForMoonPhase(context),
                        icon: const Icon(Icons.play_circle_fill_rounded,
                            size: 16, color: Colors.white),
                        label: Text(
                          AppTranslationService.tr('Reklam İzle Aç 🎬'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryViolet,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPurchaseModal(context),
                        icon: const Icon(Icons.workspace_premium_rounded,
                            size: 16, color: AppColors.starlightGold),
                        label: Text(
                          AppTranslationService.tr('VIP Sınırsız 👑'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.starlightGold),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    final moonPhase = SkyTransitsService.getMoonPhase();
    final voc = SkyTransitsService.getVoidOfCourse();
    final orbit = SkyTransitsService.getMoonMovementTrack();
    final transits = SkyTransitsService.getCurrentTransits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.pastelMint,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pastelMint,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppTranslationService.tr('CANLI GÖKYÜZÜ & AY GEÇİŞLERİ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            color: AppColors.pastelMint,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showAllTransitsModal(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      AppTranslationService.tr('Tüm Geçişler'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.starlightGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: AppColors.starlightGold),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderColor: AppColors.pastelMint.withValues(alpha: 0.35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Moon Phase and Vibe
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pastelLavender.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.pastelLavender.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        moonPhase.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppTranslationService.tr(moonPhase.phaseName),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '%${moonPhase.illuminationPercent.toInt()} ${AppTranslationService.tr('Aydınlanma')}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppTranslationService.tr(moonPhase.astrologicalVibe),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.pastelLavender,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Void of Course Alert Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: voc.isVoid
                      ? AppColors.warningOrange.withValues(alpha: 0.12)
                      : AppColors.pastelMint.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: voc.isVoid
                        ? AppColors.warningOrange.withValues(alpha: 0.35)
                        : AppColors.pastelMint.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      voc.isVoid
                          ? Icons.hourglass_top_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 16,
                      color: voc.isVoid
                          ? AppColors.warningOrange
                          : AppColors.pastelMint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        voc.isVoid
                            ? AppTranslationService.tr('Ay Boşlukta! Yeni başlangıçlar yerine tamamlamaya odaklanın.')
                            : AppTranslationService.tr('Ay Boşlukta Değil (Aktif) • Enerjiler akıcı'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: voc.isVoid
                              ? AppColors.warningOrange
                              : AppColors.pastelMint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${AppTranslationService.tr('Sonraki:')} ${AppTranslationService.signName(voc.nextSign)} (${voc.nextIngressTime})',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Via Combusta (Yanık Yol) Bildirimi & Kartı
              Builder(
                builder: (context) {
                  final viaCombusta = SkyTransitsService.getViaCombustaInfo();
                  if (!viaCombusta.isViaCombusta) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.savageRed.withValues(alpha: 0.18),
                          AppColors.warningOrange.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.savageRed.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 18,
                                    color: AppColors.savageRed,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      AppTranslationService.tr(viaCombusta.title),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.savageRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.savageRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppTranslationService.tr(viaCombusta.statusBadge),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.savageRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${AppTranslationService.tr('Konum:')} ${AppTranslationService.tr(viaCombusta.currentMoonPosition)} (${AppTranslationService.tr('Kuşak:')} ${viaCombusta.zoneRange})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppTranslationService.tr(viaCombusta.counsel),
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppTranslationService.tr(viaCombusta.exitEstimation),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pastelLavender,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Kadim Ay Menzili & Hermetik Durak
              Builder(
                builder: (context) {
                  final mansion = LunarMansionsService.getCurrentMoonMansion();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.starlightGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.starlightGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded,
                                      size: 16, color: AppColors.starlightGold),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${AppTranslationService.tr('AY MENZİLİ & HERMETİK DURAK')} (${mansion.number}/28)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                        color: AppColors.starlightGold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showAllLunarMansionsModal(context),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  AppTranslationService.tr('28 Menzil Listesi →'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.starlightGold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${AppTranslationService.tr(mansion.name)} • ${AppTranslationService.tr(mansion.signRange)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppTranslationService.tr('Hermetik Doğa:')} ${AppTranslationService.tr(mansion.nature)} (${AppTranslationService.tr(mansion.element)} ${AppTranslationService.tr('Unsuru')})',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.pastelMint),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppTranslationService.tr(mansion.description),
                          style: const TextStyle(fontSize: 11, height: 1.35, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✓ ${AppTranslationService.tr('Uğurlu:')} ${AppTranslationService.tr(mansion.favorableFor)}',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.pastelMint),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '✗ ${AppTranslationService.tr('Sakınılmalı:')} ${AppTranslationService.tr(mansion.avoidFor)}',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.pastelPeach),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 10),

              // Animated Orbital Movement Track
              Row(
                children: [
                  const Icon(Icons.timeline_rounded,
                      size: 15, color: AppColors.starlightGold),
                  const SizedBox(width: 6),
                  Text(
                    AppTranslationService.tr('AYIN GÖKYÜZÜ YOLCULUĞU & AÇI HATTI'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.starlightGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Departing
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslationService.tr('Son Temas (Ayrılan)'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 9.5, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppTranslationService.planetName(orbit.departingPlanet),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pastelLavender,
                                ),
                              ),
                              Text(
                                AppTranslationService.tr(orbit.departingAspect),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Center: Current Moon
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.starlightGold
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.starlightGold
                                    .withValues(alpha: 0.6)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                AppTranslationService.tr('☽ ŞU AN'),
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                              Text(
                                '${orbit.currentMoonDegree} ${AppTranslationService.signName(orbit.currentMoonSign)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Right: Approaching
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppTranslationService.tr('Sıradaki Temas (Yaklaşan)'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontSize: 9.5, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppTranslationService.planetName(orbit.approachingPlanet),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pastelPink,
                                ),
                              ),
                              Text(
                                AppTranslationService.tr(orbit.approachingAspect),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Track Bar
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: orbit.progressPercent,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.pastelLavender,
                                  AppColors.starlightGold,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Live Transit Planets Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: transits.take(6).length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final t = transits[i];
                    final starName = t.conjunctStars.isNotEmpty
                        ? t.conjunctStars.first.name
                        : null;
                    return InkWell(
                      onTap: () => _showAllTransitsModal(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: starName != null
                                ? AppColors.starlightGold
                                    .withValues(alpha: 0.5)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(t.symbol,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.starlightGold)),
                            const SizedBox(width: 6),
                            Text(
                              '${t.name} ${t.degreeStr}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (starName != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.starlightGold
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '★ $starName',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.starlightGold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- All Transits Modal ---
  void _showAllTransitsModal(BuildContext context) {
    final transits = SkyTransitsService.getCurrentTransits();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: AppTranslationService.tr('Canlı Gezegen Geçişleri & Sabit Yıldızlar'),
        color: AppColors.pastelMint,
        icon: Icons.public_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.pastelMint, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppTranslationService.tr('Şu an gökyüzünde gerçekleşen anlık gezegen konumları ve Yiğithan Akman Sabit Yıldızlar Kataloğu dereceleriyle kurulan kavuşumlar gösterilmektedir.'),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Via Combusta (Yanık Yol) Bildirimi
          Builder(
            builder: (ctx) {
              final vc = SkyTransitsService.getViaCombustaInfo();
              if (!vc.isViaCombusta) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.savageRed.withValues(alpha: 0.22),
                      const Color(0xFF26121E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.savageRed.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  color: AppColors.savageRed, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppTranslationService.tr(vc.title),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.savageRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.savageRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppTranslationService.tr(vc.statusBadge),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.savageRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTranslationService.tr(vc.description),
                      style: const TextStyle(
                          fontSize: 11.5, height: 1.4, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${AppTranslationService.tr('Tavsiye:')} ${AppTranslationService.tr(vc.counsel)}',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: AppColors.starlightGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTranslationService.tr(vc.exitEstimation),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pastelMint,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ...transits.map((t) {
            final hasStars = t.conjunctStars.isNotEmpty;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1625),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasStars
                      ? AppColors.starlightGold.withValues(alpha: 0.4)
                      : Colors.white12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(t.symbol,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.starlightGold)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppTranslationService.planetName(t.name),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (t.isRetrograde) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.savageRed
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Rx',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.savageRed)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppTranslationService.tr(t.degreeStr),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr(t.theme),
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  if (hasStars) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: t.conjunctStars.map((s) {
                          return Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: AppColors.starlightGold),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${AppTranslationService.tr(s.name)} (${s.degree.toInt()}° ${AppTranslationService.signName(s.sign)}) • ${AppTranslationService.tr(s.nature)} • ${AppTranslationService.tr(s.meaning)}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.starlightGold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAllLunarMansionsModal(BuildContext context) {
    final mansions = LunarMansionsService.mansions;
    final current = LunarMansionsService.getCurrentMoonMansion();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: AppTranslationService.tr('28 Kadim Ay Menzili & Hermetik Duraklar'),
        color: AppColors.starlightGold,
        icon: Icons.stars_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.starlightGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.starlightGold.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.starlightGold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppTranslationService.tr('Manazil el-Qamar (Kadim Arapça & Hermetik Ay Durakları). Ay her 28 durağı yaklaşık 1 günde geçer. Şu an transit Ay, ${current.number}. Menzil (${current.name}) durağındadır.'),
                    style: const TextStyle(
                        fontSize: 12, height: 1.4, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...mansions.map((m) {
            final isCurrent = m.number == current.number;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF231D14)
                    : const Color(0xFF14121E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrent ? AppColors.starlightGold : Colors.white12,
                  width: isCurrent ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.starlightGold
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${m.number}. ${AppTranslationService.tr('Menzil')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCurrent ? Colors.black : Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppTranslationService.tr(m.name),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.starlightGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppTranslationService.tr('ŞU AN AKTİF 🌙'),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${m.arabicName} • ${AppTranslationService.tr(m.signRange)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.starlightGold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppTranslationService.tr('Doğa:')} ${AppTranslationService.tr(m.nature)} • ${AppTranslationService.tr('Unsur:')} ${AppTranslationService.tr(m.element)}',
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.pastelMint),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr(m.description),
                    style: const TextStyle(
                        fontSize: 11.5, height: 1.4, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✓ ${AppTranslationService.tr('Uğurlu:')} ${AppTranslationService.tr(m.favorableFor)}',
                            style: const TextStyle(
                                fontSize: 10.5, color: AppColors.pastelMint)),
                        const SizedBox(height: 3),
                        Text('✗ ${AppTranslationService.tr('Sakınılmalı:')} ${AppTranslationService.tr(m.avoidFor)}',
                            style: const TextStyle(
                                fontSize: 10.5, color: AppColors.pastelPeach)),
                        const SizedBox(height: 3),
                        Text('🔮 ${AppTranslationService.tr('Tılsım Enerjisi:')} ${AppTranslationService.tr(m.hermeticTalisman)}',
                            style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.pastelLavender)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Predictive Modals ---

  void _showSecondaryProgressDemo(BuildContext context) {
    final prog = PredictiveAstrologyService.calculateSecondaryProgressions(
      profile: widget.profile,
    );
    final double age = (prog['age'] as num).toDouble();
    final String progMoonFormatted = prog['progMoonFormatted'] as String;
    final String progAscFormatted = prog['progAscFormatted'] as String;
    final String progMcFormatted = prog['progMcFormatted'] as String;
    final String progSunFormatted = prog['progSunFormatted'] as String;
    final String progMoonSign = prog['progMoonSign'] as String;
    final int progMoonDeg = prog['progMoonDeg'] as int;
    final int progMoonMin = prog['progMoonMin'] as int;
    final Map<String, String> currentTheme = Map<String, String>.from(prog['currentTheme'] as Map);

    final natalMoonSign = widget.profile.moonSign.isNotEmpty ? widget.profile.moonSign : 'Akrep';
    final natalSunSign = widget.profile.sunSign.isNotEmpty ? widget.profile.sunSign : 'Balık';
    final natalAscSign = widget.profile.risingSign.isNotEmpty ? widget.profile.risingSign : 'İkizler';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: 'Secondary Progress (İkincil İlerletim)',
        color: AppColors.pastelLavender,
        icon: Icons.auto_graph_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelLavender.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.pastelLavender.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: AppColors.starlightGold),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Solar Fire Motoru (1 Gün = 1 Yıl)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pastelLavender,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${age.toStringAsFixed(1)} Yaş Haritası',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Doğum gününüzden sonraki her gün hayatınızdaki 1 tam yıla tekabül eder. Özellikle İlerlemiş Ay (Progressed Moon) yaklaşık 2.5 yılda bir burç değiştirerek o dönemin baskın ruh halini ve duygusal odağını belirler.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vurgulu İlerlemiş Ay Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.starlightGold.withValues(alpha: 0.2),
                  const Color(0xFF1D162B),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.nightlight_round, color: AppColors.starlightGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'İLERLETİLMİŞ AY (PROGRESSED MOON)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.starlightGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentTheme['tag']!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  progMoonFormatted,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Doğumdaki $natalMoonSign Ayınız, şu anki ${age.toStringAsFixed(1)} yaşınızda $progMoonSign burcunun $progMoonDeg° $progMoonMin\' derecesine ilerlemiş durumdadır.',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.pastelLavender),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTheme['desc']!,
                  style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _buildDemoAspectItem(
            aspect: 'İlerletilmiş Yükselen (ASC): $progAscFormatted',
            tag: 'Dış Dünyaya Açılan Kapı & Fiziksel Evrim',
            desc:
              'Doğumdaki $natalAscSign Yükselen noktanız Solar Arc MC trigonometrisiyle $progAscFormatted derecesine ilerlemiştir. Dış dünyaya verdiğiniz imaj, hayata yaklaşımınız ve kişisel motivasyonunuz bu arketipin özelliklerini yansıtır.',
            color: AppColors.starlightGold,
          ),
          _buildDemoAspectItem(
            aspect: 'İlerletilmiş Tepe Noktası (MC): $progMcFormatted',
            tag: 'Kariyer & Toplumsal Statü Yönelimi',
            desc:
              'Kariyer, mesleki vizyon ve toplum önündeki duruş noktanız $progMcFormatted derecesine ilerlemiştir. Mesleki hedefleriniz ve unvanınız bu burç ekseninde şekillenir.',
            color: AppColors.pastelMint,
          ),
          _buildDemoAspectItem(
            aspect: 'İlerletilmiş Güneş: $progSunFormatted',
            tag: 'Karakter & Kimlik Evrimi',
            desc:
              'Doğumdaki $natalSunSign Güneş enerjiniz, yaşınızla birlikte $progSunFormatted konumuna doğru olgunlaşmış ve yeni bir bilinç aşamasına geçmiştir.',
            color: AppColors.pastelPeach,
          ),
        ],
      ),
    );
  }

  void _showSolarArcDemo(BuildContext context) {
    final arcData = PredictiveAstrologyService.calculateSolarArc(
      profile: widget.profile,
    );
    final double age = (arcData['age'] as num).toDouble();
    final String arcFormatted = arcData['arcFormatted'] as String;
    final List<Map<String, dynamic>> aspects = List<Map<String, dynamic>>.from(arcData['aspects']);
    final colors = [
      AppColors.starlightGold,
      AppColors.pastelPink,
      AppColors.pastelMint,
      AppColors.pastelLavender,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: 'Solar Arc Directions (Güneş Yayı Yönelimi)',
        color: AppColors.pastelPeach,
        icon: Icons.radar_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelPeach.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.pastelPeach.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Solar Arc İlerlemesi ($arcFormatted / ${age.toStringAsFixed(1)} Yaş)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pastelPeach,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateTime.now().year}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.profile.birthDate} doğumunuzdan itibaren Güneş\'in katettiği mesafe kadar ($arcFormatted) tüm natal noktalarınız yönlendirilmiştir. Solar Arc gezegenlerin ve aksların natal haritayla kurduğu kesin açılar somut yaşam dönemeçlerini aktive eder.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...aspects.asMap().entries.map((entry) {
            final idx = entry.key;
            final asp = entry.value;
            return _buildDemoAspectItem(
              aspect: asp['aspect'] as String,
              tag: asp['tag'] as String,
              desc: asp['desc'] as String,
              color: colors[idx % colors.length],
            );
          }),
        ],
      ),
    );
  }

  void _showLunarReturnDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LunarReturnModalContent(profile: widget.profile),
    );
  }

  void _showFirdariaDemo(BuildContext context) {
    DateTime birthDate;
    try {
      birthDate = DateTime.parse(widget.profile.birthDate);
    } catch (_) {
      birthDate = DateTime(1991, 3, 6);
    }
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    if (age < 0) age = 0;

    // Gündüz / Gece Doğumu Ayrımı (Astronomik Sect)
    final isDayBirth = PredictiveAstrologyService.isDayChart(widget.profile);

    String mainPlanet;
    int mainDuration;
    int mainStartAge;
    String subPlanet;
    String nextSubPlanet;

    if (isDayBirth) {
      if (age < 10) {
        mainPlanet = 'Güneş ☉'; mainDuration = 10; mainStartAge = 0; subPlanet = 'Güneş'; nextSubPlanet = 'Venüs';
      } else if (age < 18) {
        mainPlanet = 'Venüs ♀'; mainDuration = 8; mainStartAge = 10; subPlanet = 'Venüs'; nextSubPlanet = 'Merkür';
      } else if (age < 31) {
        mainPlanet = 'Merkür ☿'; mainDuration = 13; mainStartAge = 18; subPlanet = 'Merkür'; nextSubPlanet = 'Ay';
      } else if (age < 40) {
        mainPlanet = 'Ay ☽'; mainDuration = 9; mainStartAge = 31;
        final subIndex = (((age - 31) / (9.0 / 7.0)).floor()).clamp(0, 6);
        final subs = ['Ay', 'Satürn', 'Jüpiter', 'Mars', 'Güneş', 'Venüs', 'Merkür'];
        subPlanet = subs[subIndex];
        nextSubPlanet = subs[(subIndex + 1) % 7];
      } else if (age < 51) {
        mainPlanet = 'Satürn ♄'; mainDuration = 11; mainStartAge = 40; subPlanet = 'Satürn'; nextSubPlanet = 'Jüpiter';
      } else {
        mainPlanet = 'Jüpiter ♃'; mainDuration = 12; mainStartAge = 51; subPlanet = 'Jüpiter'; nextSubPlanet = 'Mars';
      }
    } else {
      if (age < 9) {
        mainPlanet = 'Ay ☽'; mainDuration = 9; mainStartAge = 0; subPlanet = 'Ay'; nextSubPlanet = 'Satürn';
      } else if (age < 20) {
        mainPlanet = 'Satürn ♄'; mainDuration = 11; mainStartAge = 9; subPlanet = 'Satürn'; nextSubPlanet = 'Jüpiter';
      } else if (age < 32) {
        mainPlanet = 'Jüpiter ♃'; mainDuration = 12; mainStartAge = 20; subPlanet = 'Jüpiter'; nextSubPlanet = 'Mars';
      } else if (age < 39) {
        mainPlanet = 'Mars ♂'; mainDuration = 7; mainStartAge = 32; subPlanet = 'Mars'; nextSubPlanet = 'Güneş';
      } else {
        mainPlanet = 'Güneş ☉'; mainDuration = 10; mainStartAge = 39; subPlanet = 'Güneş'; nextSubPlanet = 'Venüs';
      }
    }

    final mainEndAge = mainStartAge + mainDuration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: 'Firdaria (Klasik Gezegen Dönemleri)',
        color: AppColors.starlightGold,
        icon: Icons.schedule_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.starlightGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.starlightGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Ortaçağ Zaman Yöneticiliği Sistemi (Al-Biruni)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDayBirth ? 'Gündüz Doğumu ☀️' : 'Gece Doğumu 🌙',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Doğum haritanız ($age yaş, ${widget.profile.birthCity}) baz alınarak Firdaria döngünüz hesaplanmıştır. Gündüz doğumlarda Güneş, gece doğumlarda Ay döngüsüyle başlar. Şu anda $mainStartAge - $mainEndAge yaşları arasındaki $mainPlanet ana dönemi aktif durumdadır.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDemoAspectItem(
            aspect: 'Aktif Ana Dönem Yöneticisi: $mainPlanet ($mainDuration Yıl)',
            tag: '$mainStartAge - $mainEndAge Yaş Arası',
            desc:
              'Bu dönemde haritanızdaki $mainPlanet yerleşimi ve asaleti yaşamınızın ana temasını, psikolojik evrimini ve önceliklerini yönetir.',
            color: AppColors.pastelMint,
          ),
          _buildDemoAspectItem(
            aspect: 'Aktif Alt Dönem: $subPlanet',
            tag: 'Şu Anki Eylem Alanı',
            desc:
              '$mainPlanet ana döngüsü altında $subPlanet alt yöneticiliği devrededir; gündelik kararlar ve somut gelişmeler bu gezegenin arketipiyle şekillenir.',
            color: AppColors.starlightGold,
          ),
          _buildDemoAspectItem(
            aspect: 'Sıradaki Alt Dönem: $nextSubPlanet',
            tag: 'Gelecek Faz',
            desc:
              'Mevcut döngü tamamlandığında $nextSubPlanet alt dönemi başlayacak ve yaşam rotasında yeni bir ivme açılacaktır.',
            color: AppColors.savageRed,
          ),
        ],
      ),
    );
  }

  void _showProfectionDemo(BuildContext context) {
    DateTime birthDate;
    try {
      birthDate = DateTime.parse(widget.profile.birthDate);
    } catch (_) {
      birthDate = DateTime(1991, 3, 6);
    }
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    if (age < 0) age = 0;

    final int activeHouse = (age % 12) + 1;
    final String ascSign = widget.profile.risingSign.isNotEmpty
        ? widget.profile.risingSign
        : 'İkizler';
    final int ascIdx = AstrologyEngine.zodiacSigns.indexOf(ascSign);
    final validAscIdx = ascIdx >= 0 ? ascIdx : 2;

    final int profSignIdx = (validAscIdx + (activeHouse - 1)) % 12;
    final String profSign = AstrologyEngine.zodiacSigns[profSignIdx];

    final Map<String, String> traditionalLords = {
      'Koç': 'Mars ♂',
      'Boğa': 'Venüs ♀',
      'İkizler': 'Merkür ☿',
      'Yengeç': 'Ay ☽',
      'Aslan': 'Güneş ☉',
      'Başak': 'Merkür ☿',
      'Terazi': 'Venüs ♀',
      'Akrep': 'Mars ♂ & Plüton ♇',
      'Yay': 'Jüpiter ♃',
      'Oğlak': 'Satürn ♄',
      'Kova': 'Satürn ♄ & Uranüs ♅',
      'Balık': 'Jüpiter ♃ & Neptün ♆',
    };
    final String lordOfTheYear = traditionalLords[profSign] ?? 'Venüs ♀';

    final Map<int, String> houseThemes = {
      1: 'Kişisel Kimlik, Beden Sağlığı & Yeni Başlangıçlar',
      2: 'Maddi Gelirler, Taşınır Mallar & Öz Değer',
      3: 'İletişim, Kardeşler, Sözleşmeler & Yakın Çevre',
      4: 'Ev, Aile, Kökler, Gayrimenkul & İç Huzur (IC)',
      5: 'Aşk, Yaratıcılık, Çocuklar, Hobiler & Neşe',
      6: 'Günlük Rutinler, Çalışma Ortamı & Beden Sağlığı',
      7: 'Evlilik, Ortaklıklar, Anlaşmalar & İkili İlişkiler (DSC)',
      8: 'Dönüşüm, Ortak Finans, Miras & Okült Derinlik',
      9: 'Yüksek Öğrenim, Felsefe, Yurt Dışı & Yaşam Vizyonu',
      10: 'Kariyer Zirvesi, Toplumsal İtibar & Hayat Amacı (MC)',
      11: 'Gelecek Umutları, Sosyal Çevre & Kolektif Projeler',
      12: 'Bilinçaltı, İnziva, Ruhsal Arınma & Karmik Kapanışlar',
    };
    final String houseTheme = houseThemes[activeHouse] ?? 'Ruhsal Uyanış & Dönüşüm';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: 'Yıllık Ev Profeksiyonu (Annual Profections)',
        color: AppColors.pastelMint,
        icon: Icons.cached_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Yaşa Göre Aktif Ev ve Lord of the Year',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pastelMint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$age Yaş (Yıl ${now.year})',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Doğum tarihiniz (${widget.profile.birthDate}) ve yükselen burcunuz ($ascSign) baz alınarak ${now.year} yılı için $age yaş profeksiyonu hesaplanmıştır. Doğum anından itibaren her yaş bir evi aktive eder ($age mod 12 = $activeHouse. Ev). Yükseleniniz $ascSign aksından sayıldığında bu yıl $profSign burcu ve yöneticisi $lordOfTheYear aktiftir.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDemoAspectItem(
            aspect: 'Aktif Yaş Evi: $activeHouse. Ev ($profSign Profeksiyonu)',
            tag: houseTheme,
            desc:
              'Bu yaşta ($age) hayatınızın odak noktası $profSign burcunun temaları ve $activeHouse. evin konularıdır. $profSign yükselen etkisiyle dünyevi veya ruhsal enerjiniz bu alana akar.',
            color: AppColors.starlightGold,
          ),
          _buildDemoAspectItem(
            aspect: 'Yılın Efendisi (Lord of the Year): $lordOfTheYear',
            tag: 'Merkezi Gezegen',
            desc:
              'Bu yıl boyunca gökyüzünde $lordOfTheYear tarafından yapılan tüm açılar, transitler ve döngüler hayatınızda diğer tüm gezegenlerden kat be kat daha baskın olayları tetikler.',
            color: AppColors.pastelPeach,
          ),
          _buildDemoAspectItem(
            aspect: 'Profeksiyon Yükseleni: $profSign',
            tag: 'Dönemsel Arketip',
            desc:
              'Doğumdaki $ascSign yükseleniniz bu yıl $profSign arketipinin filtresinden geçer; sabırlı, sağlam temelli ve üretken yaklaşımlar ön plana çıkar.',
            color: AppColors.pastelLavender,
          ),
        ],
      ),
    );
  }

  void _showZodiacalReleasingDemo(BuildContext context) {
    final zrData = PredictiveAstrologyService.calculateZodiacalReleasing(
      profile: widget.profile,
    );

    final String spiritSign = zrData['spiritSign'] as String;
    final String spiritFormatted = zrData['spiritFormatted'] as String;
    final String l1Sign = zrData['l1Sign'] as String;
    final int l1Years = zrData['l1DurationYears'] as int;
    final String l1StartDate = zrData['l1StartDate'] as String;
    final String l1EndDate = zrData['l1EndDate'] as String;

    final String l2Sign = zrData['l2Sign'] as String;
    final int l2Months = zrData['l2DurationMonths'] as int;
    final String l2StartDate = zrData['l2StartDate'] as String;
    final String l2EndDate = zrData['l2EndDate'] as String;

    final String l3Sign = (zrData['l3Sign'] as String?) ?? l2Sign;
    final String l3Days = (zrData['l3Days'] is num
        ? ((zrData['l3Days'] as num) % 1 == 0
            ? (zrData['l3Days'] as num).toInt().toString()
            : (zrData['l3Days'] as num).toStringAsFixed(1))
        : '20');
    final String l3StartDate = (zrData['l3StartDate'] as String?) ?? l2StartDate;
    final String l3EndDate = (zrData['l3EndDate'] as String?) ?? l2EndDate;

    final String peakStatusText = zrData['peakStatusText'] as String;
    final bool isPeak = zrData['isPeak'] as bool;
    final List<Map<String, dynamic>> timeline = List<Map<String, dynamic>>.from(zrData['timeline'] as List);

    final spiritIdx = AstrologyEngine.zodiacSigns.indexOf(spiritSign);
    final validSpiritIdx = spiritIdx >= 0 ? spiritIdx : 0;
    final angle4 = AstrologyEngine.zodiacSigns[(validSpiritIdx + 3) % 12];
    final angle7 = AstrologyEngine.zodiacSigns[(validSpiritIdx + 6) % 12];
    final angle10 = AstrologyEngine.zodiacSigns[(validSpiritIdx + 9) % 12];

    final activeL1Index = timeline.indexWhere((e) => e['sign'] == l1Sign);
    final Set<int> expandedL1 = activeL1Index >= 0 ? {activeL1Index} : {0};
    final Set<String> expandedL2 = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: 'Zodiacal Releasing (Helenistik Burç Salımı)',
        color: AppColors.warningOrange,
        icon: Icons.hourglass_full_rounded,
        children: [
          // 1. AKTİF SEVİYE 1 & SEVİYE 2 & SEVİYE 3 VURGULU KART
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warningOrange.withValues(alpha: 0.22),
                  const Color(0xFF221710),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.warningOrange.withValues(alpha: 0.7),
                width: 1.4,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: AppColors.warningOrange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AKTİF SEVİYE 1 (L1) DÖNEMİ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.warningOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        peakStatusText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'L1 ${l1Sign.toUpperCase()} ($l1Years Yıllık Majör Döngü)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🗓️ Başlangıç: $l1StartDate • Bitiş: $l1EndDate',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningOrange,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppColors.starlightGold),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Aktif Seviye 2 (L2) Alt Dönemi: $l2Sign ($l2Months Ay)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.starlightGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$l2StartDate – $l2EndDate tarihleri arasında L2 $l2Sign alt dönemindesiniz. ${isPeak ? "Bu dönem iradi hedeflerinizde ve mesleki hamlelerinizde tepe noktası oluşturur." : "Bu dönem temel atma, hazırlık ve büyüme evresini temsil eder."}',
                        style: TextStyle(fontSize: 11, height: 1.4, color: Colors.white.withAlpha(210)),
                      ),
                      const Divider(color: Colors.white12, height: 14),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppColors.pastelMint),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Aktif Seviye 3 (L3) Mikro Dönemi: $l3Sign ($l3Days Gün)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pastelMint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$l3StartDate – $l3EndDate tarihleri arasında L3 $l3Sign mikro gün döngüsündesiniz.',
                        style: TextStyle(fontSize: 11, height: 1.4, color: Colors.white.withAlpha(200)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Helenistik astrolojinin 360 günlük Mısır yılı hesaplamasına göre; ${widget.profile.birthDate} doğum anınızdaki Ruh Noktanız ($spiritSign - $spiritFormatted) referans alınarak döngüler salınmıştır. Şu anda $l1Years yıllık L1 $l1Sign ana evresindesiniz ($peakStatusText).',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. KRONOLOJİK SEVİYE 1 (L1) -> SEVİYE 2 (L2) -> SEVİYE 3 (L3) ZAMAN ÇİZELGESİ
          StatefulBuilder(
            builder: (sheetCtx, setSheetState) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1A27),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.timeline_rounded, color: AppColors.starlightGold, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ZR Yaşam Döngüleri (L1 ➔ L2 ➔ L3)',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Tıklayın ▾',
                            style: TextStyle(fontSize: 10, color: AppColors.starlightGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'L1 dönemine tıklayarak L2 alt aylarını, L2 dönemine tıklayarak L3 mikro günlerini açıp inceleyebilirsiniz.',
                      style: TextStyle(fontSize: 10.5, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    ...timeline.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final sDate = item['startDate'] as DateTime;
                      final eDate = item['endDate'] as DateTime;
                      final sStr = '${sDate.day.toString().padLeft(2, '0')}.${sDate.month.toString().padLeft(2, '0')}.${sDate.year}';
                      final eStr = '${eDate.day.toString().padLeft(2, '0')}.${eDate.month.toString().padLeft(2, '0')}.${eDate.year}';
                      final isActive = item['sign'] == l1Sign;
                      final peakTag = item['peakTag'] as String;
                      final isExpanded = expandedL1.contains(index);
                      final subtitle = isActive
                          ? '★ AKTİF DÖNEM • ${peakTag.isNotEmpty ? peakTag : "GELİŞİM EVRESİ"}'
                          : (peakTag.isNotEmpty ? peakTag : 'Temel Gelişim & İnşa');

                      final List<Map<String, dynamic>> l2List =
                          List<Map<String, dynamic>>.from(item['l2Periods'] ?? []);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setSheetState(() {
                                if (expandedL1.contains(index)) {
                                  expandedL1.remove(index);
                                } else {
                                  expandedL1.add(index);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: _buildZrPeriodRow(
                              '$sStr – $eStr',
                              'L1 ${item['sign']} (${item['years']} Yıl)',
                              subtitle,
                              isActive,
                              trailingIcon: isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 6),
                            Container(
                              margin: const EdgeInsets.only(left: 10, bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.subdirectory_arrow_right_rounded,
                                          size: 14, color: AppColors.starlightGold),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${item['sign']} Seviye 2 (L2 Alt Aylar - ${l2List.length} Dönem):',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.starlightGold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ...l2List.asMap().entries.map((l2Entry) {
                                    final l2Idx = l2Entry.key;
                                    final l2 = l2Entry.value;
                                    final l2Key = '$index-$l2Idx';
                                    final isL2Expanded = expandedL2.contains(l2Key);
                                    final isL2Active = l2['isActive'] == true;
                                    final List<Map<String, dynamic>> l3List =
                                        List<Map<String, dynamic>>.from(l2['l3Periods'] ?? []);

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setSheetState(() {
                                              if (expandedL2.contains(l2Key)) {
                                                expandedL2.remove(l2Key);
                                              } else {
                                                expandedL2.add(l2Key);
                                              }
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 3),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isL2Active
                                                  ? AppColors.starlightGold.withAlpha(40)
                                                  : Colors.white.withAlpha(5),
                                              borderRadius: BorderRadius.circular(8),
                                              border: isL2Active
                                                  ? Border.all(
                                                      color: AppColors.starlightGold
                                                          .withAlpha(120))
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Wrap(
                                                        spacing: 6,
                                                        runSpacing: 2,
                                                        crossAxisAlignment: WrapCrossAlignment.center,
                                                        children: [
                                                          Text(
                                                            'L2 ${l2['sign']} ${l2['symbol']}${l2['isLoosing'] == true ? " (L)" : ""} (${l2['months']} Ay)',
                                                            style: TextStyle(
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.bold,
                                                              color: isL2Active
                                                                  ? AppColors.starlightGold
                                                                  : Colors.white,
                                                            ),
                                                          ),
                                                          if (isL2Active)
                                                            Container(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 5, vertical: 1),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.starlightGold,
                                                                borderRadius:
                                                                    BorderRadius.circular(4),
                                                              ),
                                                              child: const Text(
                                                                'ŞU AN',
                                                                style: TextStyle(
                                                                    fontSize: 8.5,
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                            ),
                                                          if (l2['isPeak'] == true)
                                                            Text(
                                                              l2['peakTag'],
                                                              style: const TextStyle(
                                                                fontSize: 9.5,
                                                                color: AppColors.pastelMint,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      Text(
                                                        '${l2['startDateFormatted']} – ${l2['endDateFormatted']}',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white60,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'L3 (${l3List.length})',
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        color: isL2Expanded
                                                            ? AppColors.pastelMint
                                                            : Colors.white38,
                                                      ),
                                                    ),
                                                    Icon(
                                                      isL2Expanded
                                                          ? Icons.keyboard_arrow_up_rounded
                                                          : Icons.keyboard_arrow_down_rounded,
                                                      size: 16,
                                                      color: isL2Expanded
                                                          ? AppColors.pastelMint
                                                          : Colors.white38,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Expanded L3 Sub-micro periods
                                        if (isL2Expanded) ...[
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 10, top: 2, bottom: 4),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${l2['sign']} Seviye 3 (L3 Mikro Günler):',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.pastelMint,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                ...l3List.map((l3) {
                                                  final isL3Active =
                                                      l3['isActive'] == true;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 2),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                isL3Active
                                                                    ? Icons.radio_button_checked
                                                                    : Icons.circle_outlined,
                                                                size: 10,
                                                                color: isL3Active
                                                                    ? AppColors.pastelMint
                                                                    : Colors.white38,
                                                              ),
                                                              const SizedBox(width: 6),
                                                              Expanded(
                                                                child: Text(
                                                                  'L3 ${l3['sign']} ${l3['symbol']}${l3['isLoosing'] == true ? " (L)" : ""} (${l3['days']} Gün)',
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                    fontSize: 10.5,
                                                                    fontWeight: isL3Active
                                                                        ? FontWeight.bold
                                                                        : FontWeight.normal,
                                                                    color: isL3Active
                                                                        ? AppColors.pastelMint
                                                                        : Colors.white70,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          '${l3['startDateFormatted']} – ${l3['endDateFormatted']}',
                                                          style: TextStyle(
                                                            fontSize: 9.5,
                                                            color: isL3Active
                                                                ? Colors.white
                                                                : Colors.white38,
                                                            fontWeight: isL3Active
                                                                ? FontWeight.bold
                                                                : FontWeight.normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                          const Divider(color: Colors.white10, height: 14),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          _buildDemoAspectItem(
            aspect: 'Ruh Noktası (Lot of Spirit): $spiritSign ($spiritFormatted)',
            tag: 'İrade & Yaşam Pusulası',
            desc:
                'Doğum haritanızdaki ASC, Güneş ve Ay pozisyonları ile gündüz/gece ayrımı baz alınarak hesaplanan Ruh Noktanız $spiritSign burcundadır. Kariyer eylemlerinizin ve iradi tercihlerinizin pusulasıdır.',
            color: AppColors.starlightGold,
          ),
          _buildDemoAspectItem(
            aspect: '90° Modül Pik Dönemleri: $spiritSign, $angle4, $angle7, $angle10',
            tag: 'Açısal Doruk Aksları ★',
            desc:
                'Ruh Noktasından itibaren 90\'lık modüle (kare ve karşıt burçlar) giren Seviye 1 dönemleri zirve noktalarıdır. Şu anki L1 $l1Sign evreniz: $peakStatusText.',
            color: AppColors.pastelMint,
          ),
          _buildDemoAspectItem(
            aspect: 'Losing of the Bond (Bağ Kopuşu)',
            tag: 'Döngü Sıçraması',
            desc:
                'L2 ve L3 alt döngülerinde gerçekleşen sıçramalar, kariyerde ani terfileri, beklenmedik fırsat kapılarını ve büyük atılımları tetikler.',
            color: AppColors.pastelLavender,
          ),
        ],
      ),
    );
  }

  Widget _buildZrPeriodRow(String dates, String title, String subtitle, bool isActive, {IconData? trailingIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.warningOrange.withAlpha(35) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: AppColors.warningOrange.withAlpha(120)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isActive ? Icons.play_circle_fill_rounded : Icons.check_circle_outline_rounded,
            color: isActive ? AppColors.warningOrange : Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.warningOrange : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dates,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isActive ? Colors.white : Colors.white54,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? Colors.white70 : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 18, color: isActive ? AppColors.warningOrange : Colors.white38),
          ],
        ],
      ),
    );
  }

  void _showPlanetaryCyclesDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDemoSheet(
        ctx: ctx,
        title: 'Majör Gezegensel Yaşam Döngüleri',
        color: AppColors.pastelLavender,
        icon: Icons.all_inclusive_rounded,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelLavender.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.pastelLavender.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İnsan Ömrünün Evrensel Kozmik Eşikleri',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pastelLavender,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Her birey belirli yaşlarda evrensel gezegensel sınav ve uyanış kapılarından geçer. Bu döngüleri önceden bilmek kaygıyı bilgeliğe ve stratejiye dönüştürür.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDemoAspectItem(
            aspect: 'Satürn Dönüşü (29.5 & 59 Yaş)',
            tag: 'Büyüme & Sorumluluk',
            desc:
              'Çocukluğun ve gençliğin bitişi; gerçek hayat sorumluluklarını üstlenme, kariyer ve yuva kurma eşiği.',
            color: AppColors.pastelLavender,
          ),
          _buildDemoAspectItem(
            aspect: 'Jüpiter Dönüşü (12, 24, 36, 48 Yaş)',
            tag: 'Fırsat & Genişleme',
            desc:
              '12 yılda bir gelen kozmik bereket ve şans döngüsü; yeni ufuklar, seyahatler ve vizyon geliştirme.',
            color: AppColors.starlightGold,
          ),
          _buildDemoAspectItem(
            aspect: 'Uranüs Karşıtlığı (40 - 42 Yaş)',
            tag: 'Bireyselleşme & Uyanış',
            desc:
              '"Hayatımı gerçekten istediğim gibi mi yaşıyorum?" sorgusu. Özgürleşme ve otantik benliğe kavuşma krizi.',
            color: AppColors.pastelPink,
          ),
          _buildDemoAspectItem(
            aspect: 'Chiron Dönüşü (50 Yaş)',
            tag: 'Yaralı Şifacı',
            desc:
              'Geçmiş çocukluk travmalarının şifalanması ve başkalarına rehberlik etme olgunluğu.',
            color: AppColors.pastelMint,
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: AppTranslationService.currentLangNotifier,
        builder: (context, activeLang, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF130E26),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppTranslationService.tr('change_language'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr('lang_prompt'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildLangOption(ctx, code: 'tr', flag: '🇹🇷', label: 'Türkçe', isSelected: activeLang == 'tr'),
                  const SizedBox(height: 10),
                  _buildLangOption(ctx, code: 'en', flag: '🇬🇧', label: 'English', isSelected: activeLang == 'en'),
                  const SizedBox(height: 10),
                  _buildLangOption(ctx, code: 'ja', flag: '🇯🇵', label: '日本語', isSelected: activeLang == 'ja'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangOption(BuildContext ctx, {required String code, required String flag, required String label, required bool isSelected}) {
    return InkWell(
      onTap: () async {
        await AppTranslationService.setLanguage(code);
        if (ctx.mounted) {
          Navigator.pop(ctx);
        }
        if (mounted) {
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starlightGold.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.starlightGold : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.starlightGold : Colors.white,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.starlightGold, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 16, color: AppColors.pastelMint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


class _RewardedAdDialog extends StatefulWidget {
  final VoidCallback onRewardEarned;

  const _RewardedAdDialog({required this.onRewardEarned});

  @override
  State<_RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<_RewardedAdDialog> {
  static const int _totalSeconds = 15;
  int _secondsLeft = _totalSeconds;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    while (_secondsLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
      });
    }
    if (mounted) {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_totalSeconds - _secondsLeft) / _totalSeconds;

    return AlertDialog(
      backgroundColor: const Color(0xFF161226),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isFinished
                  ? AppColors.pastelMint.withAlpha(40)
                  : AppColors.starlightGold.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFinished
                  ? Icons.check_circle_rounded
                  : Icons.ondemand_video_rounded,
              color: _isFinished ? AppColors.pastelMint : AppColors.starlightGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFinished ? 'Tebrikler! Ödül Hazır 🎉' : 'Sponsorlu Premium Video',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isFinished
                      ? 'Erişim hakkınız hesabınıza tanımlandı'
                      : 'Yüksek Getirili Kozmik Reklam Yayında',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sponsor Simulator Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C1E4A),
                  Colors.black.withAlpha(180),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFinished
                    ? AppColors.pastelMint.withAlpha(120)
                    : AppColors.starlightGold.withAlpha(100),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SPONSORLU YAYIN',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (!_isFinished)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$_secondsLeft sn',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!_isFinished) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.starlightGold,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    color: AppColors.starlightGold,
                    size: 38,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🌟 Cosmic Pro & Artificial Intelligence',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reklam tamamlandığında tam harita ve canlı geçişler ücretsiz açılır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.starlightGold,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tebrikler! Günlük Erişim Hakkı Kazandınız 💎',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pastelMint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Canlı gezegen geçişleri, sabit yıldızlar ve çark özellikleri kilidi açıldı.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Encouragement Note
          Text(
            _isFinished
                ? 'İçeriği keşfetmeye hazırsınız!'
                : '💡 Reklamı sonuna kadar izleyerek uygulamamızı desteklediğiniz için teşekkür ederiz.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        if (_isFinished)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRewardEarned();
              },
              icon: const Icon(Icons.lock_open_rounded, size: 16),
              label: const Text(
                'Kilidi Aç & İçeriğe Dön ✨',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.starlightGold,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Ödülü kazanmak için lütfen reklamı sonuna kadar bekleyiniz.'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.amber,
                ),
              );
            },
            child: const Text(
              'Ödülü İptal Etmek İçin Bekleyin',
              style: TextStyle(fontSize: 11, color: Colors.white30),
            ),
          ),
      ],
    );
  }
}

