import 'package:flutter/material.dart';

class ContextOption {
  final String id;
  final String title;
  final String kasusCount;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  ContextOption({
    required this.id,
    required this.title,
    required this.kasusCount,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class ContextSelectorWidget extends StatefulWidget {
  final ValueChanged<String>? onContextSelected;

  const ContextSelectorWidget({
    super.key,
    this.onContextSelected,
  });

  @override
  State<ContextSelectorWidget> createState() => _ContextSelectorWidgetState();
}

class _ContextSelectorWidgetState extends State<ContextSelectorWidget> {
  String _selectedId = 'daily';

  final List<ContextOption> _options = [
    ContextOption(
      id: 'daily',
      title: 'Daily',
      kasusCount: '5 kasus',
      icon: Icons.chat_bubble_outline_rounded,
      iconBgColor: const Color(0xFFE0F7FA),
      iconColor: const Color(0xFF00BCD4),
    ),
    ContextOption(
      id: 'peer',
      title: 'Peer',
      kasusCount: '5 kasus',
      icon: Icons.people_outline_rounded,
      iconBgColor: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF9333EA),
    ),
    ContextOption(
      id: 'public',
      title: 'Public',
      kasusCount: '5 kasus',
      icon: Icons.mic_none_rounded,
      iconBgColor: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF3B82F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih konteks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: _options.map((option) {
            final isSelected = option.id == _selectedId;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option.id != _options.last.id ? 10.0 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedId = option.id;
                    });
                    if (widget.onContextSelected != null) {
                      widget.onContextSelected!(option.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF2FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF6366F1).withOpacity(0.08)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Square Rounded Icon Box
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: option.iconBgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            option.icon,
                            color: option.iconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          option.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.kasusCount,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
