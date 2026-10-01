import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/movies_bloc.dart';
import '../blocs/movies_event.dart';
import '../blocs/movies_state.dart';
import '../../domain/entities/movie.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/loading_animation.dart';
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

  // Оценку экран деталей сохраняет сам в RatingsProvider,
  // поэтому результата от маршрута больше не ждём.
  void _openDetails(Movie movie) {
    Navigator.pushNamed(context, '/movie-detail', arguments: movie);
  }

  Future<void> _addMovie() async {
    final movie = await Navigator.pushNamed(context, '/add-movie') as Movie?;
    // После await экран мог быть уже закрыт — тогда context использовать нельзя.
    if (movie == null || !mounted) return;

    context.read<MoviesBloc>().add(AddMovie(movie));
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

  Future<void> _toggleFavorite(Movie movie) async {
    final favorites = context.read<FavoritesProvider>();
    // toggleFavorite пишет в базу — ждём, иначе isFavorite ниже
    // вернёт ещё старое значение.
    await favorites.toggleFavorite(movie);
    if (!mounted) return;
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

  // when требует обработать все варианты MoviesState: новое состояние
  // без обработки здесь не скомпилируется.
  Widget _buildBody(BuildContext context, MoviesState state) => state.when(
    initial: () => const SizedBox(),
    loading: () => const Center(child: LoadingAnimation(size: 64)),
    error: (message) => _buildError(context, message),
    loaded: (movies) => _buildMovies(context, movies),
  );

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Ошибка: $message', textAlign: TextAlign.center),
            TextButton(
              onPressed: () => context.read<MoviesBloc>().add(LoadMovies()),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovies(BuildContext context, List<Movie> movies) {
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
          child: RefreshIndicator(
            onRefresh: () {
              // Индикатор крутится, пока блок не завершит completer.
              final completer = Completer<void>();
              context.read<MoviesBloc>().add(
                RefreshMovies(completer: completer),
              );
              return completer.future;
            },
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
                      context.read<MoviesBloc>().add(RemoveMovie(movie.id)),
                  child: GestureDetector(
                    onTap: () => _openDetails(movie),
                    onDoubleTap: () => _toggleFavorite(movie),
                    child: MovieCard(movie: movie),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CineTrack'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: themeProvider.isDark ? 'Светлая тема' : 'Тёмная тема',
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Перемешать',
            onPressed: () => context.read<MoviesBloc>().add(ShuffleMovies()),
          ),
        ],
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(builder: _buildBody),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить фильм',
        onPressed: _addMovie,
        child: const Icon(Icons.add),
      ),
    );
  }
}
