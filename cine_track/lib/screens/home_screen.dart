import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/favorites_provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_preview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    // Загружаем фильмы при первом рендере: в самом initState
    // провайдер нельзя заставить уведомить слушателей во время build.
    Future.microtask(() {
      if (!mounted) return;
      context.read<MoviesProvider>().loadMovies();
    });
  }

  // Оценку экран деталей сохраняет сам в RatingsProvider,
  // поэтому результата от маршрута больше не ждём.
  void _openDetails(Movie movie) {
    Navigator.pushNamed(context, '/movie-detail', arguments: movie);
  }

  Future<void> _addMovie() async {
    final movie = await Navigator.pushNamed(context, '/add-movie') as Movie?;
    // После await экран мог быть уже закрыт — тогда context использовать нельзя.
    if (movie == null || !mounted) return;

    context.read<MoviesProvider>().addMovie(movie);
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

  void _toggleFavorite(Movie movie) {
    final favorites = context.read<FavoritesProvider>();
    favorites.toggleFavorite(movie);
    // Двойной тап переключает избранное, поэтому и текст зависит от результата.
    final added = favorites.isFavorite(movie.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '«${movie.title}» добавлен в избранное'
              : '«${movie.title}» удалён из избранного',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBody(MoviesProvider moviesProvider) {
    if (moviesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (moviesProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Ошибка: ${moviesProvider.error}',
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: moviesProvider.loadMovies,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final movies = moviesProvider.movies;
    // Лента «Популярное» — первые 5 фильмов списка.
    final popular = movies.take(5).toList();
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
            itemCount: movies.length,
            // Без этого колбэка ListView.builder не находит переставленный
            // элемент по ключу и пересоздаёт его, теряя состояние
            // (см. notes.md, Задание 7).
            findChildIndexCallback: (key) {
              final index = movies.indexWhere((m) => ValueKey(m.id) == key);
              return index == -1 ? null : index;
            },
            itemBuilder: (context, index) {
              final movie = movies[index];
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
                onDismissed: (direction) =>
                    context.read<MoviesProvider>().removeMovie(movie.id),
                child: GestureDetector(
                  onTap: () => _openDetails(movie),
                  onDoubleTap: () => _toggleFavorite(movie),
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
    final moviesProvider = context.watch<MoviesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CineTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Перемешать',
            onPressed: () => context.read<MoviesProvider>().shuffle(),
          ),
        ],
      ),
      body: _buildBody(moviesProvider),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить фильм',
        onPressed: _addMovie,
        child: const Icon(Icons.add),
      ),
    );
  }
}
