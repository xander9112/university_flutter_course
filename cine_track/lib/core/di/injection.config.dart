// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/favorites/data/repositories/favorites_repository_impl.dart'
    as _i144;
import '../../features/favorites/domain/repositories/favorites_repository.dart'
    as _i212;
import '../../features/favorites/domain/usecases/get_favorites.dart' as _i418;
import '../../features/favorites/domain/usecases/toggle_favorite.dart' as _i189;
import '../../features/favorites/presentation/providers/favorites_provider.dart'
    as _i366;
import '../../features/movies/data/datasources/movie_local_datasource.dart'
    as _i762;
import '../../features/movies/data/datasources/movie_remote_datasource.dart'
    as _i492;
import '../../features/movies/data/repositories/movie_repository_impl.dart'
    as _i652;
import '../../features/movies/domain/repositories/movie_repository.dart'
    as _i465;
import '../../features/movies/domain/usecases/get_popular_movies.dart' as _i995;
import '../../features/movies/domain/usecases/search_movies.dart' as _i356;
import '../../features/movies/presentation/blocs/movies_bloc.dart' as _i580;
import '../../features/ratings/data/repositories/ratings_repository_impl.dart'
    as _i1046;
import '../../features/ratings/domain/repositories/ratings_repository.dart'
    as _i607;
import '../../features/ratings/domain/usecases/get_ratings.dart' as _i824;
import '../../features/ratings/domain/usecases/set_rating.dart' as _i921;
import '../../features/ratings/presentation/providers/ratings_provider.dart'
    as _i101;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i519.Client>(() => appModule.httpClient);
    gh.lazySingleton<_i212.FavoritesRepository>(
      () => _i144.FavoritesRepositoryImpl(),
    );
    gh.lazySingleton<_i607.RatingsRepository>(
      () => _i1046.RatingsRepositoryImpl(),
    );
    gh.lazySingleton<_i762.MovieLocalDataSource>(
      () => _i762.MovieLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i418.GetFavorites>(
      () => _i418.GetFavorites(gh<_i212.FavoritesRepository>()),
    );
    gh.lazySingleton<_i189.ToggleFavorite>(
      () => _i189.ToggleFavorite(gh<_i212.FavoritesRepository>()),
    );
    gh.lazySingleton<_i492.MovieRemoteDataSource>(
      () => _i492.MovieRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.factory<_i366.FavoritesProvider>(
      () => _i366.FavoritesProvider(
        getFavorites: gh<_i418.GetFavorites>(),
        toggleFavorite: gh<_i189.ToggleFavorite>(),
      ),
    );
    gh.lazySingleton<_i824.GetRatings>(
      () => _i824.GetRatings(gh<_i607.RatingsRepository>()),
    );
    gh.lazySingleton<_i921.SetRating>(
      () => _i921.SetRating(gh<_i607.RatingsRepository>()),
    );
    gh.factory<_i101.RatingsProvider>(
      () => _i101.RatingsProvider(
        getRatings: gh<_i824.GetRatings>(),
        setRating: gh<_i921.SetRating>(),
      ),
    );
    gh.lazySingleton<_i465.MovieRepository>(
      () => _i652.MovieRepositoryImpl(
        remoteDataSource: gh<_i492.MovieRemoteDataSource>(),
        localDataSource: gh<_i762.MovieLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i995.GetPopularMovies>(
      () => _i995.GetPopularMovies(gh<_i465.MovieRepository>()),
    );
    gh.lazySingleton<_i356.SearchMovies>(
      () => _i356.SearchMovies(gh<_i465.MovieRepository>()),
    );
    gh.factory<_i580.MoviesBloc>(
      () => _i580.MoviesBloc(
        getPopularMovies: gh<_i995.GetPopularMovies>(),
        searchMovies: gh<_i356.SearchMovies>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
