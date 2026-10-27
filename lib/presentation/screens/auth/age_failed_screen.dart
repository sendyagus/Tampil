import 'package:flutter/material.dart';

import 'login_screen.dart';

class AgeFailedScreen extends StatelessWidget {
  const AgeFailedScreen({super.key});

  static const Color _primaryBlue = Color(0xFF4F46E5);
  static const Color _lightBlueBg = Color(0xFFEEF2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon kalender
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _lightBlueBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC7D2FE),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: _primaryBlue,
                  size: 38,
                ),
              ),
              const SizedBox(height: 28),

              // Judul
              const Text(
                'Belum bisa membuat akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              // Deskripsi
              const Text(
                'TAMPIL dibuat untuk pengguna berusia 18 tahun ke atas. Kami tidak menyimpan data yang kamu masukkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Tombol Mengerti
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
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
      ),
    );
  }
}
