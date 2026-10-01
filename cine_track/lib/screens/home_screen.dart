import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Изменяемая копия: в следующем задании список будет перемешиваться
  // и из него будут удаляться фильмы.
  final List<Movie> _movies = [...mockMovies];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CineTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Перемешать',
            onPressed: () {
              setState(() {
                _movies.shuffle();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _movies.length,
        // Без этого колбэка ListView.builder не находит переставленный элемент
        // по ключу и пересоздаёт его, теряя состояние (см. notes.md, Задание 7).
        findChildIndexCallback: (key) {
          final index = _movies.indexWhere((m) => ValueKey(m.id) == key);
          return index == -1 ? null : index;
        },
        itemBuilder: (context, index) {
          final movie = _movies[index];
          // Ключ стоит на корневом виджете элемента — Dismissible.
          return Dismissible(
            key: ValueKey(movie.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _movies.removeAt(index);
              });
            },
            child: MovieCard(movie: movie),
          );
        },
      ),
    );
  }
}
