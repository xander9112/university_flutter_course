import '../../models/movie.dart';

abstract class MoviesEvent {}

/// Загрузить популярные фильмы
class LoadMovies extends MoviesEvent {}

/// Обновить список (pull-to-refresh)
class RefreshMovies extends MoviesEvent {}

/// Пользователь ввёл поисковый запрос
class SearchMoviesRequested extends MoviesEvent {
  final String query;
  SearchMoviesRequested(this.query);
}

/// Добавить фильм вручную (форма из Задания 9)
class AddMovie extends MoviesEvent {
  final Movie movie;
  AddMovie(this.movie);
}

/// Удалить фильм (свайп из Задания 7)
class RemoveMovie extends MoviesEvent {
  final int movieId;
  RemoveMovie(this.movieId);
}

/// Перемешать список (кнопка из Задания 7)
class ShuffleMovies extends MoviesEvent {}
