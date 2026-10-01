import '../../../movies/domain/entities/movie.dart';

abstract class FavoritesRepository {
  Future<List<Movie>> getFavorites();
  Future<void> addFavorite(Movie movie);
  Future<void> removeFavorite(int movieId);
}
