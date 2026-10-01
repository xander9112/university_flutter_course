import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/movie_api_service.dart';

class MoviesProvider extends ChangeNotifier {
  final MovieApiService _apiService = MovieApiService();

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movies = await _apiService.getPopularMovies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Операции со списком, которые раньше делались через setState в HomeScreen

  void addMovie(Movie movie) {
    _movies.insert(0, movie);
    notifyListeners();
  }

  void removeMovie(int movieId) {
    _movies.removeWhere((m) => m.id == movieId);
    notifyListeners();
  }

  void shuffle() {
    _movies.shuffle();
    notifyListeners();
  }
}
