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

    if (!snapshot.exists) {
      // Jika user baru pertama kali login/daftar, buat data awal sesuai PRD
      await userDoc.set({
        'user_id': user.uid,
        'nama':
            fullName ??
            (user.displayName ?? (user.email?.split('@').first ?? 'User')),
        'email': user.email ?? '',
        'auth_provider': 'email',
        'tahun_lahir': birthYear ?? 2004,
        'is_adult': true,
        'status': 'active',
        'tujuan': ['Percakapan sehari-hari'],
        // UserStats (PRD Bagian 13 & 20)
        'total_xp': 20,
        'level': 'Pemula',
        'current_streak': 5,
        'longest_streak': 5,
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
  Future<void> addXp(int xp) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'total_xp': FieldValue.increment(xp),
        'last_activity_date': DateTime.now().toIso8601String().split('T').first,
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
      // Mengisi 3 Unit & 15 Lesson ke Firestore saat user berhasil login
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

  // Sign In dengan Google (placeholder)
  Future<bool> signInWithGoogle() async {
    return false;
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
    String unitId = '',
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
            'unit_id': unitId,
            'completed_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Gagal menyimpan progres lesson: $e');
    }
  }

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
