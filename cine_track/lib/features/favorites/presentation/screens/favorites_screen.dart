import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favorites.isEmpty
          ? const Center(child: Text('Нет избранных фильмов'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/movie-detail',
                    arguments: movie,
                  ),
                  child: MovieCard(movie: movie),
                );
              },
            ),
    );
  }
}
