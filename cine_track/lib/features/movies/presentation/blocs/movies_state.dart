import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/movie.dart';

part 'movies_state.freezed.dart';

@freezed
sealed class MoviesState with _$MoviesState {
  /// Начальное состояние (до первой загрузки)
  const factory MoviesState.initial() = MoviesInitial;

  /// Загрузка
  const factory MoviesState.loading() = MoviesLoading;

  /// Данные загружены успешно
  const factory MoviesState.loaded(List<Movie> movies) = MoviesLoaded;

  /// Произошла ошибка
  const factory MoviesState.error(String message) = MoviesError;
}
