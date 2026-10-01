// Ручная сборка зависимостей «снизу вверх»:
// источники данных → репозиторий → use cases → BLoC / провайдер.
// В Задании 16 эту работу возьмёт на себя DI-контейнер.
import 'package:http/http.dart' as http;

import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/usecases/get_favorites.dart';
import 'features/favorites/domain/usecases/toggle_favorite.dart';
import 'features/favorites/presentation/providers/favorites_provider.dart';
import 'features/movies/data/datasources/movie_local_datasource.dart';
import 'features/movies/data/datasources/movie_remote_datasource.dart';
import 'features/movies/data/repositories/movie_repository_impl.dart';
import 'features/movies/domain/repositories/movie_repository.dart';
import 'features/movies/domain/usecases/get_popular_movies.dart';
import 'features/movies/domain/usecases/search_movies.dart';
import 'features/movies/presentation/blocs/movies_bloc.dart';
import 'features/ratings/data/repositories/ratings_repository_impl.dart';
import 'features/ratings/domain/usecases/get_ratings.dart';
import 'features/ratings/domain/usecases/set_rating.dart';
import 'features/ratings/presentation/providers/ratings_provider.dart';

MovieRepository _createMovieRepository() => MovieRepositoryImpl(
  remoteDataSource: MovieRemoteDataSourceImpl(http.Client()),
  localDataSource: MovieLocalDataSourceImpl(),
);

MoviesBloc createMoviesBloc() {
  final repository = _createMovieRepository();
  return MoviesBloc(
    getPopularMovies: GetPopularMovies(repository),
    searchMovies: SearchMovies(repository),
  );
}

FavoritesProvider createFavoritesProvider() {
  final repository = FavoritesRepositoryImpl();
  return FavoritesProvider(
    getFavorites: GetFavorites(repository),
    toggleFavorite: ToggleFavorite(repository),
  );
}

RatingsProvider createRatingsProvider() {
  final repository = RatingsRepositoryImpl();
  return RatingsProvider(
    getRatings: GetRatings(repository),
    setRating: SetRating(repository),
  );
}
