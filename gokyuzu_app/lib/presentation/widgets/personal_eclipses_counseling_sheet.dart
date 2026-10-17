import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/eclipses_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/app_translation_service.dart';
import 'glass_card.dart';

/// VIP Kadersel Tutulmalar & Harita Danışmanlığı Modalı
class PersonalEclipsesCounselingSheet extends StatefulWidget {
  final UserProfile profile;

  const PersonalEclipsesCounselingSheet({super.key, required this.profile});

  @override
  State<PersonalEclipsesCounselingSheet> createState() =>
      _PersonalEclipsesCounselingSheetState();
}

class _PersonalEclipsesCounselingSheetState
    extends State<PersonalEclipsesCounselingSheet> {
  int _selectedYearFilter = 2026; // 2026 veya 2027
  List<PersonalEclipseAnalysis> _allImpacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateImpacts();
  }

  void _calculateImpacts() {
    final liveChart = AstrologyEngine.calculateChart(
      name: widget.profile.name,
      dateStr: widget.profile.birthDate,
      timeStr: widget.profile.birthTime,
      city: widget.profile.birthCity,
      country: widget.profile.birthCountry,
    );

    final impacts = EclipsesService.analyzePersonalEclipses(
      chart: liveChart,
      profile: widget.profile,
    );

    setState(() {
      _allImpacts = impacts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredImpacts = _allImpacts
        .where((e) => e.eclipse.dateTimeTr.year == _selectedYearFilter)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          border: Border.all(
                            color: AppColors.starlightGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.brightness_medium_rounded,
                          color: AppColors.starlightGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslationService.tr('KADERSEL TUTULMA DANIŞMANLIĞI'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslationService.tr('Kişisel Harita Etkileri & 18 Yıllık Saros Yankısı'),
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
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),

          // Yıl Seçici (2026 & 2027)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildYearFilterItem(2026, '2026 ${AppTranslationService.tr('Yılı Tutulmaları')}'),
                  ),
                  Expanded(
                    child: _buildYearFilterItem(2027, '2027 ${AppTranslationService.tr('Yılı Tutulmaları')}'),
                  ),
                ],
              ),
            ),
          ),

          // Liste İçeriği
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.starlightGold),
                  )
                : filteredImpacts.isEmpty
                    ? Center(
                        child: Text(
                          '$_selectedYearFilter ${AppTranslationService.tr('yılı için tutulma bulunamadı.')}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredImpacts.length,
                        itemBuilder: (ctx, index) {
                          return _buildPersonalImpactCard(filteredImpacts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilterItem(int year, String title) {
    final isSelected = _selectedYearFilter == year;
    return InkWell(
      onTap: () => setState(() => _selectedYearFilter = year),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starlightGold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black87 : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalImpactCard(PersonalEclipseAnalysis impact) {
    final isSolar = impact.eclipse.isSolar;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(18),
        borderColor: (isSolar ? AppColors.starlightGold : AppColors.pastelLavender)
            .withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Başlık & Tarih
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isSolar ? AppColors.starlightGold : AppColors.pastelLavender)
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isSolar ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          color: isSolar ? AppColors.starlightGold : AppColors.pastelLavender,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              impact.eclipse.fullTypeTitle,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${impact.eclipse.degreeSignFormatted} • ${impact.eclipse.dateFormatted}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Saros ${impact.eclipse.sarosSeries}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.starlightGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tetiklenen Ev Aksı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.explore_rounded, size: 16, color: AppColors.starlightGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppTranslationService.tr('Tetiklenen Ev Aksı:')} ${AppTranslationService.tr(impact.houseAxisTitle)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppTranslationService.tr(impact.personalHouseCounseling),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),

            // Gezegen Tetikleri
            if (impact.natalTriggers.isNotEmpty) ...[
              Text(
                AppTranslationService.tr('HARİTANIZDAKİ DOĞRUDAN TEMASLAR (ASPECT TRIGGERS):'),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.starlightGold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              ...impact.natalTriggers.map(
                (trigger) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.pastelLavender.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: trigger.color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flash_on_rounded, size: 14, color: trigger.color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${AppTranslationService.planetName(trigger.natalPlanetName)} (${trigger.natalPlanetSignDegree}) • ${AppTranslationService.aspectName(trigger.aspectName)} ${trigger.aspectSymbol} (Orb: ${trigger.orbFormatted})',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: trigger.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslationService.tr(trigger.triggerAdvice),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 18 Yıllık Saros Yankısı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1428),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.electricViolet.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_edu_rounded, size: 15, color: AppColors.electricViolet),
                      const SizedBox(width: 6),
                      Text(
                        AppTranslationService.tr('18 YILLIK SAROS DÖNGÜ YANKISI'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricViolet,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslationService.tr(impact.sarosEchoMessage),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stratejik Danışmanlık ve Tavsiye
            Text(
              AppTranslationService.tr('KOZMİK DANIŞMANLIK & STRATEJİ:'),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: AppColors.pastelMint,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppTranslationService.tr(impact.strategicActionPlan),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
