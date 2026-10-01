import 'package:flutter/foundation.dart';

import '../../domain/usecases/get_ratings.dart';
import '../../domain/usecases/set_rating.dart';

class RatingsProvider extends ChangeNotifier {
  final GetRatings _getRatings;
  final SetRating _setRating;

  final Map<int, double> _ratings = {};

  RatingsProvider({required this._getRatings, required this._setRating}) {
    _load();
  }

  Future<void> _load() async {
    _ratings
      ..clear()
      ..addAll(await _getRatings());
    notifyListeners();
  }

  /// Личная оценка фильма или `null`, если фильм ещё не оценён.
  double? ratingOf(int movieId) => _ratings[movieId];

  Future<void> setRating(int movieId, double rating) async {
    _ratings[movieId] = rating;
    notifyListeners(); // экран обновляется сразу, не дожидаясь записи
    await _setRating(movieId, rating);
  }
}
