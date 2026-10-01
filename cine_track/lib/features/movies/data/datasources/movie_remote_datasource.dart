import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/movie_dto.dart';
import 'movie_api_client.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieDto>> getPopularMovies({int page = 1});
  Future<List<MovieDto>> searchMovies(String query);
}

@LazySingleton(as: MovieRemoteDataSource)
class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  // Ключ передаётся при запуске: flutter run --dart-define=TMDB_API_KEY=ваш_ключ
  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');

  final MovieApiClient _client;
  MovieRemoteDataSourceImpl(this._client);

  @override
  Future<List<MovieDto>> getPopularMovies({int page = 1}) => _guard(() async {
    final response = await _client.getPopularMovies(
      apiKey: _apiKey,
      page: page,
    );
    return response.results;
  });

  @override
  Future<List<MovieDto>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    return _guard(() async {
      final response = await _client.searchMovies(
        apiKey: _apiKey,
        query: query,
      );
      return response.results;
    });
  }

  /// Переводит DioException в короткие сообщения, как было с пакетом http.
  Future<List<MovieDto>> _guard(
    Future<List<MovieDto>> Function() request,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Не задан ключ TMDB. Запустите приложение с '
        '--dart-define=TMDB_API_KEY=ваш_ключ',
      );
    }
    try {
      return await request();
    } on DioException catch (e) {
      // Текст DioException длинный и может содержать URL вместе с api_key —
      // показывать его пользователю на экране ошибки нельзя.
      final status = e.response?.statusCode;
      throw Exception(
        status != null
            ? 'Ошибка загрузки: $status'
            : 'Нет соединения с сервером',
      );
    }
  }
}
