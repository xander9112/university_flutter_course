import 'package:injectable/injectable.dart';

import '../repositories/ratings_repository.dart';

@lazySingleton
class GetRatings {
  final RatingsRepository repository;
  const GetRatings(this.repository);

  Future<Map<int, double>> call() => repository.getRatings();
}
