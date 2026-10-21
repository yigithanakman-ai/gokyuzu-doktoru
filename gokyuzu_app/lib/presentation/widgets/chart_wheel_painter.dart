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

  ChartWheelPainter({
    required this.planets,
    this.ascendantSign = 'Koç',
    this.ascDegree = 15.0,
    this.mcSign,
    this.mcDegree,
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

  /// Mathematical helper: calculates position on the wheel where:
  /// wheelDeg 0° is ASC (9 o'clock / East)
  /// wheelDeg 90° is IC (6 o'clock / Nadir)
  /// wheelDeg 180° is DSC (3 o'clock / West)
  /// wheelDeg 270° is MC (12 o'clock / Midheaven)
  /// Proceeding counter-clockwise in classical Western astrology convention.
  Offset _getPointOnWheel(Offset center, double r, double wheelDeg) {
    final rad = wheelDeg * math.pi / 180.0;
    return Offset(
      center.dx - r * math.cos(rad),
      center.dy + r * math.sin(rad),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final outerRingR = radius;
    final middleRingR = radius * 0.82;
    final housesRingR = radius * 0.58;
    final innerAspectsR = radius * 0.44;

    final circlePaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Background gradient circle
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF161224),
          Color(0xFF0C0A14),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Concentric boundary circles
    canvas.drawCircle(center, outerRingR, circlePaint);
    canvas.drawCircle(center, middleRingR, circlePaint);
    canvas.drawCircle(center, housesRingR, circlePaint);
    canvas.drawCircle(center, innerAspectsR, circlePaint);

    // Ascendant degree offset in absolute zodiac (0° Koç = 0, 30° Boğa = 60, etc.)
    final ascSignIdx = zodiacSigns.indexOf(ascendantSign);
    final totalAscDeg = (ascSignIdx >= 0 ? ascSignIdx * 30.0 : 0.0) + ascDegree;

    // --- 1. DRAW 12 ZODIAC SIGNS ON THE OUTER RING ---
    for (int i = 0; i < 12; i++) {
      final signStartAbsolute = i * 30.0;
      double signStartWheelDeg = (signStartAbsolute - totalAscDeg) % 360.0;
      if (signStartWheelDeg < 0) signStartWheelDeg += 360.0;

      // Draw sign divider line
      final divP1 = _getPointOnWheel(center, middleRingR, signStartWheelDeg);
      final divP2 = _getPointOnWheel(center, outerRingR, signStartWheelDeg);
      canvas.drawLine(divP1, divP2, circlePaint);

      // Symbol position at midpoint of sign (15° in sign)
      final midWheelDeg = (signStartWheelDeg + 15.0) % 360.0;
      final symbolR = (outerRingR + middleRingR) / 2;
      final symPos = _getPointOnWheel(center, symbolR, midWheelDeg);

      final textPainter = TextPainter(
        text: TextSpan(
          text: zodiacSymbols[i],
          style: TextStyle(
            color: elementColors[i],
            fontSize: 14.5,
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

    // --- 2. DRAW 12 HOUSES (Counter-Clockwise: House 1 is 9 -> 8 o'clock) ---
    for (int h = 0; h < 12; h++) {
      final houseStartWheelDeg = h * 30.0;
      final isAscDsc = (h == 0 || h == 6);

      final linePaint = Paint()
        ..color = isAscDsc ? AppColors.starlightGold : Colors.white24
        ..strokeWidth = isAscDsc ? 1.8 : 0.8;

      final hp1 = _getPointOnWheel(center, innerAspectsR, houseStartWheelDeg);
      final hp2 = _getPointOnWheel(center, middleRingR, houseStartWheelDeg);
      canvas.drawLine(hp1, hp2, linePaint);

      // House Number in the middle of house (15° offset)
      final hNumWheelDeg = houseStartWheelDeg + 15.0;
      final hNumR = (housesRingR + innerAspectsR) / 2;
      final hNumPos = _getPointOnWheel(center, hNumR, hNumWheelDeg);

      final hPainter = TextPainter(
        text: TextSpan(
          text: '${h + 1}',
          style: TextStyle(
            color: isAscDsc ? AppColors.starlightGold : Colors.white38,
            fontSize: 9.5,
            fontWeight: isAscDsc ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      hPainter.paint(
        canvas,
        Offset(hNumPos.dx - hPainter.width / 2, hNumPos.dy - hPainter.height / 2),
      );
    }

    // --- 3. AXIS LINES & BADGES (ASC, DSC, and true MC / IC angles) ---
    double mcWheelDeg = 270.0;
    if (mcSign != null && zodiacSigns.contains(mcSign)) {
      final mcIdx = zodiacSigns.indexOf(mcSign!);
      final mcAbsDeg = (mcIdx * 30.0) + (mcDegree ?? 15.0);
      mcWheelDeg = (mcAbsDeg - totalAscDeg) % 360.0;
      if (mcWheelDeg < 0) mcWheelDeg += 360.0;
    }
    final icWheelDeg = (mcWheelDeg + 180.0) % 360.0;

    // MC & IC Axis Lines
    final mcLinePaint = Paint()
      ..color = AppColors.pastelMint.withAlpha(220)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      _getPointOnWheel(center, innerAspectsR, mcWheelDeg),
      _getPointOnWheel(center, middleRingR, mcWheelDeg),
      mcLinePaint,
    );

    final icLinePaint = Paint()
      ..color = AppColors.pastelBlue.withAlpha(220)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      _getPointOnWheel(center, innerAspectsR, icWheelDeg),
      _getPointOnWheel(center, middleRingR, icWheelDeg),
      icLinePaint,
    );

    _drawAxisBadge(canvas, center, middleRingR + 14, 0.0, 'ASC', AppColors.starlightGold);
    _drawAxisBadge(canvas, center, middleRingR + 14, icWheelDeg, 'IC', AppColors.pastelBlue);
    _drawAxisBadge(canvas, center, middleRingR + 14, 180.0, 'DSC', AppColors.pastelLavender);
    _drawAxisBadge(canvas, center, middleRingR + 14, mcWheelDeg, 'MC', AppColors.pastelMint);

    // --- 4. DRAW PLANETS AT TRUE COUNTER-CLOCKWISE POSITIONS ---
    final planetPositions = <String, Offset>{};
    _drawPlanetsOnWheel(
      canvas: canvas,
      center: center,
      r: (middleRingR + housesRingR) / 2,
      totalAscDeg: totalAscDeg,
      outPositions: planetPositions,
    );

    // --- 5. DRAW HARMONIC ASPECTS IN CENTRAL DISC ---
    _drawInnerAspects(canvas, center, innerAspectsR, planetPositions);
  }

  static const Map<String, String> planetGlyphs = {
    'Güneş': '☉',
    'Ay': '☽',
    'Merkür': '☿',
    'Venüs': '♀\uFE0E',
    'Mars': '♂\uFE0E',
    'Jüpiter': '♃',
    'Satürn': '♄',
    'Uranüs': '♅',
    'Neptün': '♆',
    'Plüton': '♇',
    'Kuzey Ay Düğümü': '☊',
    'Güney Ay Düğümü': '☋',
    'Chiron': '⚷',
    'Kiron': '⚷',
    'Lilith': '⚸',
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
    'north_node': '☊',
    'south_node': '☋',
    'chiron': '⚷',
    'lilith': '⚸',
  };

  static const Map<String, Color> planetColors = {
    'sun': Color(0xFFFFD700), // Altın
    'moon': Color(0xFFE0E0FF), // Gümüş
    'mercury': Color(0xFF80D8FF), // Açık Mavi
    'venus': Color(0xFFFF80AB), // Pembe
    'mars': Color(0xFFFF5252), // Kırmızı
    'jupiter': Color(0xFFFFAB40), // Turuncu
    'saturn': Color(0xFFB0BEC5), // Çelik Grisi
    'uranus': Color(0xFF40C4FF), // Turkuaz
    'neptune': Color(0xFF7C4DFF), // Mor
    'pluto': Color(0xFFB388FF), // Koyu Lavanta
    'north_node': Color(0xFF69F0AE), // Nane Yeşili
    'south_node': Color(0xFFFFAB91), // Şeftali
    'chiron': Color(0xFFFFD54F), // Sarı
  };

  void _drawPlanetsOnWheel({
    required Canvas canvas,
    required Offset center,
    required double r,
    required double totalAscDeg,
    required Map<String, Offset> outPositions,
  }) {
    planets.forEach((name, p) {
      // Don't draw angles as planets
      final lowerName = name.toLowerCase();
      if (lowerName == 'ascendant' || lowerName == 'mc' || lowerName == 'ic' || lowerName == 'descendant') {
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
        final planetAbsDeg = (signIdx * 30.0) + deg;
        double planetWheelDeg = (planetAbsDeg - totalAscDeg) % 360.0;
        if (planetWheelDeg < 0) planetWheelDeg += 360.0;

        final pos = _getPointOnWheel(center, r, planetWheelDeg);
        outPositions[name] = pos;

        final planetColor = planetColors[lowerName] ?? AppColors.starlightGold;

        // Draw planet badge (filled disc with border and prominent glyph)
        final badgePaint = Paint()
          ..color = const Color(0xFF140F24)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 9.5, badgePaint);

        final borderPaint = Paint()
          ..color = planetColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(pos, 9.5, borderPaint);

        // Draw astrological glyph (Mars and Venus vector, others clean unicode)
        AstrologicalGlyphPainter.drawPlanet(
          canvas,
          planetKeyOrName: displayName,
          center: pos,
          size: 13.0,
          color: planetColor,
          strokeWidth: 1.5,
        );

        // If retrograde, draw small '℞' badge
        if (isRetro) {
          final rxPainter = TextPainter(
            text: const TextSpan(
              text: '℞',
              style: TextStyle(
                color: AppColors.savageRed,
                fontSize: 8.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          rxPainter.paint(
            canvas,
            Offset(pos.dx + 4, pos.dy - 10),
          );
        }
      }
    });
  }

  void _drawAxisBadge(Canvas canvas, Offset center, double r, double wheelDeg, String text, Color color) {
    final pos = _getPointOnWheel(center, r, wheelDeg);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2));
  }

  void _drawInnerAspects(Canvas canvas, Offset center, double r, Map<String, Offset> planetPositions) {
    final pKeys = planetPositions.keys.toList();
    if (pKeys.length >= 2) {
      final planetLongitudes = <String, double>{};
      planets.forEach((name, p) {
        String sign = '';
        double deg = 0.0;
        if (p is Map) {
          sign = p['sign']?.toString() ?? '';
          deg = (p['degree'] as num?)?.toDouble() ?? 0.0;
        } else {
          try {
            sign = (p as dynamic).sign?.toString() ?? '';
            deg = ((p as dynamic).degree as num?)?.toDouble() ?? 0.0;
          } catch (_) {}
        }
        final signIdx = zodiacSigns.indexOf(sign);
        if (signIdx >= 0) {
          planetLongitudes[name] = (signIdx * 30.0) + deg;
        }
      });

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
          double strokeW = 0.9;
          if ((diff - 180.0).abs() <= 8.0) {
            aspectColor = AppColors.starlightGold.withValues(alpha: 0.55);
            strokeW = 1.15;
          } else if ((diff - 120.0).abs() <= 7.5) {
            aspectColor = AppColors.pastelMint.withValues(alpha: 0.50);
            strokeW = 1.05;
          } else if ((diff - 90.0).abs() <= 7.5) {
            aspectColor = AppColors.savageRed.withValues(alpha: 0.50);
            strokeW = 1.05;
          } else if ((diff - 60.0).abs() <= 6.0) {
            aspectColor = AppColors.pastelBlue.withValues(alpha: 0.45);
            strokeW = 0.85;
          }

          if (aspectColor == null) continue;

          final p1 = planetPositions[k1]!;
          final p2 = planetPositions[k2]!;
          final dir1 = (p1 - center);
          final dir2 = (p2 - center);
          final innerP1 = center + (dir1 / dir1.distance) * (r * 0.92);
          final innerP2 = center + (dir2 / dir2.distance) * (r * 0.92);

          canvas.drawLine(
            innerP1,
            innerP2,
            Paint()
              ..color = aspectColor
              ..strokeWidth = strokeW,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
