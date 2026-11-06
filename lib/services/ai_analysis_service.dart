import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Model status poin kunci studi kasus
class KeyPointStatus {
  final String text;
  final bool isCovered;
  final List<String> matchedKeywords;

  const KeyPointStatus({
    required this.text,
    required this.isCovered,
    this.matchedKeywords = const [],
  });

  factory KeyPointStatus.fromJson(Map<String, dynamic> json) {
    return KeyPointStatus(
      text: json['nama'] ?? json['text'] ?? '',
      isCovered: json['tercapai'] ?? json['terpenuhi'] ?? json['isCovered'] ?? false,
      matchedKeywords: List<String>.from(
        json['kata_kunci_cocok'] ?? json['kata_cocok'] ?? [],
      ),
    );
  }
}

/// Model rincian nilai 5 metrik bicara
class ScoreBreakdown {
  final int kelancaranJeda; // bobot 30%
  final int kebersihanUcapan; // bobot 25% (fokus)
  final int tempo; // bobot 15%
  final int cakupanIsi; // bobot 20%
  final int struktur; // bobot 10%

  const ScoreBreakdown({
    this.kelancaranJeda = 70,
    this.kebersihanUcapan = 60,
    this.tempo = 85,
    this.cakupanIsi = 75,
    this.struktur = 65,
  });
}

/// Model hasil analisis lengkap suara dari mesin AI Eki
class SpeechAnalysisResult {
  final String transcript;
  final double durationSeconds;
  final int wordsPerMinute;
  final int fillerWordsCount;
  final int communicationIndex;
  final String scoreLabel;
  final int pointsAdded;
  final String keyPointsRatio;
  final List<KeyPointStatus> keyPoints;
  final ScoreBreakdown breakdown;
  final String strengthText;
  final String improvementText;
  final String quoteSample;
  final String suggestionText;
  final String nextLessonTitle;

  const SpeechAnalysisResult({
    required this.transcript,
    required this.durationSeconds,
    required this.wordsPerMinute,
    required this.fillerWordsCount,
    required this.communicationIndex,
    required this.scoreLabel,
    this.pointsAdded = 6,
    required this.keyPointsRatio,
    required this.keyPoints,
    required this.breakdown,
    required this.strengthText,
    required this.improvementText,
    required this.quoteSample,
    required this.suggestionText,
    this.nextLessonTitle = 'Belajar Lesson 2',
  });

  /// Data default simulasi saat server offline / demo
  factory SpeechAnalysisResult.demoDefault() {
    return const SpeechAnalysisResult(
      transcript:
          'Jadi menurut saya, eee kita perlu mempertimbangkan solusi alternatif karena waktunya terbatas.',
      durationSeconds: 52.0,
      wordsPerMinute: 142,
      fillerWordsCount: 6,
      communicationIndex: 70,
      scoreLabel: 'Baik',
      pointsAdded: 6,
      keyPointsRatio: '3/4',
      keyPoints: [
        KeyPointStatus(
          text: 'Menyebutkan konteks masalah secara jelas',
          isCovered: true,
        ),
        KeyPointStatus(
          text: 'Memberikan argumen utama yang runtut',
          isCovered: true,
        ),
        KeyPointStatus(
          text: 'Mengajukan solusi alternatif untuk rekan tim',
          isCovered: true,
        ),
        KeyPointStatus(
          text: 'Menyimpulkan kesepakatan di akhir bicara',
          isCovered: false,
        ),
      ],
      breakdown: ScoreBreakdown(),
      strengthText: 'Kamu langsung menyebut ide utama di awal.',
      improvementText: 'Kurangi filler saat berpikir.',
      quoteSample: '“eee, jadi menurutku, eee...”',
      suggestionText:
          '“Menurutku, idenya perlu diuji dulu karena waktunya terbatas.”',
      nextLessonTitle: 'Belajar Lesson 2',
    );
  }
}

/// Service komunikasi Flutter ke Mesin AI Eki (FastAPI + Groq)
class AiAnalysisService {
  AiAnalysisService._();
  static final AiAnalysisService instance = AiAnalysisService._();

  String _activeBaseUrl = 'http://localhost:8000';

  String get baseUrl => _activeBaseUrl;

