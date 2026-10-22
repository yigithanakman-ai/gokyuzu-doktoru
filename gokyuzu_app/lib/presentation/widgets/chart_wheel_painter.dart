import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'astrological_glyph.dart';

class ChartWheelPainter extends CustomPainter {
  final Map<String, dynamic> planets;
  final String ascendantSign;
  final double ascDegree;
  final String? mcSign;
  final double? mcDegree;
  final Map<int, double>? houseCusps;

  ChartWheelPainter({
    required this.planets,
    this.ascendantSign = 'Koç',
    this.ascDegree = 15.0,
    this.mcSign,
    this.mcDegree,
    this.houseCusps,
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

  double _norm(double deg) {
    final d = deg % 360.0;
    return d < 0 ? d + 360.0 : d;
  }

  /// wheelDeg 0° is ASC (9 o'clock / East), proceeding counter-clockwise.
  Offset _getPointOnWheel(Offset center, double r, double wheelDeg) {
    final rad = wheelDeg * math.pi / 180.0;
    return Offset(
      center.dx - r * math.cos(rad),
      center.dy + r * math.sin(rad),
    );
  }

  Map<int, double> _resolveHouseCusps(double totalAscDeg, double totalMcDeg) {
    if (houseCusps != null && houseCusps!.length == 12) {
      return houseCusps!;
    }
    final c1 = _norm(totalAscDeg);
    final c10 = _norm(totalMcDeg);
    final c7 = _norm(c1 + 180.0);
    final c4 = _norm(c10 + 180.0);

    // Porphyry / Placidus quadrant trisection between angles
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;

    // Leave outer margin for house cusp degree labels (like Astro Gold / Image 2)
    final cuspLabelR = maxR - 10;
    final outerRingR = maxR - 22;
    final middleRingR = outerRingR * 0.84;
    final houseNumRingR = outerRingR * 0.48;
    final innerAspectsR = outerRingR * 0.39;

    // Background radial cosmic disc
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF19142A),
          Color(0xFF0D0A18),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRingR));
    canvas.drawCircle(center, outerRingR, bgPaint);

    // Outer zodiac ring subtle fill
    final zodiacBandPaint = Paint()
      ..color = const Color(0xFF211B38).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRingR - middleRingR;
    canvas.drawCircle(center, (outerRingR + middleRingR) / 2, zodiacBandPaint);

    final circlePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawCircle(center, outerRingR, circlePaint..color = AppColors.starlightGold.withValues(alpha: 0.45));
    canvas.drawCircle(center, middleRingR, circlePaint..color = Colors.white30);
    canvas.drawCircle(center, houseNumRingR, circlePaint..color = Colors.white24);
    canvas.drawCircle(center, innerAspectsR, circlePaint..color = Colors.white30);

    final ascSignIdx = zodiacSigns.indexOf(ascendantSign);
    final totalAscDeg = (ascSignIdx >= 0 ? ascSignIdx * 30.0 : 0.0) + ascDegree;

    double totalMcDeg = _norm(totalAscDeg + 270.0);
    if (mcSign != null && zodiacSigns.contains(mcSign)) {
      final mcIdx = zodiacSigns.indexOf(mcSign!);
      totalMcDeg = (mcIdx * 30.0) + (mcDegree ?? 15.0);
    }

    // --- 1. DRAW 12 ZODIAC SIGNS & DEGREE TICKS ON THE OUTER RING ---
    final tickPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 0.8;

    for (int deg = 0; deg < 360; deg += 2) {
      final wDeg = _norm(deg - totalAscDeg);
      final isTen = deg % 10 == 0;
      final isFive = deg % 5 == 0;
      final tickLen = isTen ? 5.0 : (isFive ? 3.5 : 1.8);
      canvas.drawLine(
        _getPointOnWheel(center, middleRingR, wDeg),
        _getPointOnWheel(center, middleRingR + tickLen, wDeg),
        tickPaint..color = isTen ? Colors.white54 : Colors.white24,
      );
    }

