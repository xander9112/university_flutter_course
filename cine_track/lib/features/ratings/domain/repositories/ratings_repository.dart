/// Личные оценки: id фильма → оценка.
abstract class RatingsRepository {
  Future<Map<int, double>> getRatings();
  Future<void> setRating(int movieId, double rating);
}
