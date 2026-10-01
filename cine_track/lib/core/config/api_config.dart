/// Адреса API фильмов. По умолчанию — настоящий TMDB; для своего сервера
/// (cine_track_api в репозитории курса) их задают при сборке:
///
/// ```bash
/// flutter build web \
///   --dart-define=TMDB_API_KEY=ключ \
///   --dart-define=TMDB_BASE_URL=https://api.example.com/3 \
///   --dart-define=TMDB_IMAGE_BASE_URL=https://api.example.com/t/p/w500
/// ```
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'TMDB_BASE_URL',
    defaultValue: 'https://api.themoviedb.org/3',
  );

  /// К адресу дописывается poster_path, который начинается с «/».
  static const imageBaseUrl = String.fromEnvironment(
    'TMDB_IMAGE_BASE_URL',
    defaultValue: 'https://image.tmdb.org/t/p/w500',
  );
}
