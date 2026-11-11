import 'package:cloud_firestore/cloud_firestore.dart';

// Model Data CaseStudy sesuai standar PRD
class CaseStudyModel {
  final String id;
  final String caseId;
  final String judul;
  final String konteks;
  final String kategori;
  final String tingkatKesulitan;
  final int durasiMaks;
  final String status;
  final List<dynamic> keyPoints;

  CaseStudyModel({
    required this.id,
    required this.caseId,
    required this.judul,
    required this.konteks,
    required this.kategori,
    required this.tingkatKesulitan,
    required this.durasiMaks,
    required this.status,
    required this.keyPoints,
  });

  // Mengubah data dari Firestore ke objek Dart
  factory CaseStudyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CaseStudyModel(
      id: doc.id,
      caseId: data['case_id'] ?? '',
      judul: data['judul'] ?? '',
      konteks: data['konteks'] ?? '',
      kategori: data['kategori'] ?? 'Daily',
      tingkatKesulitan: data['tingkat_kesulitan'] ?? 'pemula',
      durasiMaks: data['durasi_maks'] is int ? data['durasi_maks'] : 60,
      status: data['status'] ?? 'draft',
      keyPoints: data['key_points'] ?? [],
    );
  }

  // Mengubah objek Dart ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'case_id': caseId,
      'judul': judul,
      'konteks': konteks,
      'kategori': kategori,
      'tingkat_kesulitan': tingkatKesulitan,
      'durasi_maks': durasiMaks,
      'status': status,
      'key_points': keyPoints,
    };
  }
}

// Service untuk mengambil dan mengelola studi kasus dari Firestore
class CaseStudyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil semua studi kasus yang berstatus "published"
  Future<List<CaseStudyModel>> getPublishedCaseStudies() async {
    try {
      final querySnapshot = await _firestore
          .collection('CaseStudies')
          .where('status', isEqualTo: 'published')
          .get();

      return querySnapshot.docs
          .map((doc) => CaseStudyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error mengambil studi kasus: $e');
      return [];
    }
  }

  // Mengambil studi kasus berdasarkan kategori (Daily, Peer, Public)
  Future<List<CaseStudyModel>> getCaseStudiesByCategory(String kategori) async {
    try {
      final querySnapshot = await _firestore
          .collection('CaseStudies')
          .where('status', isEqualTo: 'published')
          .where('kategori', isEqualTo: kategori)
          .get();

      return querySnapshot.docs
          .map((doc) => CaseStudyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error mengambil studi kasus kategori $kategori: $e');
      return [];
    }
  }

  // Mengambil satu studi kasus berdasarkan ID kasus (misal: "case_001")
  Future<CaseStudyModel?> getCaseStudyByCaseId(String caseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('CaseStudies')
          .where('case_id', isEqualTo: caseId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CaseStudyModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error mengambil studi kasus $caseId: $e');
      return null;
    }
  }
}
