import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../utils/transition_utils.dart';
import '../home_screen.dart';

class ConsentScreen extends StatefulWidget {
  final String? email;
  final String? password;
  final String? fullName;
  final int? age;

  const ConsentScreen({
    super.key,
    this.email,
    this.password,
    this.fullName,
    this.age,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  static const Color _primaryBlue = Color(0xFF4F46E5);
  static const Color _lightBlueBg = Color(0xFFEEF2FF);

  final _authService = AuthService();
  bool _agreed = false;
  bool _isLoading = false;

  Future<void> _lanjut() async {
    if (!_agreed) return;

    // Jika datang dari flow pendaftaran (ada email dan password)
    if (widget.email != null && widget.password != null) {
      setState(() => _isLoading = true);
      try {
        await _authService.signUpWithEmail(
          email: widget.email!,
          password: widget.password!,
          fullName: widget.fullName,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil! Selamat datang di TAMPIL.'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          DissolvePageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftar: ${e.toString().replaceAll("Exception:", "").trim()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Flow tanpa email/password (misal direct onboarding/consent)
      Navigator.of(context).pushAndRemoveUntil(
        DissolvePageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 30,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _lightBlueBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: _primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Judul
                    const Text(
                      'Syarat & Privasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Biar jelas sejak awal, ya.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 3 bullet points
                    _consentItem(
                      'Datamu hanya dipakai untuk latihan komunikasimu',
                    ),
                    const SizedBox(height: 18),
                    _consentItem(
                      'Kamu bisa melihat, mengekspor, dan menghapus datamu',
                    ),
                    const SizedBox(height: 18),
                    _consentItem(
                      'Kamu bisa mencabut persetujuan kapan saja',
                    ),
                    const SizedBox(height: 28),

                    // Link Terms
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Baca Terms & Privacy lengkap',
                            style: TextStyle(
                              fontSize: 14,
                              color: _primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: _primaryBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom: checkbox + tombol
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _agreed ? _primaryBlue : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreed
                                  ? _primaryBlue
                                  : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                          child: _agreed
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Saya setuju dengan Terms & Privacy',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Lanjut
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_agreed && !_isLoading) ? _lanjut : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _agreed ? _primaryBlue : const Color(0xFFE2E8F0),
                        foregroundColor:
                            _agreed ? Colors.white : const Color(0xFF94A3B8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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

  Widget _consentItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: _lightBlueBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: _primaryBlue,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
