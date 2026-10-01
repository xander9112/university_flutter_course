import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

/// Постер фильма с заглушкой.
///
/// Если постера нет, сразу показывается [fallback], а не грузится пустой URL.
/// [fallback] также показывается, когда постер есть, но не загрузился.
class MoviePoster extends StatelessWidget {
  final Movie movie;
  final double? width;
  final double? height;
  final Widget fallback;

  const MoviePoster({
    super.key,
    required this.movie,
    this.width,
    this.height,
    this.fallback = const Image(
      image: AssetImage('assets/images/placeholder.png'),
      fit: BoxFit.cover,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: movie.posterPath != null
          ? Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
            )
          : fallback,
    );
  }
}
