import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie_dto.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieDto>> getPopularMovies({int page = 1});
  Future<List<MovieDto>> searchMovies(String query);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  static const _baseUrl = 'https://api.themoviedb.org/3';

  // Ключ передаётся при запуске: flutter run --dart-define=TMDB_API_KEY=ваш_ключ
  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');

  final http.Client _client;
  MovieRemoteDataSourceImpl(this._client);

  @override
  Future<List<MovieDto>> getPopularMovies({int page = 1}) => _get(
    '$_baseUrl/movie/popular?api_key=$_apiKey&language=ru-RU&page=$page',
  );

  @override
  Future<List<MovieDto>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    return _get(
      '$_baseUrl/search/movie?api_key=$_apiKey&language=ru-RU'
      '&query=${Uri.encodeComponent(query)}',
    );
  }

  Future<List<MovieDto>> _get(String url) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Не задан ключ TMDB. Запустите приложение с '
        '--dart-define=TMDB_API_KEY=ваш_ключ',
      );
    }
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(url));
    } on http.ClientException {
      // Текст ClientException содержит полный URL вместе с api_key —
      // показывать его пользователю на экране ошибки нельзя.
      throw Exception('Нет соединения с сервером');
    }
    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((json) => MovieDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
