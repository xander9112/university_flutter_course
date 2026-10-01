import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetPopularMovies {
  final MovieRepository repository;
  const GetPopularMovies(this.repository);

  Future<List<Movie>> call({int page = 1}) =>
      repository.getPopularMovies(page: page);
}
