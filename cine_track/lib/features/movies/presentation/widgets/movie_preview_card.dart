import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';
import 'movie_poster.dart';

/// Компактная карточка-превью для горизонтальной ленты «Популярное».
class MoviePreviewCard extends StatelessWidget {
  final Movie movie;

  const MoviePreviewCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MoviePoster(movie: movie, width: 120),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '⭐ ${movie.rating}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
