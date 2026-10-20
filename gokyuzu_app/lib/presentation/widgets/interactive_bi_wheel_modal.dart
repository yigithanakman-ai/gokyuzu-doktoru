import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/saved_profile_model.dart';
import '../../data/services/profile_archive_service.dart';

/// Gökyüzü Doktoru — İnteraktif Çift Çark (Interactive Bi-Wheel) & Zaman Makinesi
/// Solar Fire ve Astro Gold düzeyinde:
/// - İç Çark: Doğum (Natal) Haritası
/// - Dış Çark: Anlık veya Gelecek/Geçmiş Transitler (Zaman Makinesiyle ileri/geri sarma)
/// - Merkez: Tıklanan gezegenin açı ışınlarını parlatan GPU Vektörel Açı Motoru
class InteractiveBiWheelModal extends StatefulWidget {
  final UserProfile natalProfile;

  const InteractiveBiWheelModal({super.key, required this.natalProfile});

  @override
  State<InteractiveBiWheelModal> createState() => _InteractiveBiWheelModalState();
}

class _InteractiveBiWheelModalState extends State<InteractiveBiWheelModal> {
  late DateTime _simulatedTransitDate;
  late TimeOfDay _simulatedTransitTime;

  BirthChartModel? _natalChart;
  BirthChartModel? _transitChart;
  bool _isLoading = true;

  // Selected planet for aspect ray highlighting
  String? _selectedPlanetKey;
  final bool _isTransitPlanetSelected = false;

  // Secondary profile for Synastry mode (optional)
  SavedProfile? _synastryPartner;
  bool _isSynastryMode = false;
  List<SavedProfile> _availableSavedProfiles = [];

