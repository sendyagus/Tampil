import 'package:flutter/material.dart';
import '../../../services/cms_content_service.dart';

/// Kartu banner yang kontennya (gambar dari Google Drive + teks) dikelola
/// lewat dashboard CMS. Menampilkan hero "published" pertama dari Firestore.
class CmsBannerWidget extends StatelessWidget {
  const CmsBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CmsContent>>(
      stream: CmsContentService().watchHero(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Belum ada konten CMS.
        }
        final hero = snapshot.data!.first;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFEEF2FF),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hero.imageUrl.isNotEmpty)
                Image.network(
                  hero.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : Container(height: 150, color: Colors.black12),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (hero.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        hero.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (hero.ctaText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(hero.ctaText),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
