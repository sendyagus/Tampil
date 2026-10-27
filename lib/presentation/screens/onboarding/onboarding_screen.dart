import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _primaryBlue = Color(0xFF4F46E5);
  static const Color _lightBlueBg = Color(0xFFEEF2FF);
  static const Color _borderBlue = Color(0xFFC7D2FE);

  final PageController _controller = PageController();
  int _page = 0;

  // State untuk pilihan user
  int? _selectedFase;
  int? _selectedSkill;
  int _confidenceLevel = 3;

  void _goNext() {
    if (_page < 4) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goHome();
    }
  }

  void _goBack() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        size: 30,
                        color: Color(0xFF0F172A),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _FasePage(
                    selected: _selectedFase,
                    onChanged: (v) => setState(() => _selectedFase = v),
                  ),
                  _SkillPage(
                    selected: _selectedSkill,
                    onChanged: (v) => setState(() => _selectedSkill = v),
                  ),
                  _ConfidencePage(
                    level: _confidenceLevel,
                    onChanged: (v) => setState(() => _confidenceLevel = v),
                  ),
                  const _MetricsPage(),
                  const _AssessmentPage(),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _page == 4 ? 'Mulai assessment' : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (_page == 4) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _goHome,
                      child: const Text(
                        'Nanti saja',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Halaman 1: Fase
// ──────────────────────────────────────────────

class _FasePage extends StatelessWidget {
  const _FasePage({required this.selected, required this.onChanged});

  final int? selected;
  final ValueChanged<int> onChanged;

  static const _options = [
    _RadioOption(icon: Icons.school_rounded, label: 'Mahasiswa'),
    _RadioOption(icon: Icons.person_search_rounded, label: 'Fresh graduate / pencari kerja'),
    _RadioOption(icon: Icons.work_outline_rounded, label: 'Pekerja muda'),
    _RadioOption(icon: Icons.more_horiz_rounded, label: 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kamu sedang di fase mana?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Biar contoh latihannya terasa dekat denganmu.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(_options.length, (i) {
            final isSelected = selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectableCard(
                icon: _options[i].icon,
                label: _options[i].label,
                isSelected: isSelected,
                onTap: () => onChanged(i),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Halaman 2: Skill
// ──────────────────────────────────────────────

class _SkillPage extends StatelessWidget {
  const _SkillPage({required this.selected, required this.onChanged});

  final int? selected;
  final ValueChanged<int> onChanged;

  static const _options = [
    _RadioOption(icon: Icons.chat_rounded, label: 'Percakapan sehari-hari'),
    _RadioOption(icon: Icons.groups_rounded, label: 'Diskusi & kerja kelompok'),
    _RadioOption(icon: Icons.bar_chart_rounded, label: 'Presentasi'),
    _RadioOption(icon: Icons.campaign_rounded, label: 'Public speaking & organisasi'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kamu ingin lebih jago di mana?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih yang paling kamu butuhkan sekarang.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(_options.length, (i) {
            final isSelected = selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectableCard(
                icon: _options[i].icon,
                label: _options[i].label,
                isSelected: isSelected,
                onTap: () => onChanged(i),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Halaman 3: Confidence Scale
// ──────────────────────────────────────────────

class _ConfidencePage extends StatelessWidget {
  const _ConfidencePage({required this.level, required this.onChanged});

  final int level;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seberapa percaya diri kamu saat berbicara?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jawab jujur saja, ini hanya untuk melihat perkembanganmu nanti.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          // Scale 1-5
          Row(
            children: List.generate(5, (i) {
              final value = i + 1;
              final isSelected = level == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(value),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 4 ? 10 : 0),
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _OnboardingScreenState._primaryBlue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? _OnboardingScreenState._primaryBlue
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Belum percaya diri',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Sangat percaya diri',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Halaman 4: Metrics Info
// ──────────────────────────────────────────────

class _MetricsPage extends StatelessWidget {
  const _MetricsPage();

  static const _metrics = [
    _MetricItem(
      icon: Icons.pause_circle_outline_rounded,
      title: 'Kelancaran jeda',
      subtitle: 'Seberapa lancar tanpa jeda panjang',
    ),
    _MetricItem(
      icon: Icons.record_voice_over_rounded,
      title: 'Kebersihan ucapan',
      subtitle: 'Seberapa sedikit kata pengisi',
    ),
    _MetricItem(
      icon: Icons.speed_rounded,
      title: 'Tempo',
      subtitle: 'Kecepatan bicara yang nyaman',
    ),
    _MetricItem(
      icon: Icons.checklist_rounded,
      title: 'Cakupan isi',
      subtitle: 'Poin penting yang tersampaikan',
    ),
    _MetricItem(
      icon: Icons.account_tree_rounded,
      title: 'Struktur',
      subtitle: 'Pembuka, penghubung, dan penutup',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apa yang kami nilai?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Skormu dihitung dengan rumus yang jelas, bukan oleh AI.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(_metrics.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _OnboardingScreenState._lightBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _metrics[i].icon,
                      color: _OnboardingScreenState._primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _metrics[i].title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _metrics[i].subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Halaman 5: Assessment CTA
// ──────────────────────────────────────────────

class _AssessmentPage extends StatelessWidget {
  const _AssessmentPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Mic icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _OnboardingScreenState._lightBlueBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: _OnboardingScreenState._borderBlue,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: _OnboardingScreenState._primaryBlue,
              size: 38,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Mau coba latihan\npertamamu?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Satu studi kasus singkat untuk melihat titik awalmu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          // Bullet points
          const _BulletItem(
            icon: Icons.description_outlined,
            text: 'Pilih satu studi kasus',
          ),
          const SizedBox(height: 18),
          const _BulletItem(
            icon: Icons.mic_none_rounded,
            text: 'Rekam jawabanmu, 30–120 detik',
          ),
          const SizedBox(height: 18),
          const _BulletItem(
            icon: Icons.insights_rounded,
            text: 'Lihat skor Communication Index-mu',
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Shared Widgets
// ──────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _OnboardingScreenState._lightBlueBg
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _OnboardingScreenState._primaryBlue
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? _OnboardingScreenState._primaryBlue
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? _OnboardingScreenState._primaryBlue
                      : const Color(0xFF334155),
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _OnboardingScreenState._primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: _OnboardingScreenState._primaryBlue,
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Data Classes
// ──────────────────────────────────────────────

class _RadioOption {
  const _RadioOption({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}