  // Wheel rotation angle in radians for gesture rotation
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _simulatedTransitDate = now;
    _simulatedTransitTime = TimeOfDay.fromDateTime(now);
    _loadInitialCharts();
  }

  Future<void> _loadInitialCharts() async {
    setState(() => _isLoading = true);

    // Parse natal birth date & time
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
    if (_isSynastryMode) return; // Time stepper is for transit mode

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
                const Icon(Icons.blur_circular_rounded, color: AppColors.starlightGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  _isSynastryMode ? 'SİNASTRİ ÇİFT ÇARKI' : 'İNTERAKTİF ÇİFT ÇARK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              _isSynastryMode
                  ? '${widget.natalProfile.name} & ${_synastryPartner?.fullName ?? "Partner"}'
                  : '${widget.natalProfile.name} (Natal & Transit)',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
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
                // Mode & Time Status Banner
                _buildTimeBanner(),

                // Bi-Wheel Interactive Canvas
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _rotationAngle += details.delta.dx * 0.005;
                        });
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final canvasSize = math.min(constraints.maxWidth - 20, constraints.maxHeight - 20).clamp(280.0, 420.0);
                          return SizedBox(
                            width: canvasSize,
                            height: canvasSize,
                            child: CustomPaint(
                              painter: BiWheelPainter(
                                natalChart: _natalChart!,
                                outerChart: _transitChart!,
                                isSynastry: _isSynastryMode,
                                selectedPlanet: _selectedPlanetKey,
                                isTransitSelected: _isTransitPlanetSelected,
                                rotationOffsetRad: _rotationAngle,
                                onAspectFound: (aspects) {},
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Selected Planet Aspect Summary / Legend
                _buildPlanetAspectInspector(),

                // Solar Fire Stepper Controls (Transit mode only)
                if (!_isSynastryMode) _buildTimeStepperBar(),
              ],
            ),
    );
  }

  Widget _buildTimeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isSynastryMode ? const Color(0xFFFF7675) : AppColors.pastelMint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isSynastryMode ? 'Sinastri İlişki Haritası' : 'Simüle Transit Zamanı:',
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ],
          ),
          Text(
            _isSynastryMode ? (_synastryPartner?.fullName ?? '') : _formatTransitDateTime(),
            style: const TextStyle(
              fontSize: 12,
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
      {'key': 'sun', 'name': 'Güneş', 'sym': '☉'},
      {'key': 'moon', 'name': 'Ay', 'sym': '☽'},
      {'key': 'mercury', 'name': 'Merkür', 'sym': '☿'},
      {'key': 'venus', 'name': 'Venüs', 'sym': '♀\uFE0E'},
      {'key': 'mars', 'name': 'Mars', 'sym': '♂\uFE0E'},
      {'key': 'jupiter', 'name': 'Jüpiter', 'sym': '♃'},
      {'key': 'saturn', 'name': 'Satürn', 'sym': '♄'},
      {'key': 'uranus', 'name': 'Uranüs', 'sym': '♅'},
      {'key': 'neptune', 'name': 'Neptün', 'sym': '♆'},
      {'key': 'pluto', 'name': 'Plüton', 'sym': '♇'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                'AÇI IŞININI PARLAT:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.starlightGold,
                ),
              ),
              if (_selectedPlanetKey != null)
                InkWell(
                  onTap: () => setState(() => _selectedPlanetKey = null),
                  child: const Text(
                    'Tüm Açıları Göster',
                    style: TextStyle(fontSize: 11, color: Colors.white60, decoration: TextDecoration.underline),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: planets.map((p) {
                final isSel = _selectedPlanetKey == p['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${p['sym']} ${p['name']}'),
                    selected: isSel,
                    selectedColor: AppColors.starlightGold,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : Colors.white70,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

/// GPU Destekli CustomPainter ile Solar Fire Çift Çark Çizimi
class BiWheelPainter extends CustomPainter {
  final BirthChartModel natalChart;
  final BirthChartModel outerChart;
  final bool isSynastry;
  final String? selectedPlanet;
  final bool isTransitSelected;
  final double rotationOffsetRad;
  final Function(List<Map<String, dynamic>>) onAspectFound;

  BiWheelPainter({
    required this.natalChart,
    required this.outerChart,
    this.isSynastry = false,
    this.selectedPlanet,
    this.isTransitSelected = false,
    this.rotationOffsetRad = 0.0,
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

  static const Map<String, String> planetSymbols = {
    'sun': '☉',
    'moon': '☽',
    'mercury': '☿',
    'venus': '♀\uFE0E',
    'mars': '♂\uFE0E',
    'jupiter': '♃',
    'saturn': '♄',
    'uranus': '♅',
    'neptune': '♆',
    'pluto': '♇',
  };

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
    try {
      final degPart = formatted.split('°').first.trim();
      return double.tryParse(degPart) ?? 15.0;
    } catch (_) {
      return 15.0;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Rings hierarchy:
    // Outer: Zodiac Signs Ring
    final rZodiacOuter = radius;
    final rZodiacInner = radius * 0.88;

    // Transit Planets Ring (Outer Wheel)
    final rTransitOuter = rZodiacInner;
    final rTransitInner = radius * 0.72;

    // Divider Ring
    // Natal Planets Ring (Inner Wheel)
    final rNatalOuter = rTransitInner;
    final rNatalInner = radius * 0.52;

    // Aspect Center Disc
    final rAspectCenter = radius * 0.38;

    final boundaryPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Background fill
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF141024), Color(0xFF090710)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Draw boundary circles
    canvas.drawCircle(center, rZodiacOuter, boundaryPaint);
    canvas.drawCircle(center, rZodiacInner, boundaryPaint);
    canvas.drawCircle(center, rTransitInner, boundaryPaint..color = Colors.cyan.withValues(alpha: 0.25));
    canvas.drawCircle(center, rNatalInner, boundaryPaint..color = AppColors.starlightGold.withValues(alpha: 0.25));
    canvas.drawCircle(center, rAspectCenter, boundaryPaint..color = Colors.white12);

    // ASC degree offset
    final ascSignIdx = zodiacSigns.indexOf(natalChart.risingSign);
    final ascDegVal = _parseDegreeFromFormatted(natalChart.risingFormatted);
    final totalAscDeg = (ascSignIdx >= 0 ? ascSignIdx * 30.0 : 0.0) + ascDegVal;

    // 1. ZODIAC SIGNS (OUTER RING)
    for (int i = 0; i < 12; i++) {
      final signStartAbsolute = i * 30.0;
      double signStartWheelDeg = (signStartAbsolute - totalAscDeg) % 360.0;
      if (signStartWheelDeg < 0) signStartWheelDeg += 360.0;

      // Dividers
      final p1 = _getPoint(center, rZodiacInner, signStartWheelDeg);
      final p2 = _getPoint(center, rZodiacOuter, signStartWheelDeg);
      canvas.drawLine(p1, p2, boundaryPaint);

      // Zodiac Glyph
      final midDeg = (signStartWheelDeg + 15.0) % 360.0;
      final symR = (rZodiacOuter + rZodiacInner) / 2;
      final symPos = _getPoint(center, symR, midDeg);

      final painter = TextPainter(
        text: TextSpan(
          text: zodiacSymbols[i],
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(symPos.dx - painter.width / 2, symPos.dy - painter.height / 2));
    }

    // Positions cache for aspect lines
    final Map<String, Offset> natalPositions = {};
    final Map<String, double> natalDegrees = {};
    final Map<String, Offset> outerPositions = {};
    final Map<String, double> outerDegrees = {};

    // 2. INNER WHEEL: NATAL PLANETS
    natalChart.planets.forEach((key, p) {
      if (!planetSymbols.containsKey(key)) return;
      final absDeg = _getSignStartAbsolute(p.sign) + _parseDegreeFromFormatted(p.formatted);
      double wheelDeg = (absDeg - totalAscDeg) % 360.0;
      if (wheelDeg < 0) wheelDeg += 360.0;

      final pR = (rNatalOuter + rNatalInner) / 2;
      final pos = _getPoint(center, pR, wheelDeg);
      natalPositions[key] = pos;
      natalDegrees[key] = absDeg;

      final isHighlight = (selectedPlanet == key);

      // Glow behind selected planet
      if (isHighlight) {
        final glowPaint = Paint()
          ..color = AppColors.starlightGold.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, 12, glowPaint);
      }

      final symPainter = TextPainter(
        text: TextSpan(
          text: planetSymbols[key] ?? '•',
          style: TextStyle(
            color: isHighlight ? AppColors.starlightGold : const Color(0xFFFFEAA7),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      symPainter.paint(canvas, Offset(pos.dx - symPainter.width / 2, pos.dy - symPainter.height / 2));
    });

    // 3. OUTER WHEEL: TRANSIT / SYNASTRY PLANETS
    outerChart.planets.forEach((key, p) {
      if (!planetSymbols.containsKey(key)) return;
      final absDeg = _getSignStartAbsolute(p.sign) + _parseDegreeFromFormatted(p.formatted);
      double wheelDeg = (absDeg - totalAscDeg) % 360.0;
      if (wheelDeg < 0) wheelDeg += 360.0;

      final pR = (rTransitOuter + rTransitInner) / 2;
      final pos = _getPoint(center, pR, wheelDeg);
      outerPositions[key] = pos;
      outerDegrees[key] = absDeg;

      final isHighlight = (selectedPlanet == key);

      if (isHighlight) {
        final glowPaint = Paint()
          ..color = (isSynastry ? const Color(0xFFFF7675) : Colors.cyan).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, 12, glowPaint);
      }

      final symPainter = TextPainter(
        text: TextSpan(
          text: planetSymbols[key] ?? '•',
          style: TextStyle(
            color: isSynastry ? const Color(0xFFFF7675) : const Color(0xFF00CEC9),
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      symPainter.paint(canvas, Offset(pos.dx - symPainter.width / 2, pos.dy - symPainter.height / 2));
    });

    // 4. CENTRAL ASPECT RAYS (NATAL <-> TRANSIT OR NATAL <-> NATAL)
    // Draw Ptolemaic aspects:
    // Conjunction: 0° (orb 5°)
    // Sextile: 60° (orb 4°)
    // Square: 90° (orb 5°)
    // Trine: 120° (orb 5°)
    // Opposition: 180° (orb 5°)
    outerDegrees.forEach((oKey, oDeg) {
      natalDegrees.forEach((nKey, nDeg) {
        // If a planet is selected, only draw aspects connecting to that planet
        if (selectedPlanet != null && selectedPlanet != oKey && selectedPlanet != nKey) {
          return;
        }

        double diff = (oDeg - nDeg).abs() % 360.0;
        if (diff > 180.0) diff = 360.0 - diff;

        Color? aspectColor;
        double strokeW = 0.8;

        if (diff <= 5.0) {
          // Conjunction
          aspectColor = const Color(0xFFFFD700);
          strokeW = 1.6;
        } else if ((diff - 60.0).abs() <= 4.0) {
          // Sextile
          aspectColor = const Color(0xFF74B9FF);
        } else if ((diff - 90.0).abs() <= 5.0) {
          // Square
          aspectColor = const Color(0xFFFF5252);
          strokeW = 1.4;
        } else if ((diff - 120.0).abs() <= 5.0) {
          // Trine
          aspectColor = const Color(0xFF55EFC4);
          strokeW = 1.4;
        } else if ((diff - 180.0).abs() <= 5.0) {
          // Opposition
          aspectColor = const Color(0xFFA29BFE);
          strokeW = 1.6;
        }

        if (aspectColor != null) {
          final p1 = natalPositions[nKey];
          final p2 = outerPositions[oKey];
          if (p1 != null && p2 != null) {
            final isFocused = (selectedPlanet == oKey || selectedPlanet == nKey);
            final linePaint = Paint()
              ..color = isFocused ? aspectColor : aspectColor.withValues(alpha: 0.35)
              ..strokeWidth = isFocused ? (strokeW + 1.0) : strokeW;

            if (isFocused) {
              final glowRay = Paint()
                ..color = aspectColor.withValues(alpha: 0.6)
                ..strokeWidth = strokeW + 3.0
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
              canvas.drawLine(p1, p2, glowRay);
            }

            canvas.drawLine(p1, p2, linePaint);
          }
        }
      });
    });

    // ASC/DSC Aksı Çizgisi
    final ascP1 = _getPoint(center, rZodiacOuter, 0.0);
    final ascP2 = _getPoint(center, rAspectCenter, 0.0);
    final dscP1 = _getPoint(center, rZodiacOuter, 180.0);
    final dscP2 = _getPoint(center, rAspectCenter, 180.0);
    final ascPaint = Paint()
      ..color = AppColors.starlightGold.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(ascP1, ascP2, ascPaint);
    canvas.drawLine(dscP1, dscP2, ascPaint..color = Colors.white24);
  }

  @override
  bool shouldRepaint(covariant BiWheelPainter oldDelegate) {
    return oldDelegate.natalChart != natalChart ||
        oldDelegate.outerChart != outerChart ||
        oldDelegate.selectedPlanet != selectedPlanet ||
        oldDelegate.rotationOffsetRad != rotationOffsetRad ||
        oldDelegate.isSynastry != isSynastry;
  }
}
