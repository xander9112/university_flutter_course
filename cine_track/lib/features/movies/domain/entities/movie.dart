import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';

/// Фильм — доменная сущность. Чистый Dart: без разбора JSON, сети и БД.
/// `copyWith`, `==`, `hashCode` и `toString` генерирует Freezed.
@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required int id,
    required String title,
    String? overview, // nullable: описание может отсутствовать
    String? posterPath, // nullable: постер может отсутствовать
    String? backdropPath, // nullable: фоновое изображение
    double? voteAverage, // nullable: рейтинг может быть не выставлен
    @Default('') String releaseDate,
    @Default([]) List<int> genreIds,
  }) = _Movie;

  // Приватный конструктор нужен, чтобы в Freezed-классе можно было объявить свои геттеры
  const Movie._();

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : 'N/A';

  String get rating => voteAverage?.toStringAsFixed(1) ?? '—';

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
}
