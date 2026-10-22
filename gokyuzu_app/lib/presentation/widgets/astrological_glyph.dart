import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gökyüzü Doktoru — Vektörel Astroloji Sembol Motoru
/// Android/iOS sistem fontlarında Mars (♂) ve Venüs (♀) sembollerinin
/// renkli emoji kutucuklarına (🚹/🚺) dönüşmesini %100 engelleyen,
/// GPU hızlandırmalı vektörel çizim motoru.
class AstrologicalGlyphPainter {
  /// Bir Canvas üzerine saf vektörel astrolojik gezegen sembolü çizer.
  /// Mars ve Venüs tamamen el yapımı vektörel path olarak çizilir;
  /// asla emoji fontuna düşmez!
  static void drawPlanet(
    Canvas canvas, {
    required String planetKeyOrName,
    required Offset center,
    required double size,
    required Color color,
    double strokeWidth = 1.6,
  }) {
    final key = planetKeyOrName.toLowerCase().trim();

    if (key == 'mars' || key == '♂' || key.contains('mars') || key.contains('♂')) {
      _drawMars(canvas, center, size, color, strokeWidth);
    } else if (key == 'venus' || key == 'venüs' || key == '♀' || key.contains('venüs') || key.contains('venus') || key.contains('♀')) {
      _drawVenus(canvas, center, size, color, strokeWidth);
    } else {
      _drawUnicodeGlyph(canvas, planetKeyOrName, center, size, color);
    }
  }

  /// Mars Vektörel Çizimi: Sol altta daire, sağ üstte 45° yönelen ok
  static void _drawMars(Canvas canvas, Offset center, double size, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = size * 0.28;
    // Daire merkezi sol-alta kaydırılır
    final c = Offset(center.dx - size * 0.12, center.dy + size * 0.12);
    canvas.drawCircle(c, r, paint);

    // Ok gövdesi (45° açıyla sağ üste)
    const cos45 = 0.70710678;
    final arrowStart = Offset(c.dx + r * cos45, c.dy - r * cos45);
    final arrowTip = Offset(center.dx + size * 0.44, center.dy - size * 0.44);
    canvas.drawLine(arrowStart, arrowTip, paint);

    // Ok kanatları (başlık)
    final barbLen = size * 0.22;
    canvas.drawLine(arrowTip, Offset(arrowTip.dx - barbLen, arrowTip.dy), paint);
    canvas.drawLine(arrowTip, Offset(arrowTip.dx, arrowTip.dy + barbLen), paint);
  }

  /// Venüs Vektörel Çizimi: Üstte daire, altta haç
  static void _drawVenus(Canvas canvas, Offset center, double size, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = size * 0.30;
    // Daire merkezi yukarıda
    final c = Offset(center.dx, center.dy - size * 0.16);
    canvas.drawCircle(c, r, paint);

    // Dikey gövde
    final stemTop = Offset(center.dx, c.dy + r);
    final stemBottom = Offset(center.dx, center.dy + size * 0.46);
    canvas.drawLine(stemTop, stemBottom, paint);

    // Yatay haç çubuğu
    final barY = stemTop.dy + (stemBottom.dy - stemTop.dy) * 0.45;
    final barHalf = size * 0.18;
    canvas.drawLine(Offset(center.dx - barHalf, barY), Offset(center.dx + barHalf, barY), paint);
  }

  static void _drawUnicodeGlyph(Canvas canvas, String text, Offset center, double size, Color color) {
    final glyph = _resolveUnicode(text);
    final painter = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          color: color,
          fontSize: size * 0.95,
          fontWeight: FontWeight.bold,
          fontFamilyFallback: const ['Noto Sans', 'Roboto', 'sans-serif'],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy - painter.height / 2));
  }

  static String _resolveUnicode(String nameOrSym) {
    final s = nameOrSym.toLowerCase().trim();
    if (s.contains('güneş') || s.contains('sun')) return '☉';
    if (s.contains('ay') && !s.contains('düğüm') && !s.contains('lilith')) return '☽';
    if (s.contains('moon') && !s.contains('node') && !s.contains('lilith')) return '☽';
    if (s.contains('merkür') || s.contains('mercury')) return '☿';
    if (s.contains('jüpiter') || s.contains('jupiter')) return '♃';
    if (s.contains('satürn') || s.contains('saturn')) return '♄';
    if (s.contains('uranüs') || s.contains('uranus')) return '♅';
    if (s.contains('neptün') || s.contains('neptune')) return '♆';
    if (s.contains('plüton') || s.contains('pluto')) return '♇';
    if (s.contains('kuzey') || s.contains('north_node')) return '☊';
    if (s.contains('güney') || s.contains('south_node')) return '☋';
    if (s.contains('kiron') || s.contains('chiron')) return '⚷';
    if (s.contains('lilith')) return '⚸';
    if (s.contains('ceres')) return '⚳';
    if (s.contains('pallas')) return '⚴';
    if (s.contains('juno')) return '⚵';
    if (s.contains('vesta')) return '⚶';
    if (s.contains('vertex') || s == 'vx') return 'Vx';
    if (s.contains('amor')) return '♡';
    if (s.contains('hekate')) return '⚝';
    if (s.contains('isis')) return '☥';
    return nameOrSym;
  }
}

/// Arayüz içinde güvenle kullanılabilecek Flutter Gezegen Sembolü Widget'ı.
/// Mars ve Venüs'ü daima vektörel çizer, asla emoji kutucuğu göstermez.
class AstrologicalGlyphWidget extends StatelessWidget {
  final String planetKeyOrName;
  final double size;
  final Color color;
  final double strokeWidth;

  const AstrologicalGlyphWidget({
    super.key,
    required this.planetKeyOrName,
    this.size = 18.0,
    this.color = Colors.white,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    final key = planetKeyOrName.toLowerCase().trim();
    final isMarsOrVenus = key == 'mars' ||
        key == '♂' ||
        key.contains('mars') ||
        key.contains('♂') ||
        key == 'venus' ||
        key == 'venüs' ||
        key == '♀' ||
        key.contains('venüs') ||
        key.contains('venus') ||
        key.contains('♀');

    if (isMarsOrVenus) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _VectorGlyphPainter(
            planetKeyOrName: planetKeyOrName,
            color: color,
            strokeWidth: strokeWidth,
          ),
        ),
      );
    }

    // Diğer gezegenler standart Unicode metin olarak gösterilebilir
    final symbol = AstrologicalGlyphPainter._resolveUnicode(planetKeyOrName);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: size * 0.9,
            fontWeight: FontWeight.bold,
            height: 1.0,
            fontFamilyFallback: const ['Noto Sans', 'Roboto', 'sans-serif'],
          ),
        ),
      ),
    );
  }
}

class _VectorGlyphPainter extends CustomPainter {
  final String planetKeyOrName;
  final Color color;
  final double strokeWidth;

  _VectorGlyphPainter({
    required this.planetKeyOrName,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    AstrologicalGlyphPainter.drawPlanet(
      canvas,
      planetKeyOrName: planetKeyOrName,
      center: center,
      size: math.min(size.width, size.height),
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _VectorGlyphPainter oldDelegate) {
    return oldDelegate.planetKeyOrName != planetKeyOrName ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
