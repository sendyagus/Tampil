import 'dart:convert';
import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const HeaderWidget({
    super.key,
    this.userName = 'Putri',
    this.greeting = 'Selamat pagi',
    this.avatarUrl,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Avatar with Status Dot & Tap to Profile
        MouseRegion(
          cursor: onAvatarTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildAvatarContent(),
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
          ),
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
        MouseRegion(
          cursor: onNotificationTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    final effectiveUrl = avatarUrl?.trim();

    if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      // 1. Base64 Data URI (dari upload foto di Edit Profile)
      if (effectiveUrl.startsWith('data:image')) {
        try {
          final base64Str = effectiveUrl.split(',').last;
          final bytes = base64Decode(base64Str);
          return Image.memory(
            bytes,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(),
          );
        } catch (_) {
          return _buildFallbackInitial();
        }
      }

      // 2. Network URL biasa (Google photo / external URL)
      return Image.network(
        effectiveUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallbackInitial();
        },
      );
    }

    // 3. Fallback Initial Avatar jika belum upload foto
    return _buildFallbackInitial();
  }

  Widget _buildFallbackInitial() {
    final cleanName = userName.trim();
    final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'U';

    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
