import 'package:flutter/material.dart';
import '../models/movie.dart';

class TrailerScreen extends StatelessWidget {
  final Movie movie;
  const TrailerScreen({super.key, required this.movie});

  String get _youtubeUrl => 'https://www.youtube.com/watch?v=${movie.trailerId}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tráiler — ${movie.title}',
          style: const TextStyle(color: Colors.white, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  'https://img.youtube.com/vi/${movie.trailerId}/hqdefault.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, e, __) => Container(
                    color: const Color(0xFF1a1a1a),
                    child: const Icon(Icons.movie, color: Colors.white12, size: 80),
                  ),
                ),
                Container(color: Colors.black38),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 46),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tráiler oficial • ${movie.year}',
                      style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.white38, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_youtubeUrl,
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Volver', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
