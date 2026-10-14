import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/astrology_encyclopedia.dart';
import '../../data/services/fixed_stars_service.dart';
import '../../data/services/sky_transits_service.dart';
import '../../data/services/sacred_astrology_service.dart';
import '../../data/services/lunar_mansions_service.dart';
import '../../data/services/chakra_service.dart';
import '../../data/services/crystals_service.dart';
import '../../data/services/kabbalah_tree_service.dart';
import '../../data/services/predictive_astrology_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/chart_wheel_painter.dart';
import '../../data/services/ad_service.dart';
import 'aspects_screen.dart';

class ChartDetailScreen extends StatefulWidget {
  final UserProfile profile;

  const ChartDetailScreen({super.key, required this.profile});

  @override
  State<ChartDetailScreen> createState() => _ChartDetailScreenState();
}

class _ChartDetailScreenState extends State<ChartDetailScreen> {
  BirthChartModel? _chart;
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;
  int _sacredSubTab = 0;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _checkVip();
    _fetchChart();
  }

  Future<void> _checkVip() async {
    final isVip = await StorageService.isVip();
    if (mounted) setState(() => _isVip = isVip);
  }

  Future<void> _fetchChart() async {
    try {
      final chart = await ApiService.calculateChart(
        name: widget.profile.name,
        birthDate: widget.profile.birthDate,
        birthTime: widget.profile.birthTime,
        city: widget.profile.birthCity,
      );
      if (mounted) {
        setState(() {
          _chart = chart;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Harita yüklenemedi: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'DOĞUM HARİTASI',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 18,
                letterSpacing: 1.2,
              ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.pastelLavender,
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.savageRed),
                  ),
                )
              : Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: _selectedTabIndex == 0
                          ? _buildListView()
                          : _selectedTabIndex == 1
                              ? _buildWheelView()
                              : _selectedTabIndex == 2
                                  ? _buildFixedStarsView()
                                  : _selectedTabIndex == 3
                                      ? (_isVip ? _buildSacredAstrologyView() : _buildVipLockedSacredView())
                                      : _selectedTabIndex == 4
                                          ? _buildChakraView()
                                          : _selectedTabIndex == 5
                                              ? _buildCrystalsView()
                                              : (_isVip ? _buildKabbalahTreeView() : _buildVipLockedKabbalahView()),
                    ),
                  ],
                ),
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elements & Modalities summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ELEMENT DENGESİ',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Row(
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  size: 14, color: AppColors.starlightGold),
                              SizedBox(width: 4),
                              Text(
                                'Dengeleme için dokun',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.starlightGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildElementCard(
                            'Ateş',
                            _chart!.elements['Ateş'] ?? 0,
                            AppColors.savageRed,
                            Icons.local_fire_department,
                          ),
                          const SizedBox(width: 8),
                          _buildElementCard(
                            'Toprak',
                            _chart!.elements['Toprak'] ?? 0,
                            AppColors.pastelMint,
                            Icons.grass,
                          ),
                          const SizedBox(width: 8),
                          _buildElementCard(
                            'Hava',
                            _chart!.elements['Hava'] ?? 0,
                            AppColors.pastelBlue,
                            Icons.air,
                          ),
                          const SizedBox(width: 8),
                          _buildElementCard(
                            'Su',
                            _chart!.elements['Su'] ?? 0,
                            AppColors.pastelLavender,
                            Icons.water_drop,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Aspects Matrix Card
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AspectsScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.pastelLavender.withValues(alpha: 0.22),
                                AppColors.starlightGold.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.starlightGold.withValues(alpha: 0.45),
                            ),
                          ),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.grid_on_rounded,
                                        color: AppColors.starlightGold,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Açılar Matrisi & Gezegen Açıları',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'YENİ',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.pastelMint,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Klasik Üçgen Izgara, Majör/Minör Açılar & Transitler',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
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
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.starlightGold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Planets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GEZEGEN KONUMLARI & NOKTALAR',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Row(
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  size: 14, color: AppColors.starlightGold),
                              SizedBox(width: 4),
                              Text(
                                'Detay için dokun',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.starlightGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._chart!.planets.entries.map((entry) {
                        final planet = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _showPlanetDetailSheet(context, entry.key, planet),
                            borderRadius: BorderRadius.circular(16),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              borderRadius: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getPlanetSymbol(entry.key),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: AppColors.pastelLavender,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                planet.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              if (planet.isRetrograde)
                                                const Text(
                                                  'Retrograde (Geri Harekette)',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.warningOrange,
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
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            planet.sign,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.pastelPink,
                                            ),
                                          ),
                                          Text(
                                            planet.formatted,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18,
                                        color: AppColors.pastelLavender.withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      _buildHousesSection(),
                    ],
                  ),
                );
  }

  // --- Top Tab Bar ---
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildTabItem(0, 'Evler & Liste', Icons.format_list_bulleted_rounded),
            _buildTabItem(1, '360° Çark', Icons.pie_chart_rounded),
            _buildTabItem(2, 'Sabit Yıldız', Icons.star_rounded),
            _buildTabItem(3, 'Dekan & Melek 👑', Icons.auto_awesome_rounded),
            _buildTabItem(4, 'Çakra & Beden ✨', Icons.spa_rounded),
            _buildTabItem(5, 'Doğal Taşlar 💎', Icons.diamond_rounded),
            _buildTabItem(6, 'Kabala Ağacı 👑', Icons.account_tree_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    final isVipTab = index == 3 || index == 6;
    final isVipLocked = isVipTab && !_isVip;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.starlightGold
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isVipLocked && !isSelected
              ? Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? Colors.black87
                  : (isVipLocked ? AppColors.starlightGold : AppColors.textMuted),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.black87
                    : (isVipLocked ? AppColors.starlightGold : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index) async {
    if (index == _selectedTabIndex) return;

    if ((index == 3 || index == 6) && !_isVip) {
      // User tapped on VIP-locked tab without VIP
      setState(() => _selectedTabIndex = index);
      return;
    }

    if (!_isVip) {
      final shouldShowAd = await AdService.shouldShowTabInterstitial();
      if (shouldShowAd && mounted) {
        _showInterstitialAdModal(onAdClosed: () {
          if (mounted) setState(() => _selectedTabIndex = index);
        });
        return;
      }
    }
    setState(() => _selectedTabIndex = index);
  }

  // Interstitial Ad Simulation
  void _showInterstitialAdModal({required VoidCallback onAdClosed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF13111C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.starlightGold.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SPONSORLU REKLAM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onAdClosed();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2C1E4A),
                        const Color(0xFF1E1A2B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.starlightGold
                            .withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.workspace_premium_rounded,
                          size: 42, color: AppColors.starlightGold),
                      SizedBox(height: 10),
                      Text(
                        'VIP KOZMİK ÜYELİKLE TANIŞIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Reklamsız kesintisiz deneyim, 10 sayfalık PDF harita kitapçığı, Sinastri ve tüm ileri öngörü modelleri sizi bekliyor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onAdClosed();
                        },
                        child: const Text('Reklamı Kapat ✕',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.starlightGold,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onAdClosed();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Ana sayfadaki VIP butonundan üyeliğinizi başlatabilirsiniz! 👑'),
                              backgroundColor: Color(0xFF2C1E4A),
                            ),
                          );
                        },
                        child: const Text(
                          'VIP\'e Geç 👑',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
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

  double _parseDegreeFromFormatted(String formatted) {
    final degMatch = RegExp(r"(\d+)°(?:(\d+)')?").firstMatch(formatted);
    if (degMatch != null) {
      final deg = double.tryParse(degMatch.group(1) ?? '0') ?? 0.0;
      final min = double.tryParse(degMatch.group(2) ?? '0') ?? 0.0;
      return deg + (min / 60.0);
    }
    return 15.0;
  }

  // --- 360 Wheel View ---
  Widget _buildWheelView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pastelLavender.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.pastelLavender.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.pastelLavender),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Geocentric Placidus 360° Zodyak Çarkı. Yükselen (ASC) 9 yönünde, Tepe Noktası (MC) 12 yönündedir.',
                    style: TextStyle(fontSize: 11.5, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wheel Canvas
          SizedBox(
            width: 330,
            height: 330,
            child: CustomPaint(
              painter: ChartWheelPainter(
                planets: _chart!.planets.map((k, v) => MapEntry(k, {
                      'sign': v.sign,
                      'degree': _parseDegreeFromFormatted(v.formatted),
                      'isRetrograde': v.isRetrograde,
                    })),
                ascendantSign: _chart!.risingSign,
                ascDegree: _parseDegreeFromFormatted(_chart!.risingFormatted),
                mcSign: _chart!.planets['mc']?.sign ?? 'Kova',
                mcDegree: _parseDegreeFromFormatted(_chart!.planets['mc']?.formatted ?? '14°30\' Kova'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Açı & Aks Göstergeleri',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.starlightGold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem('ASC', 'Yükselen', AppColors.starlightGold),
                    _buildLegendItem('MC', 'Kariyer', AppColors.pastelMint),
                    _buildLegendItem('DSC', 'İlişkiler', AppColors.pastelLavender),
                    _buildLegendItem('IC', 'Kökler', AppColors.pastelBlue),
                  ],
                ),
                const Divider(color: Colors.white10, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem('▲ 120°', 'Üçgen', AppColors.pastelMint),
                    _buildLegendItem('■ 90°', 'Kare', AppColors.savageRed),
                    _buildLegendItem('☍ 180°', 'Karşıt', AppColors.starlightGold),
                    _buildLegendItem('✶ 60°', 'Sekstil', AppColors.pastelBlue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Planet List
          ..._chart!.planets.entries.map((entry) {
            final p = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _showPlanetDetailSheet(context, entry.key, p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1625),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getPlanetSymbol(entry.key),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.starlightGold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getTurkishPlanetName(entry.key),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (p.isRetrograde) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.savageRed
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Geri Hareket',
                                  style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.savageRed)),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${p.sign} (${p.formatted})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 11, color: AppColors.textMuted),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String code, String desc, Color color) {
    return Column(
      children: [
        Text(code,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(desc,
            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
      ],
    );
  }

  // --- Fixed Stars & Degrees View ---
  Widget _buildFixedStarsView() {
    final List<Map<String, dynamic>> natalHits = [];
    _chart!.planets.forEach((pName, pPos) {
      final deg = _parseDegreeFromFormatted(pPos.formatted);
      final stars = FixedStarsService.findConjunctions(pPos.sign, deg);
      for (final s in stars) {
        natalHits.add({
          'planet': pName,
          'sign': pPos.sign,
          'formatted': pPos.formatted,
          'star': s,
        });
      }
    });

    final liveTransits = SkyTransitsService.getCurrentTransits()
        .where((t) => t.conjunctStars.isNotEmpty)
        .toList();

    final allStars = FixedStarsService.getAllStars();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.starlightGold.withValues(alpha: 0.18),
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
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        color: AppColors.starlightGold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SABİT YILDIZLAR VE DERECE ANLAMLARI',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: AppColors.starlightGold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Yiğithan Akman Sabit Yıldızlar Kataloğu (gokyuzudoktoru.com) kaynaklı 80+ sabit yıldızın haritanızdaki ve anlık transitlerdeki etkileri.',
                  style: TextStyle(
                      fontSize: 11.5, height: 1.4, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Natal Conjunctions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HARİTANIZLA KAVUŞUM YAPAN SABİT YILDIZLAR',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: natalHits.isNotEmpty
                      ? AppColors.pastelMint.withValues(alpha: 0.2)
                      : Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${natalHits.length} Eşleşme',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: natalHits.isNotEmpty
                        ? AppColors.pastelMint
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (natalHits.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.pastelLavender),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gezegenleriniz 1.5° orb toleransıyla majör bir sabit yıldızla tam kavuşumda değil; enerjiler gezegensel açılar üzerinden akıyor.',
                      style: TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            )
          else
            ...natalHits.map((hit) {
              final star = hit['star'] as FixedStar;
              final isLucky = star.nature.toLowerCase().contains('şans');
              final isUnlucky = star.nature.toLowerCase().contains('talihsiz');
              final color = isLucky
                  ? AppColors.pastelMint
                  : isUnlucky
                      ? AppColors.savageRed
                      : AppColors.starlightGold;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1625),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getPlanetSymbol(hit['planet'] as String),
                              style: const TextStyle(
                                  fontSize: 18, color: AppColors.starlightGold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_getTurkishPlanetName(hit['planet'] as String)} ☌ ${star.name}',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            star.nature,
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
                    Row(
                      children: [
                        Text(
                          '${star.degree.toInt()}° ${star.sign} (${hit['formatted']})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Yönetici: ${star.rulingPlanets}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      star.meaning,
                      style: const TextStyle(
                          fontSize: 12, height: 1.45, color: Colors.white70),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 20),

          // Section 2: Live Transit Conjunctions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CANLI TRANSİT SABİT YILDIZ TETİKLERİ',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Row(
                children: [
                  Icon(Icons.bolt_rounded,
                      size: 14, color: AppColors.starlightGold),
                  SizedBox(width: 4),
                  Text(
                    'Aktif Gökyüzü',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.starlightGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...liveTransits.map((t) {
            final star = t.conjunctStars.first;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.pastelMint.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(t.symbol,
                      style: const TextStyle(
                          fontSize: 18, color: AppColors.pastelMint)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transit ${t.name} (${t.degreeStr}) ☌ ${star.name}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${star.nature} • ${star.meaning}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Section 3: All 80+ Fixed Stars Catalog
          Text(
            'TÜM SABİT YILDIZLAR VE DERECE KATALOĞU (${allStars.length}+ YILDIZ)',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 10),

          ...allStars.map((star) {
            final isLucky = star.nature.toLowerCase().contains('şans');
            final isUnlucky = star.nature.toLowerCase().contains('talihsiz');
            final color = isLucky
                ? AppColors.pastelMint
                : isUnlucky
                    ? AppColors.savageRed
                    : AppColors.starlightGold;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14121E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: color),
                          const SizedBox(width: 6),
                          Text(
                            star.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${star.degree.toInt()}° ${star.sign}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          star.nature,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    star.meaning,
                    style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 12 Houses & Dual Classical/Modern Rulers Section ---
  Widget _buildHousesSection() {
    const zodiacSigns = [
      'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
      'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
    ];

    const Map<String, String> classicalRulers = {
      'Koç': 'Mars ♂',
      'Boğa': 'Venüs ♀',
      'İkizler': 'Merkür ☿',
      'Yengeç': 'Ay ☽',
      'Aslan': 'Güneş ☉',
      'Başak': 'Merkür ☿',
      'Terazi': 'Venüs ♀',
      'Akrep': 'Mars ♂',
      'Yay': 'Jüpiter ♃',
      'Oğlak': 'Satürn ♄',
      'Kova': 'Satürn ♄',
      'Balık': 'Jüpiter ♃',
    };

    const Map<String, String> modernRulers = {
      'Koç': 'Mars ♂',
      'Boğa': 'Venüs ♀',
      'İkizler': 'Merkür ☿',
      'Yengeç': 'Ay ☽',
      'Aslan': 'Güneş ☉',
      'Başak': 'Merkür ☿',
      'Terazi': 'Venüs ♀',
      'Akrep': 'Plüton ♇',
      'Yay': 'Jüpiter ♃',
      'Oğlak': 'Satürn ♄',
      'Kova': 'Uranüs ♅',
      'Balık': 'Neptün ♆',
    };

    const housesData = [
      {
        'num': 1,
        'name': '1. Ev (ASC) — Benlik & Beden',
        'natural': 'Koç ♈',
        'theme': 'Fiziksel beden, karakter, hayata ilk bakış açısı, dış dünyaya verilen ilk intiba ve yaşam enerjisi.',
        'psycho': 'Bireyin benlik algısı, kendini ortaya koyma tarzı, liderlik ve girişim cesareti.',
        'medical': 'Baş, beyin, kafatası ve yüz bölgesi.',
        'karmic': 'Ruhun bu enkarnasyondaki dünyevi aracı ve fiziksel alemdeki varoluş manifestosu.',
      },
      {
        'num': 2,
        'name': '2. Ev — Maddi Kaynaklar & Özdeğer',
        'natural': 'Boğa ♉',
        'theme': 'Kişisel gelirler, finansal güvence, taşınabilir mallar, sahip olma arzusu ve özsaygı.',
        'psycho': 'Kendini değerli hissetme düzeyi, güven arayışı ve maddi dünyayla kurulan bağ.',
        'medical': 'Boyun, boğaz, ses telleri ve tiroid bezi.',
        'karmic': 'Ruhun maddi bağımlılıklar ile manevi değerler arasındaki dengeyi kurma sınavı.',
      },
      {
        'num': 3,
        'name': '3. Ev — İletişim, Zihin & Yakın Çevre',
        'natural': 'İkizler ♊',
        'theme': 'Kardeşler, kuzenler, komşular, kısa yolculuklar, temel eğitim, ticaret ve zihinsel iletişim ağı.',
        'psycho': 'Bilgi işleme hızı, merak, algılama biçimi ve düşünceleri kelimelere dökme yeteneği.',
        'medical': 'Akciğerler, omuzlar, kollar, eller ve sinir sistemi.',
        'karmic': 'Düşüncenin ve sözün gücünü idrak etme, doğru ve tarafsız bilgi aktarımı.',
      },
      {
        'num': 4,
        'name': '4. Ev (IC) — Yuva, Kökler & Aile Temeli',
        'natural': 'Yengeç ♋',
        'theme': 'Ev, aile, ebeveynler, atalar, vatan, gayrimenkul ve hayatın son dönemleri.',
        'psycho': 'Bilinçaltının duygusal temeli, mahremiyet ihtiyacı ve içsel güvenliğin kurulduğu sığınak.',
        'medical': 'Mide, göğüs, sindirim sistemi ve rahmi çevreleyen dokular.',
        'karmic': 'Soydan ve aile karmasından devralınan duygusal kodların çözülmesi ve şifalanması.',
      },
      {
        'num': 5,
        'name': '5. Ev — Aşk, Yaratıcılık & Yaşam Sevinci',
        'natural': 'Aslan ♌',
        'theme': 'Romantik ilişkiler, çocuklar, sanatsal yaratıcılık, hobiler, sahne, eğlence ve spekülatif kazançlar.',
        'psycho': 'İçsel çocuğun kendini özgürce ifade etmesi, takdir görme arzusu ve hayatın tadını çıkarma cesareti.',
        'medical': 'Kalp, sırt, omurga ve kan dolaşımı.',
        'karmic': 'Egonun kibirden arınıp saf sevgi, cömertlik ve üretkenlikle parlaması.',
      },
      {
        'num': 6,
        'name': '6. Ev — Günlük Rutinler, Sağlık & Hizmet',
        'natural': 'Başak ♍',
        'theme': 'İş ortamı, çalışma arkadaşları, günlük görevler, sağlık alışkanlıkları, beslenme ve evcil hayvanlar.',
        'psycho': 'Mükemmeliyet arayışı, problem çözme dürtüsü, düzen ihtiyacı ve bedensel farkındalık.',
        'medical': 'Bağırsaklar, sindirim enzimleri ve bağışıklık sistemi.',
        'karmic': 'Kibir göstermeksizin alçakgönüllülükle hizmet etme ve bedeni kutsal bir tapınak olarak koruma.',
      },
      {
        'num': 7,
        'name': '7. Ev (DSC) — Evlilik & İkili İlişkiler',
        'natural': 'Terazi ♎',
        'theme': 'Evlilik, uzun vadeli ilişkiler, iş ortaklıkları, yasal sözleşmeler ve açık düşmanlar.',
        'psycho': '"Ben"den "Biz"e geçiş; kendi gölge yönlerini partnerinde görme ve tamamlanma arayışı.',
        'medical': 'Böbrekler, bel bölgesi ve vücut sıvı dengesi.',
        'karmic': 'İlişkilerde adalet, eşitlik ve bencil olmayan koşulsuz uyumun öğrenilmesi.',
      },
      {
        'num': 8,
        'name': '8. Ev — Krizler, Dönüşüm & Okült Bilgelik',
        'natural': 'Akrep ♏',
        'theme': 'Ortaklaşa paralar, miras, vergi, cinsellik, psikolojik krizler, cerrahi operasyonlar ve okült ilimler.',
        'psycho': 'Egonun sembolik ölümü, derin korkularla yüzleşme, tutku ve küllerinden yeniden doğuş.',
        'medical': 'Üreme organları, boşaltım sistemi ve hücresel yenilenme mekanizması.',
        'karmic': 'Bırakabilme gücü, affediş ve ruhsal simya ile toksik enerjileri arındırma.',
      },
      {
        'num': 9,
        'name': '9. Ev — Yüksek Bilgi, İnanç & Vizyon',
        'natural': 'Yay ♐',
        'theme': 'Yüksek öğrenim, felsefe, din, uluslararası seyahatler, yabancı kültürler, hukuk ve astroloji.',
        'psycho': 'Hayatın anlamını arayış, vizyon genişliği, inanç sistemi ve entelektüel iyimserlik.',
        'medical': 'Kalçalar, uyluklar, karaciğer ve siyatik siniri.',
        'karmic': 'Dar kalıpları aşıp evrensel ilahi yasalara ve yüksek hakikate teslimiyet.',
      },
      {
        'num': 10,
        'name': '10. Ev (MC) — Kariyer, Statü & Hayat Amacı',
        'natural': 'Oğlak ♑',
        'theme': 'Meslek, kariyer zirvesi, toplum önündeki unvan, itibar, otorite figürleri ve başarılar.',
        'psycho': 'Sorumluluk alma gücü, dünyevi başarı ihtiyacı ve topluma kalıcı bir iz bırakma arzusu.',
        'medical': 'Dizler, kemikler, eklemler, iskelet sistemi ve dişler.',
        'karmic': 'Dünyevi gücü adaletle kullanma ve ruhsal olgunlukla topluma rehberlik etme.',
      },
      {
        'num': 11,
        'name': '11. Ev — Gelecek Umutları & Dostluklar',
        'natural': 'Kova ♒',
        'theme': 'Sosyal çevre, arkadaş grupları, sivil toplum, geleceğe dair planlar, projeler ve hümanizm.',
        'psycho': 'Ait olma hissi, özgürlük ideali, sıra dışı hedefler ve insanlığın geleceğini düşünme.',
        'medical': 'Baldırlar, kaval kemiği, ayak bilekleri ve sinirsel iletim yolları.',
        'karmic': 'Kişisel egoyu aşarak insanlığın ortak gelişimine karşılıksız katkı sunma.',
      },
      {
        'num': 12,
        'name': '12. Ev — Bilinçaltı, İnziva & Karmik Çözülüş',
        'natural': 'Balık ♓',
        'theme': 'Bilinçaltı, rüyalar, inziva, hastaneler, gizli düşmanlar, meditasyon ve manevi alemler.',
        'psycho': 'Kolektif bilinçdışı ile bağlantı, fedakarlık, empati ve fiziksel dünyanın ötesine geçiş.',
        'medical': 'Ayaklar, lenf dolaşım sistemi ve epifiz bezi.',
        'karmic': 'Eski yaşamlardan kalan tüm karmik borçların ödenmesi ve mutlak ilahi birliğe kavuşma.',
      },
    ];

    final placidusData = PredictiveAstrologyService.calculatePlacidusHouses(profile: widget.profile);
    final Map<int, String> cuspSigns = Map<int, String>.from(placidusData['cuspSigns']);
    final Map<int, String> cuspFormatted = Map<int, String>.from(placidusData['cuspFormatted']);
    final Map<int, double> cuspSpans = Map<int, double>.from(placidusData['cuspSpans']);
    final List<Map<String, dynamic>> interceptedList = List<Map<String, dynamic>>.from(placidusData['interceptedSigns']);
    final List<String> duplicatedSigns = List<String>.from(placidusData['duplicatedSigns']);
    final bool isDayChart = placidusData['isDayChart'] as bool;
    final String sectName = placidusData['sectName'] as String;
    final String sectLight = placidusData['sectLight'] as String;
    final String sectBenefic = placidusData['sectBenefic'] as String;
    final String sectMalefic = placidusData['sectMalefic'] as String;
    final String sectDesc = placidusData['sectDescription'] as String;
    final int rawAscIdx = zodiacSigns.indexOf(_chart?.risingSign ?? 'Koç');
    final int ascIdx = rawAscIdx >= 0 ? rawAscIdx : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. HARİTA MEZHEBİ (GÜNDÜZ / GECE HARİTASI) ---
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDayChart
                  ? [
                      AppColors.starlightGold.withValues(alpha: 0.18),
                      const Color(0xFF1E1A2B),
                    ]
                  : [
                      AppColors.pastelLavender.withValues(alpha: 0.18),
                      const Color(0xFF13111C),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDayChart
                  ? AppColors.starlightGold.withValues(alpha: 0.45)
                  : AppColors.pastelLavender.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDayChart ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        color: isDayChart ? AppColors.starlightGold : AppColors.pastelLavender,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sectName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDayChart ? AppColors.starlightGold : AppColors.pastelLavender,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDayChart ? '☉ GÜNDÜZ' : '☽ GECE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDayChart ? AppColors.starlightGold : AppColors.pastelLavender,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildSectPill('Baş Işık', sectLight, AppColors.starlightGold),
                  _buildSectPill('Baş İyicil', sectBenefic, AppColors.pastelMint),
                  _buildSectPill('Zorlayıcı', sectMalefic, AppColors.savageRed),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                sectDesc,
                style: const TextStyle(fontSize: 11.5, height: 1.45, color: Colors.white70),
              ),
            ],
          ),
        ),

        // --- 2. KISTIRILMIŞ BURÇLAR (INTERCEPTED SIGNS) CARD ---
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1A2B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: interceptedList.isNotEmpty
                  ? AppColors.starlightGold.withValues(alpha: 0.5)
                  : Colors.white12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        interceptedList.isNotEmpty ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                        color: interceptedList.isNotEmpty ? AppColors.starlightGold : AppColors.pastelMint,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'KISTIRILMIŞ BURÇLAR (INTERCEPTED SIGNS)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: interceptedList.isNotEmpty
                          ? AppColors.starlightGold.withValues(alpha: 0.2)
                          : AppColors.pastelMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      interceptedList.isNotEmpty
                          ? '${interceptedList.length} Burç Kilitli'
                          : 'Açık Akslar',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: interceptedList.isNotEmpty ? AppColors.starlightGold : AppColors.pastelMint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Placidus ev sisteminde ev boyutları coğrafi enleme göre değişir. Bazı evler 30°\'den geniş olup bir burcu tamamen içine hapseder. Kıstırılmış burçlar doğrudan bir ev girişi bulamadığından içsel potansiyel olarak saklanır.',
                style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textSecondary),
              ),
              if (interceptedList.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...interceptedList.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item['symbol']} ${item['sign']} (${item['house']}. Ev)',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.compare_arrows_rounded, size: 14, color: Colors.white54),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pastelLavender.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item['oppositeSign']} (${item['oppositeHouse']}. Ev)',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pastelLavender,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(fontSize: 11, height: 1.4, color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }),
                if (duplicatedSigns.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '★ Bu dengelenme gereği ${duplicatedSigns.join(" ve ")} burçları ardışık iki evin girişini birden kesmektedir.',
                    style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppColors.pastelMint),
                  ),
                ],
              ],
            ],
          ),
        ),

        // --- 3. 12 PLACIDUS EV LİSTESİ ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '12 EV ANALİZİ (PLACIDUS AKS & YÖNETİCİLER)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Row(
              children: [
                Icon(Icons.touch_app_rounded,
                    size: 14, color: AppColors.starlightGold),
                SizedBox(width: 4),
                Text(
                  'Detay için dokun',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.starlightGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Yükselen (${_chart!.risingSign}) aksına göre kişisel Placidus ev diziliminiz, her evin tam giriş derecesi, genişliği ve yöneticilikleri.',
          style: const TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        ...List.generate(12, (index) {
          final houseNum = index + 1;
          final houseSign = cuspSigns[houseNum] ?? zodiacSigns[(ascIdx + index) % 12];
          final cuspDeg = cuspFormatted[houseNum] ?? '';
          final span = cuspSpans[houseNum] ?? 30.0;
          final cRuler = classicalRulers[houseSign] ?? '';
          final mRuler = modernRulers[houseSign] ?? '';
          final data = housesData[index];

          final interceptedInHouse = interceptedList.where((i) => i['house'] == houseNum).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _showHouseDetailSheet(
                context,
                data: data,
                chartSign: houseSign,
                classicalRuler: cRuler,
                modernRuler: mRuler,
              ),
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '${data['num']}. EV',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              cuspDeg.isNotEmpty ? cuspDeg : houseSign,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${span.toStringAsFixed(1)}° Genişlik',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (interceptedInHouse.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '🔒 Kıstırılmış: ${interceptedInHouse.first['sign']} Burcu Bu Evde Kilitli',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.starlightGold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      data['name'] as String,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pastelLavender,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.starlightGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Klasik: $cRuler',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.pastelMint.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Modern: $mRuler',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.pastelMint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Doğal: ${data['natural']}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['theme'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectPill(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            val,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showHouseDetailSheet(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String chartSign,
    required String classicalRuler,
    required String modernRuler,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF13111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0x33E5D4FF), width: 1),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${data['num']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Haritanızdaki Burç: $chartSign (Doğal: ${data['natural']})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.pastelLavender,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('KLASİK YÖNETİCİ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.starlightGold)),
                            const SizedBox(height: 2),
                            Text(classicalRuler, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.pastelMint.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MODERN YÖNETİCİ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.pastelMint)),
                            const SizedBox(height: 2),
                            Text(modernRuler, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildHouseInfoBlock('Temsil Ettiği Yaşam Alanı', data['theme'] as String, Icons.explore_rounded, AppColors.pastelLavender),
                      const SizedBox(height: 12),
                      _buildHouseInfoBlock('Psikolojik Anlamı & Dinamikleri', data['psycho'] as String, Icons.psychology_rounded, AppColors.pastelBlue),
                      const SizedBox(height: 12),
                      _buildHouseInfoBlock('Medikal & Beden Temsiliyeti', data['medical'] as String, Icons.favorite_rounded, AppColors.savageRed),
                      const SizedBox(height: 12),
                      _buildHouseInfoBlock('Karmik & Ruhsal Sınavı', data['karmic'] as String, Icons.auto_awesome_rounded, AppColors.starlightGold),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHouseInfoBlock(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // --- Sacred Astrology View (Dekanlar, Mısır Terimleri & 72 Melek) ---
  Widget _buildSacredAstrologyView() {
    final sunDeg = _parseDegreeFromFormatted(_chart!.sunFormatted);
    final moonDeg = _parseDegreeFromFormatted(_chart!.moonFormatted);
    final ascDeg = _parseDegreeFromFormatted(_chart!.risingFormatted);

    final sunDecan = SacredAstrologyService.getDecanForPosition(_chart!.sunSign, sunDeg);
    final sunTerm = SacredAstrologyService.getEgyptianTermForPosition(_chart!.sunSign, sunDeg);
    final sunAngel = SacredAstrologyService.getAngelForPosition(_chart!.sunSign, sunDeg);

    final moonDecan = SacredAstrologyService.getDecanForPosition(_chart!.moonSign, moonDeg);
    final moonTerm = SacredAstrologyService.getEgyptianTermForPosition(_chart!.moonSign, moonDeg);
    final moonAngel = SacredAstrologyService.getAngelForPosition(_chart!.moonSign, moonDeg);
    final moonMansion = LunarMansionsService.getMansionForSignDegree(_chart!.moonSign, moonDeg);

    final ascDecan = SacredAstrologyService.getDecanForPosition(_chart!.risingSign, ascDeg);
    final ascTerm = SacredAstrologyService.getEgyptianTermForPosition(_chart!.risingSign, ascDeg);
    final ascAngel = SacredAstrologyService.getAngelForPosition(_chart!.risingSign, ascDeg);

    final allAngels = SacredAstrologyService.getAllAngels();
    final allDecans = SacredAstrologyService.getAllDecans();
    final allTerms = SacredAstrologyService.getAllEgyptianTerms();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C1A4D),
                  const Color(0xFF140E24),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.35)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.starlightGold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'DEKANLAR, MISIR TERİMLERİ & 72 MELEK',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: AppColors.starlightGold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Kadim Mısır Terimleri (Egyptian Bounds), 36 Keldani Dekanı ve 360° Zodyak çarkını 5 derecelik yaylarla yöneten 72 Kabala Meleği (Shem HaMephorash) bilgeliği.',
                  style: TextStyle(fontSize: 11.5, height: 1.45, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Personal Alignment Title
          Text(
            'KİŞİSEL KADİM HARİTA EŞLEŞMENİZ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Güneş, Ay ve Yükselen derecelerinizin temas ettiği kadim yöneticiler ve koruyucu melekleriniz.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          // Triad Cards: Güneş, Ay, Yükselen
          _buildSacredTriadCard(
            title: 'Güneş Konumu',
            position: _chart!.sunFormatted,
            decan: sunDecan,
            term: sunTerm,
            angel: sunAngel,
            color: AppColors.starlightGold,
            icon: Icons.wb_sunny_rounded,
          ),
          const SizedBox(height: 10),
          _buildSacredTriadCard(
            title: 'Ay Konumu',
            position: _chart!.moonFormatted,
            decan: moonDecan,
            term: moonTerm,
            angel: moonAngel,
            color: AppColors.pastelLavender,
            icon: Icons.nightlight_round,
          ),
          const SizedBox(height: 10),
          _buildSacredTriadCard(
            title: 'Yükselen (ASC) Konumu',
            position: _chart!.risingFormatted,
            decan: ascDecan,
            term: ascTerm,
            angel: ascAngel,
            color: AppColors.pastelMint,
            icon: Icons.north_east_rounded,
          ),
          const SizedBox(height: 10),

          // 4th Card: Doğum Haritası Ay Menzili & Hermetik Durağı
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.starlightGold.withValues(alpha: 0.15),
                  const Color(0xFF1B182B),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.starlightGold.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: AppColors.starlightGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Natal Ay Menzili (${moonMansion.number}/28)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        moonMansion.nature,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${moonMansion.name} (${moonMansion.arabicName}) • ${moonMansion.signRange}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.starlightGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  moonMansion.description,
                  style: const TextStyle(
                      fontSize: 11.5, height: 1.4, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✨ Hermetik Tılsım: ${moonMansion.hermeticTalisman}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.pastelMint)),
                      const SizedBox(height: 2),
                      Text('✓ Doğuştan Yatkınlık: ${moonMansion.favorableFor}',
                          style: const TextStyle(
                              fontSize: 10.5, color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Sub-Tab Selector for Complete Catalog
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KADİM REHBER & KATALOG',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                _buildSacredSubTabButton(0, '72 Melek'),
                _buildSacredSubTabButton(1, '36 Dekan'),
                _buildSacredSubTabButton(2, 'Mısır Terimleri'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sub-Tab Content
          if (_sacredSubTab == 0) ...[
            // 72 Angels List
            ...allAngels.map((angel) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161224),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${angel.number}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              angel.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.pastelMint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            angel.choir,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pastelMint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          angel.degreeRange,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Fazilet: ${angel.virtue}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pastelLavender,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      angel.meaning,
                      style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.white70),
                    ),
                  ],
                ),
              );
            }),
          ] else if (_sacredSubTab == 1) ...[
            // 36 Decans List
            ...allDecans.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161224),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${d.sign} ${d.dekanNumber}. Dekan (${d.degreeRange})',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.starlightGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Keldani: ${d.chaldeanRuler}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Üçlü Yöneticisi: ${d.triplicityRuler}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.pastelMint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.description,
                      style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.white70),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            // Egyptian Bounds List
            ...allTerms.entries.map((entry) {
              final sign = entry.key;
              final terms = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161224),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$sign Burcu Mısır Terimleri (5 Bölünüş)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.starlightGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...terms.map((t) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 76,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${t.startDegree}° - ${t.endDegree}°',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pastelLavender.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.rulingPlanet,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pastelLavender,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.meaning,
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSacredSubTabButton(int index, String label) {
    final isSelected = _sacredSubTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _sacredSubTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.starlightGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black87 : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSacredTriadCard({
    required String title,
    required String position,
    required DecanInfo decan,
    required EgyptianTermInfo term,
    required KabbalahAngelInfo angel,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181427),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  position,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DEKAN YÖNETİCİSİ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.starlightGold)),
                      const SizedBox(height: 2),
                      Text('${decan.dekanNumber}. Dekan • ${decan.chaldeanRuler}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Üçlü: ${decan.triplicityRuler}', style: const TextStyle(fontSize: 9.5, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MISIR TERİMİ (BOUND)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.pastelMint)),
                      const SizedBox(height: 2),
                      Text(term.rulingPlanet, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${term.startDegree}° - ${term.endDegree}°', style: const TextStyle(fontSize: 9.5, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.pastelLavender.withValues(alpha: 0.15),
                  AppColors.starlightGold.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded, size: 16, color: AppColors.pastelLavender),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '72 Kabala Koruyucu Meleği: #${angel.number} ${angel.name} (${angel.choir})',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fazileti: ${angel.virtue} • ${angel.meaning}',
                        style: const TextStyle(fontSize: 10.5, height: 1.35, color: Colors.white70),
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

  // --- VIP Locked Sacred View (Melekler & Dekanlar Kilidi) ---
  Widget _buildVipLockedSacredView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C1A4D).withValues(alpha: 0.95),
                const Color(0xFF140E24).withValues(alpha: 0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.starlightGold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.starlightGold.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.starlightGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.starlightGold, width: 2),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 34,
                  color: AppColors.starlightGold,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '72 KABALA MELEĞİ & KADİM DEKANLAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.starlightGold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Doğum haritanızdaki Güneş, Ay ve Yükselen derecelerinizin koruyucu Kabala Melekleri (Shem HaMephorash), Kadim Mısır Sınırları ve 36 Keldani Dekanı VIP üyelerimize özel derin ezoterik içeriklerdir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.pastelMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Güneş & Ay derecenize denk gelen özel koruyucu melek',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.pastelMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kadim Mısır Terimleri (Egyptian Bounds) yöneticileri',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.pastelMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '28 Kadim Ay Menzili & Hermetik Tılsım potansiyeli',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.starlightGold,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _showVipCodeModal(context),
                icon: const Icon(Icons.stars_rounded, size: 20),
                label: const Text(
                  'VIP Üyeliğe Yükselt / Kod Gir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVipCodeModal(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B162B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.starlightGold, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.starlightGold),
            SizedBox(width: 8),
            Text(
              'VIP Erişim Aktivasyonu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Satın aldığınız VIP paket veya astrolog davet kodunuzu girerek tüm modüllere sınırsız erişebilirsiniz:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: const TextStyle(
                color: AppColors.starlightGold,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'VIP Kodu Giriniz',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.starlightGold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final code = controller.text.trim();
              final success = await StorageService.activateVipCode(code);
              if (success && mounted) {
                setState(() => _isVip = true);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '🎉 VIP erişimi başarıyla aktif edildi! Tüm modüller açıldı.'
                          : '❌ Geçersiz kod. Lütfen tekrar deneyiniz.',
                    ),
                    backgroundColor: success
                        ? const Color(0xFF1D5A3A)
                        : const Color(0xFF5A1D2C),
                  ),
                );
              }
            },
            child: const Text('Aktif Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Çakra & Medikal Astroloji Görünümü ---
  Widget _buildChakraView() {
    final userChakras = ChakraService.analyzeUserChakras(_chart!);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A2639),
                  Color(0xFF13111C),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.pastelMint.withValues(alpha: 0.35),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.spa_rounded, color: AppColors.pastelMint, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '7 ANA ÇAKRA & MEDİKAL ASTROLOJİ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.pastelMint,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Kozmik gezegen enerjileri fiziksel bedenimizde 7 ana çakra ve salgı bezleri vasıtasıyla tezahür eder. Doğum haritanızdaki element dengesi bu çakraların akışkanlığını veya tıkanıklıklarını yönetir.',
                  style: TextStyle(fontSize: 11.5, height: 1.45, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HARİTANIZA GÖRE ÇAKRA DURUMU',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 14, color: AppColors.pastelMint),
                  SizedBox(width: 4),
                  Text(
                    'Detay için dokun',
                    style: TextStyle(fontSize: 11, color: AppColors.pastelMint, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...userChakras.map((item) => _buildChakraCard(item)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildChakraCard(UserChakraAnalysis item) {
    final c = item.chakra;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showChakraDetailModal(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171325),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: c.color, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '${c.number}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: c.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            c.sanskritName,
                            style: TextStyle(
                              fontSize: 11,
                              color: c.color.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: item.statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: item.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Astrological Connection & Body
              Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 14, color: AppColors.starlightGold),
                  const SizedBox(width: 5),
                  Text(
                    'Gezegen: ${c.rulingPlanets} (${c.element})',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.starlightGold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.accessibility_new_rounded, size: 14, color: AppColors.pastelMint),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Beden: ${c.bodyParts}',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Personal Insight
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.personalInsight,
                  style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),

              // Chips: Mantra & Crystals
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Mantra: ${c.mantra}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.color.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      '💎 ${c.crystals}',
                      style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChakraDetailModal(BuildContext context, UserChakraAnalysis analysis) {
    final c = analysis.chakra;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF13111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0x33E5D4FF), width: 1)),
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

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: c.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: c.color, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${c.number}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            '${c.sanskritName} • ${c.element} Elementi',
                            style: TextStyle(fontSize: 12, color: c.color),
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
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: analysis.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: analysis.statusColor.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.insights_rounded, size: 16, color: analysis.statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Haritanızdaki Durum: ${analysis.status}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: analysis.statusColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              analysis.personalInsight,
                              style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildChakraDetailSection(
                        title: 'ASTROLOJİK & RUHSAL DERİNLİK',
                        icon: Icons.all_inclusive_rounded,
                        color: AppColors.starlightGold,
                        content: c.spiritualMeaning,
                      ),
                      const SizedBox(height: 14),

                      _buildChakraDetailSection(
                        title: 'YÖNETTİĞİ BEDEN & ORGANLAR',
                        icon: Icons.health_and_safety_rounded,
                        color: AppColors.pastelMint,
                        content: c.bodyParts,
                      ),
                      const SizedBox(height: 14),

                      _buildChakraDetailSection(
                        title: 'BLOKAJ / YETERSİZLİK BELİRTİLERİ',
                        icon: Icons.trending_down_rounded,
                        color: AppColors.savageRed,
                        content: c.deficiencySymptoms,
                      ),
                      const SizedBox(height: 14),

                      _buildChakraDetailSection(
                        title: 'AŞIRILIK / HİPERAKTİF BELİRTİLER',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.warningOrange,
                        content: c.excessSymptoms,
                      ),
                      const SizedBox(height: 14),

                      _buildChakraDetailSection(
                        title: 'DENGELEME & ŞİFALANMA REÇETESİ',
                        icon: Icons.spa_rounded,
                        color: AppColors.pastelBlue,
                        content: c.balancingTips,
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1830),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.diamond_rounded, size: 16, color: AppColors.starlightGold),
                                SizedBox(width: 6),
                                Text(
                                  'ŞİFALI DOĞAL TAŞLAR & KRİSTALLER',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.starlightGold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.crystals,
                              style: const TextStyle(fontSize: 12.5, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(Icons.format_quote_rounded, size: 16, color: AppColors.pastelLavender),
                                SizedBox(width: 6),
                                Text(
                                  'GÜNLÜK ÇAKRA OLUMLAMASI',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.pastelLavender),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${c.affirmation}"',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChakraDetailSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181427),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 12.5, height: 1.45, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showPlanetDetailSheet(BuildContext context, String key, PlanetPosition planet) {
    final entry = AstrologyEncyclopedia.getEntry(key);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF13111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0x33E5D4FF), width: 1),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.pastelLavender.withValues(alpha: 0.3),
                            AppColors.pastelPink.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(key),
                          style: const TextStyle(fontSize: 24, color: AppColors.starlightGold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry?.name ?? planet.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Haritandaki Konum: ${planet.formatted}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.pastelPink,
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
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Temsil Ettiği Temalar
                      _buildDetailSection(
                        title: 'TEMSİL ETTİĞİ TEMALAR & YAŞAM ALANI',
                        icon: Icons.auto_awesome_rounded,
                        accentColor: AppColors.starlightGold,
                        content: entry?.represents ?? 'Yaşam yolculuğunda bu nokta temel enerjinizi şekillendirir.',
                      ),
                      const SizedBox(height: 14),

                      // 2. Işık ve Gölge Yönleri (Pozitif / Negatif)
                      if (entry != null) ...[
                        Text(
                          'IŞIK VE GÖLGE YÖNLERİ',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.pastelLavender,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
                                borderColor: AppColors.pastelMint.withValues(alpha: 0.4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.wb_sunny_rounded, size: 16, color: AppColors.pastelMint),
                                        SizedBox(width: 6),
                                        Text(
                                          'Pozitif (Işık)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.pastelMint,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      entry.positiveLight,
                                      style: const TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
                                borderColor: AppColors.savageRed.withValues(alpha: 0.4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.nightlight_round, size: 16, color: AppColors.savageRed),
                                        SizedBox(width: 6),
                                        Text(
                                          'Gölge (Negatif)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.savageRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      entry.shadowNegative,
                                      style: const TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 3. Klasik Astroloji
                      if (entry != null)
                        _buildDetailSection(
                          title: 'KLASİK ASTROLOJİDEKİ KARŞILIĞI',
                          icon: Icons.account_balance_rounded,
                          accentColor: AppColors.pastelBlue,
                          content: entry.classical,
                        ),
                      const SizedBox(height: 14),

                      // 4. Karmik Boyut
                      if (entry != null)
                        _buildDetailSection(
                          title: 'KARMİK & RUHSAL DERS',
                          icon: Icons.all_inclusive_rounded,
                          accentColor: AppColors.pastelLavender,
                          content: entry.karmic,
                        ),
                      const SizedBox(height: 14),

                      // 5. Mundane (Dünya & Toplum)
                      if (entry != null)
                        _buildDetailSection(
                          title: 'MUNDANE (DÜNYA & TOPLUM) ASTROLOJİSİ',
                          icon: Icons.public_rounded,
                          accentColor: AppColors.pastelPeach,
                          content: entry.mundane,
                        ),
                      const SizedBox(height: 14),

                      // 6. Medikal Astroloji & Organlar
                      if (entry != null)
                        _buildDetailSection(
                          title: 'MEDİKAL ASTROLOJİ & ETKİLEDİĞİ ORGANLAR',
                          icon: Icons.health_and_safety_rounded,
                          accentColor: AppColors.pastelMint,
                          content: entry.medical,
                        ),
                      const SizedBox(height: 14),

                      // 7. Ezoterik Karşılıklar (Metal, Gün, Arketip)
                      if (entry != null) ...[
                        Text(
                          'EZOTERİK KARŞILIKLAR & ARKETİPLER',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.starlightGold,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip('Metali', entry.metal, Icons.shield_rounded),
                            const SizedBox(width: 8),
                            _buildInfoChip('Günü', entry.day, Icons.calendar_today_rounded),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoChip('Rehber Arketip / Meleği', entry.archangel, Icons.military_tech_rounded, fullWidth: true),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required String content,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: accentColor.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, {bool fullWidth = false}) {
    final chip = GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.starlightGold),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return fullWidth ? chip : Expanded(child: chip);
  }

  Widget _buildElementCard(
      String title, int count, Color color, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: () => _showElementDetailSheet(context, title, count),
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          borderRadius: 16,
          borderColor: color.withValues(alpha: 0.35),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showElementDetailSheet(BuildContext context, String elementName, int score) {
    final entry = ElementEncyclopedia.getEntry(elementName);
    if (entry == null) return;

    final String statusLabel = score > 4
        ? 'AŞIRI / BASKIN'
        : (score == 4 ? 'DENGELİ (İDEAL SEVİYE)' : 'EKSİK / YETERSİZ');
    final Color statusColor = score > 4
        ? AppColors.warningOrange
        : (score == 4 ? AppColors.pastelMint : AppColors.savageRed);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF13111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0x33E5D4FF), width: 1),
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          entry.symbol,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${entry.element} Elementi',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Haritandaki Puanı: $score Puan',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.starlightGold,
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
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection(
                        title: 'GENEL DOĞASI & YAŞAM GÜCÜ',
                        icon: Icons.all_inclusive_rounded,
                        accentColor: AppColors.pastelLavender,
                        content: entry.generalNature,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              borderColor: AppColors.pastelMint.withValues(alpha: 0.4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded,
                                          size: 16, color: AppColors.pastelMint),
                                      SizedBox(width: 6),
                                      Text(
                                        'Pozitif (Dengeli)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.pastelMint,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.positiveBalanced,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              borderColor: AppColors.savageRed.withValues(alpha: 0.4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.remove_circle_outline_rounded,
                                          size: 16, color: AppColors.savageRed),
                                      SizedBox(width: 6),
                                      Text(
                                        'Gölge (Negatif)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.savageRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.shadowNegative,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildDetailSection(
                        title: 'HARİTADA FAZLALIK DURUMUNDA (AŞIRILIK)',
                        icon: Icons.trending_up_rounded,
                        accentColor: AppColors.warningOrange,
                        content: entry.excessCondition,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailSection(
                        title: 'HARİTADA EKSİKLİK / AZLIK DURUMUNDA',
                        icon: Icons.trending_down_rounded,
                        accentColor: AppColors.savageRed,
                        content: entry.deficiencyCondition,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailSection(
                        title: 'DENGELEME VE ŞİFALANMA REÇETESİ',
                        icon: Icons.spa_rounded,
                        accentColor: AppColors.pastelMint,
                        content: entry.healingTips,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTurkishPlanetName(String key) {
    switch (key.toLowerCase()) {
      case 'sun':
      case 'güneş':
        return 'Güneş';
      case 'moon':
      case 'ay':
        return 'Ay';
      case 'mercury':
      case 'merkür':
        return 'Merkür';
      case 'venus':
      case 'venüs':
        return 'Venüs';
      case 'mars':
        return 'Mars';
      case 'jupiter':
      case 'jüpiter':
        return 'Jüpiter';
      case 'saturn':
      case 'satürn':
        return 'Satürn';
      case 'uranus':
      case 'uranüs':
        return 'Uranüs';
      case 'neptune':
      case 'neptün':
        return 'Neptün';
      case 'pluto':
      case 'plüton':
        return 'Plüton';
      case 'chiron':
      case 'kiron':
        return 'Kiron (Chiron)';
      case 'north_node':
      case 'kuzey ay düğümü':
        return 'Kuzey Ay Düğümü';
      case 'south_node':
      case 'güney ay düğümü':
        return 'Güney Ay Düğümü';
      case 'ascendant':
      case 'yükselen':
      case 'asc':
        return 'Yükselen (ASC)';
      case 'mc':
      case 'tepe noktası':
        return 'Tepe Noktası (MC)';
      case 'ic':
      case 'dip noktası':
        return 'Dip Noktası (IC)';
      case 'descendant':
      case 'alçalan':
      case 'dsc':
        return 'Alçalan (DSC)';
      default:
        return _chart?.planets[key]?.name ?? key;
    }
  }

  String _getPlanetSymbol(String key) {
    switch (key.toLowerCase()) {
      case 'sun':
      case 'güneş':
        return '☉';
      case 'moon':
      case 'ay':
        return '☽';
      case 'mercury':
      case 'merkür':
        return '☿';
      case 'venus':
      case 'venüs':
        return '♀';
      case 'mars':
        return '♂';
      case 'jupiter':
      case 'jüpiter':
        return '♃';
      case 'saturn':
      case 'satürn':
        return '♄';
      case 'uranus':
      case 'uranüs':
        return '♅';
      case 'neptune':
      case 'neptün':
        return '♆';
      case 'pluto':
      case 'plüton':
        return '♇';
      case 'chiron':
      case 'kiron':
        return '⚷';
      case 'north_node':
      case 'kuzey ay düğümü':
        return '☊';
      case 'south_node':
      case 'güney ay düğümü':
        return '☋';
      case 'ascendant':
      case 'yükselen':
        return 'ASC';
      case 'mc':
      case 'tepe noktası':
        return 'MC';
      case 'ic':
      case 'dip noktası':
        return 'IC';
      case 'descendant':
      case 'alçalan':
        return 'DSC';
      default:
        return '✧';
    }
  }

  // ==========================================
  // --- DOĞAL TAŞLAR & KRİSTAL ASTROLOJİSİ ---
  // ==========================================
  Widget _buildCrystalsView() {
    final birthstones = CrystalsService.getBirthStones(
      sunSign: _chart?.sunSign ?? 'Koç',
      ascendantSign: _chart?.risingSign ?? 'Koç',
      moonSign: _chart?.moonSign ?? 'Koç',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.pastelLavender.withValues(alpha: 0.18),
                  AppColors.starlightGold.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.starlightGold.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.starlightGold.withValues(alpha: 0.2),
                  ),
                  child: const Center(
                    child: Text('💎', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KRİSTAL ASTROLOJİSİ REHBERİ',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.starlightGold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Doğal taşlar, minerallerindeki kristal kafes geometrisi sayesinde gezegen frekanslarını bedensel çakralarla rezonansa sokar ve auranızı dengeler.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // User's Personal Birthstones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HARİTANIZA ÖZEL DOĞAL TAŞLAR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.starlightGold,
                      letterSpacing: 1.1,
                    ),
              ),
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 13, color: AppColors.pastelMint),
                  SizedBox(width: 4),
                  Text(
                    'Detay için dokun',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.pastelMint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...birthstones.map((crystal) {
            return _buildCrystalCard(crystal, isHighlighted: true);
          }),

          const SizedBox(height: 26),

          // All Crystals Directory
          Text(
            'TÜM DOĞAL TAŞLAR & ŞİFA KATALOĞU',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.pastelLavender,
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: 10),

          ...CrystalsService.allCrystals.map((crystal) {
            return _buildCrystalCard(crystal, isHighlighted: false);
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCrystalCard(CrystalModel crystal, {required bool isHighlighted}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161224),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? AppColors.starlightGold.withValues(alpha: 0.5)
              : Colors.white12,
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCrystalDetailSheet(context, crystal),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                          Text(crystal.symbol, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crystal.turkishName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  crystal.name,
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
                    ),
                    if (isHighlighted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.starlightGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text(
                          'HARİTANDA AKTİF',
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPill('Gezegen: ${crystal.planets.join(', ')}', AppColors.pastelPink),
                    _buildPill('Burç: ${crystal.zodiacSigns.join(', ')}', AppColors.pastelLavender),
                    _buildPill('Çakra: ${crystal.chakras.first}', AppColors.pastelMint),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  crystal.emotionalBenefits,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showCrystalDetailSheet(BuildContext context, CrystalModel crystal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF13111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.starlightGold, width: 1.2)),
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
                  Text(crystal.symbol, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crystal.turkishName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${crystal.name} • ${crystal.element} Elementi',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.starlightGold,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Olumlama Kartı
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.starlightGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.starlightGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.starlightGold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '"${crystal.affirmation}"',
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailSection(
                    title: 'RUHSAL & ENERJETİK FAYDALARI',
                    icon: Icons.all_inclusive_rounded,
                    accentColor: AppColors.pastelLavender,
                    content: crystal.spiritualBenefits,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'DUYGUSAL & PSİKOLOJİK ETKİLERİ',
                    icon: Icons.favorite_rounded,
                    accentColor: AppColors.pastelPink,
                    content: crystal.emotionalBenefits,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'FİZİKSEL ŞİFA & BEDENSEL DESTEK',
                    icon: Icons.healing_rounded,
                    accentColor: AppColors.pastelMint,
                    content: crystal.physicalBenefits,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'ARINDIRMA & ŞARJ ETME YÖNTEMLERİ',
                    icon: Icons.water_drop_rounded,
                    accentColor: AppColors.pastelBlue,
                    content: crystal.cleansingMethod,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'NASIL VE NEREDE KULLANILMALI?',
                    icon: Icons.touch_app_rounded,
                    accentColor: AppColors.warningOrange,
                    content: crystal.howToUse,
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

  // ==========================================
  // --- KABALA ASTROLOJİSİ & YAŞAM AĞACI ---
  // ==========================================
  Widget _buildVipLockedKabbalahView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C172C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.starlightGold.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.starlightGold.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.starlightGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.starlightGold, width: 2),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  size: 34,
                  color: AppColors.starlightGold,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'KABALA ASTROLOJİSİ & YAŞAM AĞACI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.starlightGold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '10 Kutsal Sefirot, 22 Kozmik Yol ve Ruhun İlahi İnme/Yükselme Haritası (Otz Chiim) yalnızca VIP üyelerimize özel derin ezoterik içeriktir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.pastelMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '10 Sefirot ve Gezegensel Karşılıkları (Binah, Chesed, Tiferet...)',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.pastelMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '22 İbrani Yolu ve Zodyak Eşleşmeleri (Aleph\'ten Tav\'a)',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.pastelMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Merhamet, Adalet ve Denge Sütunları Üzerindeki Ruh Konumunuz',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.starlightGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    // Show VIP info
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kabala Ağacı VIP üyelere açıktır. Ana ekrandan VIP yükseltebilirsiniz! 👑'),
                        backgroundColor: Color(0xFF2C1E4A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                  label: const Text(
                    'VIP İLE HEMEN KİLİDİ AÇ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKabbalahTreeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.starlightGold.withValues(alpha: 0.18),
                  const Color(0xFF2C1E4A).withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.starlightGold.withValues(alpha: 0.4),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_tree_rounded,
                        color: AppColors.starlightGold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'YAŞAM AĞACI (OTZ CHIIM)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.starlightGold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Kabala geleneğinde Yaşam Ağacı, Tanrısal Nur\'un Keter\'den (Taç) Malkhut\'a (Madde / Dünya) doğru inişini ve insanın tekamül ederek yukarı yükselişini gösteren 10 Sefira ve 22 Yoldan oluşur.',
                  style: TextStyle(fontSize: 12, height: 1.45, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3 Pillars Overview
          Text(
            'YAŞAM AĞACININ 3 KUTSAL SÜTUNU',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.pastelLavender,
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildPillarCard(
                  title: 'SOL SÜTUN',
                  sub: 'Şiddet / Boaz',
                  theme: 'Disiplin, Yapı, Sınırlar',
                  sephirot: 'Binah, Gevurah, Hod',
                  color: AppColors.savageRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarCard(
                  title: 'ORTA SÜTUN',
                  sub: 'Denge / Bilinç',
                  theme: 'Işık, Uyum, Ruh',
                  sephirot: 'Keter, Tiferet, Yesod, Malkhut',
                  color: AppColors.starlightGold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarCard(
                  title: 'SAĞ SÜTUN',
                  sub: 'Merhamet / Jachin',
                  theme: 'Lütuf, Genişleme, Enerji',
                  sephirot: 'Chokhmah, Chesed, Netzach',
                  color: AppColors.pastelMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 10 Sephirot Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10 KUTSAL SEFİRA & GEZEGEN KARŞILIKLARI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.starlightGold,
                      letterSpacing: 1.1,
                    ),
              ),
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 13, color: AppColors.starlightGold),
                  SizedBox(width: 4),
                  Text(
                    'İncele',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.starlightGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...KabbalahTreeService.sephirot.map((sefira) {
            return _buildSephiraCard(sefira);
          }),

          const SizedBox(height: 24),

          // 22 Paths Directory
          Text(
            '22 KOZMİK YOL & ZODYAK BAĞLANTILARI',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.pastelLavender,
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: 10),

          ...KabbalahTreeService.paths.take(10).map((path) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161224),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.starlightGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        path.hebrewLetter.split(' ').first,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path.pathName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${path.astrologicalCorrespondence} • ${path.meaning}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required String title,
    required String sub,
    required String theme,
    required String sephirot,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161224),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            theme,
            style: const TextStyle(fontSize: 9.5, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            sephirot,
            style: TextStyle(fontSize: 8.5, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSephiraCard(SephiraModel s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161224),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSephiraDetailSheet(context, s),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Color(s.colorValue).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(s.colorValue).withValues(alpha: 0.6)),
                  ),
                  child: Center(
                    child: Text(
                      '${s.number}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(s.colorValue),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.turkishName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.hebrewName.split(' ').first,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.starlightGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s.planetaryCorrespondence} • ${s.pillar}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.pastelMint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.spiritualLesson,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSephiraDetailSheet(BuildContext context, SephiraModel s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF13111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.starlightGold, width: 1.2)),
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Color(s.colorValue).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(s.colorValue)),
                    ),
                    child: Center(
                      child: Text(
                        '${s.number}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(s.colorValue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.turkishName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${s.hebrewName} • ${s.englishName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.starlightGold,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildDetailSection(
                    title: 'RUHSAL & EZOTERİK ANLAMI',
                    icon: Icons.all_inclusive_rounded,
                    accentColor: AppColors.starlightGold,
                    content: s.spiritualMeaning,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'GEZEGENSEL & ASTROLOJİK KARŞILIĞI',
                    icon: Icons.public_rounded,
                    accentColor: AppColors.pastelMint,
                    content: '${s.planetaryCorrespondence}\nSütun: ${s.pillar}\nBeden Alanı: ${s.bodyPart}',
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'BAŞMELEK & İLAHİ İSİM',
                    icon: Icons.auto_awesome_rounded,
                    accentColor: AppColors.pastelLavender,
                    content: 'Başmelek: ${s.archangel}\nİlahi İsim: ${s.divineName}\nMelek Korosu: ${s.angelicOrder}',
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'PSİKOLOJİK ARKETİP & İÇSEL BENLİK',
                    icon: Icons.psychology_rounded,
                    accentColor: AppColors.pastelPink,
                    content: s.psychologicalArchetype,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailSection(
                    title: 'RUHSAL DERS & TEKAMÜL ADIMI',
                    icon: Icons.school_rounded,
                    accentColor: AppColors.warningOrange,
                    content: s.spiritualLesson,
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
}

