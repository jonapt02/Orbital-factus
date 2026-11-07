import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/quote.dart';
import 'models/quote_item.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QuoteAdapter());
  Hive.registerAdapter(QuoteItemAdapter());
  runApp(const OrbitalFactusApp());
}

class OrbitalFactusApp extends StatelessWidget {
  const OrbitalFactusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbital Factus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const DashboardScreen(),
    );
  }
}
