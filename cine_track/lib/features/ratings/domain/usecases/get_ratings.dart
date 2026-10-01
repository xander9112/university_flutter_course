import '../repositories/ratings_repository.dart';

class GetRatings {
  final RatingsRepository repository;
  const GetRatings(this.repository);

  Future<Map<int, double>> call() => repository.getRatings();
}
