import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Mendapatkan session user saat ini
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign Up dengan email dan password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  // Sign In dengan email dan password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign In dengan Google OAuth
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.tampil://login-callback/',
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset Password via Email
  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Nama User saat ini
  String get userDisplayName {
    final meta = currentUser?.userMetadata;
    if (meta != null && meta['full_name'] != null && meta['full_name'].toString().isNotEmpty) {
      return meta['full_name'].toString();
    }
    final email = currentUser?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Pengguna';
  }
}
