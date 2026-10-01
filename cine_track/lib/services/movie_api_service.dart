import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import 'cache_service.dart';

class MovieApiService {
  static const _baseUrl = 'https://api.themoviedb.org/3';

  // Ключ не хранится в коде, а передаётся при запуске:
  // flutter run --dart-define=TMDB_API_KEY=ваш_ключ
  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      _checkApiKey();
      final uri = Uri.parse(
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=ru-RU&page=$page',
      );
      final response = await _send(uri);
      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }
      await CacheService.saveMovies(response.body); // сохраняем кэш
      return _parseMovies(response.body);
    } catch (e) {
      // при любой ошибке (нет сети или ошибка сервера) — читаем из кэша
      final cached = await CacheService.loadMovies();
      if (cached != null) {
        return _parseMovies(cached);
      }
      rethrow; // кэша нет — пробрасываем ошибку дальше, в MoviesBloc
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    _checkApiKey();
    final uri = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&language=ru-RU'
      '&query=${Uri.encodeComponent(query)}',
    );

    final response = await _send(uri);

    if (response.statusCode == 200) {
      return _parseMovies(response.body);
    } else {
      throw Exception('Ошибка поиска: ${response.statusCode}');
    }
  }

  /// GET-запрос. Сетевую ошибку заменяем понятным сообщением: текст
  /// `ClientException` содержит полный URL — вместе с `api_key`, — а сообщение
  /// об ошибке показывается пользователю на экране.
  Future<http.Response> _send(Uri uri) async {
    try {
      return await http.get(uri);
    } on http.ClientException {
      throw Exception('Нет соединения с сервером');
    }
  }

  List<Movie> _parseMovies(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Не задан ключ TMDB. Запустите приложение с '
        '--dart-define=TMDB_API_KEY=ваш_ключ',
      );
    }
  }
}
