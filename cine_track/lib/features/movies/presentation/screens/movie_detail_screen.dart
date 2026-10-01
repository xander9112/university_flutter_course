import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../genres.dart';
import '../../domain/entities/movie.dart';
import '../../../ratings/presentation/providers/ratings_provider.dart';
import '../widgets/movie_poster.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      // AppBar прозрачный и лежит поверх постера — остаётся только кнопка «Назад».
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        // Постер должен заходить под статус-бар — не добавляем отступ сверху.
        // Снизу и по бокам SafeArea защищает контент от панели навигации и нотча.
        top: false,
        child: _MovieDetailBody(movie: movie),
      ),
    );
  }
}

class _MovieDetailBody extends StatelessWidget {
  const _MovieDetailBody({required this.movie});
  final Movie movie;

  // Тот же тег, что у постера в MovieCard (Задание 19)
  Widget _poster({double? height}) => Hero(
    tag: 'poster-${movie.id}',
    child: MoviePoster(
      movie: movie,
      width: double.infinity,
      height: height,
      fallback: Container(height: height, color: Colors.grey.shade800),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          // Портрет: постер сверху, описание снизу
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _MovieInfo(movie: movie),
                ),
              ],
            ),
          );
        }

        // Ландшафт: постер слева, детали справа
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Постер занимает 40% ширины и всю высоту
            Flexible(flex: 4, child: _poster(height: double.infinity)),
            // Описание занимает 60% ширины
            Flexible(
              flex: 6,
              child: SingleChildScrollView(
                // Сверху — место под прозрачный AppBar: справа от постера
                // текст иначе начинался бы под ним. С extendBodyBehindAppBar
                // Scaffold уже включил высоту AppBar в padding.top.
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.paddingOf(context).top,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '⭐ ${movie.rating}',
                      style: const TextStyle(color: Colors.amber),
                    ),
                    const SizedBox(height: 16),
                    _MovieInfo(movie: movie),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Портретная шапка: постер с градиентом, поверх — название и рейтинг.
  Widget _buildHeader() {
    return Stack(
      children: [
        _poster(height: 300),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '⭐ ${movie.rating}',
                style: const TextStyle(color: Colors.amber),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Нижняя часть экрана деталей: год и жанры, описание, характеристики,
/// личная оценка и кнопка «Оценить».
class _MovieInfo extends StatelessWidget {
  const _MovieInfo({required this.movie});
  final Movie movie;

  Future<void> _rate(BuildContext context) async {
    final rating = await showDialog<double>(
      context: context,
      builder: (_) => const RatingDialog(),
    );
    if (rating == null || !context.mounted) return;

    // Оценка сохраняется в общем состоянии — неважно, откуда открыт экран
    // (главная, поиск, избранное). Возвращать её через pop больше не нужно.
    context.read<RatingsProvider>().setRating(movie.id, rating);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ваша оценка «${movie.title}»: $rating')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRating = context.watch<RatingsProvider>().ratingOf(movie.id);
    final genres = movie.genreIds
        .map((id) => tmdbGenres[id])
        .whereType<String>()
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          genres.isEmpty ? movie.year : '${movie.year} · $genres',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          movie.overview ?? 'Описание отсутствует',
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 24),
        // Длительности, страны и языка в модели пока нет —
        // показываем прочерки, данные появятся вместе с API.
        const Row(
          children: [
            Expanded(
              child: _Feature(
                icon: Icons.schedule,
                label: 'Длительность',
                value: '—',
              ),
            ),
            Expanded(
              child: _Feature(icon: Icons.public, label: 'Страна', value: '—'),
            ),
            Expanded(
              child: _Feature(icon: Icons.language, label: 'Язык', value: '—'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          userRating == null
              ? 'Вы ещё не оценили этот фильм'
              : 'Ваша оценка: ${userRating.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _rate(context),
            icon: const Icon(Icons.star),
            label: Text(userRating == null ? 'Оценить' : 'Изменить оценку'),
          ),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Feature({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
