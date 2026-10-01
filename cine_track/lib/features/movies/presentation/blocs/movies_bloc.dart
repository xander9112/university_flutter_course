import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/search_movies.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetPopularMovies _getPopularMovies;
  final SearchMovies _searchMovies;

  /// Последний запрошенный поиск — чтобы отбросить устаревшие ответы.
  String? _latestQuery;

  MoviesBloc({required this._getPopularMovies, required this._searchMovies})
    : super(MoviesInitial()) {
    on<LoadMovies>(_onLoadMovies);
    on<RefreshMovies>(_onRefreshMovies);
    on<SearchMoviesRequested>(_onSearchMoviesRequested);
    on<AddMovie>(_onAddMovie);
    on<RemoveMovie>(_onRemoveMovie);
    on<ShuffleMovies>(_onShuffleMovies);
  }

  Future<void> _onLoadMovies(
    LoadMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    try {
      final movies = await _getPopularMovies();
      emit(MoviesLoaded(movies));
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onRefreshMovies(
    RefreshMovies event,
    Emitter<MoviesState> emit,
  ) async {
    // Не показываем лоадер — просто обновляем данные
    try {
      final movies = await _getPopularMovies();
      emit(MoviesLoaded(movies));
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onSearchMoviesRequested(
    SearchMoviesRequested event,
    Emitter<MoviesState> emit,
  ) async {
    final query = event.query.trim();
    _latestQuery = query;
    // Пустой запрос — возвращаемся к подсказке, а не к «Ничего не найдено».
    if (query.isEmpty) {
      emit(MoviesInitial());
      return;
    }

    emit(MoviesLoading());
    try {
      final movies = await _searchMovies(query);
      // Обработчики событий выполняются параллельно: пока шёл этот запрос,
      // мог уйти более новый. Тогда этот ответ устарел — не показываем его.
      if (query != _latestQuery) return;
      emit(MoviesLoaded(movies));
    } catch (e) {
      if (query != _latestQuery) return;
      emit(MoviesError(e.toString()));
    }
  }

  // Операции со списком меняют только уже загруженное состояние

  void _onAddMovie(AddMovie event, Emitter<MoviesState> emit) {
    final current = state;
    if (current is MoviesLoaded) {
      emit(MoviesLoaded([event.movie, ...current.movies]));
    }
  }

  void _onRemoveMovie(RemoveMovie event, Emitter<MoviesState> emit) {
    final current = state;
    if (current is MoviesLoaded) {
      emit(
        MoviesLoaded(
          current.movies.where((m) => m.id != event.movieId).toList(),
        ),
      );
    }
  }

  void _onShuffleMovies(ShuffleMovies event, Emitter<MoviesState> emit) {
    final current = state;
    if (current is MoviesLoaded) {
      emit(MoviesLoaded([...current.movies]..shuffle()));
    }
  }
}
