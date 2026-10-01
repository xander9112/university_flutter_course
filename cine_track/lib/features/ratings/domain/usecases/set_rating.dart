import '../repositories/ratings_repository.dart';

class SetRating {
  final RatingsRepository repository;
  const SetRating(this.repository);

  Future<void> call(int movieId, double rating) =>
      repository.setRating(movieId, rating);
}
