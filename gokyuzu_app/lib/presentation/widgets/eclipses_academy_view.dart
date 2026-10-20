import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/eclipses_service.dart';
import 'glass_card.dart';

/// Tutulmalar & Saros Akademisi (Eğitim + Canlı Sayaç + Çok Yıllı Katalog)
class EclipsesAcademyView extends StatefulWidget {
  const EclipsesAcademyView({super.key});

  @override
  State<EclipsesAcademyView> createState() => _EclipsesAcademyViewState();
}

class _EclipsesAcademyViewState extends State<EclipsesAcademyView> {
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  late EclipseEvent _nextEclipse;
  int _activeSubTab = 0; // 0: Sayaç & 2026-2030 Kataloğu, 1: Saros & Astronomi Masterclass
  int _expandedLessonIndex = 0;

  @override
  void initState() {
    super.initState();
    _initNextEclipse();
    _startTimer();
  }

  void _initNextEclipse() {
    final next = EclipsesService.getNextUpcomingEclipse();
    final diff = next.dateTimeTr.difference(DateTime.now());
    setState(() {
      _nextEclipse = next;
      _remainingTime = diff.isNegative ? Duration.zero : diff;
    });
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = _nextEclipse.dateTimeTr.difference(DateTime.now());
      if (mounted) {
        setState(() {
          _remainingTime = diff.isNegative ? Duration.zero : diff;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Rozet
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.starlightGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.starlightGold.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.brightness_medium_rounded,
                  color: AppColors.starlightGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslationService.tr('TUTULMALAR & SAROS AKADEMİSİ'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppTranslationService.tr('Astronomik Mekanik, Saros Döngüleri & Canlı Sayaç'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Canlı Sayaç Kartı
          _buildLiveCountdownCard(),
          const SizedBox(height: 20),

          // Alt Sekmeler (Katalog vs Masterclass)
          _buildSubTabSwitcher(),
          const SizedBox(height: 18),

          // İçerik
          if (_activeSubTab == 0)
            _buildUpcomingCatalogSection()
          else
            _buildMasterclassLessonsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLiveCountdownCard() {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    final isSolar = _nextEclipse.isSolar;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isSolar
                ? const Color(0xFF2C1E0A)
                : const Color(0xFF20132B),
            const Color(0xFF110D1E),
          ],
        ),
        border: Border.all(
          color: isSolar
              ? AppColors.starlightGold.withValues(alpha: 0.6)
              : AppColors.pastelLavender.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSolar ? AppColors.starlightGold : AppColors.pastelLavender)
                .withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSolar ? '☀️' : '🌕',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppTranslationService.tr('BİR SONRAKİ KOZMİK TUTULMA'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSolar
                              ? AppColors.starlightGold
                              : AppColors.pastelLavender,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSolar
                      ? AppColors.starlightGold.withValues(alpha: 0.2)
                      : AppColors.pastelLavender.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Saros ${_nextEclipse.sarosSeries}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSolar
                        ? AppColors.starlightGold
                        : AppColors.pastelLavender,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _nextEclipse.fullTypeTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_nextEclipse.degreeSignFormatted} • ${AppTranslationService.tr(_nextEclipse.nodeName)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.pastelLavender,
            ),
          ),
          const SizedBox(height: 16),

          // Sayaç Kutuları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeBox(days.toString().padLeft(2, '0'), AppTranslationService.tr('GÜN')),
              const Text(':', style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTimeBox(hours.toString().padLeft(2, '0'), AppTranslationService.tr('SAAT')),
              const Text(':', style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTimeBox(minutes.toString().padLeft(2, '0'), AppTranslationService.tr('DAKİKA')),
              const Text(':', style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTimeBox(seconds.toString().padLeft(2, '0'), AppTranslationService.tr('SANİYE')),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.public_rounded, size: 16, color: AppColors.starlightGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppTranslationService.tr('Görünürlük:')} ${_nextEclipse.visibilityRegion}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.starlightGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.starlightGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSubTabItem(0, AppTranslationService.tr('2026 - 2030 Kataloğu 🌌'), Icons.calendar_month_rounded),
          ),
          Expanded(
            child: _buildSubTabItem(1, AppTranslationService.tr('Saros & Eğitim 📚'), Icons.school_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem(int index, String label, IconData icon) {
    final isSelected = _activeSubTab == index;
    return InkWell(
      onTap: () => setState(() => _activeSubTab = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starlightGold : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black87 : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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

  // --- 2026 - 2030 Tutulma Kataloğu ---
  Widget _buildUpcomingCatalogSection() {
    final catalog = EclipsesService.upcomingEclipsesCatalog;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTranslationService.tr('ÖNÜMÜZDEKİ YILLARIN TUTULMALARI'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.starlightGold,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${catalog.length} ${AppTranslationService.tr('Tutulma')}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...catalog.map((eclipse) {
          final isSolar = eclipse.isSolar;
          final isPast = eclipse.dateTimeTr.isBefore(DateTime.now());

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSolar
                              ? AppColors.starlightGold.withValues(alpha: 0.2)
                              : AppColors.pastelLavender.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isSolar ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 18,
                          color: isSolar ? AppColors.starlightGold : AppColors.pastelLavender,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eclipse.fullTypeTitle,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${eclipse.dateFormatted} • ${eclipse.timeFormatted}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPast ? Colors.white10 : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPast
                                ? Colors.white24
                                : (isSolar ? AppColors.starlightGold : AppColors.pastelLavender)
                                    .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          isPast ? AppTranslationService.tr('Tamamlandı') : AppTranslationService.tr('Yaklaşıyor'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.white54 : AppColors.pastelMint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildChip(AppTranslationService.tr('Burç'), eclipse.degreeSignFormatted),
                      _buildChip(AppTranslationService.tr('Düğüm'), AppTranslationService.tr(eclipse.nodeName)),
                      _buildChip(AppTranslationService.tr('Saros'), 'Saros ${eclipse.sarosSeries}'),
                      _buildChip(AppTranslationService.tr('Süre'), AppTranslationService.tr(eclipse.durationInfo)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppTranslationService.tr(eclipse.collectiveTheme),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10.5),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Saros & Astronomi Masterclass Dersleri ---
  Widget _buildMasterclassLessonsSection() {
    final lessons = EclipsesService.masterclassLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslationService.tr('SAROS & TUTULMA ASTROLOJİSİ DERSLERİ'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.starlightGold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppTranslationService.tr('Astronomik mekanikler, Saros periyotları ve doğum haritası üzerindeki kadersel tetikleyiciler.'),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        ...lessons.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          final isExpanded = _expandedLessonIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedLessonIndex = isExpanded ? -1 : index;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
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
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: lesson.accentColor.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  lesson.icon,
                                  color: lesson.accentColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppTranslationService.tr(lesson.title),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppTranslationService.tr(lesson.subtitle),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.pastelLavender,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.starlightGold,
                        ),
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),
                      Text(
                        AppTranslationService.tr(lesson.deepExplanation),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppTranslationService.tr('ÖNEMLİ KRİTİK NOKTALAR:'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...lesson.bulletPoints.map(
                        (takeaway) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '✦ ',
                                style: TextStyle(
                                  color: AppColors.starlightGold,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppTranslationService.tr(takeaway),
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
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔭 ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                AppTranslationService.tr(lesson.astronomicalNote),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.pastelMint,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
