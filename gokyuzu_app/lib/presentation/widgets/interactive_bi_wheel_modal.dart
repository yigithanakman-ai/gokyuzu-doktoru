import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/predictive_astrology_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/saved_profile_model.dart';
import '../../data/services/profile_archive_service.dart';
import 'astrological_glyph.dart';
import '../screens/chart_zoom_screen.dart';

enum BiWheelDisplayMode {
  dual, // Dış Çark: Canlı Transitler, İç Çark: Doğum (Natal)
  transitOnly, // Sadece Transit Haritası (Transitlerin kendi arasındaki açıları)
  natalOnly, // Sadece Doğum Haritası (Natal haritanın kendi arasındaki açıları)
}

/// Gökyüzü Doktoru — İnteraktif Çift Çark (Interactive Bi-Wheel) & Zaman Makinesi
/// Solar Fire ve Astro Gold düzeyinde:
/// - İç Çark: Doğum (Natal) Haritası
/// - Dış Çark: Anlık veya Gelecek/Geçmiş Transitler (Zaman Makinesiyle ileri/geri sarma)
/// - Ev giriş kaspları (1-12), kasp dereceleri, gezegen dereceleri, True/Mean Node ve Asteroit seçimi
/// - Merkez: Evrensel Açı Orbları (0°=10°, 180°=10°, 120°=8°, 90°=7°, 60°=7°)
class InteractiveBiWheelModal extends StatefulWidget {
  final UserProfile natalProfile;
  final bool initialUseTrueNode;
  final Set<String>? initialEnabledAsteroids;

  const InteractiveBiWheelModal({
    super.key,
    required this.natalProfile,
    this.initialUseTrueNode = true,
    this.initialEnabledAsteroids,
  });

  @override
  State<InteractiveBiWheelModal> createState() => _InteractiveBiWheelModalState();
}

class _InteractiveBiWheelModalState extends State<InteractiveBiWheelModal> {
  late DateTime _simulatedTransitDate;
  late TimeOfDay _simulatedTransitTime;

  BirthChartModel? _natalChart;
  BirthChartModel? _transitChart;
  Map<int, double>? _natalPlacidusCusps;
  bool _isLoading = true;

  // Selected planet for aspect ray highlighting
  String? _selectedPlanetKey;
  final bool _isTransitPlanetSelected = false;

  // True Node vs Mean Node & Optional Asteroids
  late bool _useTrueNode;
  late Set<String> _enabledAsteroids;

  static const List<Map<String, String>> selectableAsteroids = [
    {'key': 'lilith', 'name': 'Lilith', 'sym': '⚸'},
    {'key': 'vesta', 'name': 'Vesta', 'sym': '⚶'},
    {'key': 'juno', 'name': 'Juno', 'sym': '⚵'},
    {'key': 'amor', 'name': 'Amor', 'sym': '♡'},
    {'key': 'hekate', 'name': 'Hekate', 'sym': '⚝'},
    {'key': 'isis', 'name': 'Isis', 'sym': '☥'},
    {'key': 'vertex', 'name': 'Vertex', 'sym': 'Vx'},
    {'key': 'pallas', 'name': 'Pallas', 'sym': '⚴'},
    {'key': 'ceres', 'name': 'Ceres', 'sym': '⚳'},
    {'key': 'chiron', 'name': 'Chiron', 'sym': '⚷'},
  ];

