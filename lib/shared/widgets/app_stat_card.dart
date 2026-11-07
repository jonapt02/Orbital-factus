import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';

class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String caption;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.textTheme.bodySmall?.color;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTypography.overline.copyWith(color: secondaryColor),
                ),
              ),
              Icon(icon, size: 20, color: secondaryColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.h1.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: AppTypography.caption.copyWith(color: secondaryColor),
          ),
        ],
      ),
    );
  }
}
