// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';

class BirthdaySolarReturnModal extends StatefulWidget {
  final UserProfile profile;

  const BirthdaySolarReturnModal({super.key, required this.profile});

  /// Kullanıcının tam doğum günü olup olmadığını kontrol eder
  static bool isTodayUserBirthday(UserProfile profile) {
    final now = DateTime.now();
    int? m;
    int? d;
    try {
      final dt = DateTime.parse(profile.birthDate);
      m = dt.month;
      d = dt.day;
    } catch (_) {
      if (profile.birthDate.contains('.')) {
        final parts = profile.birthDate.split('.');
        if (parts.length >= 2) {
          d = int.tryParse(parts[0]);
          m = int.tryParse(parts[1]);
        }
      } else if (profile.birthDate.contains('-')) {
        final parts = profile.birthDate.split('-');
        if (parts.length == 3) {
          m = int.tryParse(parts[1]);
          d = int.tryParse(parts[2]);
        }
      }
    }
    if (m == null || d == null) return false;
    return now.month == m && now.day == d;
  }

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BirthdaySolarReturnModal(profile: profile),
    );
  }

  @override
  State<BirthdaySolarReturnModal> createState() => _BirthdaySolarReturnModalState();
}

class _BirthdaySolarReturnModalState extends State<BirthdaySolarReturnModal> {
  final GlobalKey _storyKey = GlobalKey();
  bool _isSharing = false;

  int _calculateAge() {
    final now = DateTime.now();
    int birthYear = 2000;
    try {
      birthYear = DateTime.parse(widget.profile.birthDate).year;
    } catch (_) {
      if (widget.profile.birthDate.contains('.')) {
        final parts = widget.profile.birthDate.split('.');
        if (parts.length == 3) birthYear = int.tryParse(parts[2]) ?? 2000;
      }
    }
    return now.year - birthYear;
  }

  Future<void> _shareStory() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _storyKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Render boundary error');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Image data error');
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Solar_Return_${widget.profile.name}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: '☀️ Bugün Güneş Dönüşüm (Solar Return)! Yeni yaşım bana mucizeler getiriyor. Gökyüzü Yapay Zeka ile yıldız haritanı keşfet! ✨🎂',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hikaye oluşturulurken hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge();
    final p = widget.profile;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF130F26),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.starlightGold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.starlightGold.withValues(alpha: 0.25),
              blurRadius: 35,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kapatma
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Hikaye Kartı (9:16 oranında export edilebilir RepaintBoundary)
              RepaintBoundary(
                key: _storyKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      center: Alignment(0, -0.4),
                      radius: 1.2,
                      colors: [
                        Color(0xFF2C1E55),
                        Color(0xFF130A2A),
                        Color(0xFF090414),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.starlightGold.withValues(alpha: 0.8),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Üst Taç ve Emojiler
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('🎂 ', style: TextStyle(fontSize: 26)),
                          Text('☀️ ', style: TextStyle(fontSize: 32)),
                          Text('✨', style: TextStyle(fontSize: 26)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Başlık
                      const Text(
                        'MUTLU YILLAR & SOLAR DÖNÜŞ!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.starlightGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sevgili ${p.name}, Güneş Doğduğun Dereceye Geri Döndü! 🪐',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Yaş ve Büyük Üçlü Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.starlightGold),
                        ),
                        child: Text(
                          '$age. Yaşın Kutlu Olsun! 🌟',
                          style: const TextStyle(
                            color: AppColors.starlightGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Büyük Üçlü
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAstroBadge('Güneş ☉', p.sunSign),
                          _buildAstroBadge('Ay ☽', p.moonSign),
                          _buildAstroBadge('Yükselen ASC', p.risingSign),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Özel Mesaj
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'Astrolojik olarak Güneş Dönüşü (Solar Return), hayatının yeni bir kozmik yılına adım attığın andır. ${p.sunSign} burcunun canlılığı, ${p.risingSign} yükseleninin cesareti ve ${p.moonSign} ayının sezgileri bu yıl seni en yüksek potansiyeline taşıyacak.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Alt İmza
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.auto_awesome, color: AppColors.starlightGold, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Gökyüzü Yapay Zekası • Kozmik Rehber',
                            style: TextStyle(
                              color: AppColors.starlightGold,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Paylaş Butonu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareStory,
                  icon: const Icon(Icons.photo_camera_rounded, color: Colors.black, size: 20),
                  label: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : const Text(
                          'Kozmik Doğum Günü Hikayesini Paylaş (Instagram/WhatsApp)',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.starlightGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAstroBadge(String title, String sign) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 10.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4)),
          ),
          child: Text(
            sign,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
