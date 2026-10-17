// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/storage_service.dart';

/// Instagram, WhatsApp ve TikTok için 9:16 Dikey Kozmik Hikaye Kartı Paylaşım Modalı
class CosmicStoryShareModal extends StatefulWidget {
  final UserProfile profile;

  const CosmicStoryShareModal({
    super.key,
    required this.profile,
  });

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CosmicStoryShareModal(profile: profile),
    );
  }

  @override
  State<CosmicStoryShareModal> createState() => _CosmicStoryShareModalState();
}

class _CosmicStoryShareModalState extends State<CosmicStoryShareModal> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _captureAndShare({bool saveOnly = false}) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('RenderRepaintBoundary bulunamadı.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Görsel verisi oluşturulamadı.');
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final safeName = widget.profile.name.replaceAll(RegExp(r'\s+'), '_');
      final fileName = 'Gokyuzu_Doktoru_${safeName}_Story.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Masaüstü veya İndirilenler klasörüne de kaydet (Mac için)
      try {
        final home = Platform.environment['HOME'];
        if (home != null) {
          final deskFile = File('$home/Desktop/$fileName');
          await deskFile.writeAsBytes(pngBytes);
        }
      } catch (_) {}

      if (saveOnly) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Hikaye görseli kaydedildi: ${file.path}'),
              backgroundColor: AppColors.pastelMint,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: '✨ Gökyüzü Doktoru Doğum Haritam: Güneş ${widget.profile.sunSign}, Ay ${widget.profile.moonSign}, Yükselen ${widget.profile.risingSign}! Sen de haritanı keşfet 🪐',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel paylaşılırken bir hata oluştu: $e'),
            backgroundColor: AppColors.savageRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final realChart = AstrologyEngine.calculateChart(
      name: widget.profile.name,
      dateStr: widget.profile.birthDate,
      timeStr: widget.profile.birthTime,
      city: widget.profile.birthCity,
      country: widget.profile.birthCountry,
    );

    final sun = realChart.sunFormatted;
    final moon = realChart.moonFormatted;
    final rising = realChart.risingFormatted;
    final mc = realChart.rawChart['mc']?.toString() ?? '14°27\' Kova';

    final elem = realChart.elements;
    final fire = elem['Ateş'] ?? 0;
    final air = elem['Hava'] ?? 0;
    final water = elem['Su'] ?? 0;
    final earth = elem['Toprak'] ?? 0;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF140F24),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.share_rounded, color: AppColors.starlightGold, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hikaye & Reels Paylaşım Kartı 📸',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Instagram, WhatsApp & TikTok İçin 9:16 Formatı',
                            style: TextStyle(color: AppColors.pastelLavender, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 9:16 RepaintBoundary Hikaye Kartı
              RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  width: 330,
                  height: 520,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F0A1C),
                        Color(0xFF1C1335),
                        Color(0xFF261245),
                        Color(0xFF0D0818),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.starlightGold.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.starlightGold.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & Brand
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.starlightGold, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'GÖKYÜZÜ DOKTORU',
                                style: TextStyle(
                                  color: AppColors.starlightGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.starlightGold, size: 16),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kozmik Doğum Haritası Portresi',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                          ),
                        ],
                      ),

                      // User Name
                      Column(
                        children: [
                          Text(
                            widget.profile.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.profile.birthDate} • ${widget.profile.birthCity}',
                            style: TextStyle(color: AppColors.pastelMint.withValues(alpha: 0.9), fontSize: 10.5),
                          ),
                        ],
                      ),

                      // Big Three Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBigThreeItem('GÜNEŞ', sun, Icons.wb_sunny_rounded, AppColors.starlightGold),
                            _buildDivider(),
                            _buildBigThreeItem('AY', moon, Icons.nightlight_round, AppColors.pastelLavender),
                            _buildDivider(),
                            _buildBigThreeItem('YÜKSELEN', rising, Icons.navigation_rounded, AppColors.pastelMint),
                          ],
                        ),
                      ),

                      // MC & Kilit Aks
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1E4A).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '👑 Tepe Noktası (MC - Kariyer):',
                              style: TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                            Text(
                              mc,
                              style: const TextStyle(color: AppColors.starlightGold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      // Element Scores
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('MİZAÇ VE ELEMENT GÜCÜ', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9, letterSpacing: 1)),
                              Text('15 Puan Standartı', style: TextStyle(color: AppColors.starlightGold.withValues(alpha: 0.8), fontSize: 9)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildElementChip('🔥 Ateş', fire, AppColors.savageRed),
                              const SizedBox(width: 4),
                              _buildElementChip('💨 Hava', air, AppColors.pastelMint),
                              const SizedBox(width: 4),
                              _buildElementChip('💧 Su', water, const Color(0xFF60A5FA)),
                              const SizedBox(width: 4),
                              _buildElementChip('🌱 Toprak', earth, const Color(0xFFFBBF24)),
                            ],
                          ),
                        ],
                      ),

                      // Quote
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '"Kendi hakikatini ifade etmekten asla çekinme; gökyüzü cesur adımları destekler."',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 9.5, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Footer & Download Callout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: AppColors.starlightGold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '@gokyuzudoktoru',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            'Google Play & App Store',
                            style: TextStyle(color: AppColors.pastelMint, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, color: Colors.white70, size: 18),
                      label: const Text('Görseli Kaydet', style: TextStyle(color: Colors.white, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isExporting ? null : () => _captureAndShare(saveOnly: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                      label: Text(
                        _isExporting ? 'Hazırlanıyor...' : 'Hikayede Paylaş 📲',
                        style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.starlightGold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _isExporting ? null : () => _captureAndShare(saveOnly: false),
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

  static Widget _buildBigThreeItem(String label, String formatted, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 8.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          formatted,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  static Widget _buildElementChip(String label, int score, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
            Text('$score/15', style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
