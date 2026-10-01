import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/movies/data/datasources/movie_api_client.dart';
import '../config/api_config.dart';

/// Регистрация классов из чужих пакетов и сгенерированных реализаций,
/// на которые нельзя поставить аннотацию.
@module
abstract class AppModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    // Лог запросов печатает URL вместе с api_key — только в отладочной сборке.
    if (kDebugMode) dio.interceptors.add(LogInterceptor(requestBody: true));
    return dio;
  }

  @lazySingleton
  // baseUrl передаётся здесь, а не только в @RestApi: аннотацию генератор
  // читает при кодогенерации, и --dart-define в неё не попал бы.
  MovieApiClient movieApiClient(Dio dio) =>
      MovieApiClient(dio, baseUrl: ApiConfig.baseUrl);
}
