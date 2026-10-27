import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sustainable_system/app.dart';
import 'package:sustainable_system/controllers/database_controller.dart';
import 'package:sustainable_system/utils/features_discoveries.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    //La app solo se puede usar con la pantalla vertical
    SystemUiOverlay.bottom,
    SystemUiOverlay.top
  ]);

  await initPreferences();
  await databaseController.init();

  runApp(const MyApp());
}
