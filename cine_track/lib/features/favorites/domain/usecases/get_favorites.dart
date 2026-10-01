import 'package:injectable/injectable.dart';

import '../../../movies/domain/entities/movie.dart';
import '../repositories/favorites_repository.dart';

@lazySingleton
class GetFavorites {
  final FavoritesRepository repository;
  const GetFavorites(this.repository);

  Future<List<Movie>> call() => repository.getFavorites();
}
