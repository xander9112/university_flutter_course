import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class SearchMovies {
  final MovieRepository repository;
  const SearchMovies(this.repository);

  Future<List<Movie>> call(String query) => repository.searchMovies(query);
}
