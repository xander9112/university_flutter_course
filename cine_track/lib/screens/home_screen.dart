import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_preview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = MovieApiService();

  // Загруженные из сети фильмы. Список перемешивается, из него удаляются
  // и в него добавляются фильмы.
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _error;

  // Личные оценки: id фильма → оценка. Пока живут только в памяти.
  final Map<int, double> _userRatings = {};

  static const _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

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

  Future<void> _loadMovies() async {
    try {
      final movies = await _apiService.getPopularMovies();
      if (!mounted) return;
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadMovies();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Ошибка: $_error', textAlign: TextAlign.center),
              TextButton(onPressed: _retry, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }
    // Лента «Популярное» — первые 5 фильмов списка.
    final popular = _movies.take(5).toList();
    return Column(
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
            itemCount: popular.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = popular[index];
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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить фильм',
        onPressed: _addMovie,
        child: const Icon(Icons.add),
      ),
    );
  }
}
