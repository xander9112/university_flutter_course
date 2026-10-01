import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/movie.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import 'favorite_button.dart';
import 'movie_poster.dart';

/// Карточка фильма. Плавно появляется (fade-in) после того, как попала на экран.
class MovieCard extends StatefulWidget {
  const MovieCard({super.key, required this.movie});
  final Movie movie;

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Запускаем анимацию в следующем кадре: в первом кадре карточка
    // прозрачна, затем AnimatedOpacity плавно доводит её до 1.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    final movie = widget.movie;
    // watch: карточка перерисовывается сразу, как только избранное меняется.
    final favorites = context.watch<FavoritesProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Тот же тег — у постера на экране деталей: при переходе постер
          // «летит» из карточки туда.
          Hero(
            tag: 'poster-${movie.id}',
            child: MoviePoster(movie: movie, width: 80, height: 120),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(movie.year, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('⭐ ${movie.voteAverage?.toStringAsFixed(1) ?? '—'}'),
                ],
              ),
            ),
          ),
          FavoriteButton(
            isFavorite: favorites.isFavorite(movie.id),
            onToggle: () =>
                context.read<FavoritesProvider>().toggleFavorite(movie),
          ),
        ],
      ),
    );
  }
}
