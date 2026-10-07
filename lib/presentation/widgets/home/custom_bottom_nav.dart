import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNav({
    super.key,
    this.selectedIndex = 0,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(
        icon: Icons.home_rounded,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      NavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded,
        label: 'Roadmap',
      ),
      NavItem(
        icon: Icons.mic_none_rounded,
        activeIcon: Icons.mic_rounded,
        label: 'Test',
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : Colors.grey.shade400,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
