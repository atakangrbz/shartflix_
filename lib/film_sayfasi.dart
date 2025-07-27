import 'package:flutter/material.dart';
import '../anasayfa.dart'; // getImageWidget burada ise import et

class FilmSayfasi extends StatelessWidget {
  final String title;
  final String description;
  final String? posterUrl;

  const FilmSayfasi({
    super.key,
    required this.title,
    required this.description,
    required this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Film ekranı (poster yerinde "video görünümü" gibi)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: getImageWidget(posterUrl),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Film Başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Film Açıklaması Başlık
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Film Açıklaması",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ✅ Film Açıklaması İçerik
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
