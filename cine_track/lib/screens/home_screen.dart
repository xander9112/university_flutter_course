import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_preview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Изменяемая копия: список перемешивается и из него удаляются фильмы.
  final List<Movie> _movies = [...mockMovies];

  // Личные оценки: id фильма → оценка. Пока живут только в памяти.
  final Map<int, double> _userRatings = {};

  static const _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  Future<void> _openDetails(Movie movie) async {
    // Без параметра типа: таблица routes создаёт MaterialPageRoute<dynamic>,
    // и pushNamed<double> упал бы с TypeError. Приводим тип результата.
    final rating = await Navigator.pushNamed(
      context,
      '/movie-detail',
      arguments: movie,
    ) as double?;
    if (rating == null || !mounted) return;

    setState(() => _userRatings[movie.id] = rating);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ваша оценка «${movie.title}»: $rating')),
    );
  }

  Future<void> _addMovie() async {
    final movie = await Navigator.pushNamed(context, '/add-movie') as Movie?;
    // После await экран мог быть уже закрыт — тогда context использовать нельзя.
    if (movie == null || !mounted) return;

    setState(() => _movies.insert(0, movie));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('«${movie.title}» добавлен!')));
  }

  Future<bool?> _confirmDelete(Movie movie) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фильм?'),
        content: Text('Вы уверены, что хотите удалить «${movie.title}»?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addToFavorites(Movie movie) {
    // Само избранное пока нигде не хранится — это будет в Задании 12.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('«${movie.title}» добавлен в избранное'),
        duration: const Duration(seconds: 2),
      ),
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
              // Отступ снизу, чтобы FloatingActionButton не закрывал последнюю карточку.
              padding: const EdgeInsets.only(bottom: 88),
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
                  confirmDismiss: (direction) => _confirmDelete(movie),
                  onDismissed: (direction) {
                    setState(() {
                      _movies.removeAt(index);
                    });
                  },
                  child: GestureDetector(
                    onTap: () => _openDetails(movie),
                    onDoubleTap: () => _addToFavorites(movie),
                    child: MovieCard(movie: movie),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить фильм',
        onPressed: _addMovie,
        child: const Icon(Icons.add),
      ),
    );
  }
}
