import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/app_translation_service.dart';

import '../../data/services/cosmic_theme_service.dart';

class BigThreeBadge extends StatelessWidget {
  final String label;
  final String sign;
  final Color accentColor;
  final IconData icon;

  const BigThreeBadge({
    super.key,
    required this.label,
    required this.sign,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CosmicSeason>(
      valueListenable: CosmicThemeService.seasonNotifier,
      builder: (context, season, _) {
        final emoji = CosmicThemeService.getPlanetCostumeEmoji(label);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: accentColor),
                    const SizedBox(width: 3),
                    Text(
                      AppTranslationService.tr(label).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: accentColor,
                      ),
                    ),
                    if (emoji != null) ...[
                      const SizedBox(width: 3),
                      Text(emoji, style: const TextStyle(fontSize: 11.5)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppTranslationService.signName(sign),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
