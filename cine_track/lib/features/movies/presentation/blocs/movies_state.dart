import '../../domain/entities/movie.dart';

abstract class MoviesState {}

/// Начальное состояние (до первой загрузки)
class MoviesInitial extends MoviesState {}

/// Загрузка
class MoviesLoading extends MoviesState {}

/// Данные загружены успешно
class MoviesLoaded extends MoviesState {
  final List<Movie> movies;
  MoviesLoaded(this.movies);
}

/// Произошла ошибка
class MoviesError extends MoviesState {
  final String message;
  MoviesError(this.message);
}
