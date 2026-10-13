import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/brutal_truth_model.dart';
import '../../data/services/storage_service.dart';
import '../widgets/big_three_badge.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class BrutalTruthsScreen extends StatefulWidget {
  final UserProfile profile;
  final BirthChartModel chart;
  final List<BrutalTruthModel> truths;

  const BrutalTruthsScreen({
    super.key,
    required this.profile,
    required this.chart,
    required this.truths,
  });

  @override
  State<BrutalTruthsScreen> createState() => _BrutalTruthsScreenState();
}

class _BrutalTruthsScreenState extends State<BrutalTruthsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _capitalize(String raw) {
    if (raw.trim().isEmpty) return '';
    return raw.trim().split(RegExp(r'\s+')).map((w) {
      if (w.isEmpty) return '';
      String first;
      String rest = w.length > 1 ? w.substring(1).toLowerCase() : '';
      if (w.startsWith('i') || w.startsWith('İ')) {
        first = 'İ';
      } else if (w.startsWith('ı') || w.startsWith('I')) {
        first = 'I';
      } else {
        first = w[0].toUpperCase();
      }
      return '$first$rest';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header with Big 3
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sevgili ${_capitalize(widget.profile.name)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.pastelPink,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.starlightGold.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'HARİTA ÇÖZÜMLEMESİ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starlightGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: BigThreeBadge(
                          label: 'Güneş',
                          sign: widget.chart.sunSign,
                          accentColor: AppColors.starlightGold,
                          icon: Icons.wb_sunny_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BigThreeBadge(
                          label: 'Ay',
                          sign: widget.chart.moonSign,
                          accentColor: AppColors.pastelLavender,
                          icon: Icons.nightlight_round,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BigThreeBadge(
                          label: 'Yükselen',
                          sign: widget.chart.risingSign,
                          accentColor: AppColors.pastelPink,
                          icon: Icons.north_east_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Kişisel Farkındalık &\nTemel Harita Dinamikleri',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      height: 1.2,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Doğum haritanızdaki akslar ve yerleşimlerin ortaya koyduğu 3 kilit psikolojik gerçeklik.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 16),

            // Swiping Truth Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.truths.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final truth = widget.truths[index];
                  final cardColor = (index == 0)
                      ? AppColors.savageRed
                      : (index == 1)
                          ? AppColors.warningOrange
                          : AppColors.pastelLavender;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: GlassCard(
                      borderColor: cardColor.withValues(alpha: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cardColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: cardColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      truth.title.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                        color: cardColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${index + 1} / ${widget.truths.length}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                truth.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      height: 1.6,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Controls: Geri (Sol) | Page Indicators | İleri (Sağ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left (Geri / Sol) Button
                  IconButton.filledTonal(
                    tooltip: 'Önceki Kart',
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: _currentPage > 0
                          ? AppColors.surfaceLight
                          : AppColors.surface.withValues(alpha: 0.2),
                      foregroundColor: _currentPage > 0
                          ? AppColors.pastelLavender
                          : AppColors.textMuted.withValues(alpha: 0.25),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.truths.length, (idx) {
                      final isSelected = _currentPage == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.pastelLavender
                              : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Right (İleri / Sağ) Button
                  IconButton.filledTonal(
                    tooltip: 'Sonraki Kart',
                    onPressed: _currentPage < widget.truths.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: _currentPage < widget.truths.length - 1
                          ? AppColors.surfaceLight
                          : AppColors.surface.withValues(alpha: 0.2),
                      foregroundColor: _currentPage < widget.truths.length - 1
                          ? AppColors.pastelLavender
                          : AppColors.textMuted.withValues(alpha: 0.25),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Continue CTA (Sonraki Kart / Kozmik Panele Geç)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < widget.truths.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(profile: widget.profile),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _currentPage < widget.truths.length - 1
                        ? 'Sonraki Gerçeğe Geç ➔'
                        : 'Kozmik Panele Geç ✨',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
