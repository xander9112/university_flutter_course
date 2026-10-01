import '../../domain/entities/movie.dart';

/// Фильм в том виде, в каком его отдаёт TMDB: сериализация — забота data-слоя.
class MovieDto {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String releaseDate;
  final List<int> genreIds;

  const MovieDto({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    required this.releaseDate,
    this.genreIds = const [],
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) {
    return MovieDto(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      releaseDate: json['release_date'] as String? ?? '',
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'vote_average': voteAverage,
    'release_date': releaseDate,
    'genre_ids': genreIds,
  };

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
