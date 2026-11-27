import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// Status kuota feedback AI harian user (dibaca dari dokumen Firestore users).
class FeedbackQuotaStatus {
  final int max;
  final int used;
  const FeedbackQuotaStatus({required this.max, required this.used});

  int get remaining => (max - used).clamp(0, max);
  bool get habis => remaining <= 0;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Terjemahkan exception Firebase Auth menjadi pesan yang ramah untuk user.
  /// Dipakai oleh layar login/register untuk menampilkan SnackBar error.
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau kata sandi salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan login.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah, minimal 6 karakter.';
        case 'requires-recent-login':
          return 'Silakan login kembali untuk melanjutkan.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
        case 'network-request-failed':
          return 'Koneksi jaringan bermasalah. Periksa internet Anda.';
        case 'popup-closed-by-user':
        case 'cancelled-provider-auth':
          return 'Login dibatalkan.';
        default:
          return error.message ?? 'Terjadi kesalahan: ${error.code}';
      }
    }
    return 'Terjadi kesalahan: $error';
  }

  // Mendapatkan session/user saat ini
  User? get currentUser => _auth.currentUser;
  User? get currentSession => _auth.currentUser;

  // Stream perubahan status login (login / logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Deteksi pengguna baru registrasi: akun Firebase Auth dibuat kurang dari
  /// [maxAge] yang lalu. Dipakai untuk menentukan perlu tidaknya onboarding
  /// ditampilkan setelah login (pengguna lama tidak melewati onboarding).
  bool isRecentlyRegisteredUser({
    User? user,
    Duration maxAge = const Duration(minutes: 5),
  }) {
    final createdAt = (user ?? currentUser)?.metadata.creationTime;
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt.toLocal()) < maxAge;
  }

  // Stream data profil user dari Firestore secara realtime (responsif terhadap authState)
  Stream<DocumentSnapshot<Map<String, dynamic>>> get userProfileStream {
    return _auth.authStateChanges().asyncExpand((user) {
      final uid = user?.uid ?? _auth.currentUser?.uid;
      if (uid == null) {
        return const Stream.empty();
      }
      return _firestore.collection('users').doc(uid).snapshots();
    });
  }

  // Helper: Sinkronisasi data user ke Firestore sesuai PRD Bagian 20
  Future<void> _syncUserProfile(
    User user, {
    String? fullName,
    int? birthYear,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    // Deteksi provider (Google atau Email)
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');

    if (!snapshot.exists) {
      // Jika user baru pertama kali login/daftar, buat data awal sesuai PRD
      await userDoc.set({
        'user_id': user.uid,
        'nama':
            fullName ??
            (user.displayName ?? (user.email?.split('@').first ?? 'User')),
        'email': user.email ?? '',
        'auth_provider': isGoogle ? 'google' : 'email',
        'tahun_lahir': birthYear ?? 2004,
        'is_adult': true,
        'status': 'active',
        'tujuan': ['Percakapan sehari-hari'],
        // UserStats (PRD Bagian 13 & 20)
        'total_xp': 0,
        'level': 'Pemula',
        'current_streak': 0,
        'longest_streak': 0,
        'last_activity_date': DateTime.now().toIso8601String().split('T').first,
        'fokus_aspek': 'Kelancaran jeda',
        // UserQuota (PRD Bagian 10.9 & 20)
        'kuota_feedback': 3,
        'kuota_feedback_terpakai': 0,
        'sesi_test_hari_ini': 0,
        'created_at': FieldValue.serverTimestamp(),
        'last_login_at': FieldValue.serverTimestamp(),
      });
    } else {
      // Jika dokumen sudah ada, update waktu login terakhir
      await userDoc.update({'last_login_at': FieldValue.serverTimestamp()});
    }
  }

  // Menambahkan XP ke akun user di Cloud Firestore

  // Update data profil user di Cloud Firestore
  Future<void> updateUserProfile({
    String? nama,
    String? jenisKelamin,
    String? peran,
    String? bio,
    String? photoUrl,
    String? tujuan,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    try {
      final updateData = <String, dynamic>{};
      if (nama != null && nama.trim().isNotEmpty) {
        updateData['nama'] = nama.trim();
      }
      if (jenisKelamin != null) updateData['jenis_kelamin'] = jenisKelamin;
      if (peran != null) updateData['peran'] = peran;
      if (bio != null) updateData['bio'] = bio.trim();
      if (photoUrl != null) updateData['photo_url'] = photoUrl;
      if (tujuan != null) updateData['tujuan'] = [tujuan];

      if (updateData.isNotEmpty) {
        updateData['updated_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(uid).update(updateData);
        if (nama != null && nama.trim().isNotEmpty && currentUser != null) {
          try {
            await currentUser!.updateDisplayName(nama.trim());
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error update user profile: ');
      rethrow;
    }
  }

  Future<bool> completeLesson({
    required String lessonId,
    required String unitId,
    int rewardXp = 10,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null || lessonId.isEmpty) return false;

    final userRef = _firestore.collection('users').doc(uid);
    final progressRef = userRef.collection('lesson_progress').doc(lessonId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayString = today.toIso8601String().split('T').first;

    return _firestore.runTransaction((transaction) async {
      final progressSnapshot = await transaction.get(progressRef);
      if (progressSnapshot.exists) return false;

      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final totalXp = _readInt(userData['total_xp']);
      final savedStreak = _readInt(userData['current_streak']);
      final longestStreak = _readInt(userData['longest_streak']);
      final lastActivity = DateTime.tryParse(
        userData['last_activity_date']?.toString() ?? '',
      );
      final daysSinceActivity = lastActivity == null
          ? null
          : today
                .difference(
                  DateTime(
                    lastActivity.year,
                    lastActivity.month,
                    lastActivity.day,
                  ),
                )
                .inDays;

      final currentStreak = switch (daysSinceActivity) {
        0 => savedStreak > 0 ? savedStreak : 1,
        1 => savedStreak + 1,
        _ => 1,
      };
      final updatedLongestStreak = currentStreak > longestStreak
          ? currentStreak
          : longestStreak;
      final updatedTotalXp = totalXp + rewardXp;
      final level = updatedTotalXp >= 300
          ? 'Mahir'
          : updatedTotalXp >= 100
          ? 'Menengah'
          : 'Pemula';

      transaction.set(progressRef, {
        'lesson_id': lessonId,
        'unit_id': unitId,
        'completed_at': FieldValue.serverTimestamp(),
      });
      transaction.set(userRef, {
        'total_xp': updatedTotalXp,
        'level': level,
        'current_streak': currentStreak,
        'longest_streak': updatedLongestStreak,
        'last_activity_date': todayString,
        'last_active_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    });
  }

  // Sign In dengan email dan password (Firebase Auth + Sinkron Firestore)
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (credential.user != null) {
      await _syncUserProfile(credential.user!);
    }

    return credential;
  }

  // Sign Up dengan email dan password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    int? birthYear,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (credential.user != null) {
      if (fullName != null && fullName.isNotEmpty) {
        await credential.user?.updateDisplayName(fullName);
      }
      await _syncUserProfile(
        credential.user!,
        fullName: fullName,
        birthYear: birthYear,
      );
    }

    return credential;
  }

  // Sign In dengan Google (berjalan di semua platform)
  // - Web  : popup akun Google resmi Firebase (signInWithPopup)
  // - Android/iOS/desktop Apple : alur OAuth Firebase lewat browser eksternal
  //   (signInWithProvider, memakai Chrome Custom Tab / SFSafariViewController)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final UserCredential credential;
      if (kIsWeb) {
        // Membuka pop-up akun Google bawaan Firebase (hanya tersedia di web)
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        credential = await _auth.signInWithProvider(googleProvider);
      }

      if (credential.user != null) {
        // Otomatis sinkronkan profil user ke Firestore
        await _syncUserProfile(
          credential.user!,
          fullName: credential.user!.displayName,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      // User menutup halaman OAuth sebelum selesai: jangan tampilkan error keras
      if (e.code == 'cancelled-provider-auth' ||
          e.code == 'popup-closed-by-user') {
        debugPrint('Google Sign-In dibatalkan user: ${e.code}');
        return null;
      }
      debugPrint('Error Google Sign-In: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error Google Sign-In: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset Password via Email
  Future<void> resetPasswordForEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Nama User saat ini
  String get userDisplayName {
    final name = currentUser?.displayName;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final email = currentUser?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  // ============================ KUOTA FEEDBACK AI ============================

  static const int maxFeedbackPerDay = 3;
  // Batas hari kuota: reset setiap jam 01.00 WIB (bukan tengah malam biasa).
  static const int _resetHourWib = 1;

  /// Label "hari kuota" berbasis WIB: sebelum jam 01.00 masih dihitung hari kemarin.
  String get _quotaDayLabel {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final day = wib.hour < _resetHourWib
        ? wib.subtract(const Duration(days: 1))
        : wib;
    return '${day.year}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  /// Sisa kuota feedback AI hari ini. Otomatis di-reset saat melewati jam
  /// 01.00 WIB (ganti hari kuota) dan hasil reset ditulis balik ke Firestore.
  Future<FeedbackQuotaStatus> feedbackQuotaStatus() async {
    final uid = currentUser?.uid;
    if (uid == null) {
      return const FeedbackQuotaStatus(max: maxFeedbackPerDay, used: 0);
    }
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();
    final data = snapshot.data() ?? <String, dynamic>{};

    final max = _readInt(data['kuota_feedback']) > 0
        ? _readInt(data['kuota_feedback'])
        : maxFeedbackPerDay;
    final isNewDay = data['quota_date']?.toString() != _quotaDayLabel;
    final used = isNewDay ? 0 : _readInt(data['kuota_feedback_terpakai']);

    // Persist hasil reset supaya perangkat/stream lain ikut melihat
    if (isNewDay && snapshot.exists) {
      try {
        await userRef.update({
          'kuota_feedback_terpakai': 0,
          'quota_date': _quotaDayLabel,
        });
      } catch (_) {}
    }
    return FeedbackQuotaStatus(max: max, used: used);
  }

  /// Kurangi satu kuota feedback AI secara atomik (transaction).
  /// Mengembalikan false bila kuota hari ini sudah habis.
  Future<bool> consumeFeedbackQuota() async {
    final uid = currentUser?.uid;
    if (uid == null) return true; // belum login: jangan blokir (mode demo)

    final userRef = _firestore.collection('users').doc(uid);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return true;
      final data = snapshot.data() ?? <String, dynamic>{};

      final max = _readInt(data['kuota_feedback']) > 0
          ? _readInt(data['kuota_feedback'])
          : maxFeedbackPerDay;
      final isNewDay = data['quota_date']?.toString() != _quotaDayLabel;
      final used = isNewDay ? 0 : _readInt(data['kuota_feedback_terpakai']);
      if (used >= max) return false;

      transaction.set(userRef, {
        'kuota_feedback': max,
        'kuota_feedback_terpakai': used + 1,
        'quota_date': _quotaDayLabel,
      }, SetOptions(merge: true));
      return true;
    });
  }

  // ============================ PROGRES LESSON ============================

  /// Stream berisi semua lesson_id yang sudah diselesaikan user aktif.
  Stream<Set<String>> get completedLessonsStream {
    return _auth.authStateChanges().asyncExpand((user) {
      final uid = user?.uid ?? _auth.currentUser?.uid;
      if (uid == null) return const Stream.empty();
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('lesson_progress')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.id).toSet());
    });
  }
}
