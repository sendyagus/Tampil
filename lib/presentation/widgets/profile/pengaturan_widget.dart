import 'package:flutter/material.dart';

class PengaturanWidget extends StatefulWidget {
  final VoidCallback? onTargetHarianPressed;
  final VoidCallback? onPrivasiPressed;

  const PengaturanWidget({
    super.key,
    this.onTargetHarianPressed,
    this.onPrivasiPressed,
  });

  @override
  State<PengaturanWidget> createState() => _PengaturanWidgetState();
}

class _PengaturanWidgetState extends State<PengaturanWidget> {
  bool _pengingatHarian = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // White Container holding 3 Settings options
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Target harian
              InkWell(
                onTap: widget.onTargetHarianPressed,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _buildSettingIcon(Icons.bolt_rounded),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Target harian',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        'Reguler · 20 XP',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 2. Pengingat harian
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildSettingIcon(Icons.notifications_none_rounded),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Pengingat harian',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _pengingatHarian,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) {
                        setState(() {
                          _pengingatHarian = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _pengingatHarian
                                  ? 'Pengingat harian diaktifkan'
                                  : 'Pengingat harian dinonaktifkan',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(milliseconds: 1000),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 3. Privasi & data suara
              InkWell(
                onTap: widget.onPrivasiPressed,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _buildSettingIcon(Icons.lock_outline_rounded),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Privasi & data suara',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF64748B),
        size: 20,
      ),
    );
  }
}
