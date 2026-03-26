import 'package:flutter/material.dart';
import 'core/audio/audio_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait, set status bar style
  await AppTheme.configure();

  // Pre-warm audio engine (non-blocking on failure)
  await AudioService.instance.init();

  runApp(const ThinkFastApp());
}

class ThinkFastApp extends StatelessWidget {
  const ThinkFastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Think Fast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
