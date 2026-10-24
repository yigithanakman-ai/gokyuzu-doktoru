import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/cloud_account_service.dart';
import '../dialogs/kvkk_dialog.dart';
import 'onboarding_input_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Kayıt Formu Controller'ları
  final _registerNameController = TextEditingController();
  final _registerSurnameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  String _selectedGender = 'Erkek';
  bool _obscureRegisterPassword = true;

  // Giriş Formu Controller'ları
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  // Yasal Onay Zorunlu Tik
  bool _kvkkApproved = false;

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Varsayılan: Yeni Üye Ol
  }

  @override
  void dispose() {
    _tabController.dispose();
    _registerNameController.dispose();
    _registerSurnameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  bool _checkConsent() {
    if (!_kvkkApproved) {
      setState(() {
        _errorMessage = AppTranslationService.tr(
          '⚠️ Yasal Onay Zorunludur: İçeriye giriş yapabilmek için lütfen KVKK Aydınlatma Metni ve Kullanıcı Sözleşmesi\'ni okuyup onay kutucuğunu (tik) işaretleyiniz.',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslationService.tr(
              'Lütfen devam etmeden önce Kullanım Sözleşmesi ve KVKK onay kutucuğunu işaretleyin.',
            ),
          ),
          backgroundColor: Colors.amber,
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _proceedToApp() async {
    final profile = await StorageService.getProfile();
    if (!mounted) return;
    if (profile != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingInputScreen()),
      );
    }
  }

  bool _isValidEmail(String email) {
    if (!email.contains('@')) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _handleRegister() async {
    if (!_checkConsent()) return;

    final name = _registerNameController.text.trim();
    final surname = _registerSurnameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;

    if (name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = AppTranslationService.tr('Lütfen tüm alanları eksiksiz doldurunuz.'));
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = AppTranslationService.tr(
          'Lütfen geçerli bir e-posta adresi giriniz (örnek: ad@soyad.com). @ işareti ve geçerli alan adı zorunludur.'));
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    await StorageService.saveUserAccount(
      name: name,
      surname: surname,
      email: email,
      gender: _selectedGender,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    _proceedToApp();
  }

  void _handleLogin() async {
    if (!_checkConsent()) return;

    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = AppTranslationService.tr('Lütfen e-posta ve şifrenizi giriniz.'));
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = AppTranslationService.tr(
          'Lütfen geçerli bir e-posta adresi giriniz (örnek: ad@soyad.com). @ işareti ve geçerli alan adı zorunludur.'));
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);
    _proceedToApp();
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_checkConsent()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final account = await CloudAccountService.signInWithNativeGoogleAccount();
      if (!mounted) return;

      if (account != null && account.email.contains('@')) {
        final chosenEmail = account.email.trim();
        final localPart = chosenEmail.split('@').first;
        final parts = localPart.split(RegExp(r'[._\-]'));
        final inferredName = _registerNameController.text.trim().isNotEmpty
            ? _registerNameController.text.trim()
            : (parts.isNotEmpty && parts.first.isNotEmpty
                ? '${parts.first[0].toUpperCase()}${parts.first.substring(1)}'
                : 'Kozmik');
        final inferredSurname = _registerSurnameController.text.trim().isNotEmpty
            ? _registerSurnameController.text.trim()
            : (parts.length > 1 && parts[1].isNotEmpty
                ? '${parts[1][0].toUpperCase()}${parts[1].substring(1)}'
                : 'Gezgin');

        await StorageService.saveUserAccount(
          name: inferredName,
          surname: inferredSurname,
          email: chosenEmail,
          gender: _selectedGender,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Google (Gmail) hesabınız bağlandı: $chosenEmail',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        _proceedToApp();
        return;
      }

      setState(() => _isLoading = false);
      _showManualGmailInputDialog();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showManualGmailInputDialog();
    }
  }

  void _showManualGmailInputDialog() {
    final gmailCtrl = TextEditingController(
      text: _loginEmailController.text.trim().isNotEmpty
          ? _loginEmailController.text.trim()
          : _registerEmailController.text.trim(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191528),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.mail_rounded, color: AppColors.starlightGold, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gmail Hesabınızla Giriş Yapın',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Google Play aboneliklerinizin ve harita yedeklerinizin eşleşmesi için gerçek Gmail adresinizi giriniz:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'ornek@gmail.com',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.starlightGold, size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = gmailCtrl.text.trim();
              if (!_isValidEmail(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen geçerli bir Gmail / e-posta adresi giriniz.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              Navigator.of(ctx).pop();
              await CloudAccountService.linkGoogleAccount(
                email: email,
                displayName: _registerNameController.text.trim().isNotEmpty
                    ? _registerNameController.text.trim()
                    : email.split('@').first,
              );
              await StorageService.saveUserAccount(
                name: _registerNameController.text.trim().isNotEmpty
                    ? _registerNameController.text.trim()
                    : email.split('@').first,
                surname: _registerSurnameController.text.trim(),
                email: email,
                gender: _selectedGender,
              );
              if (!mounted) return;
              _proceedToApp();
            },
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Gmail ile Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.07),
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.starlightGold, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Text(
            'G',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
        label: Text(
          AppTranslationService.tr('Google (Gmail) ile Gerçek Hesap Seç & Giriş Yap'),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Language Switcher Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLangChip('tr', '🇹🇷 TR'),
                            const SizedBox(width: 4),
                            _buildLangChip('en', '🇬🇧 EN'),
                            const SizedBox(width: 4),
                            _buildLangChip('ja', '🇯🇵 JA'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // App Emblem
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [AppColors.starlightGold, Color(0xFF3B2F04)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.starlightGold.withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('⚕️', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslationService.tr('GÖKYÜZÜ DOKTORU'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.starlightGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTranslationService.tr('Kozmik Doğum Haritası ve Gökyüzü Portalı'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.savageRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.savageRed.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.savageRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Tab Bar (Yeni Üye Ol / Giriş Yap)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.starlightGold.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.6)),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.starlightGold,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(text: AppTranslationService.tr('Giriş Yap')),
                        Tab(text: AppTranslationService.tr('Yeni Üye Ol')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tab Bar Views (Nested in Column)
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      if (_tabController.index == 0) {
                        return _buildLoginForm();
                      } else {
                        return _buildRegisterForm();
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  // Guest Bypass with mandatory consent check
                  TextButton(
                    onPressed: () {
                      if (!_checkConsent()) return;
                      _proceedToApp();
                    },
                    child: Text(
                      AppTranslationService.tr('Misafir Olarak Haritaya Devam Et →'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  // Yasal Linkler Barı
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildLegalLink(AppTranslationService.tr('Tüm Yasal Metinler'),
                          () => KvkkDialog.showAllLegalMenu(context),
                          isHighlight: true),
                      _buildDotSeparator(),
                      _buildLegalLink(AppTranslationService.tr('Gizlilik'),
                          () => KvkkDialog.showPrivacyPolicy(context)),
                      _buildDotSeparator(),
                      _buildLegalLink(AppTranslationService.tr('KVKK'), () => KvkkDialog.show(context)),
                      _buildDotSeparator(),
                      _buildLegalLink(AppTranslationService.tr('Kullanım Koşulları'),
                          () => KvkkDialog.showTerms(context)),
                      _buildDotSeparator(),
                      _buildLegalLink(AppTranslationService.tr('Mesafeli Satış & İade'),
                          () => KvkkDialog.showSalesAndRefund(context)),
                      _buildDotSeparator(),
                      _buildLegalLink(AppTranslationService.tr('Sorumluluk Reddi'),
                          () => KvkkDialog.showDisclaimer(context)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Yasal Sorumluluk Reddi Bilgilendirme Kutusu
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      AppTranslationService.tr(
                        'Astrolojik içerikler öz farkındalık ve eğlence amaçlıdır; tıbbi, psikolojik, finansal veya hukuki danışmanlık yerine geçmez.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Colors.white38,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = AppTranslationService.currentLang == code;
    return InkWell(
      onTap: () async {
        await AppTranslationService.setLanguage(code);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.starlightGold.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.starlightGold : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.starlightGold : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildConsentBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kvkkApproved
            ? AppColors.pastelMint.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _kvkkApproved
              ? AppColors.pastelMint.withValues(alpha: 0.45)
              : Colors.white24,
          width: _kvkkApproved ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _kvkkApproved,
            activeColor: AppColors.pastelMint,
            checkColor: Colors.black,
            onChanged: (val) {
              setState(() {
                _kvkkApproved = val ?? false;
                if (_kvkkApproved) _errorMessage = null;
              });
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _kvkkApproved = !_kvkkApproved;
                  if (_kvkkApproved) _errorMessage = null;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (AppTranslationService.currentLang == 'tr')
                        Text(
                          AppTranslationService.tr('6698 sayılı '),
                          style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                        ),
                      GestureDetector(
                        onTap: () => KvkkDialog.show(context),
                        child: Text(
                          AppTranslationService.tr('KVKK Aydınlatma Metni'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.starlightGold,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        AppTranslationService.tr(' ve '),
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => KvkkDialog.showTerms(context),
                        child: Text(
                          AppTranslationService.tr('Kullanıcı Sözleşmesi'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.starlightGold,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        AppTranslationService.tr('\'ni okudum, anladım ve kabul ediyorum. *'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTranslationService.tr(
                      'Kişisel verileriniz ve astrolojik profil bilgileriniz cihazınızda güvenle işlenir.',
                    ),
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _registerNameController,
                label: AppTranslationService.tr('Ad *'),
                hint: 'Yiğithan',
                icon: Icons.person_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _registerSurnameController,
                label: AppTranslationService.tr('Soyad *'),
                hint: 'Akman',
                icon: Icons.badge_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _registerEmailController,
          label: AppTranslationService.tr('E-posta Adresi *'),
          hint: 'ornek@email.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _registerPasswordController,
          label: AppTranslationService.tr('Şifre Belirleyin *'),
          hint: '••••••••',
          icon: Icons.lock_rounded,
          obscureText: _obscureRegisterPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegisterPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
          ),
        ),
        const SizedBox(height: 14),

        // Cinsiyet Seçimi
        Text(
          AppTranslationService.tr('Cinsiyet *'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: ['Erkek', 'Kadın', 'Diğer'].map((g) {
            final isSelected = _selectedGender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  AppTranslationService.tr(g),
                  style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.white70),
                ),
                selected: isSelected,
                selectedColor: AppColors.starlightGold,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                onSelected: (val) {
                  if (val) setState(() => _selectedGender = g);
                },
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // YASAL ONAY KUTUSU (FORMUN VE EKRANIN ALTINDA, BUTONUN HEMEN ÜSTÜNDE)
        _buildConsentBox(),

        const SizedBox(height: 18),

        // Hesap Oluştur Butonu
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    AppTranslationService.tr('Hesap Oluştur & Haritaya Başla'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _buildGoogleSignInButton(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _loginEmailController,
          label: AppTranslationService.tr('E-posta Adresi *'),
          hint: 'ornek@email.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _loginPasswordController,
          label: AppTranslationService.tr('Şifre *'),
          hint: '••••••••',
          icon: Icons.lock_rounded,
          obscureText: _obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
        ),
        const SizedBox(height: 16),

        // YASAL ONAY KUTUSU (FORMUN VE EKRANIN ALTINDA, BUTONUN HEMEN ÜSTÜNDE)
        _buildConsentBox(),

        const SizedBox(height: 18),

        // Giriş Yap Butonu
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starlightGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    AppTranslationService.tr('Giriş Yap'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _buildGoogleSignInButton(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.starlightGold, size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap, {bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          color: isHighlight ? AppColors.starlightGold : Colors.white60,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildDotSeparator() {
    return const Text(
      '·',
      style: TextStyle(fontSize: 12, color: Colors.white24, fontWeight: FontWeight.bold),
    );
  }
}
