import 'package:cloud_firestore/cloud_firestore.dart';

class TestSessionModel {
  final String id;
  final String sessionId;
  final String userId;
  final String caseId;
  final String tipe;
  final int durasiBicara;
  final num communicationIndex;
  final String kategoriSkor;
  final String transcript;
  final String status;
  final DateTime createdAt;

  TestSessionModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.caseId,
    required this.tipe,
    required this.durasiBicara,
    required this.communicationIndex,
    required this.kategoriSkor,
    required this.transcript,
    required this.status,
    required this.createdAt,
  });

  factory TestSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TestSessionModel(
      id: doc.id,
      sessionId: data['session_id'] ?? '',
      userId: data['user_id'] ?? '',
      caseId: data['case_id'] ?? '',
      tipe: data['tipe'] ?? 'test',
      durasiBicara: data['durasi_bicara'] is int ? data['durasi_bicara'] : 0,
      communicationIndex: data['communication_index'] ?? 0,
      kategoriSkor: data['kategori_skor'] ?? 'Perlu Latihan',
      transcript: data['transcript'] ?? '',
      status: data['status'] ?? 'completed',
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
      'tipe': tipe,
      'durasi_bicara': durasiBicara,
      'communication_index': communicationIndex,
      'kategori_skor': kategoriSkor,
      'transcript': transcript,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

class TestSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Menyimpan hasil sesi latihan baru setelah user selesai bicara
  Future<void> saveTestSession({
    required String userId,
    required String caseId,
    required String tipe,
    required int durasiBicara,
    required num communicationIndex,
    required String kategoriSkor,
    required String transcript,
  }) async {
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
      print('Sesi test berhasil disimpan ke Firestore!');
    } catch (e) {
      print('Error save test session: $e');
    }
  }

  // Mengambil riwayat latihan milik user tertentu
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
      print('Error get user history: $e');
      return [];
    }
  }

  // Mengambil sesi tes terakhir (paling baru)
  Future<TestSessionModel?> getLatestTestSession(String userId) async {
    try {
      final history = await getUserHistory(userId);
      if (history.isNotEmpty) {
        return history.first;
      }
      return null;
    } catch (e) {
      print('Error get latest test session: $e');
      return null;
    }
  }
}
