/// Фильм — доменная сущность. Чистый Dart: без разбора JSON, сети и БД.
class Movie {
  final int id;
  final String title;
  final String? overview; // nullable: описание может отсутствовать
  final String? posterPath; // nullable: постер может отсутствовать
  final String? backdropPath; // nullable: фоновое изображение
  final double? voteAverage; // nullable: рейтинг может быть не выставлен
  final String releaseDate;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    required this.releaseDate,
    this.genreIds = const [],
  });

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : 'N/A';

  String get rating => voteAverage?.toStringAsFixed(1) ?? '—';

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
}
