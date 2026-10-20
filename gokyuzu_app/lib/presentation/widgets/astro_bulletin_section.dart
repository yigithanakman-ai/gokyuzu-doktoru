import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/astro_bulletin_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/ad_service.dart';
import 'glass_card.dart';

/// Ana Sayfa Astro Bülten Bölümü ve Detay Modalı
class AstroBulletinSection extends StatefulWidget {
  final UserProfile profile;

  const AstroBulletinSection({super.key, required this.profile});

  @override
  State<AstroBulletinSection> createState() => _AstroBulletinSectionState();
}

class _AstroBulletinSectionState extends State<AstroBulletinSection> {
  late WeeklyCosmicSummary _weeklySummary;
  List<AstroBulletinEvent> _monthlyEvents = [];
  bool _isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    _weeklySummary = AstroBulletinService.getWeeklySummary();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await AstroBulletinService.getActiveMonthlyEvents();
    if (mounted) {
      setState(() {
        _monthlyEvents = events;
        _isLoadingEvents = false;
      });
    }
  }

  void _openFullBulletinModal(BuildContext context) {
    AdService.registerActionAndShowInterstitial(onDone: () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _AstroBulletinModalContent(
          profile: widget.profile,
          weeklySummary: _weeklySummary,
          monthlyEvents: _monthlyEvents,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.starlightGold,
                ),
                const SizedBox(width: 8),
                Text(
                  AppTranslationService.tr('astro_bulletin'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.starlightGold,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.pastelMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                _isLoadingEvents
                    ? AppTranslationService.tr('loading')
                    : '${_monthlyEvents.length} ${AppTranslationService.tr('active_events')} 🪐',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pastelMint,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Ana Bülten Kartı
        InkWell(
          onTap: () => _openFullBulletinModal(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1735),
                  const Color(0xFF120E22),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.pastelLavender.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pastelLavender.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.starlightGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.newspaper_rounded,
                            color: AppColors.starlightGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslationService.tr('weekly_summary'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _weeklySummary.dateRange,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Skor: %${_weeklySummary.cosmicEnergyScore}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _weeklySummary.weeklyHeadline,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _weeklySummary.weeklyStrategy,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Olasılık Önizlemesi (2 Tane Çubuk)
                ..._weeklySummary.probabilities.entries.take(2).map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '%${entry.value}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pastelMint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value / 100,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.pastelMint,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${AppTranslationService.signName(widget.profile.risingSign.isNotEmpty ? widget.profile.risingSign : widget.profile.sunSign)} (${AppTranslationService.tr('yukselen_badge')}) • ${AppTranslationService.tr('zodiac_horoscopes')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.electricViolet,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppTranslationService.tr('open_full_bulletin'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.starlightGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tam Ekran / Bottom Sheet Astro Bülten Modalı
class _AstroBulletinModalContent extends StatefulWidget {
  final UserProfile profile;
  final WeeklyCosmicSummary weeklySummary;
  final List<AstroBulletinEvent> monthlyEvents;

  const _AstroBulletinModalContent({
    required this.profile,
    required this.weeklySummary,
    required this.monthlyEvents,
  });

  @override
  State<_AstroBulletinModalContent> createState() =>
      _AstroBulletinModalContentState();
}

class _AstroBulletinModalContentState
    extends State<_AstroBulletinModalContent> {
  int _activeTab = 0; // 0: 12 Burç Yorumları, 1: Aylık Gökyüzü Olayları (Auto-Purge), 2: Haftalık Özet
  late String _selectedSign;
  bool _isWeeklyView = false; // false: Günlük, true: Haftalık

  @override
  void initState() {
    super.initState();
    final cleanRising = widget.profile.risingSign.trim();
    final cleanSun = widget.profile.sunSign.trim();
    if (cleanRising.isNotEmpty && AstroBulletinService.allSigns.contains(cleanRising)) {
      _selectedSign = cleanRising;
    } else if (cleanSun.isNotEmpty && AstroBulletinService.allSigns.contains(cleanSun)) {
      _selectedSign = cleanSun;
    } else {
      _selectedSign = 'Koç';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF100C1B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Modal Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.newspaper_rounded, color: AppColors.starlightGold, size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslationService.tr('ASTRO BÜLTEN & REHBER'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          AppTranslationService.tr('Günlük / Haftalık Yorumlar & Aylık Gökyüzü Takvimi'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Üst Sekmeler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTopTabItem(0, AppTranslationService.tr('zodiac_horoscopes'), Icons.stars_rounded),
                  ),
                  Expanded(
                    child: _buildTopTabItem(1, AppTranslationService.tr('monthly_events'), Icons.event_available_rounded),
                  ),
                  Expanded(
                    child: _buildTopTabItem(2, AppTranslationService.tr('weekly_summary'), Icons.query_stats_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),

          // İçerik
          Expanded(
            child: _activeTab == 0
                ? _buildZodiacHoroscopesView()
                : _activeTab == 1
                    ? _buildMonthlyEventsView()
                    : _buildWeeklySummaryView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabItem(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starlightGold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.black87 : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: 12 BURÇ YORUMLARI
  // ==========================================
  Widget _buildZodiacHoroscopesView() {
    final bulletin = AstroBulletinService.getZodiacBulletin(_selectedSign);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yükselen Burç Bilgilendirme Notu
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.electricViolet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.electricViolet.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.starlightGold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppTranslationService.tr('burc_yorumlari_yukselen_notu'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 12 Burç Yatay Seçici
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: AstroBulletinService.allSigns.map((s) {
                final isSelected = _selectedSign == s;
                final b = AstroBulletinService.getZodiacBulletin(s);
                final isRising = s == widget.profile.risingSign.trim();
                final isSun = s == widget.profile.sunSign.trim();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSign = s),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.starlightGold : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.starlightGold
                              : (isRising ? AppColors.electricViolet : Colors.white12),
                          width: isRising ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            b.symbol,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.black87 : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppTranslationService.signName(s),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black87 : Colors.white,
                            ),
                          ),
                          if (isRising) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black12 : AppColors.electricViolet.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppTranslationService.tr('yukselen_badge'),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black87 : AppColors.starlightGold,
                                ),
                              ),
                            ),
                          ] else if (isSun) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black12 : Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppTranslationService.tr('gunes_badge'),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black87 : AppColors.pastelMint,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Günlük / Haftalık Geçiş Düğmesi
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPeriodToggleItem(false, AppTranslationService.tr('GÜNLÜK YORUM ☀️')),
                ),
                Expanded(
                  child: _buildPeriodToggleItem(true, AppTranslationService.tr('HAFTALIK YORUM & OLASILIKLAR 📅')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seçili Burç Kartı
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          bulletin.symbol,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppTranslationService.signName(bulletin.sign)} ${AppTranslationService.tr('burcu')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${AppTranslationService.tr('element_label')}: ${AppTranslationService.elementName(bulletin.element)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.pastelLavender,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!_isWeeklyView)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${AppTranslationService.tr('Uyumlu')}: ${AppTranslationService.signName(bulletin.dailyCompatibleSign)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),

                if (!_isWeeklyView) ...[
                  // GÜNLÜK İÇERİK
                  Text(
                    AppTranslationService.tr('BUGÜNÜN KOZMİK TEMASI'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.starlightGold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr(bulletin.dailyTheme),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslationService.tr('GÜNÜN ODAK NOKTASI & TAVSİYE'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pastelMint,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr(bulletin.dailyFocus),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded, size: 16, color: AppColors.starlightGold),
                        const SizedBox(width: 8),
                        Text(
                          '${AppTranslationService.tr('Günün Şanslı Saatleri')}: ${bulletin.dailyLuckyHours}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // HAFTALIK İÇERİK
                  Text(
                    AppTranslationService.tr('HAFTALIK GENEL BAKIŞ'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.starlightGold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr(bulletin.weeklyOverview),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildWeeklySection(AppTranslationService.tr('AŞK & İLİŞKİLER ❤️'), AppTranslationService.tr(bulletin.weeklyLove)),
                  const SizedBox(height: 10),
                  _buildWeeklySection(AppTranslationService.tr('KARİYER & FİNANS 💼'), AppTranslationService.tr(bulletin.weeklyCareer)),
                  const SizedBox(height: 10),
                  _buildWeeklySection(AppTranslationService.tr('BEDEN & RUH SAĞLIĞI 🌿'), AppTranslationService.tr(bulletin.weeklyHealth)),
                  const SizedBox(height: 16),

                  Text(
                    AppTranslationService.tr('BURCUNUZA ÖZEL HAFTALIK OLASILIKLAR:'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pastelMint,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...bulletin.weeklyProbabilities.entries.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppTranslationService.tr(p.key), style: const TextStyle(fontSize: 11.5, color: Colors.white)),
                              Text('%${p.value}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.pastelMint)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: p.value / 100,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pastelMint),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPeriodToggleItem(bool isWeekly, String label) {
    final isSelected = _isWeeklyView == isWeekly;
    return InkWell(
      onTap: () => setState(() => _isWeeklyView = isWeekly),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelLavender.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.starlightGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: AYLIK GÖKYÜZÜ OLAYLARI & AÇILAR (AUTO-PURGE)
  // ==========================================
  Widget _buildMonthlyEventsView() {
    final events = widget.monthlyEvents;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto-Purge Bilgilendirme Kutusu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pastelMint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.pastelMint.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_delete_rounded, color: AppColors.pastelMint, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppTranslationService.tr('Her ayın 1\'inde yayınlanır. Zamanı geçen gökyüzü olayları ve açılar kafa karıştırmamak ve hafızayı şişirmemek için otomatik olarak silinir.'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.pastelMint,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslationService.tr('AKTİF GÖKYÜZÜ OLAYLARI & MAJÖR AÇILAR'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.starlightGold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${events.length} ${AppTranslationService.tr('Olay')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppTranslationService.tr('Yalnızca Merkür, Venüs, Mars, Jüpiter, Satürn, Uranüs, Neptün, Plüton, Ay Düğümleri ve Chiron arasındaki majör açılar ile Yeniay/Dolunay/Tutulmalar yer alır.'),
            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          if (events.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                AppTranslationService.tr('Bu ayın gerçekleşen tüm olayları tamamlandı ve hafızadan temizlendi. Gelecek ayın ilk günü yeni kozmik takvim yayınlanacaktır.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            )
          else
            ...events.map((event) {
              final isLunation = event.category.contains('Yeniay') || event.category.contains('Dolunay');
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isLunation ? AppColors.pastelLavender : AppColors.starlightGold)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isLunation ? Icons.brightness_3_rounded : Icons.hub_rounded,
                                    size: 18,
                                    color: isLunation ? AppColors.pastelLavender : AppColors.starlightGold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppTranslationService.tr(event.title),
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${event.dateTime.day}.${event.dateTime.month.toString().padLeft(2, '0')}.${event.dateTime.year} • ${AppTranslationService.tr(event.degreeAndSign)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: List.generate(
                                event.impactLevel,
                                (i) => const Icon(Icons.star_rounded, size: 11, color: AppColors.starlightGold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppTranslationService.tr(event.description),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                AppTranslationService.tr(event.strategicAdvice),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: HAFTALIK ÖZET & OLASILIKLAR
  // ==========================================
  Widget _buildWeeklySummaryView() {
    final summary = widget.weeklySummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      summary.dateRange,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.starlightGold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${AppTranslationService.tr('Kozmik Enerji')}: %${summary.cosmicEnergyScore}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppTranslationService.tr(summary.weeklyHeadline),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppTranslationService.tr(summary.weeklyStrategy),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),

                Text(
                  AppTranslationService.tr('HAFTANIN ÖNE ÇIKAN AÇILARI:'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.starlightGold,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.highlightAspects.map(
                  (aspect) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✦ ', style: TextStyle(color: AppColors.starlightGold, fontSize: 12)),
                        Expanded(
                          child: Text(
                            AppTranslationService.tr(aspect),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            AppTranslationService.tr('HAFTALIK BAŞARI & FIRSAT OLASILIKLARI'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.starlightGold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: summary.probabilities.entries.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppTranslationService.tr(p.key), style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('%${p.value}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.pastelMint)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.value / 100,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pastelMint),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