  /// Daftar kandidat URL server berdasarkan platform
  List<String> get candidateUrls {
    if (kIsWeb) {
      // Di Web (browser), coba 127.0.0.1:8000 (IPv4 langsung) baru localhost:8000
      return ['http://127.0.0.1:8000', 'http://localhost:8000'];
    }
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return [
          'http://10.0.2.2:8000', // Android Emulator ke host PC
          'http://127.0.0.1:8000',
          'http://localhost:8000',
        ];
      }
    } catch (_) {}
    // Desktop Windows / iOS / macOS
    return ['http://127.0.0.1:8000', 'http://localhost:8000'];
  }

  /// Cek apakah server Python Eki aktif di salah satu kandidat host
  Future<bool> isServerOnline() async {
    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse('$url/');
        final res = await http.get(uri).timeout(const Duration(milliseconds: 2500));
        if (res.statusCode == 200) {
          _activeBaseUrl = url;
          debugPrint('[AiAnalysisService] Terhubung ke Server AI aktif di $_activeBaseUrl');
          return true;
        }
      } catch (e) {
        debugPrint('[AiAnalysisService] Server check di $url gagal: $e');
      }
    }
    return false;
  }

  /// Mengirim rekaman audio ke server Eki dan mengolah hasilnya
  Future<SpeechAnalysisResult> analyzeRecording({
    String? audioPath,
    List<int>? audioBytes,
    String caseId = 'proyek_terlambat',
  }) async {
    try {
      final online = await isServerOnline();
      if (!online) {
        debugPrint('[AiAnalysisService] Server AI offline, menggunakan hasil demo.');
        return SpeechAnalysisResult.demoDefault();
      }

      // Ambil audio bytes dari blob URL (Web) atau File (Native)
      List<int>? bytes = audioBytes;
      if ((bytes == null || bytes.isEmpty) && audioPath != null && audioPath.isNotEmpty) {
        if (kIsWeb || audioPath.startsWith('blob:') || audioPath.startsWith('http')) {
          try {
            debugPrint('[AiAnalysisService] Mengambil audio bytes dari Web blob URL: $audioPath');
            final blobRes = await http.get(Uri.parse(audioPath)).timeout(const Duration(seconds: 30));
            if (blobRes.statusCode == 200) {
              bytes = blobRes.bodyBytes;
              debugPrint('[AiAnalysisService] Berhasil mengambil ${bytes.length} bytes audio');
            } else {
              debugPrint('[AiAnalysisService] Gagal fetch blob: status ${blobRes.statusCode}');
            }
          } catch (e) {
            debugPrint('[AiAnalysisService] Error mengambil blob audio: $e');
          }
        } else if (!kIsWeb) {
          try {
            final f = io.File(audioPath);
            if (f.existsSync()) {
              bytes = await f.readAsBytes();
              debugPrint('[AiAnalysisService] Berhasil membaca file lokal: ${bytes.length} bytes');
            }
          } catch (e) {
            debugPrint('[AiAnalysisService] Error membaca file lokal: $e');
          }
        }
      }

      // 1. Transkripsi suara melalui POST /transkrip
      final transcriptData = await _uploadAudioToTranskrip(bytes);
      final text = (transcriptData['teks'] as String?)?.trim() ?? '';
      final durasi = (transcriptData['durasi'] as num?)?.toDouble() ?? 30.0;
      debugPrint('[AiAnalysisService] Hasil transkripsi dari server: "$text" (durasi: $durasi detik)');

      // 2. Evaluasi Cakupan Studi Kasus melalui POST /nilai_cakupan
      final cakupanData = await _evaluasiCakupan(text, caseId);

      // 3. Evaluasi Kualitas Isi & Feedback AI melalui POST /nilai_isi
      final feedbackData = await _evaluasiIsi(text);

      // 4. Hitung Skor Keseluruhan & Communication Index
      return _buildResult(
        transcript: text,
        duration: durasi,
        transcriptData: transcriptData,
        cakupanData: cakupanData,
        feedbackData: feedbackData,
      );
    } catch (e) {
      debugPrint('[AiAnalysisService] Terjadi error analisis: $e');
      return SpeechAnalysisResult.demoDefault();
    }
  }

  // ── Helper API Calls ──────────────────────────────────

  Future<Map<String, dynamic>> _uploadAudioToTranskrip(List<int>? bytes) async {
    try {
      if (bytes == null || bytes.isEmpty) {
        debugPrint('[AiAnalysisService] Peringatan: Data audio kosong!');
        return {'teks': '', 'durasi': 0.0};
      }

      debugPrint('[AiAnalysisService] Upload audio (${bytes.length} bytes) ke $baseUrl/transkrip');

      final uri = Uri.parse('$baseUrl/transkrip');
      final request = http.MultipartRequest('POST', uri);
      final isWav = bytes.length >= 4 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46;
      final ext = isWav ? 'wav' : 'webm';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'rekaman.$ext',
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('[AiAnalysisService] Server transkrip respons: $decoded');
        return decoded;
      }
      debugPrint('[AiAnalysisService] Upload transkrip HTTP ${response.statusCode}: ${response.body}');
      return {'teks': '', 'durasi': 0.0};
    } catch (e) {
      debugPrint('[AiAnalysisService] Error upload transkrip: $e');
      return {'teks': '', 'durasi': 0.0};
    }
  }

  Future<Map<String, dynamic>> _evaluasiCakupan(String text, String caseId) async {
    try {
      final uri = Uri.parse('$baseUrl/nilai_cakupan');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'teks': text, 'kasus_id': caseId}),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        debugPrint('[AiAnalysisService] Server cakupan respons: $decoded');
        return decoded;
      }
      debugPrint('[AiAnalysisService] Evaluasi cakupan HTTP ${res.statusCode}: ${res.body}');
      return {};
    } catch (e) {
      debugPrint('[AiAnalysisService] Error evaluasi cakupan: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _evaluasiIsi(String text) async {
    try {
      final uri = Uri.parse('$baseUrl/nilai_isi');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'teks': text, 'naskah': '', 'topik': ''}),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        debugPrint('[AiAnalysisService] Server isi respons: $decoded');
        return decoded;
      }
      debugPrint('[AiAnalysisService] Evaluasi isi HTTP ${res.statusCode}: ${res.body}');
      return {};
    } catch (e) {
      debugPrint('[AiAnalysisService] Error evaluasi isi: $e');
      return {};
    }
  }

  SpeechAnalysisResult _buildResult({
    required String transcript,
    required double duration,
    required Map<String, dynamic> transcriptData,
    required Map<String, dynamic> cakupanData,
    required Map<String, dynamic> feedbackData,
  }) {
    // 1. Kata dan WPM
    final kataList = transcriptData['kata'] as List<dynamic>? ?? [];
    final totalWords = kataList.isNotEmpty
        ? kataList.length
        : transcript.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final safeDuration = duration > 1.0 ? duration : 30.0;
    final wpm = ((totalWords / safeDuration) * 60).round();

    // 2. Hitung filler words (e.g. eee, hmm, anu, dll)
    final pengisiRegex = RegExp(
      r'\b(e+h*m*|e+m+|h+m+|u+m+|a+h+|e+r+|anu|gitu|kayak|kayaknya|nah|pokoknya)\b',
      caseSensitive: false,
    );
    final fillerMatches = pengisiRegex.allMatches(transcript);
    final fillerCount = fillerMatches.length;
    final fillersPerMin = ((fillerCount / safeDuration) * 60).round();

    // 3. Poin kunci (studi kasus)
    final poinListRaw = cakupanData['rincian_poin'] as List<dynamic>? ??
        cakupanData['rincian'] as List<dynamic>? ??
        [];
    final List<KeyPointStatus> keyPoints = [];
    int coveredCount = 0;

    for (final item in poinListRaw) {
      if (item is Map<String, dynamic>) {
        final kp = KeyPointStatus.fromJson(item);
        keyPoints.add(kp);
        if (kp.isCovered) coveredCount++;
      }
    }

    // Jika poin kunci belum terdeteksi dari kata kunci, buat poin dinamis berdasarkan panjang ucapan
    if (keyPoints.isEmpty) {
      keyPoints.addAll([
        KeyPointStatus(text: 'Menyebutkan konteks masalah secara jelas', isCovered: totalWords >= 3),
        KeyPointStatus(text: 'Memberikan argumen utama yang runtut', isCovered: totalWords >= 10),
        KeyPointStatus(text: 'Mengajukan solusi alternatif untuk rekan tim', isCovered: totalWords >= 20),
        KeyPointStatus(text: 'Menyimpulkan kesepakatan di akhir bicara', isCovered: totalWords >= 35),
      ]);
      coveredCount = keyPoints.where((k) => k.isCovered).length;
    }

    final keyPointsRatio = '$coveredCount/${keyPoints.length}';

    // 4. Hitung 5 Metrik Bicara Dinamis Menyesuaikan Hasil Tes & Suara Asli
    // A. Kebersihan ucapan (bobot 25%): Semakin sedikit filler words, semakin tinggi nilainya
    final int skorKebersihan = (96 - (fillersPerMin * 6)).clamp(40, 98);

    // B. Tempo (bobot 15%): Ideal percakapan 120-155 WPM
    final int skorTempo;
    if (wpm >= 115 && wpm <= 165) {
      skorTempo = (94 - ((wpm - 135).abs() * 0.5)).round().clamp(80, 96);
    } else if (wpm < 115) {
      skorTempo = (55 + (wpm * 0.3)).round().clamp(40, 85);
    } else {
      skorTempo = (94 - ((wpm - 165) * 0.6)).round().clamp(45, 88);
    }

    // C. Cakupan isi (bobot 20%): Berdasarkan kesesuaian poin kunci kasus
    final int skorCakupan = cakupanData['skor_cakupan'] is num
        ? (cakupanData['skor_cakupan'] as num).toInt()
        : keyPoints.isNotEmpty
            ? ((coveredCount / keyPoints.length) * 100).round()
            : 75;

    // D. Struktur (bobot 10%): Struktur argumentasi dan kejelasan
    final int skorStruktur = feedbackData['skor_isi'] is num
        ? ((feedbackData['skor_isi'] as num).toInt() * 0.9 + (coveredCount >= 2 ? 10 : 0)).round().clamp(40, 95)
        : (coveredCount >= 3 ? 85 : coveredCount >= 2 ? 72 : 55);

    // E. Kelancaran jeda (bobot 30%): Kombinasi tempo dan kebersihan ucapan
    final int skorKelancaran = (
      (skorKebersihan * 0.4) +
      (skorTempo * 0.4) +
      (totalWords > 15 ? 20 : totalWords > 5 ? 10 : 0)
    ).round().clamp(45, 96);

    // F. TOTAL COMMUNICATION INDEX (Bobot: Kelancaran 30% + Kebersihan 25% + Cakupan 20% + Tempo 15% + Struktur 10%)
    final communicationIndex = (
      (skorKelancaran * 0.30) +
      (skorKebersihan * 0.25) +
      (skorCakupan * 0.20) +
      (skorTempo * 0.15) +
      (skorStruktur * 0.10)
    ).round().clamp(30, 98);

    // Label dinamis sesuai Communication Index
    final String label;
    if (communicationIndex >= 85) {
      label = 'Luar Biasa';
    } else if (communicationIndex >= 70) {
      label = 'Baik';
    } else if (communicationIndex >= 55) {
      label = 'Cukup';
    } else {
      label = 'Perlu Latihan';
    }

    final int pointsAdded = (communicationIndex / 12).round().clamp(3, 10);

    // 5. Feedback dari Groq LLM
    final kekuatanList = feedbackData['kekuatan'] as List<dynamic>? ?? [];
    final strength = kekuatanList.isNotEmpty
        ? kekuatanList.first.toString()
        : (skorKebersihan >= 75 ? 'Ucapanmu terdengar jelas dan minim kata pengisi.' : 'Kamu langsung menyampaikan inti pembicaraan di awal.');

    final perbaikanList = feedbackData['perbaikan'] as List<dynamic>? ?? [];
    String improvement = fillerCount > 0 ? 'Kurangi filler saat berpikir.' : 'Latih variasi intonasi bicara.';
    String quote = fillerCount > 0 ? '“eee, jadi menurutku, eee...”' : '“Jadi menurut saya...”';
    String suggestion = '“Menurutku, kita bisa membagi tugas agar solusinya lebih jelas.”';

    if (perbaikanList.isNotEmpty && perbaikanList.first is Map) {
      final p = perbaikanList.first as Map<String, dynamic>;
      improvement = p['masalah']?.toString() ?? improvement;
      if (p['bagian'] != null) quote = '“${p['bagian']}”';
      if (p['saran'] != null) suggestion = '“${p['saran']}”';
    }

    // 6. Transkrip asli yang ditampilkan
    final displayTranscript = transcript.trim().isNotEmpty
        ? transcript.trim()
        : 'Belum ada ucapan yang terdeteksi pada rekaman suara.';

    return SpeechAnalysisResult(
      transcript: displayTranscript,
      durationSeconds: safeDuration,
      wordsPerMinute: wpm > 0 ? wpm : 130,
      fillerWordsCount: fillerCount,
      communicationIndex: communicationIndex,
      scoreLabel: label,
      pointsAdded: pointsAdded,
      keyPointsRatio: keyPointsRatio,
      keyPoints: keyPoints,
      breakdown: ScoreBreakdown(
        kelancaranJeda: skorKelancaran,
        kebersihanUcapan: skorKebersihan,
        tempo: skorTempo,
        cakupanIsi: skorCakupan,
        struktur: skorStruktur,
      ),
      strengthText: strength,
      improvementText: improvement,
      quoteSample: quote,
      suggestionText: suggestion,
    );
  }
}
