import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Регистрация классов из чужих пакетов, на которые нельзя поставить аннотацию.
@module
abstract class AppModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
