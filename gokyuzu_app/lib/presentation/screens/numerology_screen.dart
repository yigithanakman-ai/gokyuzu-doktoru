import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/numerology_service.dart';
import '../../data/services/storage_service.dart';
import '../widgets/glass_card.dart';

class NumerologyScreen extends StatefulWidget {
  final UserProfile profile;

  const NumerologyScreen({super.key, required this.profile});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  late NumerologyResult _result;
  bool _isVip = false;
  bool get isVip => _isVip;

  @override
  void initState() {
    super.initState();
    _result = NumerologyService.calculate(
      fullName: widget.profile.name,
      birthDate: widget.profile.birthDate,
    );
    _checkVip();
  }

  Future<void> _checkVip() async {
    final vip = await StorageService.isVipUnlocked();
    if (mounted) setState(() => _isVip = vip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'KOZMİK NUMEROLOJİ MATRİSİ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.starlightGold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Life Path Hero Card (Yaşam Yolu)
            _buildLifePathHeroCard(),
            const SizedBox(height: 16),

            // 2. Strengths & Challenges Card
            _buildStrengthsAndChallengesCard(),
            const SizedBox(height: 16),

            // 3. Personal Year 2026 Cycle Card
            _buildPersonalYearCard(),
            const SizedBox(height: 16),

            // 4. Advanced Numerology Matrix (Destiny, Soul Urge, Personality)
            _buildCoreNumbersCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLifePathHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.starlightGold.withValues(alpha: 0.20),
            AppColors.pastelLavender.withValues(alpha: 0.12),
            const Color(0xFF1E1736),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.starlightGold.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.starlightGold.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.starlightGold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.starlightGold),
                    SizedBox(width: 6),
                    Text(
                      'YAŞAM YOLU SAYISI (LİFE PATH)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.starlightGold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_result.isMasterNumber)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pastelPink.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.pastelPink),
                  ),
                  child: const Text(
                    'ÜSTAT SAYI ⭐',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pastelPink,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.starlightGold, Color(0xFFFFA000)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.starlightGold.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${_result.lifePathNumber}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF13111C),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result.lifePathTitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _result.lifePathArchetype,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pastelMint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yönetici Gezegen: ${_result.rulingPlanet}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          Text(
            _result.lifePathDescription,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsAndChallengesCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.pastelMint.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, size: 18, color: AppColors.pastelMint),
              SizedBox(width: 8),
              Text(
                'KOZMİK GÜÇLER & GÖLGE SINAVLAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.pastelMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoPill(
            title: 'IŞIK GÜÇLERİNİZ (YETENEKLER)',
            content: _result.lifePathStrengths,
            color: AppColors.pastelMint,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 12),
          _buildInfoPill(
            title: 'GÖLGE TUZAKLAR (DİKKAT EDİLECEKLER)',
            content: _result.lifePathChallenges,
            color: AppColors.warningOrange,
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalYearCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.pastelLavender.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.pastelLavender),
                  SizedBox(width: 8),
                  Text(
                    '2026 KİŞİSEL YIL DÖNGÜSÜ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.pastelLavender,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pastelLavender.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_result.personalYearNumber}. YIL',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pastelLavender,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _result.personalYearTitle,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _result.personalYearForecast,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreNumbersCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.starlightGold.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fingerprint_rounded, size: 18, color: AppColors.starlightGold),
              SizedBox(width: 8),
              Text(
                'İSİM MATRİSİ & RUH FREKANSLARI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.starlightGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMiniNumberRow(
            badge: '${_result.destinyNumber}',
            title: _result.destinyTitle,
            desc: _result.destinyMeaning,
            color: AppColors.starlightGold,
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildMiniNumberRow(
            badge: '${_result.soulUrgeNumber}',
            title: _result.soulUrgeTitle,
            desc: _result.soulUrgeMeaning,
            color: AppColors.pastelPink,
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildMiniNumberRow(
            badge: '${_result.personalityNumber}',
            title: _result.personalityTitle,
            desc: _result.personalityMeaning,
            color: AppColors.pastelBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required String title,
    required String content,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNumberRow({
    required String badge,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
