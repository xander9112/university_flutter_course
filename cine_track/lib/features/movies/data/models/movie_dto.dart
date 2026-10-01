import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/movie.dart';

part 'movie_dto.freezed.dart';
part 'movie_dto.g.dart';

/// Фильм в том виде, в каком его отдаёт TMDB: сериализация — забота data-слоя.
@freezed
abstract class MovieDto with _$MovieDto {
  // fieldRename: snake — поле posterPath читается из JSON-ключа poster_path и т.д.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieDto({
    required int id,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    @Default('') String releaseDate,
    @Default([]) List<int> genreIds,
  }) = _MovieDto;

  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDtoFromJson(json);
}

extension MovieDtoMapper on MovieDto {
  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    releaseDate: releaseDate,
    genreIds: genreIds,
  );
}
