import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/movie.dart';

part 'movies_event.freezed.dart';

/// Имена после `=` совпадают с классами из Задания 13 — `on<LoadMovies>`
/// и `add(AddMovie(movie))` работают без изменений.
@freezed
sealed class MoviesEvent with _$MoviesEvent {
  /// Загрузить популярные фильмы
  const factory MoviesEvent.load() = LoadMovies;

  /// Обновить список (pull-to-refresh). `completer` завершается, когда
  /// обновление закончено — даже если состояние не изменилось.
  const factory MoviesEvent.refresh({Completer<void>? completer}) =
      RefreshMovies;

  /// Пользователь ввёл поисковый запрос
  const factory MoviesEvent.search(String query) = SearchMoviesRequested;

  /// Добавить фильм вручную (форма из Задания 9)
  const factory MoviesEvent.add(Movie movie) = AddMovie;

  /// Удалить фильм (свайп из Задания 7)
  const factory MoviesEvent.remove(int movieId) = RemoveMovie;

  /// Перемешать список (кнопка из Задания 7)
  const factory MoviesEvent.shuffle() = ShuffleMovies;
}
