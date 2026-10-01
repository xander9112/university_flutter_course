import 'package:flutter/material.dart';

import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  static const Widget _placeholder = Image(
    image: AssetImage('assets/images/placeholder.png'),
    fit: BoxFit.cover,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 120,
            // Если постера нет, сразу показываем заглушку, а не грузим пустой URL.
            // errorBuilder срабатывает, когда постер есть, но не загрузился.
            child: movie.posterPath != null
                ? Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _placeholder,
                  )
                : _placeholder,
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
        ],
      ),
    );
  }
}
