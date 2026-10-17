import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/app_translation_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _selectedLang = 'tr';
  bool _navigating = false;

  final Map<String, Map<String, String>> _translations = {
    'tr': {
      'title': 'GÖKYÜZÜ DOKTORU',
      'subtitle': 'Geocentric & Placidus Profesyonel Doğum Haritası Sistemi',
      'langPrompt': 'Lütfen Kullanmak İstediğiniz Dili Seçiniz',
      'start': 'Uygulamaya Giriş Yap',
    },
    'en': {
      'title': 'SKY DOCTOR',
      'subtitle': 'Professional Geocentric & Placidus Natal Chart Analysis',
      'langPrompt': 'Please Select Your Preferred Language',
      'start': 'Enter Application',
    },
    'ja': {
      'title': '天空のドクター',
      'subtitle': '高精度ジオセントリック・プラシーダス出生図解析システム',
      'langPrompt': '言語を選択してください',
      'start': 'アプリを開始する',
    },
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.repeat(reverse: true);
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await StorageService.getLanguage();
    if (mounted) {
      setState(() => _selectedLang = lang);
    }
  }

  Future<void> _proceed() async {
    if (_navigating) return;
    _navigating = true;
    final profile = await StorageService.getProfile();
    if (!mounted) return;

    if (profile != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations[_selectedLang] ?? _translations['tr']!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Animated Logo & Professional Titles
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              AppColors.pastelLavender,
                              AppColors.starlightGold,
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pastelLavender
                                  .withValues(alpha: 0.35),
                              blurRadius: 48,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color:
                                  AppColors.starlightGold.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 52,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            t['title']!,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: AppColors.starlightGold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Text(
                              t['subtitle']!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.5,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Mandatory Language Selector & Explicit Enter Button
            Positioned(
              bottom: 28,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t['langPrompt']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Language Selection Bar
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.pastelLavender.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLangChip('tr', '🇹🇷 Türkçe'),
                        const SizedBox(width: 8),
                        _buildLangChip('en', '🇬🇧 English'),
                        const SizedBox(width: 8),
                        _buildLangChip('ja', '🇯🇵 日本語'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Prominent Enter Button (Mandatory action)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _proceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.starlightGold,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t['start']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 18, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = _selectedLang == code;
    return InkWell(
      onTap: () async {
        setState(() => _selectedLang = code);
        await AppTranslationService.setLanguage(code);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.starlightGold.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.starlightGold : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.starlightGold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
