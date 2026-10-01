import 'package:freezed_annotation/freezed_annotation.dart';

import 'movie_dto.dart';

part 'movie_list_response.freezed.dart';
part 'movie_list_response.g.dart';

/// Ответ TMDB со списком фильмов: `/movie/popular` и `/search/movie`.
@freezed
abstract class MovieListResponse with _$MovieListResponse {
  const factory MovieListResponse({
    required List<MovieDto> results,
    @Default(1) int page,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _MovieListResponse;

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);
}
