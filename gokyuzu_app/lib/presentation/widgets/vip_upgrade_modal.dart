import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/in_app_purchase_service.dart';
import '../../data/services/storage_service.dart';

class VipUpgradeModal extends StatefulWidget {
  final VipTier? preselectedTier;
  final VoidCallback? onPurchased;

  const VipUpgradeModal({
    super.key,
    this.preselectedTier,
    this.onPurchased,
  });

  static Future<void> show(
    BuildContext context, {
    VipTier? preselectedTier,
    VoidCallback? onPurchased,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VipUpgradeModal(
        preselectedTier: preselectedTier,
        onPurchased: onPurchased,
      ),
    );
  }

  @override
  State<VipUpgradeModal> createState() => _VipUpgradeModalState();
}

class _VipUpgradeModalState extends State<VipUpgradeModal> {
  int _secretTapCount = 0;
  DateTime? _lastTapTime;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    InAppPurchaseService.instance.loadProducts().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onCrownSecretTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) < const Duration(milliseconds: 900)) {
      _secretTapCount++;
    } else {
      _secretTapCount = 1;
    }
    _lastTapTime = now;

    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      _showSecretAdminDialog();
    }
  }

  void _showSecretAdminDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B162B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
        ),
        title: const Row(
          children: [
            Text('👑', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'Patron Yönetici Girişi',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yalnızca geliştirici ve sistem yönetimi içindir:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              style: const TextStyle(color: AppColors.starlightGold, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Yönetici Kodunu Girin',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black38,
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
            child: const Text('Kapat', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final ok = await StorageService.activateVipCode(codeCtrl.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (ok) {
                if (mounted) {
                  Navigator.of(context).pop();
                  widget.onPurchased?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Tebrikler Patron! VIP Platinum üyeliğiniz aktif edildi 👑'),
                      backgroundColor: Color(0xFF1D5A3A),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Geçersiz yönetici kodu.'),
                      backgroundColor: AppColors.savageRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Aktif Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePackageSelection(
    String productId,
    String packageName,
    VipTier tier,
  ) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final storeName = Platform.isIOS ? 'Apple App Store' : 'Google Play Store';
      debugPrint('[VipUpgradeModal] $packageName ($productId) seçildi. $storeName oturumu açılıyor...');

      final initiated = await InAppPurchaseService.instance.buySubscription(productId, tier);

      if (!initiated) {
        // Mağazanın doğrudan abonelik sayfasına yönlendirildi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.shopping_bag_rounded, color: AppColors.starlightGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$storeName abonelik sayfası açılıyor...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF221C38),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[VipUpgradeModal] Satın alma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem başlatılırken bir hata oluştu: $e'),
            backgroundColor: AppColors.savageRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeLabel = Platform.isIOS
        ? 'Apple App Store Güvencesiyle Resmi Abonelik'
        : 'Google Play Store Güvencesiyle Resmi Abonelik';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF13111C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFD166), width: 1.2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _onCrownSecretTap,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.starlightGold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.starlightGold,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslationService.tr('VIP KOZMİK ABONELİK PAKETLERİ'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.starlightGold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        storeLabel,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              children: [
                // VIP Benefits Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.starlightGold.withValues(alpha: 0.14),
                        AppColors.pastelLavender.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.35)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ VIP Üyelik Ayrıcalıkları:',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _BenefitItem('10 Sayfalık Kapsamlı Harita Kitapçığı (PDF İndirme)'),
                      _BenefitItem('Sınırsız Harita Arşivi & 3 Kişi Başa Sabitleme (Pinleme)'),
                      _BenefitItem('Kozmik Günlük (Astro-Journal) & Hatırlatıcılar'),
                      _BenefitItem('72 Kabala Meleği, Dekanlar, Çakralar & Sabit Yıldızlar'),
                      _BenefitItem('Sinastri, Lunar Return & Majör Yaşam Döngüleri'),
                      _BenefitItem('Secondary Progress (İlerletilmiş ASC), Solar Arc & Kabala Ağacı'),
                      _BenefitItem('%100 Reklamsız, Kesintisiz ve Hızlı Deneyim'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Abonelik Seçenekleri (Doğrudan Mağaza Ödemesi):',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Paket 1: Platinum Yıllık
                _buildPackageCard(
                  title: 'Platinum VIP (Yıllık İndirimli)',
                  price: '4.199 ₺ / yıl',
                  period: '12 Ay Peşin (Aylık ~10\$)',
                  badge: '%25 İNDİRİM 👑',
                  badgeColor: AppColors.starlightGold,
                  isHighlight: true,
                  features: 'HER ŞEY AÇIK • Sınırsız PDF • Tüm Kozmik Modüller & İleri Öngörüler • Sıfır Reklam',
                  onTap: () => _handlePackageSelection(
                    InAppPurchaseService.platinumYearId,
                    'Platinum VIP (Yıllık)',
                    VipTier.platinum,
                  ),
                ),
                const SizedBox(height: 10),

                // Paket 2: Platinum Aylık
                _buildPackageCard(
                  title: 'Platinum VIP (Aylık)',
                  price: '459 ₺ / ay',
                  period: 'Aylık Abonelik (13\$)',
                  badge: 'TAM ERİŞİM 💎',
                  badgeColor: AppColors.starlightGold,
                  isHighlight: false,
                  features: 'HER ŞEY AÇIK • Sınırsız PDF • Tüm Modüller & Derin Analizler • Sıfır Reklam',
                  onTap: () => _handlePackageSelection(
                    InAppPurchaseService.platinumMonthId,
                    'Platinum VIP (Aylık)',
                    VipTier.platinum,
                  ),
                ),
                const SizedBox(height: 10),

                // Paket 3: Gold Aylık
                _buildPackageCard(
                  title: 'Gold VIP (Altın Paket)',
                  price: '319 ₺ / ay',
                  period: 'Aylık Abonelik (9\$)',
                  badge: 'EN POPÜLER ⭐',
                  badgeColor: AppColors.pastelMint,
                  isHighlight: false,
                  features: 'Ayda 2 PDF • Sinastri, Lunar Return, Yaşam Döngüleri, Tam Harita Çarkı • Sıfır Reklam',
                  onTap: () => _handlePackageSelection(
                    InAppPurchaseService.goldMonthId,
                    'Gold VIP (Aylık)',
                    VipTier.gold,
                  ),
                ),
                const SizedBox(height: 10),

                // Paket 4: Silver Aylık
                _buildPackageCard(
                  title: 'Silver VIP (Gümüş Paket)',
                  price: '179 ₺ / ay',
                  period: 'Aylık Abonelik (5\$)',
                  badge: 'BAŞLANGIÇ 🌙',
                  badgeColor: AppColors.pastelLavender,
                  isHighlight: false,
                  features: 'Ayda 1 PDF • Melekler, Dekanlar, Çakralar, Sabitler, Tam Harita & Anasayfa • Sıfır Reklam',
                  onTap: () => _handlePackageSelection(
                    InAppPurchaseService.silverMonthId,
                    'Silver VIP (Aylık)',
                    VipTier.silver,
                  ),
                ),
                const SizedBox(height: 18),

                // Restore Purchases
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await InAppPurchaseService.instance.restorePurchases();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Satın alımlarınız kontrol ediliyor ve güncelleniyor...'),
                            backgroundColor: Color(0xFF221C38),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.restore_rounded, size: 16, color: Colors.white54),
                    label: const Text(
                      'Satın Alımları Geri Yükle',
                      style: TextStyle(fontSize: 11.5, color: Colors.white60),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    required String period,
    required String badge,
    required Color badgeColor,
    required bool isHighlight,
    required String features,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFF1E1A2C)
            : const Color(0xFF181524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight
              ? AppColors.starlightGold
              : Colors.white12,
          width: isHighlight ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  features,
                  style: const TextStyle(fontSize: 11, color: Colors.white60, height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                          ),
                        ),
                        Text(
                          period,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHighlight ? AppColors.starlightGold : Colors.white12,
                        foregroundColor: isHighlight ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(
                        isHighlight ? 'Hemen Abone Ol' : 'Seç',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;
  const _BenefitItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.pastelMint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
