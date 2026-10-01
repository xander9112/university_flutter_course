import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/movie.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import 'movie_poster.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // watch: карточка перерисовывается сразу, как только избранное меняется.
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(movie.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoviePoster(movie: movie, width: 80, height: 120),
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
          IconButton(
            tooltip: isFav ? 'Убрать из избранного' : 'В избранное',
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () =>
                context.read<FavoritesProvider>().toggleFavorite(movie),
          ),
        ],
      ),
    );
  }
}
