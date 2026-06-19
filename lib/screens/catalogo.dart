import 'package:flutter/material.dart';
import '../data/movies_data.dart';
import '../models/movie.dart';
import 'detalle_pelicula.dart';

class CatalogScreen extends StatelessWidget {
  final int userAge;
  const CatalogScreen({super.key, required this.userAge});

  String get _ageLabel {
    if (userAge >= 18) return '+18';
    if (userAge >= 16) return '+16';
    if (userAge >= 13) return '+13';
    return 'ATP';
  }

  Color get _ageBadgeColor {
    if (userAge >= 18) return const Color(0xFF7C3AED);
    if (userAge >= 16) return Colors.orange;
    return const Color(0xFF06B6D4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.play_circle_fill, color: Color(0xFF7C3AED), size: 30),
            SizedBox(width: 8),
            Text('StreamFlix',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _ageBadgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_ageLabel,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: MoviesApi.fetchMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  SizedBox(height: 16),
                  Text('Cargando películas...', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar películas:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFEC4899)),
              ),
            );
          }
          final all = snapshot.data!.where((m) => userAge >= m.ageRating).toList();
          final popular = all.where((m) => m.popular).toList();
          final categories = all.map((m) => m.category).toSet().toList();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (popular.isNotEmpty) _FeaturedBanner(movie: popular.first, userAge: userAge),
                const SizedBox(height: 24),
                if (popular.isNotEmpty)
                  _MovieRow(title: '🔥 Populares', movies: popular, userAge: userAge),
                const SizedBox(height: 20),
                ...categories.map((cat) {
                  final movies = all.where((m) => m.category == cat).toList();
                  if (movies.isEmpty) return const SizedBox();
                  return Column(
                    children: [
                      _MovieRow(title: cat, movies: movies, userAge: userAge),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  final Movie movie;
  final int userAge;
  const _FeaturedBanner({required this.movie, required this.userAge});

  void _goDetail(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie, userAge: userAge)),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _goDetail(context),
      child: Stack(
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.network(
              movie.image,
              fit: BoxFit.cover,
              errorBuilder: (_, e, __) => Container(
                color: const Color(0xFF1E1E2E),
                child: const Icon(Icons.movie, color: Colors.white12, size: 80),
              ),
            ),
          ),
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC0F0F1A), Color(0xFF0F0F1A)],
                stops: [0.3, 0.7, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${movie.year}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(width: 10),
                    Text(movie.duration, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(width: 10),
                    _AgeBadge(label: movie.ageLabel, color: movie.ageLabelColor),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _goDetail(context),
                  icon: const Icon(Icons.info_outline, color: Colors.black, size: 18),
                  label: const Text('Ver detalles',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final int userAge;
  const _MovieRow({required this.title, required this.movies, required this.userAge});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, i) => _MovieCard(movie: movies[i], userAge: userAge),
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  final int userAge;
  const _MovieCard({required this.movie, required this.userAge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie, userAge: userAge)),
      ),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF1E1E2E),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Stack(
                children: [
                  Image.network(
                    movie.image,
                    height: 145,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, __) => Container(
                      height: 145,
                      color: const Color(0xFF2e2e2e),
                      child: const Icon(Icons.movie, color: Colors.white12),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _AgeBadge(
                      label: movie.ageLabel,
                      color: movie.ageLabelColor.withValues(alpha: 0.9),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 11),
                      const SizedBox(width: 2),
                      Text(movie.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;
  const _AgeBadge({required this.label, required this.color, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }
}
