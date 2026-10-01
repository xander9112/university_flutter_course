import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_datasource.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  const MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final dtos = await remoteDataSource.getPopularMovies(page: page);
      await localDataSource.cacheMovies(dtos);
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (error, stackTrace) {
      // Сеть не ответила — отдаём кэш.
      try {
        final cached = await localDataSource.getCachedMovies();
        return cached.map((dto) => dto.toEntity()).toList();
      } catch (_) {
        // Кэша нет — сообщаем исходную причину (нет сети, 401, не задан ключ),
        // а не «нет сохранённых данных».
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final dtos = await remoteDataSource.searchMovies(query);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
