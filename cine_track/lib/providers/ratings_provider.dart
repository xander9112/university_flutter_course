import 'package:flutter/foundation.dart';

class RatingsProvider extends ChangeNotifier {
  final Map<int, double> _ratings = {};

  /// Личная оценка фильма или `null`, если фильм ещё не оценён.
  double? ratingOf(int movieId) => _ratings[movieId];

  void setRating(int movieId, double rating) {
    _ratings[movieId] = rating;
    notifyListeners();
  }
}
