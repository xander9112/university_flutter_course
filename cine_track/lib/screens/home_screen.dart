import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_preview_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Изменяемая копия: список перемешивается и из него удаляются фильмы.
  final List<Movie> _movies = [...mockMovies];

  static const _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  void _openDetails(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Популярное', style: _sectionTitleStyle),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _movies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return GestureDetector(
                  onTap: () => _openDetails(movie),
                  child: MoviePreviewCard(movie: movie),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Все фильмы', style: _sectionTitleStyle),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 6),
              itemCount: _movies.length,
              // Без этого колбэка ListView.builder не находит переставленный
              // элемент по ключу и пересоздаёт его, теряя состояние
              // (см. notes.md, Задание 7).
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
                  child: GestureDetector(
                    onTap: () => _openDetails(movie),
                    child: MovieCard(movie: movie),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
