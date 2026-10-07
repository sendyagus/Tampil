import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const TampilApp(),
    ),
  );
}

class TampilApp extends StatelessWidget {
  const TampilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAMPIL - AI Communication Coach',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Fallback modern sans font
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF8B5CF6),
          tertiary: const Color(0xFF06B6D4),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const HomeScreen(),
    );
  }
}
