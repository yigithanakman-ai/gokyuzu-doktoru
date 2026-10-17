// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/referral_service.dart';
import '../../data/services/storage_service.dart';

class ReferralModal extends StatefulWidget {
  final UserProfile profile;

  const ReferralModal({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReferralModal(profile: profile),
    );
  }

  @override
  State<ReferralModal> createState() => _ReferralModalState();
}

class _ReferralModalState extends State<ReferralModal> {
  final TextEditingController _codeController = TextEditingController();
  late String _myReferralCode;
  int _invitedCount = 0;
  int _remainingVipDays = 0;
  bool _hasRedeemed = false;
  bool _hasFreePdf = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _myReferralCode = ReferralService.generateReferralCode(widget.profile);
    _loadReferralData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadReferralData() async {
    final activeCode = await ReferralService.getOrCreateUserReferralCode(widget.profile);
    final count = await ReferralService.getInvitedCount();
    final vipDays = await ReferralService.getRemainingVipGiftDays();
    final redeemed = await ReferralService.hasRedeemedReferral();
    final freePdf = await ReferralService.hasFreePdfGift();

    if (mounted) {
      setState(() {
        _myReferralCode = activeCode;
        _invitedCount = count;
        _remainingVipDays = vipDays;
        _hasRedeemed = redeemed;
        _hasFreePdf = freePdf;
      });
    }
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _myReferralCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Davet kodunuz kopyalandı: $_myReferralCode 📋'),
          backgroundColor: AppColors.starlightGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareCode() async {
    final message = ReferralService.getShareMessage(_myReferralCode);
    await Share.share(message, subject: 'Gökyüzü Astroloji Davet Hediyesi');
    // Paylaşım simülasyonu / teşvik olarak davet kaydı
    await ReferralService.recordSuccessfulInvite();
    await _loadReferralData();
  }

  Future<void> _redeemCode() async {
    final inputCode = _codeController.text.trim();
    if (inputCode.isEmpty) return;

    setState(() => _isSubmitting = true);

    final res = await ReferralService.redeemCode(
      code: inputCode,
      currentProfile: widget.profile,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      final success = res['success'] as bool? ?? false;
      final msg = res['message'] as String? ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppColors.pastelMint : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      if (success) {
        _codeController.clear();
        await _loadReferralData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF130F26),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎁', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arkadaşını Davet Et',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '3 Gün VIP & 10 Sayfalık PDF Rapor Kazan',
                            style: TextStyle(
                              color: AppColors.starlightGold.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
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

              // Kampanya Tanıtım Kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.starlightGold.withValues(alpha: 0.18),
                      const Color(0xFF6B4EE8).withValues(alpha: 0.20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('👑 ', style: TextStyle(fontSize: 18)),
                        Expanded(
                          child: Text(
                            AppTranslationService.tr(
                              'Senin Kazancın: Davet ettiğin her arkadaşın için 3 Günlük Tam VIP Üyelik hediye!',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('📜 ', style: TextStyle(fontSize: 18)),
                        Expanded(
                          child: Text(
                            AppTranslationService.tr(
                              'Arkadaşının Kazancı: Uygulamayı indirdiğinde 10 Sayfalık Kapsamlı Doğum Haritası Raporu (PDF) ücretsiz hediye!',
                            ),
                            style: const TextStyle(
                              color: AppColors.starlightGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Senin Davet Kodun Kutusu
              const Text(
                'Senin Özel Davet Kodun',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _myReferralCode,
                        style: const TextStyle(
                          color: AppColors.starlightGold,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                      tooltip: 'Kodu Kopyala',
                      onPressed: _copyCode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Paylaş Butonu
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _shareCode,
                  icon: const Icon(Icons.share_rounded, color: Colors.black, size: 18),
                  label: const Text(
                    'Bağlantıyı Paylaş (WhatsApp, Instagram)',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.starlightGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Davet İstatistikleri
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Davet Edilenler',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_invitedCount Kişi 👥',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hediye VIP Süren',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _remainingVipDays > 0 ? '$_remainingVipDays Gün Aktif ⭐' : 'Henüz Yok',
                            style: TextStyle(
                              color: _remainingVipDays > 0 ? AppColors.starlightGold : Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Davet Kodu Kullanma Alanı
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              const Text(
                'Bir Arkadaşının Davet Kodunu Gir',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sana iletilen davet kodunu girerek 10 Sayfalık Doğum Haritası Raporu hediyeni anında aktive edebilirsin.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 10),

              if (_hasRedeemed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.pastelMint),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.pastelMint, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _hasFreePdf
                              ? 'Davet hediyen aktif: 10 Sayfalık Doğum Haritası Raporun hazır! 📜'
                              : 'Davet kodu başarıyla kullanıldı.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Örn: GOK-CAN-KO',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.starlightGold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _redeemCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pastelMint,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : const Text(
                              'Onayla',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
