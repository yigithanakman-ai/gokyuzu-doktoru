import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/app_translation_service.dart';
import '../../data/services/cosmic_compass_service.dart';
import '../../data/services/storage_service.dart';

class CosmicCompassModal extends StatefulWidget {
  final UserProfile profile;

  const CosmicCompassModal({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CosmicCompassModal(profile: profile),
    );
  }

  @override
  State<CosmicCompassModal> createState() => _CosmicCompassModalState();
}

class _CosmicCompassModalState extends State<CosmicCompassModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  String _selectedCategory = 'Kariyer';
  final List<String> _categories = ['Kariyer', 'İlişkiler', 'Finans', 'Kişisel'];

  Map<String, dynamic>? _quotaInfo;
  CompassConsultationResult? _result;
  bool _isConsulting = false;

  late AnimationController _needleAnimController;
  late Animation<double> _needleAnimation;
  double _currentNeedleAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _needleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _needleAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _needleAnimController, curve: Curves.easeOutBack),
    );
    _loadQuota();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _needleAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadQuota() async {
    final info = await CosmicCompassService.checkQuotaStatus();
    if (mounted) {
      setState(() {
        _quotaInfo = info;
      });
    }
  }

  Future<void> _consultCompass() async {
    if (_quotaInfo == null) return;
    final canAsk = _quotaInfo!['canAsk'] as bool? ?? false;

    if (!canAsk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslationService.tr(
              'Bugünkü/bu haftaki soru hakkınız doldu. Reklam izleyerek +1 hak kazanabilir veya VIP üyeliğe geçebilirsiniz.',
            ),
          ),
          backgroundColor: Colors.amber.shade900,
        ),
      );
      return;
    }

    setState(() {
      _isConsulting = true;
    });

    FocusScope.of(context).unfocus();

    // Hafif kozmik bekleme hissi
    await Future.delayed(const Duration(milliseconds: 800));

    final res = await CosmicCompassService.consultCompass(
      profile: widget.profile,
      category: _selectedCategory,
      optionalQuestion: _questionController.text.trim(),
    );

    await CosmicCompassService.consumeQuota();
    await _loadQuota();

    final targetAngleRad = res.needleAngleDegrees * (pi / 180.0);

    _needleAnimation = Tween<double>(
      begin: _currentNeedleAngle,
      end: targetAngleRad,
    ).animate(
      CurvedAnimation(parent: _needleAnimController, curve: Curves.easeOutBack),
    );

    _needleAnimController.forward(from: 0.0);
    _currentNeedleAngle = targetAngleRad;

    if (mounted) {
      setState(() {
        _result = res;
        _isConsulting = false;
      });
    }
  }

  Future<void> _watchAdForBonus() async {
    try {
      final rewarded = await AdService.showRewardedAd(
        onRewardGranted: () async {
          final success = await CosmicCompassService.addAdBonusQuota();
          await _loadQuota();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Tebrikler! +1 Kozmik Karar Pusulası hakkı tanımlandı. 🎉'
                    : 'Bugünkü reklamla hak kazanma limitiniz (günde maks. 1 reklam) dolmuştur. ⏳'),
                backgroundColor: success ? AppColors.starlightGold : Colors.orange.shade800,
              ),
            );
          }
        },
      );

      if (!rewarded) {
        // Simülasyon / Test reklamı fallback
        final success = await CosmicCompassService.addAdBonusQuota();
        await _loadQuota();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '+1 Kozmik Karar Pusulası hakkı eklendi! ✨'
                  : 'Bugünkü reklam hakkınız dolmuştur (Günde maks. 1 reklam). ⏳'),
              backgroundColor: success ? AppColors.starlightGold : Colors.orange.shade800,
            ),
          );
        }
      }
    } catch (_) {
      await CosmicCompassService.addAdBonusQuota();
      await _loadQuota();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAsk = _quotaInfo?['canAsk'] as bool? ?? false;
    final isUnlimited = _quotaInfo?['isUnlimited'] as bool? ?? false;
    final remaining = _quotaInfo?['remaining'] as int? ?? 0;
    final tier = _quotaInfo?['tier'] as String? ?? 'Standart';

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
              // Başlık ve Kapatma Butonu
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
                        child: const Text('🧭', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kozmik Karar Pusulası',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gökyüzü Transitleri & Sezgisel Rehber',
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
              const SizedBox(height: 14),

              // Hak Durumu Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUnlimited ? Icons.all_inclusive_rounded : Icons.hourglass_top_rounded,
                      size: 16,
                      color: AppColors.starlightGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isUnlimited
                            ? '$tier: Sınırsız Soru Hakkı 💎'
                            : '$tier: Kalan Hak $remaining (${_quotaInfo?['period'] ?? ''})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isUnlimited && _quotaInfo?['canWatchAdForBonus'] == true)
                      ElevatedButton.icon(
                        onPressed: _watchAdForBonus,
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 14, color: Colors.black),
                        label: const Text(
                          '+1 Hak (Reklam)',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.starlightGold,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    else if (!isUnlimited && tier == 'Standart')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.starlightGold),
                            SizedBox(width: 4),
                            Text(
                              'Reklam Kullanıldı',
                              style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kategori Seçimi
              const Text(
                'Soru / Karar Kategorisi',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat == 'Kariyer'
                          ? '💼 $cat'
                          : (cat == 'İlişkiler'
                              ? '❤️ $cat'
                              : (cat == 'Finans' ? '💰 $cat' : '🌿 $cat')),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.starlightGold,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Opsiyonel Soru Metni Kutusu
              TextField(
                controller: _questionController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Aklındaki karar veya soru (İsteğe bağlı)...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.starlightGold),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Danış Butonu
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isConsulting ? null : _consultCompass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.starlightGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isConsulting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.explore_rounded, color: Colors.black, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              canAsk ? 'Pusulayı Çevir & Kozmik Enerjiyi Oku' : 'Hakkınız Kalmadı',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Pusula Göstergesi & İbre
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pusula Arka Plan Çemberi
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF1D1635),
                              const Color(0xFF0C0917),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.starlightGold.withValues(alpha: 0.6),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.starlightGold.withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Pusula Yön Etiketleri
                      Positioned(
                        top: 10,
                        child: _buildCompassLabel('🟢 HAREKET', Colors.greenAccent),
                      ),
                      Positioned(
                        bottom: 10,
                        child: _buildCompassLabel('🔴 DİKKAT', Colors.redAccent),
                      ),
                      Positioned(
                        left: 8,
                        child: _buildCompassLabel('🟡 BEKLE', Colors.amberAccent),
                      ),
                      Positioned(
                        right: 8,
                        child: _buildCompassLabel('✨ DÖNÜŞ', AppColors.starlightGold),
                      ),

                      // Dönen İbre
                      AnimatedBuilder(
                        animation: _needleAnimation,
                        builder: (context, child) {
                          Color needleTipColor = AppColors.starlightGold;
                          Color needleGlowColor = AppColors.starlightGold;
                          if (_result != null) {
                            switch (_result!.answerType) {
                              case CompassAnswerType.affirmative:
                                needleTipColor = Colors.greenAccent;
                                needleGlowColor = Colors.greenAccent;
                                break;
                              case CompassAnswerType.neutral:
                                needleTipColor = Colors.amberAccent;
                                needleGlowColor = Colors.amberAccent;
                                break;
                              case CompassAnswerType.cautious:
                                needleTipColor = Colors.redAccent;
                                needleGlowColor = Colors.redAccent;
                                break;
                            }
                          }

                          return Transform.rotate(
                            angle: _needleAnimation.value,
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // İbre Ucu
                                  Positioned(
                                    top: 10,
                                    child: Container(
                                      width: 4,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [needleTipColor, AppColors.starlightGold],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: needleGlowColor.withValues(alpha: 0.7),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Orta Göbek
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.starlightGold,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.starlightGold.withValues(alpha: 0.8),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Sonuç Kartı
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getResultColor(_result!.answerType).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _getResultColor(_result!.answerType).withValues(alpha: 0.6),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _result!.title,
                              style: TextStyle(
                                color: _getResultColor(_result!.answerType),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getResultColor(_result!.answerType),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Puan: ${_result!.cosmicScore} / 100',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!.summary,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result!.astrologicalInsight,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⏳ ', style: TextStyle(fontSize: 13)),
                            Expanded(
                              child: Text(
                                _result!.timingRecommendation,
                                style: const TextStyle(
                                  color: AppColors.starlightGold,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // YASAL UYARI & SORUMLULUK REDDİ (Patron'un Şartı)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.gavel_rounded, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        CosmicCompassService.legalNotice,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompassLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _getResultColor(CompassAnswerType type) {
    switch (type) {
      case CompassAnswerType.affirmative:
        return Colors.greenAccent;
      case CompassAnswerType.neutral:
        return Colors.amberAccent;
      case CompassAnswerType.cautious:
        return Colors.redAccent;
    }
  }
}
