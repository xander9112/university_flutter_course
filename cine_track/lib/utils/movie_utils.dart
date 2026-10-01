import '../models/movie.dart';

/// Фильтрует фильмы с рейтингом выше порога
List<Movie> filterByRating(List<Movie> movies, double minRating) {
  return movies.where((m) => (m.voteAverage ?? 0) >= minRating).toList();
}

/// Сортирует фильмы по рейтингу (по убыванию)
List<Movie> sortByRating(List<Movie> movies) {
  final sorted = [...movies];
  sorted.sort((a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0));
  return sorted;
}

/// Возвращает фильмы, в названии которых есть строка query (без учёта регистра)
List<Movie> searchByTitle(List<Movie> movies, String query) {
  if (query.isEmpty) return movies;
  return movies
      .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
      .toList();
}
