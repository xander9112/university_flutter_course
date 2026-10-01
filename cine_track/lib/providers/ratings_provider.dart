import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingsProvider extends ChangeNotifier {
  static const _key = 'user_ratings';
  final Map<int, double> _ratings = {};

  RatingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return;
    // В JSON ключи всегда строки: {"27205": 8.5}
    final map = jsonDecode(json) as Map<String, dynamic>;
    _ratings
      ..clear()
      ..addAll(
        map.map(
          (id, rating) => MapEntry(int.parse(id), (rating as num).toDouble()),
        ),
      );
    notifyListeners();
  }

  /// Личная оценка фильма или `null`, если фильм ещё не оценён.
  double? ratingOf(int movieId) => _ratings[movieId];

  Future<void> setRating(int movieId, double rating) async {
    _ratings[movieId] = rating;
    notifyListeners(); // экран обновляется сразу, не дожидаясь записи
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_ratings.map((id, r) => MapEntry(id.toString(), r))),
    );
  }
}
