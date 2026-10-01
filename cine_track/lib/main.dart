// Временный консольный вывод для проверки модели (Задание 3).
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'data/mock_movies.dart';
import 'utils/movie_utils.dart';

void main() {
  for (final movie in mockMovies) {
    // Вместо: movie.voteAverage == null ? '—' : movie.voteAverage!.toStringAsFixed(1)
    print(
      '${movie.title} (${movie.year}) — ⭐ ${movie.voteAverage?.toStringAsFixed(1) ?? '—'}',
    );

    // Вместо: movie.overview == null ? 'Описание отсутствует' : movie.overview!
    print('  ${movie.overview ?? 'Описание отсутствует'}');
  }

  print(filterByRating(mockMovies, 8.5).map((m) => m.title));
  print(sortByRating(mockMovies).map((m) => m.title));
  print(searchByTitle(mockMovies, 'in').map((m) => m.title));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineTrack',
      home: Scaffold(
        body: Center(child: Text('CineTrack — скоро здесь будут фильмы')),
      ),
    );
  }
}
