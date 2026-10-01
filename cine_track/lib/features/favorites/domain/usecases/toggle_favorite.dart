import '../../../movies/domain/entities/movie.dart';
import '../repositories/favorites_repository.dart';

/// Добавляет фильм в избранное или убирает его оттуда.
class ToggleFavorite {
  final FavoritesRepository repository;
  const ToggleFavorite(this.repository);

  Future<void> call(Movie movie, {required bool isFavorite}) => isFavorite
      ? repository.removeFavorite(movie.id)
      : repository.addFavorite(movie);
}
