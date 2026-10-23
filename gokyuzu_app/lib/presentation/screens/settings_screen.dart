import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/cloud_account_service.dart';
import '../../data/services/in_app_purchase_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../dialogs/kvkk_dialog.dart';
import '../widgets/vip_upgrade_modal.dart';
import 'legal_document_screen.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile? profile;

  const SettingsScreen({super.key, this.profile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CloudAccount? _cloudAccount;
  String _vipRecoveryKey = '';
  bool _isVip = false;
  VipTier _vipTier = VipTier.free;
  DateTime? _vipExpiryDate;
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final account = await CloudAccountService.getActiveAccount();
    final isVip = await StorageService.isVipUnlocked();
    final tier = await StorageService.getVipTier();
    final notif = await NotificationService.isEnabled();
    final expiry = await StorageService.getVipExpiryDate();

    final profile = widget.profile ?? await StorageService.getProfile();
    final seed = account?.email ?? profile?.name ?? 'gokyuzu_cosmic_user';
    final key = await CloudAccountService.generateVipTransferKey() ??
        await CloudAccountService.getOrCreateVipRecoveryKey(seed);

    if (mounted) {
      setState(() {
        _cloudAccount = account;
        _isVip = isVip;
        _vipTier = tier;
        _notificationsEnabled = notif;
        _vipRecoveryKey = key;
        _vipExpiryDate = expiry;
      });
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return AppTranslationService.tr('Henüz yapılmadı');
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Google Hesabı ile Bağlanma Modalı
  void _showGoogleLinkModal() {
    final emailController = TextEditingController();
    final nameController = TextEditingController(
      text: widget.profile?.name.trim() ?? '',
    );
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF161226),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0xFF4285F4), width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4).withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_circle_rounded,
                          color: Color(0xFF4285F4),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslationService.tr(
                                  'Google Hesabını Bağla & Yedekle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslationService.tr(
                                  'Cihaz değiştiğinde harita ve VIP aktarımı sağlar'),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppTranslationService.tr(
                        'Google Play veya kullandığınız Gmail adresinizi girerek doğum haritanızı, kayıtlı danışanlarınızı ve VIP üyeliğinizi bulut hesabınıza mühürleyebilirsiniz:'),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: AppTranslationService.tr('Gmail / E-Posta'),
                      labelStyle: const TextStyle(color: Colors.white60),
                      hintText: 'ornek@gmail.com',
                      hintStyle: const TextStyle(color: Colors.white24),
                      prefixIcon: const Icon(Icons.mail_outline_rounded,
                          color: Color(0xFF4285F4)),
                      filled: true,
                      fillColor: Colors.white.withAlpha(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: AppTranslationService.tr('İsim / Rumuz (İsteğe bağlı)'),
                      labelStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white.withAlpha(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty ||
                            !email.contains('@') ||
                            !email.contains('.')) {
                          setModalState(() {
                            errorText = AppTranslationService.tr(
                                'Lütfen geçerli bir e-posta adresi girin.');
                          });
                          return;
                        }
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        final acc = await CloudAccountService.linkGoogleAccount(
                          email: email,
                          displayName: nameController.text.trim().isEmpty
                              ? null
                              : nameController.text.trim(),
                        );
                        await _loadState();
                        setState(() => _isLoading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AppTranslationService.tr("✅ Google hesabı başarıyla bağlandı:")} ${acc.email}\n${AppTranslationService.tr("Doğum haritanız ve VIP bilgileriniz buluta yedeklendi.")}',
                              ),
                              backgroundColor: const Color(0xFF4285F4),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.cloud_done_rounded, size: 20),
                      label: Text(
                        AppTranslationService.tr('Hesabı Bağla ve Yedekle'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Farklı Cihazdan VIP Lisans Anahtarı Girme Modalı
  void _showVipKeyRestoreModal() {
    final keyController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF161226),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: AppColors.starlightGold, width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          color: AppColors.starlightGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppTranslationService.tr(
                              'VIP Lisans Anahtarını Gir (Android ➔ iOS)'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppTranslationService.tr(
                        'Eski telefonunuzdaki Gökyüzü Doktoru uygulamasından kopyaladığınız VIP Transfer Anahtarını (GKY-VIP-xxxx-xxxx) veya fatura kodunuzu buraya yapıştırarak üyeliğinizi bu cihaza aktarabilirsiniz:'),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: keyController,
                    style: const TextStyle(
                      color: AppColors.starlightGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'GKY-VIP-xxxx-xxxx',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withAlpha(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.starlightGold,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final key = keyController.text.trim();
                        if (key.isEmpty) {
                          setModalState(() {
                            errorText = AppTranslationService.tr(
                                'Lütfen geçerli bir anahtar girin.');
                          });
                          return;
                        }
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        final result = await CloudAccountService
                            .redeemVipTransferKey(key);
                        await _loadState();
                        setState(() => _isLoading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.message),
                              backgroundColor: result.success
                                  ? const Color(0xFF6C5CE7)
                                  : Colors.redAccent,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        AppTranslationService.tr('VIP Lisansını Aktif Et'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslationService.currentLangNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0C0A14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF140F24),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppTranslationService.tr('Ayarlar & Hesap Yönetimi'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.starlightGold,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  children: [
                    _buildCloudSyncSection(),
                    const SizedBox(height: 20),
                    _buildVipManagementSection(),
                    const SizedBox(height: 20),
                    _buildNotificationSection(),
                    const SizedBox(height: 20),
                    _buildLanguageSection(currentLang),
                    const SizedBox(height: 20),
                    _buildLegalSection(),
                    const SizedBox(height: 20),
                    _buildDangerZone(),
                    const SizedBox(height: 30),
                    _buildFooter(),
                  ],
                ),
        );
      },
    );
  }

  // 1. Bulut Hesabı & Cihaz Değişimi Yedekleme Bölümü
  Widget _buildCloudSyncSection() {
    final isLinked = _cloudAccount != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLinked
              ? const Color(0xFF4285F4).withAlpha(120)
              : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_sync_rounded,
                  color: Color(0xFF4285F4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslationService.tr('Bulut Hesabı & Cihaz Değişimi'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isLinked
                          ? AppTranslationService.tr('Hesap bağlı ve senkronize')
                          : AppTranslationService.tr('Misafir Modu • Bağlı hesap yok'),
                      style: TextStyle(
                        color: isLinked
                            ? const Color(0xFF4285F4)
                            : Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLinked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4285F4)),
                  ),
                  child: const Text(
                    'Google',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLinked) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          size: 16, color: Color(0xFF4285F4)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _cloudAccount!.email,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslationService.tr('Son Bulut Yedeği:'),
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11),
                      ),
                      Text(
                        _formatDateTime(_cloudAccount!.lastBackupAt),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4285F4)),
                      foregroundColor: const Color(0xFF4285F4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await CloudAccountService.backupToCloud();
                      await _loadState();
                      setState(() => _isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppTranslationService.tr(
                                '☁️ Haritalarınız ve VIP bilgileriniz buluta başarıyla yedeklendi!')),
                            backgroundColor: const Color(0xFF4285F4),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                    label: Text(
                      AppTranslationService.tr('Şimdi Yedekle'),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00E5FF)),
                      foregroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      final success =
                          await CloudAccountService.restoreFromCloud();
                      await _loadState();
                      setState(() => _isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? AppTranslationService.tr(
                                      '📥 Buluttaki harita ve VIP verileriniz cihaza geri yüklendi!')
                                  : AppTranslationService.tr(
                                      'ℹ️ Bulutta yedek bulunamadı; mağaza satın alımları sorgulandı.'),
                            ),
                            backgroundColor: success
                                ? const Color(0xFF00E5FF)
                                : Colors.amber,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_download_rounded, size: 16),
                    label: Text(
                      AppTranslationService.tr('Geri Yükle'),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () async {
                  await CloudAccountService.unlinkAccount();
                  await _loadState();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTranslationService.tr(
                            'Hesap bağlantısı kaldırıldı. Verileriniz bu cihazda korunmaktadır.')),
                      ),
                    );
                  }
                },
                child: Text(
                  AppTranslationService.tr('Hesap Bağlantısını Kaldır'),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),
          ] else ...[
            Text(
              AppTranslationService.tr(
                  'Telefonunuzu değiştirdiğinizde (Android\'den başka bir Android\'e veya Android\'den iPhone\'a) doğum haritanızı, danışan arşivinizi ve VIP üyeliğinizi tek tıkla geri alabilmek için Google hesabınızı bağlayın:'),
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11.5, height: 1.45),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showGoogleLinkModal,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: Text(
                  AppTranslationService.tr('Google ile Hesabı Bağla & Yedekle'),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const Divider(color: Colors.white12, height: 26),
          // Çapraz Platform VIP Lisans Anahtarı Kutusu
          Row(
            children: [
              const Icon(Icons.key_rounded,
                  color: AppColors.starlightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppTranslationService.tr('VIP Transfer Anahtarınız (Android ➔ iOS):'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_isVip && _vipExpiryDate != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.starlightGold.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.starlightGold.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.starlightGold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppTranslationService.tr("Kalan Süre:")} ${_vipExpiryDate!.difference(DateTime.now()).inDays.clamp(0, 3650)} ${AppTranslationService.tr("gün")} (${_vipExpiryDate!.day.toString().padLeft(2, "0")}.${_vipExpiryDate!.month.toString().padLeft(2, "0")}.${_vipExpiryDate!.year})',
                      style: const TextStyle(
                        color: AppColors.starlightGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.starlightGold.withAlpha(60)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _vipRecoveryKey.isEmpty ? 'GKY-VIP-...' : _vipRecoveryKey,
                    style: const TextStyle(
                      color: AppColors.starlightGold,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      color: AppColors.starlightGold, size: 18),
                  tooltip: AppTranslationService.tr('Kopyala'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _vipRecoveryKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTranslationService.tr(
                            'VIP transfer anahtarı panoya kopyalandı! Yeni telefonunuzda bu anahtarı girerek kalan sürenizi aktarabilirsiniz.')),
                        backgroundColor: const Color(0xFF6C5CE7),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppTranslationService.tr(
              '⚠️ Bu anahtar kişiye özel ve tek kullanımlıktır. Yeni cihazınıza aktarıldığında üyeliğiniz tam kalan süresiyle aktif edilir (sil baştan yıl verilmez) ve anahtar kullanılmış olarak mühürlenir.',
            ),
            style: const TextStyle(
                color: Colors.white54, fontSize: 10.5, height: 1.35),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslationService.tr('Başka bir cihazdan mı geçtiniz?'),
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              TextButton(
                onPressed: _showVipKeyRestoreModal,
                child: Text(
                  AppTranslationService.tr('VIP Anahtarını Gir'),
                  style: const TextStyle(
                    color: AppColors.starlightGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. VIP Üyelik & Abonelik Yönetimi Bölümü
  Widget _buildVipManagementSection() {
    final tierName = _vipTier == VipTier.platinum
        ? 'Platinum VIP'
        : (_vipTier == VipTier.gold
            ? 'Gold VIP'
            : (_vipTier == VipTier.silver ? 'Silver VIP' : 'Ücretsiz Üyelik'));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isVip
              ? AppColors.starlightGold.withAlpha(120)
              : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.starlightGold.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.starlightGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslationService.tr('VIP Üyelik & Abonelik'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tierName,
                      style: TextStyle(
                        color: _isVip
                            ? AppColors.starlightGold
                            : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.starlightGold,
                  foregroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  VipUpgradeModal.show(context, onPurchased: () => _loadState());
                },
                child: Text(
                  _isVip
                      ? AppTranslationService.tr('Paketler')
                      : AppTranslationService.tr('VIP Ol'),
                  style: const TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    foregroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await InAppPurchaseService.instance.restorePurchases();
                    await _loadState();
                    setState(() => _isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppTranslationService.tr(
                              'Google Play / App Store mağaza abonelikleriniz sorgulandı ve yenilendi.')),
                          backgroundColor: const Color(0xFF6C5CE7),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    AppTranslationService.tr('Satın Alımları Geri Yükle'),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    foregroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      InAppPurchaseService.openStoreSubscriptionPage(),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    AppTranslationService.tr('Aboneliği Yönet'),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Kozmik Bildirim Ayarları
  Widget _buildNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF00E5FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslationService.tr('Canlı Gökyüzü Bildirimleri'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppTranslationService.tr(
                          'Kilit ekranı ve uyku modunda kesintisiz akış'),
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                activeThumbColor: const Color(0xFF00E5FF),
                onChanged: (val) async {
                  if (val) {
                    final profile =
                        widget.profile ?? await StorageService.getProfile();
                    if (profile != null) {
                      await NotificationService.requestPermissionAndEnable(
                        profile,
                        sendImmediateConfirmation: false,
                      );
                    }
                  } else {
                    await NotificationService.disableNotifications();
                  }
                  await _loadState();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppTranslationService.tr(
                '• 09:30 Günlük Transit & Güneş/Ay Burcu\n• 14:30 Gün Ortası Ay & Boşlukta Rehberi\n• 20:30 Gece Gökyüzü & Canlı Açılar\n• Anlık Ay burcu ve 28 menzil geçiş alarmları'),
            style: const TextStyle(
                color: Colors.white60, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00E5FF)),
                foregroundColor: const Color(0xFF00E5FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final profile =
                    widget.profile ?? await StorageService.getProfile();
                if (profile != null) {
                  await NotificationService.sendTestOrDailyNotification(
                    profile,
                    isWelcome: false,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTranslationService.tr(
                            '🔔 Canlı test bildirimi telefonunuza iletildi!')),
                        backgroundColor: const Color(0xFF00E5FF),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(
                AppTranslationService.tr('Test Bildirimi Gönder'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Dil Seçimi
  Widget _buildLanguageSection(String currentLang) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.purpleAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppTranslationService.tr('Uygulama Dili / Language'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildLangButton('tr', '🇹🇷 Türkçe', currentLang == 'tr'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLangButton('en', '🇬🇧 English', currentLang == 'en'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLangButton('ja', '🇯🇵 日本語', currentLang == 'ja'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String code, String label, bool isSelected) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF6C5CE7) : Colors.white.withAlpha(12),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.white12,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onPressed: () {
        AppTranslationService.setLanguage(code);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // 5. Yasal Bilgilendirme & KVKK
  Widget _buildLegalSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.tealAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppTranslationService.tr('Yasal Mevzuat & KVKK'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegalTile(
            title: AppTranslationService.tr('KVKK Aydınlatma Metni'),
            onTap: () => KvkkDialog.show(context),
          ),
          _buildLegalTile(
            title: AppTranslationService.tr('Gizlilik Politikası (Privacy Policy)'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                    type: LegalDocType.privacy),
              ),
            ),
          ),
          _buildLegalTile(
            title: AppTranslationService.tr('Kullanıcı Sözleşmesi & Şartlar'),
            onTap: () => KvkkDialog.showTerms(context),
          ),
          _buildLegalTile(
            title: AppTranslationService.tr('Mesafeli Satış & İade Koşulları'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                    type: LegalDocType.salesAndRefund),
              ),
            ),
          ),
          _buildLegalTile(
            title: AppTranslationService.tr('Yasal Sorumluluk Reddi (Disclaimer)'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                    type: LegalDocType.disclaimer),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile({required String title, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white30, size: 14),
        onTap: onTap,
      ),
    );
  }

  // 6. Tehlikeli Bölge: Hesabı ve Verileri Kalıcı Sil
  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF221118),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE74C3C).withAlpha(100), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFE74C3C),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppTranslationService.tr('Tehlikeli Bölge'),
                style: const TextStyle(
                  color: Color(0xFFE74C3C),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppTranslationService.tr(
                '6698 sayılı KVKK ve Apple App Store 5.1.1 kuralı uyarınca; bu cihazdaki tüm doğum verilerinizi, danışan arşivinizi ve bulut yedeklerinizi kalıcı olarak silebilirsiniz.'),
            style: const TextStyle(
                color: Colors.white60, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE74C3C)),
                foregroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF191428),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                          color: Color(0xFFE74C3C), width: 1.2),
                    ),
                    title: Text(
                      AppTranslationService.tr('Tüm Verileri Kalıcı Olarak Sil?'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    content: Text(
                      AppTranslationService.tr(
                          'Bu işlem geri alınamaz. Kayıtlı doğum haritanız, danışan arşiviniz ve tüm yerel/bulut eşlemeleriniz silinecektir.'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(AppTranslationService.tr('Vazgeç'),
                            style: const TextStyle(color: Colors.white60)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await CloudAccountService.unlinkAccount();
                          await StorageService.clearAll();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const AuthScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Text(AppTranslationService.tr('Evet, Kalıcı Olarak Sil')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: Text(
                AppTranslationService.tr('Hesabı ve Verileri Kalıcı Olarak Sil'),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Footer
  Widget _buildFooter() {
    return Column(
      children: [
        Image.asset(
          'assets/icon/app_icon.png',
          width: 38,
          height: 38,
          errorBuilder: (_, _, _) => const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.starlightGold,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gökyüzü Doktoru AI • v1.0.14+20',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Swiss Ephemeris JPL DE441 Astrological Engine Standard',
          style: TextStyle(color: Colors.white30, fontSize: 10),
        ),
      ],
    );
  }
}
