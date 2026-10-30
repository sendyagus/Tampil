import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'roadmap_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan session/user saat ini
  User? get currentUser => _auth.currentUser;
  User? get currentSession => _auth.currentUser;

  // Stream perubahan status login (login / logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
        // UserStats (PRD Bagian 13 & 20) — mulai dari 0 agar angka di beranda
        // benar-benar hasil aktivitas user, bukan nilai demo.
        'total_xp': 0,
        'xp_by_day': <String, int>{},
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

  // Kunci tanggal 'YYYY-MM-DD' untuk pencatatan XP harian & streak.
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Menambahkan XP + update XP harian, tanggal aktivitas, dan streak.
  /// Streak bertambah bila kemarin juga aktif, dan reset ke 1 bila bolong.
  Future<void> addXp(int xp) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final ref = _firestore.collection('users').doc(uid);
    final today = dateKey(DateTime.now());
    final yesterday = dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    try {
      final snap = await ref.get();
      final data = snap.data() ?? {};
      final last = (data['last_activity_date'] ?? '').toString();
      final streak = data['current_streak'] is int ? data['current_streak'] : 0;
      final longest = data['longest_streak'] is int ? data['longest_streak'] : 0;

      int newStreak = streak;
      if (last != today) {
        newStreak = last == yesterday ? streak + 1 : 1;
      }
      final newLongest = newStreak > longest ? newStreak : longest;

      await ref.update({
        'total_xp': FieldValue.increment(xp),
        // XP harian dipakai kartu Hero ("Target harian x/y XP") di beranda.
        'xp_by_day.$today': FieldValue.increment(xp),
        'last_activity_date': today,
        'current_streak': newStreak,
        'longest_streak': newLongest,
      });
      print('🎉 Berhasil menambah +$xp XP ke Firestore untuk user $uid!');
    } catch (e) {
      print('❌ Gagal menambah XP: $e');
    }
  }

  // Sign In dengan email dan password (Firebase Auth + Sinkron Firestore + Seeder)
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
      // Mengisi 3 Modul & 15 Lesson ke Firestore saat user berhasil login
      await RoadmapService().seedInitialData();
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
      await RoadmapService().seedInitialData();
    }

    return credential;
  }

  // Sign In dengan Google (Pop-up Akun Google Resmi Firebase)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Membuka pop-up login Google bawaan Firebase
      final UserCredential credential = await _auth.signInWithPopup(
        googleProvider,
      );

      if (credential.user != null) {
        // Otomatis sinkronkan profil user ke Firestore
        await _syncUserProfile(
          credential.user!,
          fullName: credential.user!.displayName,
        );
        // Pastikan database modul & lessons siap
        await RoadmapService().seedInitialData();
      }

      return credential;
    } catch (e) {
      print('Error Google Sign-In: $e');
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

  // ============================ PROGRES LESSON ============================

  /// Tandai satu lesson selesai untuk user aktif (membuka lesson berikutnya).
  Future<void> markLessonCompleted({
    required String lessonId,
    String modulId = '',
    int xp = 10,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null || lessonId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('lesson_progress')
          .doc(lessonId)
          .set({
            'lesson_id': lessonId,
            'modul_id': modulId,
            'xp': xp,
            'completed_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Gagal menyimpan progres lesson: $e');
    }
  }

  /// Satu panggilan lengkap untuk "lesson selesai": simpan progres DAN beri XP
  /// supaya keduanya selalu konsisten di Firestore.
  Future<void> completeLesson({
    required String lessonId,
    String modulId = '',
    int xp = 10,
  }) async {
    await markLessonCompleted(lessonId: lessonId, modulId: modulId, xp: xp);
    await addXp(xp);
  }

  /// Stream progres lesson user aktif (termasuk waktu selesai & XP),
  /// tersortir terbaru di depan.
  Stream<List<LessonProgress>> get lessonProgressStream {
    return _auth.authStateChanges().asyncExpand((user) {
      final uid = user?.uid ?? _auth.currentUser?.uid;
      if (uid == null) return const Stream.empty();
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('lesson_progress')
          .snapshots()
          .map((snap) {
            final list = snap.docs.map(LessonProgress.fromDoc).toList()
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
            return list;
          });
    });
  }

  /// Stream berisi semua lesson_id yang sudah diselesaikan user aktif.
  Stream<Set<String>> get completedLessonsStream {
    return lessonProgressStream.map(
      (list) => list.map((p) => p.lessonId).toSet(),
    );
  }
}

/// Satu dokumen progres lesson (`users/{uid}/lesson_progress/{lessonId}`).
class LessonProgress {
  final String lessonId;
  final String modulId;
  final int xp;
  final DateTime completedAt;

  LessonProgress({
    required this.lessonId,
    required this.modulId,
    required this.xp,
    required this.completedAt,
  });

  factory LessonProgress.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final raw = data['completed_at'];
    return LessonProgress(
      lessonId: (data['lesson_id'] ?? doc.id).toString(),
      modulId: (data['modul_id'] ?? data['unit_id'] ?? '').toString(),
      xp: data['xp'] is int ? data['xp'] : 10,
      completedAt: raw is Timestamp
          ? raw.toDate()
          // Timestamp masih pending di cache lokal / dokumen lama tanpa tanggal:
          // anggap baru saja selesai agar urutan aktivitas tetap masuk akal.
          : DateTime.now(),
    );
  }
}
