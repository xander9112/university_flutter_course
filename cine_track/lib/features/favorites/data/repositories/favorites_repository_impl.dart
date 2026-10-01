import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_database.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  @override
  Future<List<Movie>> getFavorites() => FavoritesDatabase.getAll();

  @override
  Future<void> addFavorite(Movie movie) => FavoritesDatabase.insert(movie);

  @override
  Future<void> removeFavorite(int movieId) => FavoritesDatabase.delete(movieId);
}
