import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Model representasi kuota harian user
class DailyQuota {
  final int testRemaining;
  final int feedbackRemaining;
  final String cycleDate;

  const DailyQuota({
    required this.testRemaining,
    required this.feedbackRemaining,
    required this.cycleDate,
  });

  bool get hasTestQuota => testRemaining > 0;
  bool get hasFeedbackQuota => feedbackRemaining > 0;

  static const DailyQuota initial = DailyQuota(
    testRemaining: QuotaService.maxDailyTests,
    feedbackRemaining: QuotaService.maxDailyFeedbacks,
    cycleDate: '',
  );
}

/// Service untuk mengelola kuota latihan harian & reset otomatis pukul 01.00 WIB
class QuotaService {
  static const int maxDailyTests = 5;
  static const int maxDailyFeedbacks = 3;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Menghitung ID tanggal siklus berdasarkan patokan reset pukul 01.00 WIB (UTC+7).
  ///
  /// Penjelasan:
  /// Sebelum jam 01.00 WIB (misal 00.30 WIB), masih dianggap siklus hari kemarin.
  /// Tepat pukul 01.00 WIB, berganti menjadi siklus hari baru.
  static String getTodayCycleDate() {
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    // Kurangi 1 jam agar jam 01.00 WIB menjadi titik 00.00 awal hari baru
    final cycleTime = nowWib.subtract(const Duration(hours: 1));
    final y = cycleTime.year;
    final m = cycleTime.month.toString().padLeft(2, '0');
    final d = cycleTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Realtime Stream data kuota harian untuk user aktif.
  /// Jika tanggal siklus di Firestore sudah kadaluarsa (sudah lewat jam 01.00 WIB),
  /// sistem otomatis mereset kuota kembali ke 5 sesi test & 3 feedback AI.
  Stream<DailyQuota> getDailyQuotaStream(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream.value(DailyQuota.initial);
    }

    final todayCycle = getTodayCycleDate();
    final docRef = _firestore.collection('users').doc(userId);

    return docRef.snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();

      // Jika data belum ada atau tanggal siklus berbeda dari hari ini (sudah lewat 01.00 WIB)
      if (data == null || data['quota_cycle_date'] != todayCycle) {
        // Reset kuota di Firestore ke nilai awal
        try {
          await docRef.set({
            'quota_cycle_date': todayCycle,
            'test_quota_remaining': maxDailyTests,
            'feedback_quota_remaining': maxDailyFeedbacks,
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[QuotaService] Gagal mereset kuota di Firestore: $e');
        }

        return DailyQuota(
          testRemaining: maxDailyTests,
          feedbackRemaining: maxDailyFeedbacks,
          cycleDate: todayCycle,
        );
      }

      final testRem = (data['test_quota_remaining'] as num?)?.toInt() ?? maxDailyTests;
      final fbRem = (data['feedback_quota_remaining'] as num?)?.toInt() ?? maxDailyFeedbacks;

      return DailyQuota(
        testRemaining: testRem,
        feedbackRemaining: fbRem,
        cycleDate: todayCycle,
      );
    });
  }

  /// Mengambil data kuota saat ini dan memastikan sinkron dengan tanggal siklus aktif.
  Future<DailyQuota> getOrSyncQuota(String userId) async {
    final todayCycle = getTodayCycleDate();
    final docRef = _firestore.collection('users').doc(userId);

    try {
      final snap = await docRef.get();
      final data = snap.data();

      if (data == null || data['quota_cycle_date'] != todayCycle) {
        await docRef.set({
          'quota_cycle_date': todayCycle,
          'test_quota_remaining': maxDailyTests,
          'feedback_quota_remaining': maxDailyFeedbacks,
        }, SetOptions(merge: true));

        return DailyQuota(
          testRemaining: maxDailyTests,
          feedbackRemaining: maxDailyFeedbacks,
          cycleDate: todayCycle,
        );
      }

      final testRem = (data['test_quota_remaining'] as num?)?.toInt() ?? maxDailyTests;
      final fbRem = (data['feedback_quota_remaining'] as num?)?.toInt() ?? maxDailyFeedbacks;

      return DailyQuota(
        testRemaining: testRem,
        feedbackRemaining: fbRem,
        cycleDate: todayCycle,
      );
    } catch (e) {
      debugPrint('[QuotaService] Error getOrSyncQuota: $e');
      return DailyQuota.initial;
    }
  }

  /// Mengurangi 1 kuota sesi tes dan 1 kuota feedback AI setelah tes selesai dianalisis.
  Future<void> consumeQuotaAfterTest(String userId) async {
    if (userId.isEmpty) return;

    final todayCycle = getTodayCycleDate();
    final docRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(docRef);
        final data = snap.data() ?? {};

        int curTest = maxDailyTests;
        int curFb = maxDailyFeedbacks;

        if (data['quota_cycle_date'] == todayCycle) {
          curTest = (data['test_quota_remaining'] as num?)?.toInt() ?? maxDailyTests;
          curFb = (data['feedback_quota_remaining'] as num?)?.toInt() ?? maxDailyFeedbacks;
        }

        final updatedTest = (curTest > 0) ? curTest - 1 : 0;
        final updatedFb = (curFb > 0) ? curFb - 1 : 0;

        transaction.set(docRef, {
          'quota_cycle_date': todayCycle,
          'test_quota_remaining': updatedTest,
          'feedback_quota_remaining': updatedFb,
        }, SetOptions(merge: true));

        debugPrint(
          '[QuotaService] Kuota terpakai. Sisa test: $updatedTest, feedback: $updatedFb (Siklus: $todayCycle)',
        );
      });
    } catch (e) {
      debugPrint('[QuotaService] Gagal memotong kuota: $e');
    }
  }

  /// Dialog peringatan ramah saat kuota harian habis
  static void showQuotaExceededDialog(
    BuildContext context, {
    String title = 'Kuota Latihan Habis',
    String message =
        'Kamu sudah menggunakan seluruh kuota sesi latihan hari ini (0 tersisa).\n\nKuota harianmu akan otomatis direset kembali menjadi 5 Sesi & 3 Feedback AI setiap hari pukul 01.00 WIB.',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                color: Color(0xFFEF4444),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
