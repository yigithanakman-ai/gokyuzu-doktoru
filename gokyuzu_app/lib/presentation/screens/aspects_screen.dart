import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/aspects_service.dart';
import '../widgets/glass_card.dart';

class AspectsScreen extends StatefulWidget {
  const AspectsScreen({super.key});

  @override
  State<AspectsScreen> createState() => _AspectsScreenState();
}

class _AspectsScreenState extends State<AspectsScreen> {
  bool _includeTransits = false;
  bool _isTriangleGridView = true;

  @override
  Widget build(BuildContext context) {
    final natalAspects = AspectsService.getNatalAspects();
    final transitAspects = AspectsService.getTransitAspects();
    final displayedAspects = _includeTransits
        ? [...natalAspects, ...transitAspects]
        : natalAspects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Açılar Matrisi & Etkileşimler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Açılar Kılavuzu (Majör & Minör)',
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
                            title: 'Yalnızca Natal Açılar',
                            icon: Icons.brightness_medium_rounded,
                            isSelected: !_includeTransits,
                            onTap: () => setState(() => _includeTransits = false),
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            title: 'Natal + Transit Açılar',
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
                                            'Izgara (Grid)',
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
                                            'Açı Listesi',
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_stories_rounded,
                                  size: 14, color: AppColors.pastelLavender),
                              SizedBox(width: 4),
                              Text(
                                'Rehber',
                                style: TextStyle(
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
                ],
              ),
            ),

            const Divider(color: Colors.white10),

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

  // --- Classical Astrology Aspect Triangle Grid ---
  Widget _buildTriangleGrid(BuildContext context) {
    final planets = AspectsService.matrixPlanets;
    final int count = planets.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Planet symbols for columns
            Row(
              children: [
                const SizedBox(width: 60), // Corner blank
                for (int c = 0; c < count - 1; c++)
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
            // Rows (Lower triangle)
            for (int r = 1; r < count; r++)
              Row(
                children: [
                  // Left Header (Row planet label)
                  Container(
                    width: 60,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      planets[r].length > 7 ? planets[r].substring(0, 6) : planets[r],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pastelLavender,
                      ),
                    ),
                  ),
                  // Cells for columns up to r
                  for (int c = 0; c < count - 1; c++)
                    if (c < r)
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
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Hücrelere dokunarak açının tam yorumunu ve orb derecesini görüntüleyebilirsiniz.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(BuildContext context, String pA, String pB) {
    final aspect = AspectsService.findAspectInGrid(pA, pB, includeTransits: _includeTransits);

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
                                    '${item.planetA} - ${item.planetB}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${item.aspectName} Açı (Orb: ${item.orbStr})',
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
                          item.isTransit ? 'TRANSİT' : 'NATAL',
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
        height: MediaQuery.of(context).size.height * 0.65,
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
                          '${hit.planetA} ${hit.aspectName} ${hit.planetB}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Orb Sapması: ${hit.orbStr} | ${hit.isTransit ? 'Güncel Transit Etkisi' : 'Doğum Haritası Temel Açısı'}',
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
                              const Text(
                                'PSİKOLOJİK & PRATİK ETKİSİ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                  letterSpacing: 0.8,
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
                                const Text('Açı Tipi',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  hit.isMajor ? 'Majör (Temel)' : 'Minör (İnce)',
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
                                const Text('Tolerans (Orb)',
                                    style: TextStyle(
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

  // --- Full Major & Minor Aspects Guide Modal ---
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AÇILAR KILAVUZU (ANSİKLOPEDİ)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: AppColors.starlightGold,
                            ),
                          ),
                          Text(
                            'Majör ve Minör Gezegen Etkileşimleri',
                            style: TextStyle(
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
              const TabBar(
                indicatorColor: AppColors.starlightGold,
                labelColor: AppColors.starlightGold,
                unselectedLabelColor: AppColors.textMuted,
                tabs: [
                  Tab(text: 'Majör Açılar (Ptolemaic)'),
                  Tab(text: 'Minör Açılar (Özel)'),
                ],
              ),
              const Divider(color: Colors.white10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              def.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: def.color,
                              ),
                            ),
                            Text(
                              '${def.degree.toInt()}° Açısı | Orb: ±${def.defaultOrb.toInt()}°',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: def.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        def.nature,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: def.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  def.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Psikolojik Anlamı: ${def.psychologicalMeaning}',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✨ Hediye: ${def.gift}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.pastelMint),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warningOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⚠️ Sınav: ${def.challenge}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.warningOrange),
                        ),
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
