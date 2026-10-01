import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../movies/domain/entities/movie.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';

@injectable
class FavoritesProvider extends ChangeNotifier {
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  List<Movie> _favorites = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);

  FavoritesProvider({
    required this._getFavorites,
    required this._toggleFavorite,
  }) {
    _load();
  }

  Future<void> _load() async {
    _favorites = await _getFavorites();
    notifyListeners();
  }

  bool isFavorite(int movieId) => _favorites.any((m) => m.id == movieId);

  Future<void> toggleFavorite(Movie movie) async {
    final wasFavorite = isFavorite(movie.id);
    await _toggleFavorite(movie, isFavorite: wasFavorite);
    if (wasFavorite) {
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }
}