  // Secondary profile for Synastry mode (optional)
  SavedProfile? _synastryPartner;
  bool _isSynastryMode = false;
  List<SavedProfile> _availableSavedProfiles = [];
  BiWheelDisplayMode _displayMode = BiWheelDisplayMode.dual;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _simulatedTransitDate = now;
    _simulatedTransitTime = TimeOfDay.fromDateTime(now);
    _useTrueNode = widget.initialUseTrueNode;
    _enabledAsteroids = widget.initialEnabledAsteroids != null
        ? Set<String>.from(widget.initialEnabledAsteroids!)
        : {'chiron', 'lilith', 'vertex'};
    _loadInitialCharts();
  }

  Future<void> _loadInitialCharts() async {
    setState(() => _isLoading = true);

    DateTime natalDate = DateTime(1995, 1, 1);
    if (widget.natalProfile.birthDate.contains('-')) {
      final p = widget.natalProfile.birthDate.split('-');
      natalDate = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } else if (widget.natalProfile.birthDate.contains('.')) {
      final p = widget.natalProfile.birthDate.split('.');
      natalDate = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }

    final tp = widget.natalProfile.birthTime.split(':');
    final nhour = tp.isNotEmpty ? (int.tryParse(tp[0]) ?? 12) : 12;
    final nmin = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;

    _natalChart = AstrologyEngine.calculateChart(
      name: widget.natalProfile.name,
      birthDate: natalDate,
      birthTime: TimeOfDay(hour: nhour, minute: nmin),
      city: widget.natalProfile.birthCity.isEmpty ? 'İstanbul' : widget.natalProfile.birthCity,
      country: widget.natalProfile.birthCountry.isEmpty ? 'Türkiye' : widget.natalProfile.birthCountry,
    );

    final placidus = PredictiveAstrologyService.calculatePlacidusHouses(profile: widget.natalProfile);
    if (placidus['cusps'] is Map<int, double>) {
      _natalPlacidusCusps = placidus['cusps'] as Map<int, double>;
    }

    _calculateTransitChart();

    final saved = await ProfileArchiveService.getProfiles();
    if (mounted) {
      setState(() {
        _availableSavedProfiles = saved;
        _isLoading = false;
      });
    }
  }

  void _calculateTransitChart() {
    if (_isSynastryMode && _synastryPartner != null) {
      final p = _synastryPartner!;
      final tp = p.birthTime.split(':');
      final h = tp.isNotEmpty ? (int.tryParse(tp[0]) ?? 12) : 12;
      final m = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;

      _transitChart = AstrologyEngine.calculateChart(
        name: p.fullName,
        birthDate: p.birthDate,
        birthTime: TimeOfDay(hour: h, minute: m),
        city: p.birthCity.isEmpty ? 'İstanbul' : p.birthCity,
        country: p.birthCountry.isEmpty ? 'Türkiye' : p.birthCountry,
      );
    } else {
      _transitChart = AstrologyEngine.calculateChart(
        name: 'Transit Gökyüzü',
        birthDate: _simulatedTransitDate,
        birthTime: _simulatedTransitTime,
        city: widget.natalProfile.birthCity.isEmpty ? 'İstanbul' : widget.natalProfile.birthCity,
        country: widget.natalProfile.birthCountry.isEmpty ? 'Türkiye' : widget.natalProfile.birthCountry,
      );
    }
  }

  void _stepTime({int days = 0, int hours = 0, int months = 0, int years = 0}) {
    if (_isSynastryMode) return;

    DateTime newDt = _simulatedTransitDate;
    if (years != 0) {
      newDt = DateTime(newDt.year + years, newDt.month, newDt.day, newDt.hour, newDt.minute);
    }
    if (months != 0) {
      int newMonth = newDt.month + months;
      int newYear = newDt.year;
      while (newMonth > 12) {
        newMonth -= 12;
        newYear += 1;
      }
      while (newMonth < 1) {
        newMonth += 12;
        newYear -= 1;
      }
      newDt = DateTime(newYear, newMonth, math.min(newDt.day, 28), newDt.hour, newDt.minute);
    }
    if (days != 0) {
      newDt = newDt.add(Duration(days: days));
    }
    if (hours != 0) {
      newDt = newDt.add(Duration(hours: hours));
    }

    setState(() {
      _simulatedTransitDate = newDt;
      _simulatedTransitTime = TimeOfDay.fromDateTime(newDt);
      _calculateTransitChart();
    });
  }

  void _resetToNow() {
    final now = DateTime.now();
    setState(() {
      _simulatedTransitDate = now;
      _simulatedTransitTime = TimeOfDay.fromDateTime(now);
      _calculateTransitChart();
    });
  }

  String _formatTransitDateTime() {
    final d = _simulatedTransitDate;
    final t = _simulatedTransitTime;
    final hStr = t.hour.toString().padLeft(2, '0');
    final mStr = t.minute.toString().padLeft(2, '0');
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${d.day} ${months[d.month]} ${d.year} • $hStr:$mStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.blur_circular_rounded, color: AppColors.starlightGold, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _isSynastryMode ? 'SİNASTRİ ÇİFT ÇARKI' : 'İNTERAKTİF 360° ÇARK',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              _isSynastryMode
                  ? '${widget.natalProfile.name} & ${_synastryPartner?.fullName ?? "Partner"}'
                  : '${widget.natalProfile.name} (Natal & Transit)',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.zoom_in_rounded,
              color: AppColors.starlightGold,
            ),
            tooltip: '2 Parmakla Büyüt & İncele',
            onPressed: () {
              if (_natalChart != null && _transitChart != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ChartZoomScreen.biWheel(
                      title: _isSynastryMode
                          ? 'Sinastri & Çift Çark'
                          : 'Transit & Çift Çark',
                      natalChart: _natalChart,
                      outerChart: _transitChart,
                      isSynastry: _isSynastryMode,
                      displayMode: _displayMode,
                      useTrueNode: _useTrueNode,
                      enabledExtraBodies: _enabledAsteroids,
                      houseCusps: _natalPlacidusCusps,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              _isSynastryMode ? Icons.access_time_filled_rounded : Icons.people_alt_rounded,
              color: AppColors.starlightGold,
            ),
            tooltip: _isSynastryMode ? 'Transit Moduna Dön' : 'Sinastri Moduna Geç',
            onPressed: () {
              if (_isSynastryMode) {
                setState(() {
                  _isSynastryMode = false;
                  _calculateTransitChart();
                });
              } else {
                if (_availableSavedProfiles.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sinastri için arşivinizde en az 1 kayıtlı harita olmalıdır.'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                  return;
                }
                _showSynastryPicker();
              }
            },
          ),
        ],
      ),
      body: _isLoading || _natalChart == null || _transitChart == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.starlightGold),
            )
          : Column(
              children: [
                _buildModeSelector(),
                _buildTimeBanner(),
                _buildNodeAndAsteroidFilterBar(),

                // Bi-Wheel Canvas (Dokununca 2 Parmakla Büyütme Ekranına Geçer)
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_natalChart != null && _transitChart != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ChartZoomScreen.biWheel(
                                title: _isSynastryMode
                                    ? 'Sinastri & Çift Çark'
                                    : 'Transit & Çift Çark',
                                natalChart: _natalChart,
                                outerChart: _transitChart,
                                isSynastry: _isSynastryMode,
                                displayMode: _displayMode,
                                useTrueNode: _useTrueNode,
                                enabledExtraBodies: _enabledAsteroids,
                                houseCusps: _natalPlacidusCusps,
                              ),
                            ),
                          );
                        }
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final canvasSize = math.min(constraints.maxWidth - 12, constraints.maxHeight - 8).clamp(260.0, 430.0);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: canvasSize,
                                height: canvasSize,
                                child: CustomPaint(
                                  painter: BiWheelPainter(
                                    natalChart: _natalChart!,
                                    outerChart: _transitChart!,
                                    isSynastry: _isSynastryMode,
                                    selectedPlanet: _selectedPlanetKey,
                                    isTransitSelected: _isTransitPlanetSelected,
                                    rotationOffsetRad: 0.0,
                                    displayMode: _displayMode,
                                    useTrueNode: _useTrueNode,
                                    enabledExtraBodies: _enabledAsteroids,
                                    houseCusps: _natalPlacidusCusps,
                                    onAspectFound: (aspects) {},
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.pinch_rounded, size: 14, color: AppColors.starlightGold),
                                      SizedBox(width: 4),
                                      Text(
                                        '2 Parmakla Büyütmek İçin Dokunun',
                                        style: TextStyle(fontSize: 10, color: AppColors.starlightGold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                _buildPlanetAspectInspector(),
                if (!_isSynastryMode) _buildTimeStepperBar(),
              ],
            ),
    );
  }

  Widget _buildNodeAndAsteroidFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.starlightGold, size: 13),
              const SizedBox(width: 5),
              const Text(
                'Ay Düğümü:',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(width: 6),
              _buildNodeChip('True Node (Gerçek)', true),
              const SizedBox(width: 4),
              _buildNodeChip('Mean Node (Ortalama)', false),
            ],
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectableAsteroids.map((ast) {
                final key = ast['key']!;
                final isOn = _enabledAsteroids.contains(key);
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isOn) {
                          _enabledAsteroids.remove(key);
                        } else {
                          _enabledAsteroids.add(key);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOn ? AppColors.starlightGold.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isOn ? AppColors.starlightGold : Colors.white12,
                        ),
                      ),
                      child: Text(
                        '${ast['sym']} ${ast['name']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
                          color: isOn ? AppColors.starlightGold : Colors.white60,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeChip(String label, bool isTrue) {
    final selected = _useTrueNode == isTrue;
    return InkWell(
      onTap: () => setState(() => _useTrueNode = isTrue),
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppColors.pastelMint.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: selected ? AppColors.pastelMint : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColors.pastelMint : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildModeTab(BiWheelDisplayMode.dual, '🌓 İkili Çark'),
          _buildModeTab(BiWheelDisplayMode.transitOnly, '⚡ Sadece Transitler'),
          _buildModeTab(BiWheelDisplayMode.natalOnly, '🌟 Sadece Doğum'),
        ],
      ),
    );
  }

  Widget _buildModeTab(BiWheelDisplayMode mode, String label) {
    final isSelected = _displayMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _displayMode = mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.starlightGold : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isSynastryMode ? const Color(0xFFFF7675) : AppColors.pastelMint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _isSynastryMode ? 'Sinastri Haritası:' : 'Transit Zamanı:',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isSynastryMode ? (_synastryPartner?.fullName ?? '') : _formatTransitDateTime(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.starlightGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetAspectInspector() {
    final planets = [
      {'key': 'sun', 'name': 'Güneş'},
      {'key': 'moon', 'name': 'Ay'},
      {'key': 'mercury', 'name': 'Merkür'},
      {'key': 'venus', 'name': 'Venüs'},
      {'key': 'mars', 'name': 'Mars'},
      {'key': 'jupiter', 'name': 'Jüpiter'},
      {'key': 'saturn', 'name': 'Satürn'},
      {'key': 'uranus', 'name': 'Uranüs'},
      {'key': 'neptune', 'name': 'Neptün'},
      {'key': 'pluto', 'name': 'Plüton'},
      {'key': _useTrueNode ? 'true_north_node' : 'mean_north_node', 'name': 'KAD'},
      ...selectableAsteroids
          .where((a) => _enabledAsteroids.contains(a['key']))
          .map((a) => {'key': a['key']!, 'name': a['name']!}),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF13101E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AÇI IŞININI PARLAT (ORB: 0°/180°=10°, 120°=8°, 90°/60°=7°):',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: AppColors.starlightGold,
                ),
              ),
              if (_selectedPlanetKey != null)
                InkWell(
                  onTap: () => setState(() => _selectedPlanetKey = null),
                  child: const Text(
                    'Tüm Açılar',
                    style: TextStyle(fontSize: 10.5, color: Colors.white60, decoration: TextDecoration.underline),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: planets.map((p) {
                final isSel = _selectedPlanetKey == p['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AstrologicalGlyphWidget(
                          planetKeyOrName: p['key']!,
                          size: 12,
                          color: isSel ? Colors.black : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(p['name']!),
                      ],
                    ),
                    selected: isSel,
                    selectedColor: AppColors.starlightGold,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : Colors.white70,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedPlanetKey = val ? p['key'] : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStepperBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0C1B),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStepBtn(label: '-1 Ay', onTap: () => _stepTime(months: -1)),
            _buildStepBtn(label: '-1 G', onTap: () => _stepTime(days: -1)),
            _buildStepBtn(label: '-1 S', onTap: () => _stepTime(hours: -1)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.starlightGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: Size.zero,
              ),
              onPressed: _resetToNow,
              child: const Text('ŞİMDİ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            ),
            _buildStepBtn(label: '+1 S', onTap: () => _stepTime(hours: 1)),
            _buildStepBtn(label: '+1 G', onTap: () => _stepTime(days: 1)),
            _buildStepBtn(label: '+1 Ay', onTap: () => _stepTime(months: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBtn({required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _showSynastryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161224),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dış Çark İçin Partner Seçin (Sinastri)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ..._availableSavedProfiles.map((p) {
                return ListTile(
                  title: Text(p.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${p.birthCity} • ${p.sunSign}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: const Icon(Icons.favorite_rounded, color: Color(0xFFFF7675), size: 18),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _synastryPartner = p;
                      _isSynastryMode = true;
                      _calculateTransitChart();
                    });
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// GPU Destekli CustomPainter ile Solar Fire & Astro Gold Çift Çark Çizimi
class BiWheelPainter extends CustomPainter {
  final BirthChartModel natalChart;
  final BirthChartModel outerChart;
  final bool isSynastry;
  final String? selectedPlanet;
  final bool isTransitSelected;
  final double rotationOffsetRad;
  final BiWheelDisplayMode displayMode;
  final bool useTrueNode;
  final Set<String> enabledExtraBodies;
  final Map<int, double>? houseCusps;
  final Function(List<Map<String, dynamic>>) onAspectFound;

  BiWheelPainter({
    required this.natalChart,
    required this.outerChart,
    this.isSynastry = false,
    this.selectedPlanet,
    this.isTransitSelected = false,
    this.rotationOffsetRad = 0.0,
    this.displayMode = BiWheelDisplayMode.dual,
    this.useTrueNode = true,
    this.enabledExtraBodies = const {'chiron', 'lilith', 'vertex'},
    this.houseCusps,
    required this.onAspectFound,
  });

  static const List<String> zodiacSigns = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  static const List<String> zodiacSymbols = [
    '♈\uFE0E', '♉\uFE0E', '♊\uFE0E', '♋\uFE0E', '♌\uFE0E', '♍\uFE0E',
    '♎\uFE0E', '♏\uFE0E', '♐\uFE0E', '♑\uFE0E', '♒\uFE0E', '♓\uFE0E'
  ];

  static const List<Color> elementColors = [
    Color(0xFFFF5252), // Koç - Ateş
    Color(0xFF81C784), // Boğa - Toprak
    Color(0xFF64B5F6), // İkizler - Hava
    Color(0xFF4DD0E1), // Yengeç - Su
    Color(0xFFFF5252), // Aslan - Ateş
    Color(0xFF81C784), // Başak - Toprak
    Color(0xFF64B5F6), // Terazi - Hava
    Color(0xFF4DD0E1), // Akrep - Su
    Color(0xFFFF5252), // Yay - Ateş
    Color(0xFF81C784), // Oğlak - Toprak
    Color(0xFF64B5F6), // Kova - Hava
    Color(0xFF4DD0E1), // Balık - Su
  ];

  static const Set<String> coreTenPlanets = {
    'sun', 'moon', 'mercury', 'venus', 'mars',
    'jupiter', 'saturn', 'uranus', 'neptune', 'pluto',
  };

  double _norm(double deg) {
    final d = deg % 360.0;
    return d < 0 ? d + 360.0 : d;
  }

  Offset _getPoint(Offset center, double r, double wheelDeg) {
    final rad = (wheelDeg * math.pi / 180.0) + rotationOffsetRad;
    return Offset(
      center.dx - r * math.cos(rad),
      center.dy + r * math.sin(rad),
    );
  }

  double _getSignStartAbsolute(String sign) {
    final idx = zodiacSigns.indexOf(sign);
    return idx >= 0 ? idx * 30.0 : 0.0;
  }

  double _parseDegreeFromFormatted(String formatted) {
    final m = RegExp(r"(\d+)°(?:(\d+)')?").firstMatch(formatted);
    if (m != null) {
      final d = double.tryParse(m.group(1) ?? '0') ?? 0.0;
      final min = double.tryParse(m.group(2) ?? '0') ?? 0.0;
      return d + min / 60.0;
    }
    return 15.0;
  }

  Map<int, double> _resolveHouseCusps(double totalAscDeg, double totalMcDeg) {
    if (houseCusps != null && houseCusps!.length == 12 && displayMode != BiWheelDisplayMode.transitOnly) {
      return houseCusps!;
    }
    final c1 = _norm(totalAscDeg);
    final c10 = _norm(totalMcDeg);
    final c7 = _norm(c1 + 180.0);
    final c4 = _norm(c10 + 180.0);

    final span10to1 = _norm(c1 - c10);
    final c11 = _norm(c10 + span10to1 / 3.0);
    final c12 = _norm(c10 + (span10to1 * 2.0) / 3.0);

    final span1to4 = _norm(c4 - c1);
    final c2 = _norm(c1 + span1to4 / 3.0);
    final c3 = _norm(c1 + (span1to4 * 2.0) / 3.0);

    return {
      1: c1,
      2: c2,
      3: c3,
      4: c4,
      5: _norm(c11 + 180.0),
      6: _norm(c12 + 180.0),
      7: c7,
      8: _norm(c2 + 180.0),
      9: _norm(c3 + 180.0),
      10: c10,
      11: c11,
      12: c12,
    };
  }

  String _formatCuspCompact(double absLon) {
    final norm = _norm(absLon);
    final sIdx = (norm / 30.0).floor() % 12;
    final degInSign = norm % 30.0;
    int d = degInSign.floor();
    int m = ((degInSign - d) * 60).round();
    if (m >= 60) {
      m = 0;
      d = (d + 1) % 30;
    }
    return '${d.toString().padLeft(2, '0')}°${zodiacSymbols[sIdx]}${m.toString().padLeft(2, '0')}\'';
  }

  List<String> _activePlanetKeys() {
    final keys = <String>[
      ...coreTenPlanets,
      useTrueNode ? 'true_north_node' : 'mean_north_node',
      useTrueNode ? 'true_south_node' : 'mean_south_node',
      ...enabledExtraBodies,
    ];
    return keys;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;

    // Outer margin for 12 house cusp degree+sign labels (Astro Gold / Image 2 style)
    final rCuspLabels = maxR - 9;
    final rZodiacOuter = maxR - 21;
    final rZodiacInner = rZodiacOuter * 0.86;

    // Transit / Outer Wheel Ring
    final rTransitOuter = rZodiacInner;
    final rTransitInner = rZodiacOuter * 0.67;

    // Natal / Inner Wheel Ring
    final rNatalOuter = rTransitInner;
    final rNatalInner = rZodiacOuter * 0.46;

    // Inner House Number Ring & Central Aspect Disc
    final rHouseNumInner = rZodiacOuter * 0.38;
    final rAspectCenter = rHouseNumInner;

    final showNatal = (displayMode == BiWheelDisplayMode.dual || displayMode == BiWheelDisplayMode.natalOnly);
    final showTransit = (displayMode == BiWheelDisplayMode.dual || displayMode == BiWheelDisplayMode.transitOnly);

    // Background radial cosmic disc
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF18132B), Color(0xFF0A0814)],
      ).createShader(Rect.fromCircle(center: center, radius: rZodiacOuter));
    canvas.drawCircle(center, rZodiacOuter, bgPaint);

    // Zodiac outer band subtle fill
    canvas.drawCircle(
      center,
      (rZodiacOuter + rZodiacInner) / 2,
      Paint()
        ..color = const Color(0xFF211B38).withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rZodiacOuter - rZodiacInner,
    );

    final boundaryPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, rZodiacOuter, boundaryPaint..color = AppColors.starlightGold.withValues(alpha: 0.45));
    canvas.drawCircle(center, rZodiacInner, boundaryPaint..color = Colors.white30);
    if (displayMode == BiWheelDisplayMode.dual) {
      canvas.drawCircle(center, rTransitInner, boundaryPaint..color = Colors.cyan.withValues(alpha: 0.28));
    }
    canvas.drawCircle(center, rNatalInner, boundaryPaint..color = Colors.white24);
    canvas.drawCircle(center, rAspectCenter, boundaryPaint..color = Colors.white30);

    // Base chart for ASC/MC & Houses
    final baseChart = (displayMode == BiWheelDisplayMode.transitOnly) ? outerChart : natalChart;
    final ascSignIdx = zodiacSigns.indexOf(baseChart.risingSign);
    final ascDegVal = _parseDegreeFromFormatted(baseChart.risingFormatted);
    final totalAscDeg = (ascSignIdx >= 0 ? ascSignIdx * 30.0 : 0.0) + ascDegVal;

    double totalMcDeg = _norm(totalAscDeg + 270.0);
    final mcPlanet = baseChart.planets['mc'];
    if (mcPlanet != null) {
      totalMcDeg = mcPlanet.longitude ?? (_getSignStartAbsolute(mcPlanet.sign) + _parseDegreeFromFormatted(mcPlanet.formatted));
    }

    // 1. ZODIAC SIGNS & DEGREE TICKS (OUTER RING)
    final tickPaint = Paint()..strokeWidth = 0.8;
    for (int deg = 0; deg < 360; deg += 2) {
      final wDeg = _norm(deg - totalAscDeg);
      final isTen = deg % 10 == 0;
      final isFive = deg % 5 == 0;
      final tickLen = isTen ? 4.5 : (isFive ? 3.0 : 1.5);
      canvas.drawLine(
        _getPoint(center, rZodiacInner, wDeg),
        _getPoint(center, rZodiacInner + tickLen, wDeg),
        tickPaint..color = isTen ? Colors.white54 : Colors.white24,
      );
    }

    for (int i = 0; i < 12; i++) {
      final signStartAbsolute = i * 30.0;
      final signStartWheelDeg = _norm(signStartAbsolute - totalAscDeg);

      final p1 = _getPoint(center, rZodiacInner, signStartWheelDeg);
      final p2 = _getPoint(center, rZodiacOuter, signStartWheelDeg);
      canvas.drawLine(p1, p2, Paint()..color = Colors.white38..strokeWidth = 1.2);

      final midDeg = _norm(signStartWheelDeg + 15.0);
      final symR = (rZodiacOuter + rZodiacInner) / 2;
      final symPos = _getPoint(center, symR, midDeg);

      final painter = TextPainter(
        text: TextSpan(
          text: zodiacSymbols[i],
          style: TextStyle(
            color: elementColors[i],
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(symPos.dx - painter.width / 2, symPos.dy - painter.height / 2));
    }

    // 2. DRAW 12 PROMINENT HOUSE CUSPS, OUTER CUSP DEGREES & INNER HOUSE NUMBERS
    final cusps = _resolveHouseCusps(totalAscDeg, totalMcDeg);
    for (int h = 1; h <= 12; h++) {
      final cuspLon = cusps[h]!;
      final nextCuspLon = cusps[h == 12 ? 1 : h + 1]!;
      final wDeg = _norm(cuspLon - totalAscDeg);
      final nextWDeg = _norm(nextCuspLon - totalAscDeg);

      final isAngle = (h == 1 || h == 4 || h == 7 || h == 10);
      final Color lineColor = h == 1
          ? AppColors.starlightGold
          : h == 10
              ? AppColors.pastelMint
              : h == 7
                  ? AppColors.pastelLavender
                  : h == 4
                      ? AppColors.pastelBlue
                      : Colors.white30;

      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = isAngle ? 2.1 : 1.0;

      // Prominent house cusp line extending across the wheel
      canvas.drawLine(
        _getPoint(center, rAspectCenter, wDeg),
        _getPoint(center, isAngle ? rZodiacOuter + 2 : rZodiacInner, wDeg),
        linePaint,
      );

      // Outer House Cusp Degree + Sign Label (e.g. "04°♑17'")
      final cuspPos = _getPoint(center, rCuspLabels, wDeg);
      final cuspText = _formatCuspCompact(cuspLon);
      final cuspPainter = TextPainter(
        text: TextSpan(
          text: cuspText,
          style: TextStyle(
            color: isAngle ? lineColor : Colors.white70,
            fontSize: isAngle ? 7.4 : 6.5,
            fontWeight: isAngle ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      cuspPainter.paint(canvas, Offset(cuspPos.dx - cuspPainter.width / 2, cuspPos.dy - cuspPainter.height / 2));

      // Inner House Number (1..12)
      double span = _norm(nextWDeg - wDeg);
      if (span == 0) span = 30.0;
      final midHouseWDeg = _norm(wDeg + span / 2.0);
      final hNumR = (rNatalInner + rHouseNumInner) / 2;
      final hNumPos = _getPoint(center, hNumR, midHouseWDeg);

      final hPainter = TextPainter(
        text: TextSpan(
          text: '$h',
          style: TextStyle(
            color: isAngle ? AppColors.starlightGold : Colors.white70,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      hPainter.paint(canvas, Offset(hNumPos.dx - hPainter.width / 2, hNumPos.dy - hPainter.height / 2));
    }

    // Positions cache for aspect lines
    final Map<String, Offset> natalPositions = {};
    final Map<String, double> natalDegrees = {};
    final Map<String, Offset> outerPositions = {};
    final Map<String, double> outerDegrees = {};

    final activeKeys = _activePlanetKeys();

    // Helper to draw a ring of planets with anti-collision & degree+sign labels
    void drawRingPlanets({
      required BirthChartModel chart,
      required double glyphR,
      required double degLabelR,
      required double tickBaseR,
      required Color defaultColor,
      required Map<String, Offset> outPos,
      required Map<String, double> outDeg,
    }) {
      final items = <_BiWheelBody>[];
      for (final key in activeKeys) {
        PlanetPosition? p = chart.planets[key];
        // Fallback if true/mean node key wasn't populated on older cached chart
        if (p == null && (key == 'true_north_node' || key == 'mean_north_node')) {
          p = chart.planets['north_node'];
        } else if (p == null && (key == 'true_south_node' || key == 'mean_south_node')) {
          p = chart.planets['south_node'];
        }
        if (p == null) continue;

        final degInSign = _parseDegreeFromFormatted(p.formatted);
        final absDeg = p.longitude ?? (_getSignStartAbsolute(p.sign) + degInSign);
        final wDeg = _norm(absDeg - totalAscDeg);
        final sIdx = zodiacSigns.indexOf(p.sign).clamp(0, 11);

        items.add(_BiWheelBody(
          key: key,
          signIdx: sIdx,
          degInSign: degInSign,
          absDeg: absDeg,
          trueWheelDeg: wDeg,
          displayWheelDeg: wDeg,
          isRetro: p.isRetrograde,
        ));
      }

      if (items.isEmpty) return;

      // Anti-collision spreading
      items.sort((a, b) => a.trueWheelDeg.compareTo(b.trueWheelDeg));
      const double minSep = 7.0;
      for (int pass = 0; pass < 4; pass++) {
        for (int i = 0; i < items.length; i++) {
          final next = (i + 1) % items.length;
          double diff = items[next].displayWheelDeg - items[i].displayWheelDeg;
          if (next == 0) diff += 360.0;
          if (diff < minSep && diff >= 0) {
            final push = (minSep - diff) / 2.0;
            items[i].displayWheelDeg = _norm(items[i].displayWheelDeg - push);
            items[next].displayWheelDeg = _norm(items[next].displayWheelDeg + push);
          }
        }
      }

      for (final item in items) {
        final pos = _getPoint(center, glyphR, item.displayWheelDeg);
        final aspectAnchor = _getPoint(center, rAspectCenter, item.trueWheelDeg);
        outPos[item.key] = aspectAnchor;
        outDeg[item.key] = item.absDeg;

        final isHighlight = (selectedPlanet == item.key);
        final color = isHighlight ? AppColors.starlightGold : defaultColor;

        // Tick line to true zodiac longitude
        canvas.drawLine(
          _getPoint(center, tickBaseR, item.trueWheelDeg),
          pos,
          Paint()
            ..color = color.withValues(alpha: 0.45)
            ..strokeWidth = 0.8,
        );

        if (isHighlight) {
          final glowPaint = Paint()
            ..color = color.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(pos, 11, glowPaint);
        }

        // Small dark disc under glyph for crisp readability over house lines
        canvas.drawCircle(
          pos,
          8.0,
          Paint()..color = const Color(0xFF120E20).withValues(alpha: 0.88),
        );

        AstrologicalGlyphPainter.drawPlanet(
          canvas,
          planetKeyOrName: item.key,
          center: pos,
          size: 12.0,
          color: color,
          strokeWidth: 1.5,
        );

        // Degree & Sign label next to planet inside wheel ("11°♓")
        final degInt = item.degInSign.floor().clamp(0, 29);
        final degPos = _getPoint(center, degLabelR, item.displayWheelDeg);
        final degStr = '${degInt.toString().padLeft(2, '0')}°${zodiacSymbols[item.signIdx]}';
        final degPainter = TextPainter(
          text: TextSpan(
            text: degStr,
            style: TextStyle(
              color: color.withValues(alpha: 0.92),
              fontSize: 6.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        degPainter.paint(canvas, Offset(degPos.dx - degPainter.width / 2, degPos.dy - degPainter.height / 2));
      }
    }

    // 3. INNER / SINGLE WHEEL: NATAL PLANETS
    if (showNatal) {
      final isSingle = displayMode == BiWheelDisplayMode.natalOnly;
      drawRingPlanets(
        chart: natalChart,
        glyphR: isSingle ? (rZodiacInner - 18) : (rNatalOuter - 12),
        degLabelR: isSingle ? (rZodiacInner - 34) : (rNatalInner + 9),
        tickBaseR: isSingle ? rZodiacInner : rNatalOuter,
        defaultColor: const Color(0xFFFFEAA7),
        outPos: natalPositions,
        outDeg: natalDegrees,
      );
    }

    // 4. OUTER / SINGLE WHEEL: TRANSIT / SYNASTRY PLANETS
    if (showTransit) {
      final isSingle = displayMode == BiWheelDisplayMode.transitOnly;
      drawRingPlanets(
        chart: outerChart,
        glyphR: isSingle ? (rZodiacInner - 18) : (rTransitOuter - 12),
        degLabelR: isSingle ? (rZodiacInner - 34) : (rTransitInner + 9),
        tickBaseR: rZodiacInner,
        defaultColor: isSynastry ? const Color(0xFFFF7675) : const Color(0xFF00CEC9),
        outPos: outerPositions,
        outDeg: outerDegrees,
      );
    }

    // 5. CENTRAL ASPECT RAYS (Evrensel Orb Kuralı: 0°=10°, 180°=10°, 120°=8°, 90°=7°, 60°=7°)
    void drawAspectBetween(String k1, double deg1, Offset p1, String k2, double deg2, Offset p2) {
      if (selectedPlanet != null && selectedPlanet != k1 && selectedPlanet != k2) {
        return;
      }

      double diff = (deg1 - deg2).abs() % 360.0;
      if (diff > 180.0) diff = 360.0 - diff;

      Color? aspectColor;
      String? aspectSym;
      double strokeW = 0.9;

      if (diff <= 10.0) {
        // Kavuşum (0° - 10° Orb)
        aspectColor = const Color(0xFFFFD700);
        aspectSym = '☌';
        strokeW = 1.4;
      } else if ((diff - 180.0).abs() <= 10.0) {
        // Karşıt (180° - 10° Orb)
        aspectColor = const Color(0xFFFF5252);
        aspectSym = '☍';
        strokeW = 1.35;
      } else if ((diff - 120.0).abs() <= 8.0) {
        // Üçgen (120° - 8° Orb)
        aspectColor = const Color(0xFF55EFC4);
        aspectSym = '△';
        strokeW = 1.25;
      } else if ((diff - 90.0).abs() <= 7.0) {
        // Kare (90° - 7° Orb)
        aspectColor = const Color(0xFFFF9F43);
        aspectSym = '□';
        strokeW = 1.25;
      } else if ((diff - 60.0).abs() <= 7.0) {
        // Sekstil (60° - 7° Orb)
        aspectColor = const Color(0xFF74B9FF);
        aspectSym = '✶';
        strokeW = 1.05;
      }

      if (aspectColor != null) {
        final isFocused = (selectedPlanet == k1 || selectedPlanet == k2);
        final linePaint = Paint()
          ..color = isFocused ? aspectColor : aspectColor.withValues(alpha: 0.50)
          ..strokeWidth = isFocused ? (strokeW + 0.9) : strokeW;

        if (isFocused) {
          final glowRay = Paint()
            ..color = aspectColor.withValues(alpha: 0.55)
            ..strokeWidth = strokeW + 2.5
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawLine(p1, p2, glowRay);
        }

        canvas.drawLine(p1, p2, linePaint);

        if (aspectSym != null && (p1 - p2).distance > 20) {
          final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
          final symPainter = TextPainter(
            text: TextSpan(
              text: aspectSym,
              style: TextStyle(
                color: aspectColor.withValues(alpha: 0.95),
                fontSize: 7.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          symPainter.paint(canvas, Offset(mid.dx - symPainter.width / 2, mid.dy - symPainter.height / 2));
        }
      }
    }

    if (displayMode == BiWheelDisplayMode.dual) {
      outerDegrees.forEach((oKey, oDeg) {
        natalDegrees.forEach((nKey, nDeg) {
          final p1 = natalPositions[nKey];
          final p2 = outerPositions[oKey];
          if (p1 != null && p2 != null) {
            drawAspectBetween(oKey, oDeg, p2, nKey, nDeg, p1);
          }
        });
      });
    } else if (displayMode == BiWheelDisplayMode.transitOnly) {
      final oKeys = outerDegrees.keys.toList();
      for (int i = 0; i < oKeys.length; i++) {
        for (int j = i + 1; j < oKeys.length; j++) {
          final k1 = oKeys[i];
          final k2 = oKeys[j];
          final p1 = outerPositions[k1];
          final p2 = outerPositions[k2];
          if (p1 != null && p2 != null) {
            drawAspectBetween(k1, outerDegrees[k1]!, p1, k2, outerDegrees[k2]!, p2);
          }
        }
      }
    } else if (displayMode == BiWheelDisplayMode.natalOnly) {
      final nKeys = natalDegrees.keys.toList();
      for (int i = 0; i < nKeys.length; i++) {
        for (int j = i + 1; j < nKeys.length; j++) {
          final k1 = nKeys[i];
          final k2 = nKeys[j];
          final p1 = natalPositions[k1];
          final p2 = natalPositions[k2];
          if (p1 != null && p2 != null) {
            drawAspectBetween(k1, natalDegrees[k1]!, p1, k2, natalDegrees[k2]!, p2);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BiWheelPainter oldDelegate) {
    return oldDelegate.natalChart != natalChart ||
        oldDelegate.outerChart != outerChart ||
        oldDelegate.selectedPlanet != selectedPlanet ||
        oldDelegate.rotationOffsetRad != rotationOffsetRad ||
        oldDelegate.displayMode != displayMode ||
        oldDelegate.useTrueNode != useTrueNode ||
        oldDelegate.enabledExtraBodies != enabledExtraBodies ||
        oldDelegate.isSynastry != isSynastry;
  }
}

class _BiWheelBody {
  final String key;
  final int signIdx;
  final double degInSign;
  final double absDeg;
  final double trueWheelDeg;
  double displayWheelDeg;
  final bool isRetro;

  _BiWheelBody({
    required this.key,
    required this.signIdx,
    required this.degInSign,
    required this.absDeg,
    required this.trueWheelDeg,
    required this.displayWheelDeg,
    required this.isRetro,
  });
}
