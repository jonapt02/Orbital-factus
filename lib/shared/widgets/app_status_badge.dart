import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum AppStatus { borrador, enviada, aprobada, rechazada }

class AppStatusBadge extends StatelessWidget {
  final AppStatus status;

  const AppStatusBadge({super.key, required this.status});

  String get _label {
    switch (status) {
      case AppStatus.borrador:
        return 'BORRADOR';
      case AppStatus.enviada:
        return 'ENVIADA';
      case AppStatus.aprobada:
        return 'APROBADA';
      case AppStatus.rechazada:
        return 'RECHAZADA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    double borderWidth;
    double bgOpacity;

    switch (status) {
      case AppStatus.borrador:
        borderWidth = 1;
        bgOpacity = 0.0;
        break;
      case AppStatus.enviada:
        borderWidth = 1;
        bgOpacity = 0.05;
        break;
      case AppStatus.aprobada:
        borderWidth = 2;
        bgOpacity = 0.08;
        break;
      case AppStatus.rechazada:
        borderWidth = 2;
        bgOpacity = 0.0;
        break;
    }

    final bgColor = isDark
        ? Colors.white.withOpacity(bgOpacity)
        : Colors.black.withOpacity(bgOpacity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: textColor, width: borderWidth),
      ),
      child: Text(
        _label,
        style: AppTypography.overline.copyWith(color: textColor),
      ),
    );
  }
}
