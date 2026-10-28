import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/roadmap_service.dart';

import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Otomatis login akun test user@gmail.com jika sesi kosong
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'user@gmail.com',
        password: '12345678',
      );
    }
  } catch (e) {
    debugPrint('Auto sign-in note: $e');
  }

  // Otomatis isi database units & lessons ke Cloud Firestore
  await RoadmapService().seedInitialData();

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
      home: const SplashScreen(),
    );
  }
}
