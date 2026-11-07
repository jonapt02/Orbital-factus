import 'package:flutter/material.dart';

enum LogoType { completo, isotipo }

class AppLogo extends StatelessWidget {
  final LogoType type;
  final double height;
  final Color? color;

  const AppLogo({
    super.key,
    this.type = LogoType.completo,
    this.height = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath = type == LogoType.completo
        ? 'assets/images/logo_completo.png'
        : 'assets/images/logo_isotipo.png';

    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      color: color,
    );
  }
}
