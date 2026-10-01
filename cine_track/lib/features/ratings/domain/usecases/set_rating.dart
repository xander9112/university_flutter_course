import 'package:injectable/injectable.dart';

import '../repositories/ratings_repository.dart';

@lazySingleton
class SetRating {
  final RatingsRepository repository;
  const SetRating(this.repository);

  Future<void> call(int movieId, double rating) =>
      repository.setRating(movieId, rating);
}
