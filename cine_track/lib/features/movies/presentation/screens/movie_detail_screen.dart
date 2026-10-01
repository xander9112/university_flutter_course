import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../genres.dart';
import '../../domain/entities/movie.dart';
import '../../../ratings/presentation/providers/ratings_provider.dart';
import '../widgets/movie_poster.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key});

  Future<void> _rate(BuildContext context, Movie movie) async {
    final rating = await showDialog<double>(
      context: context,
      builder: (_) => const RatingDialog(),
    );
    if (rating == null || !context.mounted) return;

    // Оценка сохраняется в общем состоянии — неважно, откуда открыт экран
    // (главная, поиск, избранное). Возвращать её через pop больше не нужно.
    context.read<RatingsProvider>().setRating(movie.id, rating);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ваша оценка «${movie.title}»: $rating')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;
    final userRating = context.watch<RatingsProvider>().ratingOf(movie.id);
    final genres = movie.genreIds
        .map((id) => tmdbGenres[id])
        .whereType<String>()
        .join(', ');

    return Scaffold(
      // AppBar прозрачный и лежит поверх постера — остаётся только кнопка «Назад».
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(movie),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    genres.isEmpty ? movie.year : '${movie.year} · $genres',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.overview ?? 'Описание отсутствует',
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  // Длительности, страны и языка в модели пока нет —
                  // показываем прочерки, данные появятся вместе с API.
                  const Row(
                    children: [
                      Expanded(
                        child: _Feature(
                          icon: Icons.schedule,
                          label: 'Длительность',
                          value: '—',
                        ),
                      ),
                      Expanded(
                        child: _Feature(
                          icon: Icons.public,
                          label: 'Страна',
                          value: '—',
                        ),
                      ),
                      Expanded(
                        child: _Feature(
                          icon: Icons.language,
                          label: 'Язык',
                          value: '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    userRating == null
                        ? 'Вы ещё не оценили этот фильм'
                        : 'Ваша оценка: ${userRating.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _rate(context, movie),
                      icon: const Icon(Icons.star),
                      label: Text(
                        userRating == null ? 'Оценить' : 'Изменить оценку',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Movie movie) {
    return Stack(
      children: [
        MoviePoster(
          movie: movie,
          width: double.infinity,
          height: 300,
          fallback: Container(height: 300, color: Colors.grey.shade800),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
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
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '⭐ ${movie.rating}',
                style: const TextStyle(color: Colors.amber),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Feature({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
