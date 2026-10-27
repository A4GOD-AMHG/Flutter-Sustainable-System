import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sustainable_system/screens/home_page.dart';
import 'package:sustainable_system/utils/constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData _theme(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(seedColor: brandGreen, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // AppBar con el verde de marca en ambos temas para mantener la identidad.
      appBarTheme: const AppBarTheme(
        backgroundColor: brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema Sostenible',
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
