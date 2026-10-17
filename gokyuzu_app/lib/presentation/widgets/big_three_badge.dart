import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/app_translation_service.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Text(
                AppTranslationService.tr(label).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppTranslationService.signName(sign),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
