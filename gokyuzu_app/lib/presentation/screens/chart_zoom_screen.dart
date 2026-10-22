import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/birth_chart_model.dart';
import '../widgets/chart_wheel_painter.dart';
import '../widgets/interactive_bi_wheel_modal.dart';

/// 2 Parmakla Büyütme & Serbest Gezinme (Pinch-to-Zoom) Harita Ekranı
class ChartZoomScreen extends StatefulWidget {
  final String title;
  final bool isBiWheel;
  // Tekli harita parametreleri
  final Map<String, dynamic>? singleWheelPlanets;
  final String ascendantSign;
  final double ascDegree;
  final String? mcSign;
  final double? mcDegree;
  final Map<int, double>? houseCusps;
  // Çift çark parametreleri
  final BirthChartModel? natalChart;
  final BirthChartModel? outerChart;
  final bool isSynastry;
  final BiWheelDisplayMode displayMode;
  final bool useTrueNode;
  final Set<String> enabledExtraBodies;

  const ChartZoomScreen.single({
    super.key,
    required this.title,
    required this.singleWheelPlanets,
    required this.ascendantSign,
    required this.ascDegree,
    this.mcSign,
    this.mcDegree,
    this.houseCusps,
  })  : isBiWheel = false,
        natalChart = null,
        outerChart = null,
        isSynastry = false,
        displayMode = BiWheelDisplayMode.dual,
        useTrueNode = true,
        enabledExtraBodies = const {'chiron', 'lilith', 'vertex'};

  const ChartZoomScreen.biWheel({
    super.key,
    required this.title,
    required this.natalChart,
    required this.outerChart,
    this.isSynastry = false,
    this.displayMode = BiWheelDisplayMode.dual,
    this.useTrueNode = true,
    this.enabledExtraBodies = const {'chiron', 'lilith', 'vertex'},
    this.houseCusps,
  })  : isBiWheel = true,
        singleWheelPlanets = null,
        ascendantSign = 'Koç',
        ascDegree = 15.0,
        mcSign = null,
        mcDegree = null;

  @override
  State<ChartZoomScreen> createState() => _ChartZoomScreenState();
}

class _ChartZoomScreenState extends State<ChartZoomScreen> {
  final TransformationController _transformController =
      TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(() {
      final scale = _transformController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.05) {
        setState(() {
          _currentScale = scale;
        });
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_currentScale > 1.3) {
      _resetZoom();
    } else {
      final position = details.localPosition;
      final x = -position.dx * 1.5 + (position.dx);
      final y = -position.dy * 1.5 + (position.dy);
      final zoomed = Matrix4.identity()
        ..translateByDouble(x, y, 0.0, 1.0)
        ..scaleByDouble(2.5, 2.5, 1.0, 1.0);
      setState(() {
        _transformController.value = zoomed;
        _currentScale = 2.5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double highResCanvasSize = 540.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0916),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Kapat',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.starlightGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Büyütme Oranı: ${(_currentScale * 100).toInt()}% • Yakınlaştırıp İnceleyin',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded,
                color: AppColors.starlightGold),
            onPressed: _resetZoom,
            tooltip: 'Görünümü Sıfırla',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Yıldızlı Arka Plan Dokusu
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.1),
                    radius: 1.1,
                    colors: [
                      Color(0xFF1E1738),
                      Color(0xFF0C0916),
                    ],
                  ),
                ),
              ),
            ),

            // 2 Parmakla Pinch-to-Zoom Canvas
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.6,
                maxScale: 6.0,
                boundaryMargin: const EdgeInsets.all(260),
                clipBehavior: Clip.none,
                child: GestureDetector(
                  onDoubleTapDown: _handleDoubleTap,
                  onDoubleTap: () {},
                  child: Center(
                    child: Container(
                      width: highResCanvasSize,
                      height: highResCanvasSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.starlightGold.withValues(alpha: 0.08),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: widget.isBiWheel
                          ? CustomPaint(
                              painter: BiWheelPainter(
                                natalChart: widget.natalChart!,
                                outerChart: widget.outerChart!,
                                isSynastry: widget.isSynastry,
                                rotationOffsetRad: 0.0,
                                displayMode: widget.displayMode,
                                useTrueNode: widget.useTrueNode,
                                enabledExtraBodies: widget.enabledExtraBodies,
                                houseCusps: widget.houseCusps,
                                onAspectFound: (_) {},
                              ),
                            )
                          : CustomPaint(
                              painter: ChartWheelPainter(
                                planets: widget.singleWheelPlanets ?? {},
                                ascendantSign: widget.ascendantSign,
                                ascDegree: widget.ascDegree,
                                mcSign: widget.mcSign,
                                mcDegree: widget.mcDegree,
                                houseCusps: widget.houseCusps,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Alt Bilgi İpucu Rozeti
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19142E).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.starlightGold.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pinch_rounded,
                        color: AppColors.starlightGold,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '2 parmakla serbestçe büyütüp küçültebilirsiniz • Çift dokunarak yakınlaştırın',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
