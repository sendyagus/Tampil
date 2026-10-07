import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String userName;
  final String greeting;
  final String avatarUrl;

  const HeaderWidget({
    super.key,
    this.userName = 'Putri',
    this.greeting = 'Selamat pagi',
    this.avatarUrl = 'https://i.pravatar.cc/150?img=47',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Avatar with Status Dot
        Stack(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981), // Green online indicator
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),

        // Greeting & User Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Halo, $userName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Notification Bell Container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
              Positioned(
                top: 13,
                right: 14,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF06B6D4), // Cyan active dot
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