    for (int i = 0; i < 12; i++) {
      final signStartAbsolute = i * 30.0;
      final signStartWheelDeg = _norm(signStartAbsolute - totalAscDeg);

      // Sign divider line
      final divP1 = _getPointOnWheel(center, middleRingR, signStartWheelDeg);
      final divP2 = _getPointOnWheel(center, outerRingR, signStartWheelDeg);
      canvas.drawLine(
        divP1,
        divP2,
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 1.2,
      );

      // Zodiac Symbol at midpoint of sign (15°)
      final midWheelDeg = _norm(signStartWheelDeg + 15.0);
      final symbolR = (outerRingR + middleRingR) / 2;
      final symPos = _getPointOnWheel(center, symbolR, midWheelDeg);

      final textPainter = TextPainter(
        text: TextSpan(
          text: zodiacSymbols[i],
          style: TextStyle(
            color: elementColors[i],
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(symPos.dx - textPainter.width / 2, symPos.dy - textPainter.height / 2),
      );
    }

    // --- 2. DRAW 12 PROMINENT HOUSE CUSPS, OUTER CUSP DEGREES & INNER HOUSE NUMBERS ---
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
                      : Colors.white38;

      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = isAngle ? 2.2 : 1.1;

      // Prominent cusp line from innerAspectsR through middleRingR to outerRingR
      final hp1 = _getPointOnWheel(center, innerAspectsR, wDeg);
      final hp2 = _getPointOnWheel(center, isAngle ? outerRingR + 3 : middleRingR, wDeg);
      canvas.drawLine(hp1, hp2, linePaint);

      // Outer House Cusp Degree Label (e.g. "04°♑17'")
      final cuspPos = _getPointOnWheel(center, cuspLabelR, wDeg);
      final cuspLabel = _formatCuspCompact(cuspLon);
      final cuspPainter = TextPainter(
        text: TextSpan(
          text: cuspLabel,
          style: TextStyle(
            color: isAngle ? lineColor : Colors.white70,
            fontSize: isAngle ? 7.8 : 6.8,
            fontWeight: isAngle ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      cuspPainter.paint(
        canvas,
        Offset(cuspPos.dx - cuspPainter.width / 2, cuspPos.dy - cuspPainter.height / 2),
      );

      // Inner House Number (1..12) in the house number ring
      double span = _norm(nextWDeg - wDeg);
      if (span == 0) span = 30.0;
      final midHouseWDeg = _norm(wDeg + span / 2.0);
      final hNumR = (houseNumRingR + innerAspectsR) / 2;
      final hNumPos = _getPointOnWheel(center, hNumR, midHouseWDeg);

      final hPainter = TextPainter(
        text: TextSpan(
          text: '$h',
          style: TextStyle(
            color: isAngle ? AppColors.starlightGold : Colors.white70,
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      hPainter.paint(
        canvas,
        Offset(hNumPos.dx - hPainter.width / 2, hNumPos.dy - hPainter.height / 2),
      );
    }

    // Angle badges on the outer rim of the middle ring
    final mcWheelDeg = _norm(totalMcDeg - totalAscDeg);
    final icWheelDeg = _norm(mcWheelDeg + 180.0);
    _drawAxisBadge(canvas, center, middleRingR - 9, 0.0, 'ASC', AppColors.starlightGold);
    _drawAxisBadge(canvas, center, middleRingR - 9, icWheelDeg, 'IC', AppColors.pastelBlue);
    _drawAxisBadge(canvas, center, middleRingR - 9, 180.0, 'DSC', AppColors.pastelLavender);
    _drawAxisBadge(canvas, center, middleRingR - 9, mcWheelDeg, 'MC', AppColors.pastelMint);

    // --- 3. DRAW PLANETS & THEIR DEGREES INSIDE THE WHEEL ---
    final planetPositions = <String, Offset>{};
    final planetTrueLongitudes = <String, double>{};
    _drawPlanetsOnWheel(
      canvas: canvas,
      center: center,
      outerPlanetR: middleRingR - 22,
      degreeLabelR: houseNumRingR + 16,
      middleRingR: middleRingR,
      totalAscDeg: totalAscDeg,
      outPositions: planetPositions,
      outLongitudes: planetTrueLongitudes,
    );

    // --- 4. DRAW CENTRAL ASPECT LINES & ASPECT GLYPHS (Universal Orbs: 10/10/8/7/7) ---
    _drawInnerAspects(canvas, center, innerAspectsR, planetPositions, planetTrueLongitudes);
  }

  static const Map<String, Color> planetColors = {
    'sun': Color(0xFFFFD700),
    'moon': Color(0xFFE0E0FF),
    'mercury': Color(0xFF80D8FF),
    'venus': Color(0xFFFF80AB),
    'mars': Color(0xFFFF5252),
    'jupiter': Color(0xFFFFAB40),
    'saturn': Color(0xFFB0BEC5),
    'uranus': Color(0xFF40C4FF),
    'neptune': Color(0xFF7C4DFF),
    'pluto': Color(0xFFB388FF),
    'north_node': Color(0xFF69F0AE),
    'true_north_node': Color(0xFF69F0AE),
    'mean_north_node': Color(0xFF69F0AE),
    'south_node': Color(0xFFFFAB91),
    'true_south_node': Color(0xFFFFAB91),
    'mean_south_node': Color(0xFFFFAB91),
    'chiron': Color(0xFFFFD54F),
    'lilith': Color(0xFFCE93D8),
    'ceres': Color(0xFFA5D6A7),
    'pallas': Color(0xFF90CAF9),
    'juno': Color(0xFFF48FB1),
    'vesta': Color(0xFFFFCC80),
    'vertex': Color(0xFF80CBC4),
    'amor': Color(0xFFFF8A80),
    'hekate': Color(0xFFB39DDB),
    'isis': Color(0xFFFFF59D),
  };

  void _drawPlanetsOnWheel({
    required Canvas canvas,
    required Offset center,
    required double outerPlanetR,
    required double degreeLabelR,
    required double middleRingR,
    required double totalAscDeg,
    required Map<String, Offset> outPositions,
    required Map<String, double> outLongitudes,
  }) {
    final items = <_WheelPlanetItem>[];

    planets.forEach((name, p) {
      final lowerName = name.toLowerCase();
      if (lowerName == 'ascendant' || lowerName == 'rising' || lowerName == 'mc' || lowerName == 'ic' || lowerName == 'descendant') {
        return;
      }

      String sign = '';
      double deg = 0.0;
      bool isRetro = false;
      String displayName = name;

      if (p is Map) {
        sign = p['sign']?.toString() ?? '';
        deg = (p['degree'] as num?)?.toDouble() ?? 0.0;
        isRetro = p['isRetrograde'] == true;
        if (p['name'] != null) displayName = p['name'].toString();
      } else {
        try {
          sign = (p as dynamic).sign?.toString() ?? '';
          deg = ((p as dynamic).degree as num?)?.toDouble() ?? 0.0;
          isRetro = (p as dynamic).isRetrograde == true;
          if ((p as dynamic).name != null) displayName = (p as dynamic).name.toString();
        } catch (_) {}
      }

      final signIdx = zodiacSigns.indexOf(sign);
      if (signIdx >= 0) {
        final planetAbsDeg = _norm((signIdx * 30.0) + deg);
        final trueWheelDeg = _norm(planetAbsDeg - totalAscDeg);
        items.add(_WheelPlanetItem(
          key: name,
          displayName: displayName,
          signIdx: signIdx,
          degInSign: deg,
          absDeg: planetAbsDeg,
          trueWheelDeg: trueWheelDeg,
          displayWheelDeg: trueWheelDeg,
          isRetro: isRetro,
          color: planetColors[lowerName] ?? AppColors.starlightGold,
        ));
      }
    });

    if (items.isEmpty) return;

    // Anti-collision angular spreading (so clustered planets & degrees are clearly legible)
    items.sort((a, b) => a.trueWheelDeg.compareTo(b.trueWheelDeg));
    const double minSep = 7.5;
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
      outLongitudes[item.key] = item.absDeg;
      final trueRingPt = _getPointOnWheel(center, middleRingR, item.trueWheelDeg);
      final pos = _getPointOnWheel(center, outerPlanetR, item.displayWheelDeg);
      outPositions[item.key] = _getPointOnWheel(center, middleRingR, item.trueWheelDeg);

      // Leader tick from true degree on zodiac ring to planet badge
      canvas.drawLine(
        trueRingPt,
        _getPointOnWheel(center, outerPlanetR + 10, item.displayWheelDeg),
        Paint()
          ..color = item.color.withValues(alpha: 0.65)
          ..strokeWidth = 0.9,
      );

      // Planet badge
      final badgePaint = Paint()
        ..color = const Color(0xFF140F24)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 9.5, badgePaint);

      final borderPaint = Paint()
        ..color = item.color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25;
      canvas.drawCircle(pos, 9.5, borderPaint);

      AstrologicalGlyphPainter.drawPlanet(
        canvas,
        planetKeyOrName: item.displayName,
        center: pos,
        size: 12.5,
        color: item.color,
        strokeWidth: 1.5,
      );

      // Planet degree & sign label inward along the radial ray (Astro Gold style: "11°♓")
      final degInt = item.degInSign.floor().clamp(0, 29);
      final minInt = ((item.degInSign - degInt) * 60).round().clamp(0, 59);
      final degPos = _getPointOnWheel(center, degreeLabelR, item.displayWheelDeg);
      final degText = '${degInt.toString().padLeft(2, '0')}°${zodiacSymbols[item.signIdx]}${minInt.toString().padLeft(2, '0')}\'';

      final degPainter = TextPainter(
        text: TextSpan(
          text: degText,
          style: TextStyle(
            color: item.color.withValues(alpha: 0.95),
            fontSize: 6.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      degPainter.paint(
        canvas,
        Offset(degPos.dx - degPainter.width / 2, degPos.dy - degPainter.height / 2),
      );

      if (item.isRetro) {
        final rxPainter = TextPainter(
          text: const TextSpan(
            text: '℞',
            style: TextStyle(
              color: AppColors.savageRed,
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        rxPainter.paint(canvas, Offset(pos.dx + 5, pos.dy - 10));
      }
    }
  }

  void _drawAxisBadge(Canvas canvas, Offset center, double r, double wheelDeg, String text, Color color) {
    final pos = _getPointOnWheel(center, r, wheelDeg);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 8.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2));
  }

  /// Evrensel Açı Orbları: Kavuşum 10°, Karşıt 10°, Üçgen (120°) 8°, Kare (90°) 7°, Sekstil (60°) 7°
  void _drawInnerAspects(
    Canvas canvas,
    Offset center,
    double r,
    Map<String, Offset> planetPositions,
    Map<String, double> planetLongitudes,
  ) {
    final pKeys = planetLongitudes.keys.toList();
    if (pKeys.length < 2) return;

    for (int i = 0; i < pKeys.length; i++) {
      for (int j = i + 1; j < pKeys.length; j++) {
        final k1 = pKeys[i];
        final k2 = pKeys[j];
        final lon1 = planetLongitudes[k1];
        final lon2 = planetLongitudes[k2];
        if (lon1 == null || lon2 == null) continue;

        double diff = (lon1 - lon2).abs() % 360.0;
        if (diff > 180.0) diff = 360.0 - diff;

        Color? aspectColor;
        String? aspectSymbol;
        double strokeW = 1.0;

        if (diff <= 10.0) {
          aspectColor = AppColors.starlightGold.withValues(alpha: 0.70);
          aspectSymbol = '☌';
          strokeW = 1.3;
        } else if ((diff - 180.0).abs() <= 10.0) {
          aspectColor = AppColors.savageRed.withValues(alpha: 0.65);
          aspectSymbol = '☍';
          strokeW = 1.25;
        } else if ((diff - 120.0).abs() <= 8.0) {
          aspectColor = AppColors.pastelMint.withValues(alpha: 0.65);
          aspectSymbol = '△';
          strokeW = 1.15;
        } else if ((diff - 90.0).abs() <= 7.0) {
          aspectColor = AppColors.warningOrange.withValues(alpha: 0.65);
          aspectSymbol = '□';
          strokeW = 1.15;
        } else if ((diff - 60.0).abs() <= 7.0) {
          aspectColor = AppColors.pastelBlue.withValues(alpha: 0.60);
          aspectSymbol = '✶';
          strokeW = 1.0;
        }

        if (aspectColor == null) continue;

        final p1 = planetPositions[k1]!;
        final p2 = planetPositions[k2]!;
        final dir1 = (p1 - center);
        final dir2 = (p2 - center);
        final innerP1 = center + (dir1 / dir1.distance) * (r * 0.96);
        final innerP2 = center + (dir2 / dir2.distance) * (r * 0.96);

        canvas.drawLine(
          innerP1,
          innerP2,
          Paint()
            ..color = aspectColor
            ..strokeWidth = strokeW,
        );

        // Draw small aspect symbol at midpoint of aspect chord (Astro Gold style)
        if (aspectSymbol != null && (innerP1 - innerP2).distance > 18) {
          final mid = Offset((innerP1.dx + innerP2.dx) / 2, (innerP1.dy + innerP2.dy) / 2);
          final symPainter = TextPainter(
            text: TextSpan(
              text: aspectSymbol,
              style: TextStyle(
                color: aspectColor.withValues(alpha: 0.95),
                fontSize: 7.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          symPainter.paint(canvas, Offset(mid.dx - symPainter.width / 2, mid.dy - symPainter.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WheelPlanetItem {
  final String key;
  final String displayName;
  final int signIdx;
  final double degInSign;
  final double absDeg;
  final double trueWheelDeg;
  double displayWheelDeg;
  final bool isRetro;
  final Color color;

  _WheelPlanetItem({
    required this.key,
    required this.displayName,
    required this.signIdx,
    required this.degInSign,
    required this.absDeg,
    required this.trueWheelDeg,
    required this.displayWheelDeg,
    required this.isRetro,
    required this.color,
  });
}
