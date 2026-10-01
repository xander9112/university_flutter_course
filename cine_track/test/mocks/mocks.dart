import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:cine_track/features/favorites/domain/usecases/get_favorites.dart';
import 'package:cine_track/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:cine_track/features/movies/domain/usecases/search_movies.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_bloc.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_event.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_state.dart';
import 'package:cine_track/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:cine_track/features/ratings/domain/usecases/get_ratings.dart';
import 'package:cine_track/features/ratings/domain/usecases/set_rating.dart';
import 'package:cine_track/features/ratings/presentation/providers/ratings_provider.dart';

// Общие моки для тестов, добавленных сверх задания.

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

class MockSearchMovies extends Mock implements SearchMovies {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockGetFavorites extends Mock implements GetFavorites {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

class MockRatingsRepository extends Mock implements RatingsRepository {}

class MockGetRatings extends Mock implements GetRatings {}

class MockSetRating extends Mock implements SetRating {}

class MockFavoritesProvider extends Mock implements FavoritesProvider {}

class MockRatingsProvider extends Mock implements RatingsProvider {}

/// Мок блока из bloc_test: состояния задаются через `whenListen`.
class MockMoviesBloc extends MockBloc<MoviesEvent, MoviesState>
    implements MoviesBloc {}
