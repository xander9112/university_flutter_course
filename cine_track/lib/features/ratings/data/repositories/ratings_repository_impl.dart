import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ratings_repository.dart';

/// Хранит оценки в SharedPreferences строкой JSON: `{"27205": 8.5}`.
/// В JSON ключи всегда строки, поэтому id переводятся туда и обратно.
@LazySingleton(as: RatingsRepository)
class RatingsRepositoryImpl implements RatingsRepository {
  static const _key = 'user_ratings';

  @override
  Future<Map<int, double>> getRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return {};
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map(
      (id, rating) => MapEntry(int.parse(id), (rating as num).toDouble()),
    );
  }

  @override
  Future<void> setRating(int movieId, double rating) async {
    final ratings = await getRatings();
    ratings[movieId] = rating;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(ratings.map((id, r) => MapEntry(id.toString(), r))),
    );
  }
}
