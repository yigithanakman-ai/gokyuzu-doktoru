import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/services/aspects_service.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/storage_service.dart';
import '../widgets/glass_card.dart';
import '../../data/services/app_translation_service.dart';

class AspectsScreen extends StatefulWidget {
  final BirthChartModel? chart;
  final UserProfile? profile;

  const AspectsScreen({
    super.key,
    this.chart,
    this.profile,
  });

  @override
  State<AspectsScreen> createState() => _AspectsScreenState();
}

class _AspectsScreenState extends State<AspectsScreen> {
  bool _includeTransits = false;
  bool _isTriangleGridView = true;
  BirthChartModel? _resolvedChart;
  UserProfile? _resolvedProfile;

  String _localizeCoord(String raw) {
    if (raw.isEmpty) return raw;
    var res = raw;
    for (final s in AspectsService.zodiacSigns) {
      if (res.contains(s)) {
        res = res.replaceAll(s, AppTranslationService.signName(s));
      }
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    _resolvedChart = widget.chart;
    _resolvedProfile = widget.profile;
    if (_resolvedChart == null) {
      _loadUserChart();
    }
  }

  Future<void> _loadUserChart() async {
    final prof = _resolvedProfile ?? await StorageService.getProfile();
    if (prof != null) {
      final c = AstrologyEngine.calculateChart(
        name: prof.name,
        dateStr: prof.birthDate,
        timeStr: prof.birthTime,
        city: prof.birthCity.isEmpty ? 'İstanbul' : prof.birthCity,
        country: prof.birthCountry.isEmpty ? 'Türkiye' : prof.birthCountry,
      );
      if (mounted) {
        setState(() {
          _resolvedProfile = prof;
          _resolvedChart = c;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final natalAspects = AspectsService.getNatalAspects(
      chart: _resolvedChart,
      profile: _resolvedProfile,
    );
    final transitAspects = AspectsService.getTransitAspects(
      chart: _resolvedChart,
      profile: _resolvedProfile,
    );

    // Sayfalar arası yorum ve liste tamamen değişir:
    // - Yalnızca Natal Açılar: Doğum haritasının kendi içindeki natal gezegen açıları ve karakter yorumları
    // - Natal + Transit Açılar: Anlık gökyüzü transitlerinin doğum haritası gezegenlerine yaptığı canlı açılar ve öngörü yorumları
    final displayedAspects = _includeTransits ? transitAspects : natalAspects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            AppTranslationService.tr('Açılar Matrisi & Etkileşimler'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppTranslationService.tr('Açılar Kılavuzu (Majör & Minör)'),
            icon: const Icon(Icons.menu_book_rounded, color: AppColors.starlightGold),
            onPressed: () => _showAspectsGuideModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Control Panel: Mode Selection (Natal vs Transit, Grid vs List)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Transit / Natal Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.pastelLavender.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            title: AppTranslationService.tr('Yalnızca Natal Açılar'),
                            icon: Icons.brightness_medium_rounded,
                            isSelected: !_includeTransits,
                            onTap: () => setState(() => _includeTransits = false),
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            title: AppTranslationService.tr('Natal + Transit Açılar'),
                            icon: Icons.bolt_rounded,
                            isSelected: _includeTransits,
                            onTap: () => setState(() => _includeTransits = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Grid vs List Toggle & Guide Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isTriangleGridView = true),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: _isTriangleGridView
                                          ? AppColors.starlightGold.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.grid_on_rounded,
                                            size: 14,
                                            color: _isTriangleGridView
                                                ? AppColors.starlightGold
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${AppTranslationService.tr("Izgara")} (${_includeTransits ? AppTranslationService.tr("Transit×Natal") : AppTranslationService.tr("Natal")})',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: _isTriangleGridView
                                                  ? AppColors.starlightGold
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isTriangleGridView = false),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: !_isTriangleGridView
                                          ? AppColors.starlightGold.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.view_list_rounded,
                                            size: 14,
                                            color: !_isTriangleGridView
                                                ? AppColors.starlightGold
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${AppTranslationService.tr("Açı Listesi")} (${displayedAspects.length})',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: !_isTriangleGridView
                                                  ? AppColors.starlightGold
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Guide Quick Button
                      InkWell(
                        onTap: () => _showAspectsGuideModal(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.pastelLavender.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.pastelLavender.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_stories_rounded,
                                  size: 14, color: AppColors.pastelLavender),
                              const SizedBox(width: 4),
                              Text(
                                AppTranslationService.tr('Rehber'),
                                style: const TextStyle(
                                  fontSize: 11.5,
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
                  const SizedBox(height: 8),
                  // Active Mode Info Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: (_includeTransits
                              ? AppColors.warningOrange
                              : AppColors.pastelMint)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_includeTransits
                                ? AppColors.warningOrange
                                : AppColors.pastelMint)
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                           _includeTransits
                              ? Icons.bolt_rounded
                              : Icons.auto_awesome_rounded,
                          size: 15,
                          color: _includeTransits
                              ? AppColors.warningOrange
                              : AppColors.pastelMint,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _includeTransits
                                ? AppTranslationService.tr('CANLI TRANSİT → NATAL MODU: Anlık gökyüzü gezegenlerinin doğum haritanıza yaptığı güncel açılar ve öngörü yorumları listeleniyor.')
                                : AppTranslationService.tr('NATAL HARİTA MODU: Doğum anınızdaki gezegenlerin kendi aralarındaki gerçek astronomik açıları ve karakter/potansiyel yorumları listeleniyor.'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 8),

            // Content Area: Grid or List
            Expanded(
              child: _isTriangleGridView
                  ? _buildTriangleGrid(context)
                  : _buildAspectsList(displayedAspects),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelLavender : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 15,
                    color: isSelected ? Colors.black87 : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black87 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Classical Astrology Aspect Triangle Grid / Transit×Natal Matrix ---
  Widget _buildTriangleGrid(BuildContext context) {
    final planets = AspectsService.matrixPlanets;
    final int count = planets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: Planet symbols for columns (Natal Planets)
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _includeTransits ? 'T ↓ / N →' : AppTranslationService.tr('NATAL'),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                      ),
                      for (int c = 0; c < (_includeTransits ? count : count - 1); c++)
                        Container(
                          width: 44,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            AspectsService.planetSymbols[planets[c]] ?? planets[c],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Rows:
                  // - If _includeTransits == false: Classical lower triangle (1..count-1)
                  // - If _includeTransits == true: Full Transit rows (0..count-3, excluding ASC/MC transits) × Natal columns
                  for (int r = (_includeTransits ? 0 : 1);
                      r < (_includeTransits ? count - 2 : count);
                      r++)
                    Row(
                      children: [
                        // Left Header (Row planet label)
                        Container(
                          width: 72,
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            _includeTransits
                                ? 'T.${AppTranslationService.planetName(planets[r]).split(' ').first}'
                                : AppTranslationService.planetName(planets[r]).split(' ').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: _includeTransits
                                  ? AppColors.warningOrange
                                  : AppColors.pastelLavender,
                            ),
                          ),
                        ),
                        // Cells
                        for (int c = 0;
                            c < (_includeTransits ? count : count - 1);
                            c++)
                          if (_includeTransits || c < r)
                            _buildGridCell(context, planets[r], planets[c])
                          else
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                border: Border.all(color: Colors.white10),
                              ),
                            ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _includeTransits
                      ? AppTranslationService.tr('Hücrelere dokunarak ilgili Transit gezegenin Natal gezegeninize yaptığı açının güncel öngörü yorumunu okuyabilirsiniz.')
                      : AppTranslationService.tr('Hücrelere dokunarak doğum haritanızdaki iki gezegen arasındaki gerçek açının detaylı yorumunu okuyabilirsiniz.'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridCell(BuildContext context, String pA, String pB) {
    final aspect = AspectsService.findAspectInGrid(
      pA,
      pB,
      includeTransits: _includeTransits,
      chart: _resolvedChart,
      profile: _resolvedProfile,
    );

    if (aspect == null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF161320),
          border: Border.all(color: Colors.white10),
        ),
      );
    }

    return InkWell(
      onTap: () => _showAspectDetailSheet(context, aspect),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: aspect.color.withValues(alpha: 0.18),
          border: Border.all(color: aspect.color.withValues(alpha: 0.5)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  aspect.aspectSymbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: aspect.color,
                  ),
                ),
                Text(
                  aspect.orbStr.split('\'').first,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: aspect.color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            if (aspect.isTransit)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: AppColors.starlightGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'T',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Aspects List View ---
  Widget _buildAspectsList(List<AspectHit> aspects) {
    if (aspects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            AppTranslationService.tr('Belirtilen orb aralığında aktif açı bulunamadı.'),
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: aspects.length,
      itemBuilder: (ctx, index) {
        final item = aspects[index];
        return InkWell(
          onTap: () => _showAspectDetailSheet(ctx, item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              borderColor: item.color.withValues(alpha: 0.35),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.aspectSymbol,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: item.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppTranslationService.planetName(item.planetA)} (${_localizeCoord(item.planetADegreeSign)}) ${item.aspectSymbol} ${AppTranslationService.planetName(item.planetB)} (${_localizeCoord(item.planetBDegreeSign)})',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${AppTranslationService.aspectName(item.aspectName)} ${AppTranslationService.tr("Açı")} (${item.aspectDegree.toInt()}°) • Orb: ${item.orbStr}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: item.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isTransit
                              ? AppColors.warningOrange.withValues(alpha: 0.15)
                              : AppColors.pastelMint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isTransit ? AppTranslationService.tr('TRANSİT') : AppTranslationService.tr('NATAL'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: item.isTransit
                                ? AppColors.warningOrange
                                : AppColors.pastelMint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.interpretation,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Aspect Detail Sheet ---
  void _showAspectDetailSheet(BuildContext context, AspectHit hit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.68,
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hit.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: hit.color.withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Text(
                        hit.aspectSymbol,
                        style: TextStyle(fontSize: 22, color: hit.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppTranslationService.planetName(hit.planetA)} ${hit.aspectSymbol} ${AppTranslationService.planetName(hit.planetB)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_localizeCoord(hit.planetADegreeSign)} — ${_localizeCoord(hit.planetBDegreeSign)} | ${AppTranslationService.aspectName(hit.aspectName)} (${hit.aspectDegree.toInt()}°)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: hit.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: hit.color.withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: hit.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hit.isTransit
                                      ? AppTranslationService.tr('CANLI TRANSİT ÖNGÖRÜ ANALİZİ')
                                      : AppTranslationService.tr('DOĞUM HARİTASI (NATAL) ETKİ ANALİZİ'),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            hit.interpretation,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppTranslationService.tr('Açı Tipi'),
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  hit.isMajor
                                      ? '${AppTranslationService.tr("Majör")} (${hit.aspectDegree.toInt()}°)'
                                      : '${AppTranslationService.tr("Minör")} (${hit.aspectDegree.toInt()}°)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: hit.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppTranslationService.tr('Tolerans (Orb Sapması)'),
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  hit.orbStr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.starlightGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Full Major & Minor Aspects Guide Modal (Overflow-Free) ---
  void _showAspectsGuideModal(BuildContext context) {
    final list = AspectsService.allAspectDefinitions;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: Container(
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          color: AppColors.starlightGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslationService.tr('AÇILAR KILAVUZU (ANSİKLOPEDİ)'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: AppColors.starlightGold,
                            ),
                          ),
                          Text(
                            AppTranslationService.tr('Majör ve Minör Gezegen Etkileşimleri'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 8),
              TabBar(
                indicatorColor: AppColors.starlightGold,
                labelColor: AppColors.starlightGold,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: AppTranslationService.tr('Majör Açılar (Temel)')),
                  Tab(text: AppTranslationService.tr('Minör Açılar (Özel)')),
                ],
              ),
              const Divider(color: Colors.white10, height: 1),
              Expanded(
                child: TabBarView(
                  children: [
                    // Major Aspects Tab
                    _buildAspectDefinitionList(
                        list.where((a) => a.isMajor).toList()),
                    // Minor Aspects Tab
                    _buildAspectDefinitionList(
                        list.where((a) => !a.isMajor).toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspectDefinitionList(List<AspectDefinition> definitions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: definitions.length,
      itemBuilder: (ctx, index) {
        final def = definitions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: def.color.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: def.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: def.color.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          def.symbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: def.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  def.localizedName,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: def.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: def.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  def.localizedNature,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: def.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${def.degree.toInt()}° ${AppTranslationService.tr("Açısı")} | ${AppTranslationService.tr("Orb Toleransı")}: ±${def.defaultOrb.toInt()}°',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  def.localizedDescription,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppTranslationService.tr("Psikolojik Anlamı")}: ${def.localizedPsychologicalMeaning}',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.pastelMint.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        '✨ ${AppTranslationService.tr("Hediye")}: ${def.localizedGift}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.pastelMint, height: 1.35),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.warningOrange.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        '⚠️ ${AppTranslationService.tr("Sınav")}: ${def.localizedChallenge}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.warningOrange, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
