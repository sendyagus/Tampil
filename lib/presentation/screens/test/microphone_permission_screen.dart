import 'package:flutter/material.dart';
import 'recording_screen.dart';

class MicrophonePermissionScreen extends StatefulWidget {
  /// Callback yang dipanggil setelah user centang checkbox dan tekan Lanjut
  final VoidCallback? onPermissionGranted;

  const MicrophonePermissionScreen({super.key, this.onPermissionGranted});

  @override
  State<MicrophonePermissionScreen> createState() =>
      _MicrophonePermissionScreenState();
}

class _MicrophonePermissionScreenState
    extends State<MicrophonePermissionScreen> {
  static const Color _primaryIndigo = Color(0xFF4F46E5);

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tombol Back ──
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: const Color(0xFF0F172A),
              ),
            ),

            // ── Konten Utama ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Ikon mikrofon dalam lingkaran ungu lembut
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEBFC),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic_rounded,
                          size: 34,
                          color: _primaryIndigo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Judul
                    const Text(
                      'Izin rekam suara',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subjudul
                    const Text(
                      'Dipakai untuk menganalisis latihan bicaramu.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Kartu daftar poin informasi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE8E6FF),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.mic_none_rounded,
                            text: 'Suaramu direkam hanya saat kamu\nmenekan tombol rekam',
                          ),
                          const SizedBox(height: 18),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            text: 'Audio dihapus otomatis maksimal\n30 hari',
                          ),
                          const SizedBox(height: 18),
                          _InfoRow(
                            icon: Icons.history_rounded,
                            text: 'Bisa dicabut kapan saja di Profile',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bagian Bawah: Checkbox + Tombol Lanjut ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox persetujuan
                  InkWell(
                    onTap: () => setState(() => _isChecked = !_isChecked),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isChecked
                              ? _primaryIndigo
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Custom checkbox
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _isChecked
                                  ? _primaryIndigo
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _isChecked
                                    ? _primaryIndigo
                                    : const Color(0xFFCBD5E1),
                                width: 1.8,
                              ),
                            ),
                            child: _isChecked
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Saya mengizinkan perekaman suara\nsaya',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tombol Lanjut
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isChecked
                          ? () {
                              // Tutup lalu buka layar rekaman
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const RecordingScreen(),
                                ),
                              );
                              widget.onPermissionGranted?.call();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryIndigo,
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lanjut',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widget untuk satu baris informasi ──
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDF9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
              child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
