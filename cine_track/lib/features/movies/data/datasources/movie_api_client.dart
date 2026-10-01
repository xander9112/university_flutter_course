import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/movie_list_response.dart';

part 'movie_api_client.g.dart';

/// HTTP-клиент TMDB. Реализацию `_MovieApiClient` генерирует Retrofit.
@RestApi(baseUrl: 'https://api.themoviedb.org/3')
abstract class MovieApiClient {
  factory MovieApiClient(Dio dio, {String baseUrl}) = _MovieApiClient;

  @GET('/movie/popular')
  Future<MovieListResponse> getPopularMovies({
    @Query('api_key') required String apiKey,
    @Query('language') String language = 'ru-RU',
    @Query('page') int page = 1,
  });

  @GET('/search/movie')
  Future<MovieListResponse> searchMovies({
    @Query('api_key') required String apiKey,
    @Query('query') required String query,
    @Query('language') String language = 'ru-RU',
  });
}
