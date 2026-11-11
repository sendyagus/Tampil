import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'ai_analysis_service.dart';

/// Model komprehensif data satu sesi tes komunikasi
class TestSessionModel {
  final String id;
  final String sessionId;
  final String userId;
  final String caseId;
  final String caseTitle;
  final String tipe;
  final int durasiBicara;
  final num communicationIndex;
  final String kategoriSkor;
  final String transcript;
  final String status;
  final DateTime createdAt;

  // Analisis Detail AI (5 Metrik, WPM, Filler Words, Feedback)
  final int wordsPerMinute;
  final int fillerWordsCount;
  final int pointsAdded;
  final String keyPointsRatio;
  final ScoreBreakdown breakdown;
  final List<KeyPointStatus> keyPoints;
  final String strengthText;
  final String improvementText;
  final String quoteSample;
  final String suggestionText;

  TestSessionModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.caseId,
    this.caseTitle = '',
    required this.tipe,
    required this.durasiBicara,
    required this.communicationIndex,
    required this.kategoriSkor,
    required this.transcript,
    required this.status,
    required this.createdAt,
    this.wordsPerMinute = 0,
    this.fillerWordsCount = 0,
    this.pointsAdded = 6,
    this.keyPointsRatio = '0/0',
    this.breakdown = const ScoreBreakdown(),
    this.keyPoints = const [],
    this.strengthText = '',
    this.improvementText = '',
    this.quoteSample = '',
    this.suggestionText = '',
  });

  factory TestSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // 1. Parsing Breakdown 5 Metrik Radar
    final bData = data['score_breakdown'] as Map<String, dynamic>?;
    final breakdown = ScoreBreakdown(
      kelancaranJeda: (bData?['kelancaran_jeda'] is int)
          ? bData!['kelancaran_jeda'] as int
          : 70,
      kebersihanUcapan: (bData?['kebersihan_ucapan'] is int)
          ? bData!['kebersihan_ucapan'] as int
          : 60,
      tempo: (bData?['tempo'] is int) ? bData!['tempo'] as int : 85,
      cakupanIsi:
          (bData?['cakupan_isi'] is int) ? bData!['cakupan_isi'] as int : 75,
      struktur: (bData?['struktur'] is int) ? bData!['struktur'] as int : 65,
    );

    // 2. Parsing Poin Kunci Studi Kasus
    final kpRaw = data['key_points'] as List<dynamic>? ?? [];
    final keyPoints = kpRaw.map((kp) {
      if (kp is Map<String, dynamic>) {
        return KeyPointStatus(
          text: kp['text'] ?? kp['nama'] ?? '',
          isCovered: kp['is_covered'] ?? kp['tercapai'] ?? false,
          matchedKeywords: List<String>.from(
            kp['matched_keywords'] ?? kp['kata_kunci_cocok'] ?? [],
          ),
        );
      }
      return const KeyPointStatus(text: '', isCovered: false);
    }).toList();

    return TestSessionModel(
      id: doc.id,
      sessionId: data['session_id'] ?? doc.id,
      userId: data['user_id'] ?? '',
      caseId: data['case_id'] ?? '',
      caseTitle: data['case_title'] ?? '',
      tipe: data['tipe'] ?? 'test',
      durasiBicara: data['durasi_bicara'] is int ? data['durasi_bicara'] : 0,
      communicationIndex: data['communication_index'] ?? 0,
      kategoriSkor: data['kategori_skor'] ?? 'Perlu Latihan',
      transcript: data['transcript'] ?? '',
      status: data['status'] ?? 'completed',
      wordsPerMinute:
          data['words_per_minute'] is int ? data['words_per_minute'] : 0,
      fillerWordsCount:
          data['filler_words_count'] is int ? data['filler_words_count'] : 0,
      pointsAdded: data['points_added'] is int ? data['points_added'] : 6,
      keyPointsRatio: data['key_points_ratio'] ?? '',
      breakdown: breakdown,
      keyPoints: keyPoints,
      strengthText: data['strength_text'] ?? '',
      improvementText: data['improvement_text'] ?? '',
      quoteSample: data['quote_sample'] ?? '',
      suggestionText: data['suggestion_text'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'case_id': caseId,
      'case_title': caseTitle,
      'tipe': tipe,
      'durasi_bicara': durasiBicara,
      'communication_index': communicationIndex,
      'kategori_skor': kategoriSkor,
      'transcript': transcript,
      'status': status,
      'words_per_minute': wordsPerMinute,
      'filler_words_count': fillerWordsCount,
      'points_added': pointsAdded,
      'key_points_ratio': keyPointsRatio,
      'score_breakdown': {
        'kelancaran_jeda': breakdown.kelancaranJeda,
        'kebersihan_ucapan': breakdown.kebersihanUcapan,
        'tempo': breakdown.tempo,
        'cakupan_isi': breakdown.cakupanIsi,
        'struktur': breakdown.struktur,
      },
      'key_points': keyPoints
          .map((kp) => {
                'text': kp.text,
                'is_covered': kp.isCovered,
                'matched_keywords': kp.matchedKeywords,
              })
          .toList(),
      'strength_text': strengthText,
      'improvement_text': improvementText,
      'quote_sample': quoteSample,
      'suggestion_text': suggestionText,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// Mengonversi kembali ke SpeechAnalysisResult untuk ditinjau di ResultScreen
  SpeechAnalysisResult toSpeechAnalysisResult() {
    return SpeechAnalysisResult(
      transcript: transcript,
      durationSeconds: durasiBicara.toDouble(),
      wordsPerMinute: wordsPerMinute,
      fillerWordsCount: fillerWordsCount,
      communicationIndex: communicationIndex.toInt(),
      scoreLabel: kategoriSkor,
      pointsAdded: pointsAdded,
      keyPointsRatio: keyPointsRatio,
      keyPoints: keyPoints,
      breakdown: breakdown,
      strengthText: strengthText,
      improvementText: improvementText,
      quoteSample: quoteSample,
      suggestionText: suggestionText,
    );
  }
}

class TestSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Menyimpan hasil analisis lengkap dari AI ke koleksi `test_sessions`
  /// DAN otomatis memperbarui statistik profil di `users/{userId}`
  Future<String?> saveAnalysisResult({
    required String userId,
    required String caseId,
    String caseTitle = '',
    String tipe = 'test',
    required SpeechAnalysisResult result,
  }) async {
    try {
      final docRef = _firestore.collection('test_sessions').doc();
      final session = TestSessionModel(
        id: docRef.id,
        sessionId: docRef.id,
        userId: userId,
        caseId: caseId,
        caseTitle: caseTitle.isNotEmpty ? caseTitle : caseId,
        tipe: tipe,
        durasiBicara: result.durationSeconds.round(),
        communicationIndex: result.communicationIndex,
        kategoriSkor: result.scoreLabel,
        transcript: result.transcript,
        status: 'completed',
        wordsPerMinute: result.wordsPerMinute,
        fillerWordsCount: result.fillerWordsCount,
        pointsAdded: result.pointsAdded,
        keyPointsRatio: result.keyPointsRatio,
        breakdown: result.breakdown,
        keyPoints: result.keyPoints,
        strengthText: result.strengthText,
        improvementText: result.improvementText,
        quoteSample: result.quoteSample,
        suggestionText: result.suggestionText,
        createdAt: DateTime.now(),
      );

      // 1. Simpan dokumen sesi tes lengkap
      await docRef.set(session.toMap());
      debugPrint(
        '[TestSessionService] Sesi test lengkap berhasil disimpan ke Firestore! ID: ${docRef.id}',
      );

      // 2. Otomatis perbarui statistik user (XP, completed_tests, streak, skor terbaru)
      await updateUserStatsAfterTest(
        userId: userId,
        xpEarned: result.pointsAdded,
        communicationIndex: result.communicationIndex,
        scoreLabel: result.scoreLabel,
      );

      return docRef.id;
    } catch (e) {
      debugPrint('[TestSessionService] Error save test session: $e');
      return null;
    }
  }

  /// Memperbarui statistik user di Firestore `users/{userId}` setelah tes selesai
  Future<void> updateUserStatsAfterTest({
    required String userId,
    required int xpEarned,
    required int communicationIndex,
    required String scoreLabel,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T').first;

      int currentStreak = 1;
      int longestStreak = 1;
      int currentXp = 0;

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        currentXp = (data['total_xp'] is int) ? data['total_xp'] as int : 0;
        final lastDateStr = data['last_activity_date'] as String?;
        final savedStreak =
            (data['current_streak'] is int) ? data['current_streak'] as int : 1;
        final savedLongest = (data['longest_streak'] is int)
            ? data['longest_streak'] as int
            : savedStreak;

        if (lastDateStr == todayStr) {
          // Aktivitas sudah tercatat hari ini, pertahankan streak
          currentStreak = savedStreak;
          longestStreak = savedLongest;
        } else if (lastDateStr != null) {
          try {
            final lastDate = DateTime.parse(lastDateStr);
            final differenceInDays = DateTime(now.year, now.month, now.day)
                .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
                .inDays;

            if (differenceInDays == 1) {
              // Berkelanjutan hari berikutnya -> streak naik
              currentStreak = savedStreak + 1;
              longestStreak =
                  currentStreak > savedLongest ? currentStreak : savedLongest;
            } else if (differenceInDays > 1) {
              // Terlewat lebih dari 1 hari -> reset streak ke 1
              currentStreak = 1;
              longestStreak = savedLongest;
            }
          } catch (_) {
            currentStreak = savedStreak;
            longestStreak = savedLongest;
          }
        }
      }

      // Hitung level baru berdasarkan akumulasi total XP
      final newTotalXp = currentXp + xpEarned;
      String newLevel = 'Pemula';
      if (newTotalXp >= 300) {
        newLevel = 'Mahir';
      } else if (newTotalXp >= 100) {
        newLevel = 'Menengah';
      }

      await userRef.set({
        'total_xp': FieldValue.increment(xpEarned),
        'completed_tests': FieldValue.increment(1),
        'communication_index': communicationIndex,
        'kategori_skor': scoreLabel,
        'level': newLevel,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_activity_date': todayStr,
        'last_active_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint(
        '[TestSessionService] User stats updated: +$xpEarned XP, test selesai +1, streak $currentStreak hari (Level: $newLevel)',
      );
    } catch (e) {
      debugPrint('[TestSessionService] Gagal memperbarui user stats: $e');
    }
  }

  /// Kompatibilitas mundur: fungsi lama yang kini juga mendukung [fullResult]
  Future<void> saveTestSession({
    required String userId,
    required String caseId,
    required String tipe,
    required int durasiBicara,
    required num communicationIndex,
    required String kategoriSkor,
    required String transcript,
    SpeechAnalysisResult? fullResult,
  }) async {
    if (fullResult != null) {
      await saveAnalysisResult(
        userId: userId,
        caseId: caseId,
        tipe: tipe,
        result: fullResult,
      );
      return;
    }

    try {
      final docRef = _firestore.collection('test_sessions').doc();
      await docRef.set({
        'session_id': docRef.id,
        'user_id': userId,
        'case_id': caseId,
        'tipe': tipe,
        'durasi_bicara': durasiBicara,
        'communication_index': communicationIndex,
        'kategori_skor': kategoriSkor,
        'transcript': transcript,
        'status': 'completed',
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update statistik profil user secara atomik
      await updateUserStatsAfterTest(
        userId: userId,
        xpEarned: 6,
        communicationIndex: communicationIndex.toInt(),
        scoreLabel: kategoriSkor,
      );

      debugPrint('[TestSessionService] Sesi test dasar & user stats berhasil disimpan.');
    } catch (e) {
      debugPrint('[TestSessionService] Error save test session: $e');
    }
  }

  /// Mengambil riwayat latihan milik user tertentu (diurutkan dari yang terbaru)
  Future<List<TestSessionModel>> getUserHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('test_sessions')
          .where('user_id', isEqualTo: userId)
          .get();

      final list = snapshot.docs
          .map((doc) => TestSessionModel.fromFirestore(doc))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('[TestSessionService] Error get user history: $e');
      return [];
    }
  }

  /// Mengambil sesi tes terakhir (paling baru)
  Future<TestSessionModel?> getLatestTestSession(String userId) async {
    try {
      final history = await getUserHistory(userId);
      if (history.isNotEmpty) {
        return history.first;
      }
      return null;
    } catch (e) {
      debugPrint('[TestSessionService] Error get latest test session: $e');
      return null;
    }
  }
}
