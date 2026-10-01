import 'package:flutter/foundation.dart';

import '../database/favorites_database.dart';
import '../models/movie.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Movie> _favorites = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);

  FavoritesProvider() {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    _favorites = await FavoritesDatabase.getAll();
    notifyListeners();
  }

  bool isFavorite(int movieId) => _favorites.any((m) => m.id == movieId);

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await FavoritesDatabase.delete(movie.id);
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      await FavoritesDatabase.insert(movie);
      _favorites.add(movie);
    }
    notifyListeners();
  }
}
