import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'microphone_permission_screen.dart';
import 'recording_screen.dart';

class CaseStudySelectionScreen extends StatefulWidget {
  final String initialCategory;

  const CaseStudySelectionScreen({
    super.key,
    this.initialCategory = 'Peer',
  });

  @override
  State<CaseStudySelectionScreen> createState() =>
      _CaseStudySelectionScreenState();
}

class _CaseStudyModel {
  final String number;
  final String title;
  final String situation;
  final String instruction;
  final int durationSeconds;
  final String duration;
  final String caseId;

  const _CaseStudyModel({
    required this.number,
    required this.title,
    required this.situation,
    required this.instruction,
    required this.durationSeconds,
    required this.duration,
    required this.caseId,
  });

  String get prepDuration => '15 dtk persiapan';
  String get description => '$situation $instruction';
}

class _CaseStudySelectionScreenState extends State<CaseStudySelectionScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryIndigo = Color(0xFF4F46E5);

  late String _selectedCategory;
  int _selectedIndex = 2; // Default ke Kasus 03 (index 2) sesuai Figma
  double _currentDisplayIndex = 2.0;

  late AnimationController _animController;
  late Animation<double> _indexAnimation;

  // ── Database 15 Studi Kasus Resmi Sesuai Kurikulum TAMPIL ──
  final Map<String, List<_CaseStudyModel>> _caseData = {
    // ── 1. Daily Communication (01 - 05) ──
    'Daily': const [
      _CaseStudyModel(
        number: 'KASUS 01',
        title: 'Berkenalan di acara baru',
        situation: 'Kamu hadir di acara kampus dan belum kenal siapa pun.',
        instruction: 'Perkenalkan dirimu dan mulai obrolan singkat.',
        durationSeconds: 30,
        duration: '30 dtk',
        caseId: 'daily_01',
      ),
      _CaseStudyModel(
        number: 'KASUS 02',
        title: 'Menolak ajakan dengan sopan',
        situation:
            'Temanmu mengajak nongkrong, padahal kamu harus mengerjakan tugas.',
        instruction: 'Tolak dengan sopan dan tawarkan waktu lain.',
        durationSeconds: 45,
        duration: '45 dtk',
        caseId: 'daily_02',
      ),
      _CaseStudyModel(
        number: 'KASUS 03',
        title: 'Meminta bantuan dosen',
        situation:
            'Kamu belum paham materi dan ingin bertanya di luar jam kuliah.',
        instruction:
            'Sampaikan kesulitanmu dan minta waktu bimbingan dengan jelas.',
        durationSeconds: 60,
        duration: '60 dtk',
        caseId: 'daily_03',
      ),
      _CaseStudyModel(
        number: 'KASUS 04',
        title: 'Menyampaikan keluhan layanan',
        situation: 'Pesananmu salah dan kamu menghubungi penjual.',
        instruction:
            'Jelaskan masalahnya dengan tenang dan sebutkan solusi yang kamu minta.',
        durationSeconds: 75,
        duration: '75 dtk',
        caseId: 'daily_04',
      ),
      _CaseStudyModel(
        number: 'KASUS 05',
        title: 'Menjelaskan alasan terlambat',
        situation:
            'Kamu terlambat ke wawancara magang dan harus menjelaskannya.',
        instruction: 'Minta maaf, jelaskan singkat, lalu alihkan ke hal positif.',
        durationSeconds: 90,
        duration: '90 dtk',
        caseId: 'daily_05',
      ),
    ],

    // ── 2. Peer Communication (01 - 05) ──
    'Peer': const [
      _CaseStudyModel(
        number: 'KASUS 01',
        title: 'Memperkenalkan diri di kelompok',
        situation:
            'Kamu masuk kelompok tugas baru yang anggotanya belum kamu kenal.',
        instruction: 'Perkenalkan dirimu dan peranmu dalam tugas.',
        durationSeconds: 30,
        duration: '30 dtk',
        caseId: 'peer_01',
      ),
      _CaseStudyModel(
        number: 'KASUS 02',
        title: 'Menawarkan ide dalam diskusi',
        situation: 'Kelompokmu bingung menentukan topik presentasi.',
        instruction: 'Sampaikan satu ide dengan alasan singkat.',
        durationSeconds: 45,
        duration: '45 dtk',
        caseId: 'peer_02',
      ),
      _CaseStudyModel(
        number: 'KASUS 03',
        title: 'Menjelaskan ide ke teman',
        situation: 'Temanmu belum paham idemu.',
        instruction: 'Jelaskan idemu dengan runtut dan mudah diikuti.',
        durationSeconds: 60,
        duration: '60 dtk',
        caseId: 'peer_03',
      ),
      _CaseStudyModel(
        number: 'KASUS 04',
        title: 'Menegur teman yang mendominasi',
        situation: 'Satu anggota terus memotong dan menguasai pembicaraan.',
        instruction:
            'Sampaikan pendapatmu dengan sopan dan beri ruang bagi yang lain.',
        durationSeconds: 75,
        duration: '75 dtk',
        caseId: 'peer_04',
      ),
      _CaseStudyModel(
        number: 'KASUS 05',
        title: 'Menyelesaikan beda pendapat',
        situation: 'Dua anggota berselisih soal pembagian tugas.',
        instruction:
            'Jadi penengah, rangkum kedua sisi, dan usulkan jalan tengah.',
        durationSeconds: 90,
        duration: '90 dtk',
        caseId: 'peer_05',
      ),
    ],

    // ── 3. Public Speaking (01 - 05) ──
    'Public': const [
      _CaseStudyModel(
        number: 'KASUS 01',
        title: 'Membuka presentasi di kelas',
        situation:
            'Kamu mendapat giliran pertama presentasi tugas kelompok.',
        instruction: 'Sapa audiens, sebutkan topik dan tujuanmu.',
        durationSeconds: 45,
        duration: '45 dtk',
        caseId: 'public_01',
      ),
      _CaseStudyModel(
        number: 'KASUS 02',
        title: 'Memaparkan satu gagasan utama',
        situation:
            'Kamu diminta menjelaskan satu gagasan dalam seminar kecil.',
        instruction: 'Sampaikan dengan pembuka, isi, dan penutup.',
        durationSeconds: 60,
        duration: '60 dtk',
        caseId: 'public_02',
      ),
      _CaseStudyModel(
        number: 'KASUS 03',
        title: 'Menjawab pertanyaan penonton',
        situation:
            'Seorang peserta bertanya kritis soal hasil presentasimu.',
        instruction: 'Jawab dengan tenang, tepat, dan beri satu contoh.',
        durationSeconds: 75,
        duration: '75 dtk',
        caseId: 'public_03',
      ),
      _CaseStudyModel(
        number: 'KASUS 04',
        title: 'Mengajak audiens bertindak',
        situation:
            'Kamu berbicara di acara organisasi untuk mengajak mahasiswa ikut kegiatan.',
        instruction: 'Yakinkan dengan alasan kuat dan ajakan yang jelas.',
        durationSeconds: 90,
        duration: '90 dtk',
        caseId: 'public_04',
      ),
      _CaseStudyModel(
        number: 'KASUS 05',
        title: 'Presentasi singkat tanpa catatan',
        situation:
            'Kamu mendapat kesempatan memaparkan ide kepada juri tanpa naskah.',
        instruction:
            'Sampaikan idemu secara runtut dan menarik dalam waktu terbatas.',
        durationSeconds: 120,
        duration: '120 dtk',
        caseId: 'public_05',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedIndex = 2;
      _currentDisplayIndex = 2.0;
    });
  }

  void _selectNodeIndex(int index) {
    if (index < 0 || index >= 5) return;
    if (_selectedIndex == index && _currentDisplayIndex == index.toDouble()) {
      return;
    }

    final startIndex = _currentDisplayIndex;
    final targetIndex = index.toDouble();

    _indexAnimation = Tween<double>(
      begin: startIndex,
      end: targetIndex,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _currentDisplayIndex = _indexAnimation.value;
        });
      });

    setState(() {
      _selectedIndex = index;
    });

    _animController.forward(from: 0.0);
  }

  void _startTest() {
    final currentCases = _caseData[_selectedCategory] ?? _caseData['Peer']!;
    final currentCase = currentCases[_selectedIndex];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MicrophonePermissionScreen(
          onPermissionGranted: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => RecordingScreen(
                  caseId: currentCase.caseId,
                  caseTitle: currentCase.title,
                  contextTitle: _selectedCategory.toUpperCase(),
                  caseDescription: currentCase.situation,
                  casePrompt: currentCase.instruction,
                  caseNumber: currentCase.number,
                  maxDurationSeconds: currentCase.durationSeconds,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCases = _caseData[_selectedCategory] ?? _caseData['Peer']!;
    final currentCase = currentCases[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. TOP BAR (< Back & Sisa tes hari ini 2/3) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sisa tes hari ini ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: '2/3',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 2. JUDUL HEADER ("Pilih studi kasus") ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pilih studi kasus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── 3. SEGMENTED CATEGORY TABS (Daily, Peer, Public) DENGAN KOTAK PER TOMBOL ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 52,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildCategoryTab('Daily'),
                    const SizedBox(width: 8),
                    _buildCategoryTab('Peer'),
                    const SizedBox(width: 8),
                    _buildCategoryTab('Public'),
                  ],
                ),
              ),
            ),

            // ── JARAK LEGA ANTARA TAB KE KOTAK KASUS (34px - SESUAI FIGMA) ──
            const SizedBox(height: 34),

            // ── 4. KARTU DETAIL KASUS YANG AKTIF (BISA DI-SWIPE KE SAMPING) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0.0;
                  if (velocity < -200 && _selectedIndex < 4) {
                    _selectNodeIndex(_selectedIndex + 1);
                  } else if (velocity > 200 && _selectedIndex > 0) {
                    _selectNodeIndex(_selectedIndex - 1);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey<String>(
                          '${_selectedCategory}_$_selectedIndex'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label KASUS 0X
                        Text(
                          currentCase.number,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Judul Kasus
                        Text(
                          currentCase.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Deskripsi Kasus
                        Text(
                          currentCase.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Garis batas pemisah halus persis Figma
                        const Divider(
                          color: Color(0xFFF1F5F9),
                          height: 1,
                          thickness: 1,
                        ),

                        const SizedBox(height: 14),

                        // Info Durasi & Waktu Persiapan
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentCase.duration,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.hourglass_empty_rounded,
                              size: 16,
                              color: Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentCase.prepDuration,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 5. BUSUR SCROLLING SEJAJAR 100% IDENTIK DENGAN FIGMA ──
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0.0;
                  if (velocity < -200 && _selectedIndex < 4) {
                    _selectNodeIndex(_selectedIndex + 1);
                  } else if (velocity > 200 && _selectedIndex > 0) {
                    _selectNodeIndex(_selectedIndex - 1);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final availableHeight = constraints.maxHeight;

                    // Posisi diturunkan ke bawah (~45px lebih rendah) agar ngepres dengan tombol Mulai tes
                    final apexY = (availableHeight * 0.28).clamp(92.0, 115.0);
                    final radius = width * 0.55; // Radius ~215px agar sejajar dan anggun
                    final centerY = apexY + 28.0 + radius; // Pusat lingkaran

                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // 1. Lukisan 4 Busur (Dotted Atas, Solid Tengah, Solid Bawah, Faint Bawah)
                        //    serta 14 Titik Jarum Radial yang Renggang & Bersih
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DialArcPainter(
                              radius: radius,
                              centerY: centerY,
                              apexY: apexY,
                            ),
                          ),
                        ),

                        // 2. Indikator Panah Segitiga ▲ Presisi di Bawah Lingkaran Puncak 03
                        Positioned(
                          left: (width / 2) - 5,
                          top: apexY + 54.0 - 2.0,
                          child: ClipPath(
                            clipper: _TriangleClipper(),
                            child: Container(
                              width: 10,
                              height: 7,
                              color: _primaryIndigo,
                            ),
                          ),
                        ),

                        // 3. Node Lingkaran 01 - 05 (Besar di puncak, Sedang di sisi, Kecil di sayap)
                        ..._buildDialNodes(width, centerY, radius, apexY),

                        // ── 6. TOMBOL MULAI TEST MELAYANG DI BAWAH ──
                        Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _startTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryIndigo,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor:
                                    _primaryIndigo.withValues(alpha: 0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Mulai tes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB KATEGORI (Daily, Peer, Public)
  // Masing-masing opsi memiliki kotak tombol individual sesuai Figma
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategoryTab(String category) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onCategoryChanged(category),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _primaryIndigo : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _primaryIndigo.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DIAL NODES: LINGKARAN KECIL, SEDANG, BESAR SESUAI FIGMA
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildDialNodes(
      double width, double centerY, double radius, double apexY) {
    final centerX = width / 2;
    final labels = ['01', '02', '03', '04', '05'];
    final widgets = <Widget>[];

    // Sudut langkah: 28 derajat (0.488 radian) per langkah
    const stepAngle = 0.488;

    for (int i = 0; i < 5; i++) {
      final angle = (i - _currentDisplayIndex) * stepAngle;

      // Hanya render yang masuk dalam tampilan visual layar
      if (angle.abs() > 1.25) continue;

      final nodeX = centerX + radius * math.sin(angle);
      final nodeY = centerY - radius * math.cos(angle);

      final absAngle = angle.abs();
      final isBesar = absAngle < 0.15;
      final isSedang = absAngle >= 0.15 && absAngle < 0.70;

      // Ukuran presisi:
      // Besar (56px) - Lingkaran Puncak Ungu
      // Sedang (44px) - Lingkaran Pengapit Hitam
      // Kecil (38px) - Lingkaran Sayap Abu-abu
      final nodeSize = isBesar ? 56.0 : (isSedang ? 44.0 : 38.0);

      widgets.add(
        Positioned(
          left: nodeX - (nodeSize / 2),
          top: nodeY - (nodeSize / 2),
          child: GestureDetector(
            onTap: () => _selectNodeIndex(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                color: isBesar ? _primaryIndigo : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isBesar
                      ? Colors.white
                      : (isSedang
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1)),
                  width: isBesar ? 2.5 : (isSedang ? 1.6 : 1.2),
                ),
                boxShadow: isBesar
                    ? [
                        const BoxShadow(
                          color: Color(0xFFEEF2FF),
                          blurRadius: 0,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: _primaryIndigo.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: isBesar ? 18 : (isSedang ? 14.5 : 12.5),
                    fontWeight: isBesar
                        ? FontWeight.w800
                        : (isSedang ? FontWeight.w700 : FontWeight.w600),
                    color: isBesar
                        ? Colors.white
                        : (isSedang
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM PAINTER: BUSUR PERSIS FIGMA (DOTTED ATAS, SOLID TENGAH, SOLID BAWAH & 14 JARUM BERSIH)
// ─────────────────────────────────────────────────────────────
class _DialArcPainter extends CustomPainter {
  final double radius;
  final double centerY;
  final double apexY;

  const _DialArcPainter({
    required this.radius,
    required this.centerY,
    required this.apexY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // 1. Busur Atas Dotted (Titik halus melengkung di atas node)
    final dotPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;
    final dotRadius = radius + 22.0;
    for (double a = -1.15; a <= 1.15; a += 0.038) {
      final x = centerX + dotRadius * math.sin(a);
      final y = centerY - dotRadius * math.cos(a);
      canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
    }

    // 2. Busur Utama Solid (Melintasi pusat lingkaran node 01, 02, 04, 05)
    final mainArcPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final mainRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );
    canvas.drawArc(
      mainRect,
      -math.pi / 2 - 1.20,
      2.40,
      false,
      mainArcPaint,
    );

    // 3. Busur Bawah Solid (Inner Arc)
    final innerRadius = radius - 44.0;
    final innerArcPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final innerRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: innerRadius,
    );
    canvas.drawArc(
      innerRect,
      -math.pi / 2 - 1.15,
      2.30,
      false,
      innerArcPaint,
    );

    // 4. Busur Faint Paling Bawah (Lingkaran halus di belakang tombol Mulai tes)
    final bottomFaintRadius = innerRadius - 40.0;
    final faintArcPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final faintRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: bottomFaintRadius,
    );
    canvas.drawArc(
      faintRect,
      -math.pi / 2 - 1.0,
      2.0,
      false,
      faintArcPaint,
    );

    // 5. Tepat 14 Titik Jarum Radial Renggang & Bersih Persis Figma
    //    (7 di kiri, 7 di kanan, tanpa garis rapat ala penggaris)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0
      ..color = const Color(0xFFE2E8F0);

    // Sudut jarum: ±0.15, ±0.30, ±0.488 (dekat 02/04), ±0.65, ±0.80, ±0.976 (dekat 01/05), ±1.12
    const tickAngles = [
      -1.12, -0.976, -0.80, -0.65, -0.488, -0.30, -0.15,
      0.15, 0.30, 0.488, 0.65, 0.80, 0.976, 1.12,
    ];

    for (final a in tickAngles) {
      final isMajor = (a.abs() - 0.488).abs() < 0.02 || (a.abs() - 0.976).abs() < 0.02;
      final tickLength = isMajor ? 18.0 : 13.0;

      final x1 = centerX + innerRadius * math.sin(a);
      final y1 = centerY - innerRadius * math.cos(a);
      final x2 = centerX + (innerRadius + tickLength) * math.sin(a);
      final y2 = centerY - (innerRadius + tickLength) * math.cos(a);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialArcPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.centerY != centerY ||
      oldDelegate.apexY != apexY;
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Puncak segitiga atas
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
