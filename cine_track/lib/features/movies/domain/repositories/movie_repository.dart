import '../entities/movie.dart';

/// Откуда берутся фильмы — решает реализация в data-слое.
/// Ошибки (нет сети, ошибка сервера) сообщаются исключением.
abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies({int page = 1});
  Future<List<Movie>> searchMovies(String query);
}
