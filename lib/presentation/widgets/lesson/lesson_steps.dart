import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'lesson_button.dart';

// ---------------------------------------------------------------------------
// Step — Concept / materi (diaisi dari CMS: blok 'materi')
// ---------------------------------------------------------------------------
class LessonConceptStep extends StatelessWidget {
  final String title;
  final String body;

  const LessonConceptStep({
    super.key,
    this.title = '',
    this.body = '',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mic illustration badge.
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 40,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Lavender content card.
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Materi' : title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  body.isEmpty
                      ? 'Materi belum ditambahkan admin lewat dashboard CMS.'
                      : body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step — Video (diaisi dari CMS: blok 'video' berisi link YouTube)
// ---------------------------------------------------------------------------
class LessonVideoStep extends StatefulWidget {
  final String url;
  final String title;
  final String subtitle;

  const LessonVideoStep({
    super.key,
    required this.url,
    this.title = 'Video Materi',
    this.subtitle = '',
  });

  @override
  State<LessonVideoStep> createState() => _LessonVideoStepState();
}

class _LessonVideoStepState extends State<LessonVideoStep> {
  WebViewController? _controller;
  String? _videoError;

  static final RegExp _idExp = RegExp(
    r'(?:youtu\.be/|youtube\.com/(?:watch\?v=|embed/|shorts/|v/))([\w-]{11})',
  );

  String? _extractId(String url) => _idExp.firstMatch(url)?.group(1);

  @override
  void initState() {
    super.initState();
    final url = widget.url.trim();
    if (url.isNotEmpty) {
      final id = _extractId(url);
      final src = id != null ? 'https://www.youtube.com/embed/$id' : url;
      // WebViewController akan gagal bila implementasi platform webview belum
      // terdaftar (build lama / platform tanpa dukungan). Ditangkap agar tidak
      // muncul layar merah, lalu dipakai fallback tombol "Tonton di YouTube".
      try {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFF0F172A))
          ..loadRequest(Uri.parse(src));
      } catch (e) {
        _controller = null;
        _videoError =
            'Player tertanam tidak tersedia di perangkat/build ini. '
            'Gunakan tombol di bawah untuk menonton, atau jalankan ulang dengan '
            'build penuh (flutter clean lalu flutter run).';
      }
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.url.trim());
    if (uri == null || !uri.hasScheme) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka video di browser.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = widget.url.trim().isNotEmpty;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller != null)
            SizedBox(
              height: 230,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: WebViewWidget(controller: _controller!),
              ),
            )
          else if (hasUrl)
            _buildFallbackPlayer()
          else
            _buildEmpty(),
          if (hasUrl && _controller != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openExternal,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Tonton di YouTube'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            widget.title.isEmpty ? 'Video Materi' : widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          if (widget.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }

  /// Tampilan cadangan saat webview tidak bisa dipakai: kartu gelap dengan
  /// tombol untuk membuka video di aplikasi YouTube/browser.
  Widget _buildFallbackPlayer() {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F172A),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_circle_fill_rounded,
            size: 56,
            color: Color(0xFFFF0000),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _videoError ?? 'Video tersedia di halaman ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _openExternal,
            icon: const Icon(Icons.smartphone_rounded, size: 18),
            label: const Text('Tonton di YouTube'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          'Video belum ditambahkan admin.',
          style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step — Gambar (diisi dari CMS: blok 'gambar'; URL gambar dari internet)
// ---------------------------------------------------------------------------
class LessonImageStep extends StatelessWidget {
  final String imageUrl;
  final String title;

  const LessonImageStep({
    super.key,
    this.imageUrl = '',
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (imageUrl.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Gambar belum ditambahkan admin. Edit lesson ini di dashboard '
                'CMS lalu isi URL gambar pada blok "gambar".',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null
                    ? child
                    : Container(
                        height: 200,
                        alignment: Alignment.center,
                        color: const Color(0xFFF1F5F9),
                        child: const CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                          strokeWidth: 3,
                        ),
                      ),
                errorBuilder: (context, error, stack) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.broken_image_rounded,
                          color: Color(0xFFEF4444)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Gambar gagal dimuat. Periksa URL gambar di CMS.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step — Quiz (diisi dari CMS: blok 'kuis'; 1 soal, opsi A..F bebas jumlah)
// ---------------------------------------------------------------------------
class LessonQuizStep extends StatelessWidget {
  final String pertanyaan;
  final List<String> options;
  final int? selectedOption;
  final bool isChecked;
  final int correctOption;
  final ValueChanged<int> onSelect;

  const LessonQuizStep({
    super.key,
    this.pertanyaan = '',
    this.options = const [],
    required this.selectedOption,
    required this.isChecked,
    required this.correctOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = selectedOption == correctOption;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pertanyaan.isEmpty ? 'Soal kuis' : pertanyaan,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih satu jawaban',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),

          for (int i = 0; i < options.length; i++) ...[
            _buildOption(i, options[i]),
            const SizedBox(height: 12),
          ],

          if (options.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Opsi kuis belum diisi admin. Edit lesson ini di dashboard CMS '
                '-> isi field "Opsi jawaban" (1 baris = 1 opsi).',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),

          if (isChecked) ...[
            const SizedBox(height: 8),
            _buildFeedback(isCorrect),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    final bool isSelected = selectedOption == index;
    final bool showCorrect = isChecked && index == correctOption;
    final bool showWrong =
        isChecked && isSelected && index != correctOption;

    final Color borderColor = showCorrect
        ? const Color(0xFF4F46E5)
        : showWrong
            ? const Color(0xFFEF4444)
            : isSelected
                ? const Color(0xFF818CF8)
                : const Color(0xFFE2E8F0);

    final Color badgeColor = isSelected || showCorrect
        ? const Color(0xFF4F46E5)
        : const Color(0xFFF1F5F9);
    final Color badgeTextColor = isSelected || showCorrect
        ? Colors.white
        : const Color(0xFF64748B);

    return GestureDetector(
      onTap: isChecked ? null : () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4F46E5), size: 24),
            if (showWrong)
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFEF4444), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(bool isCorrect) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Tepat!' : 'Belum tepat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? const Color(0xFF047857)
                        : const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCorrect
                      ? 'Jawaban kamu sesuai dengan kunci.'
                      : 'Coba perhatikan lagi materinya, lalu pilih jawaban lain.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step — Completion ("Lesson selesai!")
// ---------------------------------------------------------------------------
class LessonCompleteStep extends StatelessWidget {
  final int lessonNumber;
  final VoidCallback onRestart;
  final VoidCallback onBackToRoadmap;

  const LessonCompleteStep({
    super.key,
    required this.lessonNumber,
    required this.onRestart,
    required this.onBackToRoadmap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Success badge.
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  size: 58, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),

          const Center(
            child: Text(
              'Lesson selesai!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Kemampuan bicaramu kini bertambah.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 28),

          // Stat cards.
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: '+10 XP',
                  label: 'Didapat',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFEF4444),
                  value: 'Streak',
                  label: 'Terjaga',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          LessonButton(label: 'Lanjut ke Roadmap', onPressed: onBackToRoadmap),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRestart,
            child: const Text(
              'Ulangi lesson',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
