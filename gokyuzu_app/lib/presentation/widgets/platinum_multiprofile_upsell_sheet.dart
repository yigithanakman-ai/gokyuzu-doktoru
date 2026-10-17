import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/app_translation_service.dart';

void showPlatinumMultiProfileUpsellSheet(BuildContext context, {String? targetProfileName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PlatinumMultiProfileUpsellSheet(targetProfileName: targetProfileName),
  );
}

class PlatinumMultiProfileUpsellSheet extends StatelessWidget {
  final String? targetProfileName;

  const PlatinumMultiProfileUpsellSheet({super.key, this.targetProfileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF13101E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.starlightGold, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x77FFD700),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Crown & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.starlightGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 28,
                    color: AppColors.starlightGold,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP PLATINUM AYRICALIĞI',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.starlightGold,
                      ),
                    ),
                    Text(
                      'Çoklu Harita & Danışan Yönetimi',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (targetProfileName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.pastelLavender),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$targetProfileName haritasını aktif bağlam olarak kullanmak ve tüm analizleri bu kişi adına üretmek VIP Platinum gerektirir.',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Feature Highlights
            _buildFeatureTile(
              icon: Icons.sync_rounded,
              title: 'Tek Dokunuşla Profil Değiştirme',
              subtitle: 'Çocuklarınız, eşiniz veya danışanlarınızın haritaları arasında anında geçiş yapın. Ana sayfa ve tüm hesaplamalar o kişiye göre güncellensin.',
            ),
            const SizedBox(height: 10),
            _buildFeatureTile(
              icon: Icons.picture_as_pdf_rounded,
              title: '10 Sayfalık Kapsamlı PDF Raporları',
              subtitle: 'Arşivdeki tüm kayıtlı haritalar için sınırsız kadersel yaşam kitapçığı ve öngörü PDF\'leri oluşturup indirin.',
            ),
            const SizedBox(height: 10),
            _buildFeatureTile(
              icon: Icons.auto_awesome_rounded,
              title: 'Solar Fire & Astro Gold Seviyesi',
              subtitle: 'Solar Return (Güneş Dönüşü), İkincil İlerletimler (Progress) ve Firdaria döngülerini seçilen kişinin doğum anına göre çıkarın.',
            ),
            const SizedBox(height: 16),

            // INCENTIVE BANNER (+1 PDF GIFT)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                    const Color(0xFFFFD700).withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎁', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ÖZEL PLATINUM HEDİYESİ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Şimdi VIP Platinum\'a Geçin, Hesabınıza +1 Ekstra Kapsamlı 10 Sayfalık PDF Raporu Hediye Edilsin!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Upgrade and Close Action Buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.starlightGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
              onPressed: () async {
                await StorageService.setVipTier(VipTier.platinum);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🎉 Tebrikler! VIP Platinum üyeliğiniz ve +1 Hediye PDF raporunuz aktif edildi.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Color(0xFF6C5CE7),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.workspace_premium_rounded, size: 20),
              label: const Text(
                'VIP Platinum\'a Yükselt 👑',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(AppTranslationService.tr('Daha Sonra')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.pastelLavender.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.pastelLavender),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.white60,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
