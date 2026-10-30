import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/lesson/lesson_app_bar.dart';
import '../widgets/lesson/lesson_button.dart';
import '../widgets/lesson/lesson_steps.dart';

/// Alur satu lesson yang isinya DINAMIS dari Firestore (field `blocks`),
/// yang dikelola admin lewat dashboard CMS. Tiap blok = satu halaman,
/// jumlah & urutannya bebas dikustom admin:
///   - blok 'teks' / 'materi' -> halaman baca teks
///   - blok 'video'  -> pemutar video tertanam
///   - blok 'gambar' -> halaman gambar (URL)
///   - blok 'kuis'   -> 1 soal pilihan (opsi A..F bebas jumlah)
///   - langkah akhir -> "Lesson selesai!" (+10 XP)
class LessonScreen extends StatefulWidget {
  /// Lesson lengkap dari Firestore. Bila null, dipakai konten demo
  /// (dipakai mis. tombol "Lanjut belajar" di Home).
  final LessonModel? lesson;

  /// Fallback saat [lesson] null: nomor & tag untuk app bar.
  final int lessonNumber;
  final String lessonTag;

  /// True bila lesson ini dibuka ulang padahal sudah selesai:
  /// materi tetap bisa dibaca, tapi XP tidak diberikan dua kali.
  final bool rewardAlreadyGiven;

  const LessonScreen({
    super.key,
    this.lesson,
    this.lessonNumber = 6,
    this.lessonTag = 'Response',
    this.rewardAlreadyGiven = false,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _step = 0;
  bool _hasAwardedXp = false;

  int? _selectedOption;
  bool _isChecked = false;

  static final List<LessonBlock> _demoBlocks = [
    LessonBlock('materi', {
      'judul': 'Kurangi filler words',
      'isi':
          'Filler words seperti "eee" dan "anu" membuat jawabanmu terdengar '
          'ragu. Ganti dengan jeda singkat. Jeda terdengar lebih yakin dan '
          'memberi waktu untuk berpikir.',
    }),
    LessonBlock('kuis', {
      'pertanyaan': 'Mana kalimat yang paling sedikit filler words?',
      'opsi':
          'Eee, jadi menurutku, eee, idenya bagus.\n'
          'Menurutku, idenya bagus karena hemat waktu.\n'
          'Jadi, ya, gtu, eee, pokonya bagus.',
      'jawaban': '1',
    }),
  ];

  List<LessonBlock> get _blocks {
    final lesson = widget.lesson;
    if (lesson == null) return _demoBlocks;
    final list = lesson.blockList;
    if (list.isEmpty) {
      return [
        LessonBlock('materi', {
          'judul': lesson.judul.isEmpty ? lesson.judul : lesson.judul,
          'isi':
              'Materi untuk lesson ini belum ditambahkan admin lewat dashboard '
              'CMS (menu "Lesson / Langkah Roadmap" -> Blok konten).',
        }),
      ];
    }
    return list;
  }

  int get _totalSteps => _blocks.length + 1; // + completion
  bool get _isLastStep => _step >= _blocks.length;
  int get _displayNumber => widget.lesson?.urutan ?? widget.lessonNumber;
  String get _displayTag {
    final aspek = widget.lesson?.targetAspek ?? '';
    return aspek.isEmpty ? widget.lessonTag : aspek;
  }

  void _next() {
    if (_step < _blocks.length) {
      setState(() {
        _step++;
        _selectedOption = null;
        _isChecked = false;
        if (_step == _blocks.length && !_hasAwardedXp) {
          _hasAwardedXp = true;
          if (!widget.rewardAlreadyGiven) {
            _completeLesson();
          }
        }
      });
    }
  }

  /// Simpan progres (lesson berikutnya jadi terbuka) DAN beri XP dalam satu
  /// panggilan agar keduanya selalu konsisten di Firestore.
  Future<void> _completeLesson() async {
    final l = widget.lesson;
    if (l != null && l.lessonId.isNotEmpty) {
      await AuthService().completeLesson(
        lessonId: l.lessonId,
        modulId: l.modulId,
      );
    } else {
      // Konten demo tanpa lesson Firestore: tetap beri XP.
      await AuthService().addXp(10);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Selamat! +10 XP berhasil ditambahkan ke akunmu!'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _restart() {
    setState(() {
      _step = 0;
      _selectedOption = null;
      _isChecked = false;
    });
  }

  void _handleCheck() {
    if (_selectedOption == null) return;
    if (!_isChecked) {
      setState(() => _isChecked = true);
    } else {
      _next();
    }
  }

  void _close() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            LessonAppBar(
              lessonNumber: _displayNumber,
              lessonTag: _displayTag,
              step: _step + 1,
              totalSteps: _totalSteps,
              onClose: _close,
            ),
            Expanded(child: _buildStepBody()),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    if (_isLastStep) {
      return LessonCompleteStep(
        lessonNumber: _displayNumber,
        onRestart: _restart,
        onBackToRoadmap: _close,
      );
    }

    final block = _blocks[_step];
    switch (block.tipe) {
      case 'video':
        return LessonVideoStep(
          url: block.str('url'),
          title: block.str('judul'),
        );
      case 'gambar':
        return LessonImageStep(
          imageUrl: block.str('gambar'),
          title: block.str('judul'),
        );
      case 'kuis':
        return LessonQuizStep(
          pertanyaan: block.str('pertanyaan'),
          options: block.opsiList,
          correctOption: block.intVal,
          selectedOption: _selectedOption,
          isChecked: _isChecked,
          onSelect: (i) => setState(() {
            _selectedOption = i;
            _isChecked = false;
          }),
        );
      case 'teks':
      case 'materi':
      default:
        return LessonConceptStep(
          title: block.str('judul'),
          body: block.str('isi'),
        );
    }
  }

  Widget _buildBottomAction() {
    if (_isLastStep) return const SizedBox.shrink();

    final block = _blocks[_step];
    late final String label;
    late final VoidCallback onTap;
    late final bool enabled;

    if (block.tipe == 'kuis') {
      label = _isChecked ? 'Lanjut' : 'Periksa';
      onTap = _handleCheck;
      enabled = _isChecked || _selectedOption != null;
    } else {
      label = 'Lanjut';
      onTap = _next;
      enabled = true;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: LessonButton(
        label: label,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}
