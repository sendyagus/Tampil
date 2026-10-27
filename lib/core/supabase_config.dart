import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Inisialisasi Supabase menggunakan URL dan Anon Key dari .env
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Peringatan: Gagal memuat file .env: $e");
    }

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty ||
        supabaseUrl.contains('your-project-id')) {
      debugPrint(
        '⚠️ PERINGATAN: Supabase URL atau Anon Key belum dikonfigurasi dengan benar di file .env!',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }
}
