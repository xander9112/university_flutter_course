# CHANGELOG — CineTrack

Каждая лекция курса — отдельная ветка `lesson_N`. Здесь описано, что изменилось в приложении по сравнению с предыдущей лекцией.

## Лекция 17 — Генерация кода (`lesson_17`)

Ручной бойлерплейт заменён кодогенерацией: модели, события и состояния — на Freezed и json_serializable, HTTP-клиент `http` — на Dio с API-клиентом Retrofit.

### Добавлено
- Зависимости `freezed_annotation: ^3.1.0`, `json_annotation: ^4.12.0`, `retrofit: ^4.10.0`, `dio: ^5.11.1`; dev — `freezed: ^4.0.1`, `json_serializable: ^6.14.1`, `retrofit_generator: ^10.2.11`.
- `lib/features/movies/data/datasources/movie_api_client.dart` — Retrofit-клиент `MovieApiClient` (`@RestApi`, `@GET('/movie/popular')`, `@GET('/search/movie')`, параметры через `@Query`).
- `lib/features/movies/data/models/movie_list_response.dart` — ответ TMDB (`results`, `page`, `total_pages`).
- Сгенерированные файлы `*.freezed.dart`, `*.g.dart` — лежат в репозитории, как и `injection.config.dart`.
- `analysis_options.yaml`: `invalid_annotation_target: ignore` — Freezed ставит `@JsonSerializable`/`@JsonKey` на параметры конструктора.

### Изменено
- `Movie` — `@freezed abstract class`: появились `copyWith`, `==`, `hashCode`; геттеры `year`, `rating`, `posterUrl` остались (через приватный конструктор `Movie._()`). `releaseDate` теперь `@Default('')`.
- `MovieDto` — `@freezed` + `@JsonSerializable(fieldRename: FieldRename.snake)`: `fromJson`/`toJson` генерируются, формат JSON прежний — старый файловый кэш читается. `toEntity()` стал расширением `MovieDtoMapper`, поэтому в `MovieRepositoryImpl` добавлен импорт `movie_dto.dart`.
- `MoviesEvent` и `MoviesState` — `@freezed sealed class` с прежними именами классов (`LoadMovies`, `MoviesLoaded` и т.д.), так что `on<...>` в блоке и вызовы `add(...)` не изменились.
- `HomeScreen`: цепочка `if (state is ...)` заменена на `state.when(...)` — разметка ошибки и списка вынесена в `_buildError` и `_buildMovies`.
- Pull-to-refresh: событие `RefreshMovies` несёт `Completer`, блок завершает его в `finally`, `RefreshIndicator` ждёт `completer.future`. Раньше индикатор ждал `bloc.stream.first`, а Bloc не выдаёт состояние, равное текущему: при тех же фильмах индикатор крутился бы бесконечно.
- `AppModule`: вместо `http.Client` — `Dio` (таймауты 15 с) и фабрика `MovieApiClient`.
- `MovieRemoteDataSourceImpl` работает через `MovieApiClient`; ручной разбор JSON удалён. `_guard` переводит `DioException` в прежние сообщения «Ошибка загрузки: код» и «Нет соединения с сервером» — текст `DioException` может содержать URL с `api_key`.
- `README.md`: какие файлы генерируются.

### Удалено
- Зависимость `http` (остаётся только транзитивной).

### Отличия от задания
- `LogInterceptor` подключается только при `kDebugMode`: он печатает URL запроса вместе с `api_key`, а в релизной сборке логи тоже видны (например, в `adb logcat`).
- Проверка пустого ключа («Не задан ключ TMDB», подсказка из Задания 11) осталась — теперь в `_guard`.

### Проверка
- `dart run build_runner build --delete-conflicting-outputs` — без ошибок; `flutter analyze` — без замечаний.
- Временные тесты (удалены после проверки):
  - `MovieDto.fromJson`: snake_case-ключи, `release_date: null` → `''`, обратимость `toJson`, чтение кэша прошлой версии;
  - `MovieApiClient` через подменный адаптер Dio: путь и параметры (`api_key`, `language=ru-RU`, `page`, `query` с кириллицей); ответ 401 → «Ошибка загрузки: 401», сетевая ошибка → «Нет соединения с сервером» без URL;
  - `MoviesBloc`: refresh с теми же фильмами завершает `Completer`, удаление работает;
  - `HomeScreen`: pull-to-refresh с теми же данными — индикатор исчезает.
- `flutter build web`, `flutter build apk --debug`, `flutter build ios --simulator` проходят; в headless Chrome приложение запускается без ошибок, сетевая ошибка Dio показывается как «Нет соединения с сервером».

## Лекция 16 — Dependency Injection (`lesson_16`)

Ручная сборка зависимостей из `app_dependencies.dart` заменена на GetIt + Injectable: классы помечены аннотациями, регистрация генерируется.

### Добавлено
- Зависимости `get_it: ^9.3.0`, `injectable: ^3.0.0`; dev — `injectable_generator: ^3.1.3`, `build_runner: ^2.16.1`.
- `lib/core/di/injection.dart` — `sl = GetIt.instance` и `configureDependencies()` (`@InjectableInit`).
- `lib/core/di/injection.config.dart` — сгенерирован `build_runner`, лежит в репозитории.
- `lib/core/di/app_module.dart` — `@module AppModule` регистрирует `http.Client` как `@lazySingleton`: один клиент на всё приложение.
- Аннотации:
  - `@LazySingleton(as: ...)` — `MovieRemoteDataSourceImpl`, `MovieLocalDataSourceImpl`, `MovieRepositoryImpl`, `FavoritesRepositoryImpl`, `RatingsRepositoryImpl` (регистрируются под типом абстракции);
  - `@lazySingleton` — use cases `GetPopularMovies`, `SearchMovies`, `GetFavorites`, `ToggleFavorite`, `GetRatings`, `SetRating`;
  - `@injectable` (factory) — `MoviesBloc`, `FavoritesProvider`, `RatingsProvider`: у каждого `BlocProvider` свой экземпляр.
- `README.md`: как перегенерировать код.

### Изменено
- `lib/main.dart`: `main()` стал асинхронным — `WidgetsFlutterBinding.ensureInitialized()`, веб-фабрика SQLite, затем `await configureDependencies()` до `runApp`. Блок и провайдеры берутся из `sl<T>()`.
- `SearchScreen`: `BlocProvider(create: (_) => sl<MoviesBloc>())`.

### Удалено
- `lib/app_dependencies.dart`.

### Проверка
- `flutter analyze` — без замечаний; `dart run build_runner build` генерирует регистрацию всех 15 классов и `http.Client`.
- Временный тест (удалён после проверки) через настоящий `configureDependencies()`: `MoviesBloc`, `FavoritesProvider`, `RatingsProvider` — новые экземпляры при каждом `sl<T>()`; `MovieRepository` (это `MovieRepositoryImpl`), use cases и `http.Client` — одни и те же; приложение, собранное через `sl<T>()`, загружает список, поиск работает и не меняет главный экран.
- `flutter build web` проходит, в headless Chrome приложение запускается без ошибок.

## Лекция 15 — Clean Architecture (`lesson_15`)

Проект разложен по фичам (`movies`, `favorites`, `ratings`, `main`) и трём слоям: `domain`, `data`, `presentation`. Поведение приложения не изменилось.

### Новая структура `lib/`
```
core/theme/theme_provider.dart
features/
  main/presentation/screens/main_screen.dart
  movies/
    domain/      entities/movie.dart, repositories/movie_repository.dart,
                 usecases/get_popular_movies.dart, usecases/search_movies.dart
    data/        models/movie_dto.dart, datasources/movie_remote_datasource.dart,
                 datasources/movie_local_datasource.dart, repositories/movie_repository_impl.dart
    presentation/blocs/, screens/ (home, search, add_movie, movie_detail),
                 widgets/ (movie_card, movie_poster, movie_preview_card, rating_dialog), genres.dart
  favorites/
    domain/      repositories/favorites_repository.dart, usecases/get_favorites.dart, usecases/toggle_favorite.dart
    data/        datasources/favorites_database.dart, repositories/favorites_repository_impl.dart
    presentation/providers/favorites_provider.dart, screens/favorites_screen.dart
  ratings/
    domain/      repositories/ratings_repository.dart, usecases/get_ratings.dart, usecases/set_rating.dart
    data/        repositories/ratings_repository_impl.dart
    presentation/providers/ratings_provider.dart
app_dependencies.dart
main.dart
```
Файлы перенесены через `git mv` — история сохранилась.

### Добавлено
- `Movie` — доменная сущность без `fromJson`. Разбор и сериализация JSON — в `MovieDto` (`fromJson`, `toJson` для кэша, `toEntity()`).
- `MovieRepository` (интерфейс) и `MovieRepositoryImpl`: берёт фильмы из сети, кэширует, при ошибке отдаёт кэш.
- `MovieRemoteDataSourceImpl` (вместо `MovieApiService`) получает `http.Client` через конструктор. `MovieLocalDataSourceImpl` (вместо `CacheService`) хранит список DTO: файл на Android/iOS, `SharedPreferences` в вебе.
- Use cases: `GetPopularMovies`, `SearchMovies`, `GetFavorites`, `ToggleFavorite`, `GetRatings`, `SetRating`.
- `FavoritesRepository` / `FavoritesRepositoryImpl` (поверх `FavoritesDatabase`), `RatingsRepository` / `RatingsRepositoryImpl` (поверх `SharedPreferences`, ключ `user_ratings`).
- `lib/app_dependencies.dart` — ручная сборка: `createMoviesBloc()`, `createFavoritesProvider()`, `createRatingsProvider()`.

### Изменено
- `MoviesBloc` получает `GetPopularMovies` и `SearchMovies` через конструктор и не знает про сеть.
- `FavoritesProvider` и `RatingsProvider` получают use cases через конструктор и не обращаются к БД и `SharedPreferences` напрямую.
- `main.dart` и `SearchScreen` создают блок и провайдеры через функции из `app_dependencies.dart`.
- Конструкторы с именованными параметрами для приватных полей записаны как `required this._getPopularMovies` (снаружи параметр называется `getPopularMovies:`).
- `MovieRepositoryImpl`: если сеть не ответила и кэша нет, пробрасывается исходная ошибка (`Error.throwWithStackTrace`) — 401, «Не задан ключ» или «Нет соединения с сервером», — а не «Нет сети и нет сохранённых данных».
- `MovieRemoteDataSourceImpl`: сетевая ошибка, как и в `MovieApiService` с Лекции 11, заменяется на «Нет соединения с сервером» — текст `ClientException` содержит URL вместе с `api_key`.

### Удалено
- Старые папки `lib/models`, `lib/services`, `lib/database`, `lib/providers`, `lib/blocs`, `lib/screens`, `lib/widgets`, `lib/data`, `lib/utils`, в том числе `mock_movies.dart` и `movie_utils.dart` из Лекции 3.

### Отличия от кода в задании
- Проверка незаданного ключа TMDB (подсказка из Задания 11) перенесена из `MovieApiService` в `MovieRemoteDataSourceImpl`.

### Проверка
- `flutter analyze` — без замечаний. Domain-слой не импортирует ни data, ни presentation, ни Flutter/сеть/БД; data не импортирует presentation; presentation не импортирует data.
- Временные тесты (удалены после проверки; SQLite через временную `sqflite_common_ffi`, тоже удалена):
  - репозиторий: без кэша — исходная ошибка 401; после успешного ответа кэш записан; при ответе 500 возвращается кэш;
  - приложение, собранное через `create*`-функции: загрузка, сердце → вкладка «Избранное», оценка из избранного, поиск, удаление, добавление, тёмная тема; после «перезапуска» избранное и оценка восстанавливаются;
  - сетевая ошибка не показывает `api_key`.
- `flutter build web` проходит, в headless Chrome приложение запускается без ошибок.

## Лекция 14 — Хранение данных на устройстве (`lesson_14`)

Данные переживают перезапуск: тема и личные оценки — в `SharedPreferences`, избранное — в SQLite, последний список популярных фильмов — в файле (в вебе — в `SharedPreferences`). Всё работает на трёх платформах: Android, iOS и веб.

### Добавлено
- Зависимости `shared_preferences`, `sqflite`, `path`, `path_provider`, `sqflite_common_ffi_web`.
- `web/sqlite3.wasm` и `web/sqflite_sw.js` — SQLite для браузера (созданы командой `dart run sqflite_common_ffi_web:setup`).
- `lib/main.dart`: в вебе (`kIsWeb`) `databaseFactory = databaseFactoryFfiWeb` — SQLite работает через WebAssembly и хранит базу в IndexedDB; на Android и iOS остаётся стандартный `sqflite`.
- `lib/providers/theme_provider.dart` — `ThemeProvider`: тёмная/светлая тема, выбор сохраняется в `SharedPreferences` (ключ `dark_mode`) и загружается при старте.
- `HomeScreen`: кнопка луны/солнца в `AppBar` переключает тему.
- `lib/database/favorites_database.dart` — `FavoritesDatabase`: таблица `favorites` в `cine_track.db` со всеми полями фильма; жанры хранятся строкой «28,878,12».
- `lib/services/cache_service.dart` — `CacheService`: сохраняет JSON последнего ответа `/movie/popular` в `movies_cache.json` в папке документов приложения. В вебе файловой системы нет, поэтому там JSON хранится в `SharedPreferences` (`localStorage`). Ошибка записи кэша перехватывается — иначе она превратила бы успешный ответ сервера в ошибку загрузки.

### Изменено
- `lib/main.dart`: в `MultiProvider` добавлен `ThemeProvider`; `MaterialApp` берёт `themeMode` из него, заданы `theme` (светлая) и `darkTheme` (тёмная).
- `RatingsProvider`: оценки сохраняются в `SharedPreferences` строкой JSON (ключ `user_ratings`, например `{"27205":8.5}`) и загружаются в конструкторе. `setRating` стал асинхронным, но уведомляет экран сразу, не дожидаясь записи.
- `FavoritesProvider`: загружает избранное из БД в конструкторе; `toggleFavorite` стал асинхронным и сначала пишет в БД.
- `MovieApiService.getPopularMovies`: успешный ответ сохраняется в кэш; при любой ошибке (нет сети, ответ не 200, не задан ключ) возвращается кэш, а если его нет — ошибка пробрасывается в `MoviesBloc`. Разбор JSON — в общем `_parseMovies`.
- `HomeScreen`: двойной тап ждёт `toggleFavorite` (`await`) и только потом выбирает текст `SnackBar` — иначе `isFavorite` вернул бы значение до записи в БД, и сообщение было бы неверным.

### Проверка
- `flutter analyze` — без замечаний.
- Временные тесты (удалены после проверки; SQLite через временную dev-зависимость `sqflite_common_ffi`, которая тоже удалена):
  - избранное после «перезапуска» (новый `FavoritesProvider`) восстанавливается со всеми полями, включая `null` и пустой список жанров; удаление тоже сохраняется;
  - оценки и тема восстанавливаются после «перезапуска»; в `SharedPreferences` лежит `{"27205":8.5,"1":9.0}`;
  - кэш: без кэша ошибка пробрасывается; после успешного ответа файл создаётся; при ответе 500 и без сети возвращается кэш; новый успешный ответ обновляет кэш;
  - кнопка темы переключает `themeMode` и иконку; двойной тап показывает «добавлен» / «удалён» правильно при асинхронной записи в БД;
  - снимки экрана в тёмной теме: главная и экран деталей читаются, сохранённая оценка показана.
- Веб: временная точка входа собрана `flutter build web` и запущена в headless Chrome (puppeteer) дважды с одним профилем. Первый запуск: SQLite insert/delete, запись оценки, кэш после успешного ответа. Второй запуск (после перезагрузки): избранное из SQLite и оценка на месте, без сети возвращается кэш. Само приложение в браузере запускается без ошибок.
- Сборки: `flutter build apk --debug` и `flutter build ios --simulator` проходят.

## Лекция 13 — BLoC (`lesson_13`)

`MoviesProvider` заменён на `MoviesBloc`: загрузка, обновление, поиск, добавление, удаление и перемешивание стали событиями. `FavoritesProvider` и `RatingsProvider` остаются провайдерами.

### Добавлено
- Зависимость `flutter_bloc: ^9.1.1` (`bloc` 9).
- `lib/blocs/movies/movies_event.dart` — события `LoadMovies`, `RefreshMovies`, `SearchMoviesRequested`, `AddMovie`, `RemoveMovie`, `ShuffleMovies`.
- `lib/blocs/movies/movies_state.dart` — состояния `MoviesInitial`, `MoviesLoading`, `MoviesLoaded`, `MoviesError`.
- `lib/blocs/movies/movies_bloc.dart` — `MoviesBloc` с обработчиком на каждое событие. Операции со списком не меняют `current.movies` на месте, а выдают новое состояние с новым списком.
- `MoviesBloc`: пустой поисковый запрос возвращает `MoviesInitial` (на экране снова подсказка), а ответ на устаревший запрос отбрасывается (`_latestQuery`) — Bloc выполняет обработчики параллельно, и медленный старый ответ мог бы затереть новый.
- `HomeScreen`: pull-to-refresh — `RefreshIndicator` вокруг списка «Все фильмы» отправляет `RefreshMovies` и ждёт следующего состояния (`bloc.stream.first`).

### Изменено
- `lib/main.dart`: вместо `ChangeNotifierProvider(MoviesProvider)` — `BlocProvider(create: (_) => MoviesBloc(MovieApiService())..add(LoadMovies()))`.
- `HomeScreen`: тело экрана — `BlocBuilder<MoviesBloc, MoviesState>`; перемешивание, удаление и добавление отправляют события. Вызов `loadMovies()` из `initState` удалён — загрузку запускает `LoadMovies` при создании блока.
- `SearchScreen`: создаёт собственный `MoviesBloc` через `BlocProvider`, а поле ввода и debounce переехали в `_SearchView`. Тело — `BlocBuilder`: `MoviesInitial` → подсказка, `MoviesLoading` → индикатор, `MoviesError` → текст ошибки, пустой результат → «Ничего не найдено».

### Удалено
- `lib/providers/movies_provider.dart`.

### Известное ограничение
- Если pull-to-refresh завершился ошибкой, весь список заменяется экраном ошибки с «Повторить» — так написано в задании (`RefreshMovies` выдаёт `MoviesError`).

### Проверка
- `flutter analyze` — без замечаний.
- Временные тесты (удалены после проверки) с подменой сети через `MockClient`:
  - блок: `RemoveMovie` и `ShuffleMovies` не меняют список предыдущего состояния; при запросах «slow» → «fast» выдаётся только результат «fast»; пустой запрос даёт `MoviesInitial`;
  - главный экран: индикатор → список; удаление свайпом без ошибок `Dismissible`; перемешивание; добавление фильма; pull-to-refresh делает новый запрос, показывает `RefreshProgressIndicator` и скрывает его после ответа; ошибка 500 → «Повторить» → список;
  - поиск: подсказка, результаты, «Ничего не найдено», очистка возвращает подсказку; список на главной после поиска не меняется.

## Лекция 12 — Управление состоянием (`lesson_12`)

Список фильмов, избранное и личные оценки вынесены из виджетов в `Provider`. Избранное теперь по-настоящему хранится и видно на отдельной вкладке, а оценка сохраняется, откуда бы ни был открыт экран деталей.

### Добавлено
- Зависимость `provider: ^6.1.5+1`.
- `lib/providers/movies_provider.dart` — `MoviesProvider` (`ChangeNotifier`): `movies`, `isLoading`, `error`, `loadMovies()` (через `MovieApiService`), `addMovie`, `removeMovie`, `shuffle`.
- `lib/providers/favorites_provider.dart` — `FavoritesProvider`: `favorites` (неизменяемая копия), `isFavorite(id)`, `toggleFavorite(movie)`.
- `lib/providers/ratings_provider.dart` — `RatingsProvider`: личные оценки «id фильма → оценка», `ratingOf(id)`, `setRating(id, rating)`.
- `MovieDetailScreen`: под характеристиками — «Ваша оценка: 8.0» или «Вы ещё не оценили этот фильм» (через `context.watch<RatingsProvider>()`); кнопка называется «Оценить» или «Изменить оценку».
- `MovieCard`: кнопка-сердце справа. Состояние читается через `context.watch<FavoritesProvider>()`, поэтому иконка меняется сразу после нажатия.

### Изменено
- `lib/main.dart`: приложение обёрнуто в `MultiProvider` с тремя провайдерами.
- `HomeScreen`: поля `_apiService`, `_movies`, `_isLoading`, `_error` и методы загрузки удалены — всё это теперь в `MoviesProvider`. Экран подписан через `context.watch`, загрузка запускается в `initState` через `Future.microtask`. Перемешивание, удаление свайпом и добавление вызывают методы провайдера через `context.read`. Словарь `_userRatings` удалён — оценки хранит `RatingsProvider`. Переход на детали снова простой `pushNamed`, без ожидания результата и `setState`.
- `HomeScreen`: двойной тап вызывает `toggleFavorite`. Текст `SnackBar` зависит от результата: «… добавлен в избранное» или «… удалён из избранного».
- `FavoritesScreen`: вместо заглушки — список избранного из `FavoritesProvider`, при пустом списке «Нет избранных фильмов».
- `MovieDetailScreen`: после диалога оценка записывается в `RatingsProvider` и показывается `SnackBar`; экран остаётся открытым. Возврат оценки через `Navigator.pop(context, rating)` из Лекции 10 убран — с общим состоянием он не нужен.

### Отличия от кода в задании
- В `FavoritesScreen` `AppBar` «Избранное» показан и при пустом списке — иначе заголовок вкладки пропадал бы. Тап по карточке в избранном открывает экран деталей, как на главной и в поиске.
- В `Future.microtask` из `initState` перед `context.read` проверяется `mounted`.

### Проверка
- `flutter analyze` — без замечаний.
- Временный виджет-тест (удалён после проверки) с подменой сети через `MockClient`:
  - сердце сразу меняет иконку и не открывает детали;
  - вкладка «Избранное» обновляется без перезагрузки; снятие сердца в избранном возвращает «Нет избранных фильмов», и иконка на главной тоже снимается;
  - двойной тап добавляет и удаляет из избранного с правильным `SnackBar`;
  - удаление, перемешивание и добавление меняют `MoviesProvider.movies`, и список на экране совпадает с ним;
  - ошибка загрузки, затем «Повторить» — индикатор и успешная загрузка;
  - оценка, поставленная с главной, из поиска и из избранного, сохраняется в `RatingsProvider` и видна при открытии фильма с любого экрана; «Изменить оценку» перезаписывает её, «Отмена» — нет.

## Лекция 11 — Работа с HTTP (`lesson_11`)

Главный экран и поиск работают с реальным TMDB API вместо `mockMovies`.

### Добавлено
- Зависимость `http: ^1.6.0`.
- `Movie.fromJson` — разбор фильма из ответа TMDB (`vote_average` может прийти целым числом, `release_date` и `genre_ids` — отсутствовать).
- `lib/services/movie_api_service.dart` — `MovieApiService`:
  - `getPopularMovies({page})` — `GET /movie/popular`;
  - `searchMovies(query)` — `GET /search/movie`, запрос кодируется через `Uri.encodeComponent`; пустой запрос сразу возвращает `[]`;
  - при ответе не 200 бросается `Exception('Ошибка загрузки: <код>')` / `Exception('Ошибка поиска: <код>')`.
  - сетевая ошибка (`http.ClientException`) заменяется на `Exception('Нет соединения с сервером')`: текст `ClientException` содержит полный URL вместе с `api_key`, а сообщение об ошибке показывается на экране.
- `HomeScreen`: состояние загрузки (`_isLoading`, `CircularProgressIndicator`) и ошибки (`_error`: иконка, текст и кнопка «Повторить»).
- `SearchScreen`: debounce через `Timer` — запрос уходит после 500 мс без ввода; таймер отменяется в `dispose`.
- `android/app/src/main/AndroidManifest.xml`: разрешение `INTERNET`. В debug-сборке оно уже было, но release без него не выйдет в сеть.
- Ключ TMDB читается через `String.fromEnvironment('TMDB_API_KEY')` и передаётся при запуске: `flutter run --dart-define=TMDB_API_KEY=ваш_ключ`. В коде и в git ключа нет.
- `README.md`: как запустить приложение с ключом TMDB.

### Изменено
- `HomeScreen`: фильмы загружаются в `initState` через `getPopularMovies()`; импорт `mock_movies.dart` удалён. Перемешивание, удаление, добавление фильма, переходы и личные оценки работают с загруженным списком как раньше. Лента «Популярное» показывает первые 5 фильмов (`_movies.take(5)`).
- `SearchScreen`: поиск через `searchMovies` вместо `searchByTitle` по мокам; импорты `mock_movies.dart` и `movie_utils.dart` удалены. До ввода запроса экран пуст.

### Отличия от кода в задании
- **Проверка ключа.** Если ключ не задан, сервис сразу бросает исключение «Не задан ключ TMDB…» и не отправляет запрос. В задании это подсказка, а не обязательная часть.
- **Защита от устаревших ответов в поиске.** Если пока шёл запрос, текст в поле изменился, ответ отбрасывается — иначе медленный старый ответ мог бы затереть результаты нового запроса.
- **Состояния поиска.** При пустом поле — подсказка «Введите название фильма», пока идёт задержка и запрос — индикатор загрузки, при пустом ответе — «Ничего не найдено».

### Проверка
- `flutter analyze` — без замечаний.
- Временный тест (удалён после проверки) с подменой сети через `http.runWithClient` и `MockClient`:
  - `fromJson` разбирает `null`-поля и целый `vote_average`;
  - на главном экране сначала индикатор, потом список; запрос — `/3/movie/popular?api_key=…&language=ru-RU&page=1`; в ленте 5 фильмов; удаление, добавление и переход на детали работают;
  - ответ 401 и сетевая ошибка показывают текст ошибки и «Повторить», повторная попытка загружает список; при сетевой ошибке на экране «Нет соединения с сервером» без URL и ключа;
  - без ключа выводится «Не задан ключ TMDB…», запрос не отправляется;
  - при быстром наборе уходит один запрос через 500 мс, кириллица и пробелы кодируются; устаревший ответ не затирает новый; ошибка 500 показывает `SnackBar`; очистка поля возвращает подсказку.
- С настоящим ключом TMDB приложение не запускалось — ключа у меня нет.

## Лекция 10 — Навигация и передача данных (`lesson_10`)

Появились нижняя панель с тремя вкладками, именованные маршруты и возврат личной оценки с экрана деталей.

### Добавлено
- `lib/screens/main_screen.dart` — `MainScreen`, корневой экран: `BottomNavigationBar` с вкладками «Главная», «Поиск», «Избранное». Вкладки лежат в `IndexedStack`, поэтому `HomeScreen` не теряет состояние при переключении. У каждой вкладки свой `ScaffoldMessenger` — `SnackBar` не перекрывает кнопку «+».
- `lib/screens/favorites_screen.dart` — `FavoritesScreen`, заглушка «Избранное пусто» (настоящее избранное — Лекция 12).
- `lib/widgets/rating_dialog.dart` — `RatingDialog`: `AlertDialog` с полем ввода. «Отмена» возвращает `null`, «Сохранить» — `double` от 1 до 10. При неверном вводе диалог не закрывается, под полем показывается ошибка.
- `MovieDetailScreen`: кнопка «Оценить» — открывает `RatingDialog` и возвращает оценку на предыдущий экран через `Navigator.pop(context, rating)`.
- `HomeScreen`: личные оценки в `Map<int, double> _userRatings` (id фильма → оценка) и `SnackBar` «Ваша оценка …» после возврата оценки. Оценки пока хранятся только в памяти.

### Изменено
- `lib/main.dart`: вместо `home` — `initialRoute: '/'` и таблица `routes`: `'/'` → `MainScreen`, `'/movie-detail'` → `MovieDetailScreen`, `'/add-movie'` → `AddMovieScreen`. `MaterialApp` больше не `const`.
- `MovieDetailScreen`: фильм берётся из `ModalRoute.of(context)!.settings.arguments`, а не из конструктора.
- `HomeScreen`: переходы на детали (из списка и из ленты) и на добавление фильма — через `Navigator.pushNamed`. Тип результата задаётся приведением (`as Movie?`, `as double?`), а не параметром `pushNamed<Movie>`: таблица `routes` создаёт `MaterialPageRoute<dynamic>`, и `pushNamed<Movie>` упал бы с `TypeError`. Кнопка поиска из `AppBar` убрана — поиск стал вкладкой.
- `SearchScreen`: тап по результату — `pushNamed('/movie-detail', arguments: movie)`. Убран `autofocus` из Лекции 9: вкладка строится сразу при запуске и забирала бы фокус с клавиатурой.

### Отличия от кода в задании
- В `RatingDialog` клавиатура `numberWithOptions(decimal: true)`, а не `number`: на iOS у обычной цифровой клавиатуры нет разделителя, и дробную оценку («7.5») нельзя было бы ввести. Принимаются и точка, и запятая.

### Известное ограничение
- Если открыть детали из поиска и поставить оценку, она не сохраняется: оценки хранятся в состоянии `HomeScreen`, а поиск — отдельная вкладка. Исправлено в Лекции 12 (`RatingsProvider`).

### Проверка
- `flutter analyze` — без замечаний.
- Временный виджет-тест (удалён после проверки):
  - три вкладки; кнопки поиска на главной нет; при запуске фокус не уходит в поле поиска;
  - удалённый фильм не возвращается после переключения на «Поиск», «Избранное» и обратно;
  - `+` открывает маршрут `/add-movie`, добавленный фильм появляется в списке;
  - детали открываются по маршруту `/movie-detail` с главной и из поиска;
  - в `RatingDialog` «Отмена» оставляет на экране деталей; пустой ввод, «abc», «0» и «11» отклоняются; «9,5» возвращает 9.5 и показывает `SnackBar`;
  - на снимке экрана кнопка «+» поднимается над `SnackBar`.

## Лекция 9 — Взаимодействие с пользователем (`lesson_9`)

Добавлены поиск, форма добавления фильма, подтверждение удаления и двойной тап «в избранное».

### Добавлено
- `lib/screens/search_screen.dart` — `SearchScreen`: `TextField` в `AppBar`, при каждом изменении текста фильтрует `mockMovies` через `searchByTitle` из Лекции 3. При пустом запросе показаны все фильмы.
- `lib/screens/add_movie_screen.dart` — `AddMovieScreen`: `Form` с `GlobalKey<FormState>` и четырьмя `TextFormField`, у каждого свой `TextEditingController` (освобождается в `dispose`):
  - название — обязательно, минимум 2 символа (пробелы по краям не считаются);
  - год — обязательно, ровно 4 цифры;
  - описание — необязательно, пустое превращается в `null`;
  - рейтинг — необязательно; если заполнен, то число от 0 до 10, принимаются и «8.5», и «8,5».
  
  По кнопке «Добавить фильм» экран возвращает новый `Movie` через `Navigator.pop`. `id` — `DateTime.now().millisecondsSinceEpoch`.
- `HomeScreen`:
  - кнопка поиска в `AppBar`;
  - `FloatingActionButton` открывает `AddMovieScreen` через `Navigator.push<Movie>`, вставляет фильм в начало списка и показывает `SnackBar` «… добавлен!». Перед обращением к `context` после `await` проверяется `mounted`;
  - `confirmDismiss` у `Dismissible`: `AlertDialog` «Удалить фильм?» с кнопками «Отмена» и «Удалить»;
  - `onDoubleTap` у `GestureDetector`: `SnackBar` «… добавлен в избранное». Само избранное пока не хранится — это Лекция 12.

### Изменено
- `HomeScreen`: у вертикального списка отступ снизу увеличен до 88, чтобы `FloatingActionButton` не закрывал последнюю карточку.

### Сверх задания
- В `SearchScreen` тап по результату открывает `MovieDetailScreen`, поле поиска получает фокус сразу (`autofocus`). Если ничего не найдено, выводится «Ничего не найдено».
- В форме заданы подходящие клавиатуры (цифровая для года и рейтинга) и `maxLength: 4` для года.

### Проверка
- `flutter analyze` — без замечаний.
- Временный виджет-тест (удалён после проверки):
  - поиск фильтрует по мере ввода, без учёта регистра;
  - пустая и неверная форма показывает ошибки; рейтинг «11» и «abc» отклоняется, «8,1» принимается;
  - добавленный фильм появляется первым в списке, показывается `SnackBar`; фильм без описания и рейтинга открывается на экране деталей без ошибок;
  - если выйти из формы кнопкой «Назад», ничего не добавляется;
  - «Отмена» в диалоге оставляет фильм, «Удалить» удаляет;
  - двойной тап показывает `SnackBar` и не открывает детали, одиночный тап открывает.

## Лекция 8 — Основы компоновки UI (`lesson_8`)

Главный экран разделён на две секции, по тапу на фильм открывается экран деталей.

### Добавлено
- `lib/screens/movie_detail_screen.dart` — `MovieDetailScreen`, получает `Movie` через конструктор:
  - сверху `Stack`: постер высотой 300 на всю ширину, градиент `transparent → black87`, поверх — белое название и рейтинг «⭐ 8.8» (или «⭐ —»);
  - ниже, с отступами 16: год и жанры, описание (`movie.overview ?? 'Описание отсутствует'`), `Row` из трёх характеристик — длительность, страна, язык;
  - прозрачный `AppBar` поверх постера (`extendBodyBehindAppBar`) — видна только кнопка «Назад».
- `lib/widgets/movie_preview_card.dart` — `MoviePreviewCard`: компактная карточка (постер, название, рейтинг) для горизонтальной ленты.
- `lib/widgets/movie_poster.dart` — `MoviePoster`: постер с заглушкой. Его используют `MovieCard`, `MoviePreviewCard` и экран деталей.
- `lib/data/genres.dart` — `tmdbGenres`: названия жанров по id TMDB (для жанров из `genreIds`).

### Изменено
- `HomeScreen`: `Column` из двух секций — «Популярное» (горизонтальный `ListView` высотой 200) и «Все фильмы» (вертикальный `ListView.builder` внутри `Expanded`). Перемешивание, удаление свайпом, `ValueKey` и `findChildIndexCallback` из Лекции 7 сохранены.
- `HomeScreen`: тап по карточке в любой из секций открывает `MovieDetailScreen` через `Navigator.push`. В вертикальном списке порядок вложенности: `Dismissible` → `GestureDetector` → `MovieCard`.
- `MovieCard`: логика постера вынесена в `MoviePoster`; горизонтальный отступ карточки увеличен с 12 до 16, как у заголовков секций.

### Решения, не описанные в задании
- Жанр не захардкожен одной строкой: названия берутся из `tmdbGenres` по `movie.genreIds` — так у каждого фильма свои жанры.
- Длительности, страны и языка в модели `Movie` нет, поэтому в `Row` характеристик стоят прочерки «—».
- Если у фильма нет постера, экран деталей сразу показывает тёмно-серую заглушку из задания, без запроса по пустому URL.

### Проверка
- `flutter analyze` — без замечаний.
- Временный виджет-тест (удалён после проверки): тап по карточке в вертикальном списке и по превью в ленте открывает нужный фильм, «Назад» возвращает на главный экран; на экране 320×568 переполнения нет; на снимках экрана у Parasite — «⭐ —» и «Описание отсутствует», у Inception — жанры «Боевик, Фантастика, Приключения».

## Лекция 7 — Введение в ключи (`lesson_7`)

Список фильмов на главном экране стал интерактивным: его можно перемешивать, а фильмы — удалять свайпом.

### Добавлено
- `HomeScreen`: кнопка `IconButton(Icons.shuffle)` в `AppBar` — перемешивает `_movies` через `setState`.
- `HomeScreen`: каждый элемент списка обёрнут в `Dismissible` с `ValueKey(movie.id)`. Свайп влево (`endToStart`) на красном фоне с иконкой корзины удаляет фильм из `_movies`.
- `notes.md`: раздел «Задание 7» — результаты эксперимента с ключами.

### Изменено
- `HomeScreen`: в `ListView.builder` добавлен `findChildIndexCallback`, который по ключу находит новый индекс фильма. Без него при перемешивании состояние элемента не переносится вслед за ключом — элемент пересоздаётся (подробности в `notes.md`).

### Проверка
- `flutter analyze` — без замечаний.
- Временный виджет-тест (удалён после проверки): кнопка меняет порядок карточек; свайп влево удаляет карточку (осталось 4), свайп вправо — нет. Эксперимент с временной `StatefulWidget`-карточкой: без ключа отметки остаются на позициях, с `ValueKey` без колбэка — сбрасываются, с колбэком — переходят вместе с фильмами.

## Лекция 6 — Введение в виджеты (`lesson_6`)

Вместо заглушки с текстом появился первый настоящий экран — список фильмов из `mockMovies` (Лекция 3) в виде карточек.

### Добавлено
- `lib/widgets/movie_card.dart` — `MovieCard` (`StatelessWidget`): принимает `Movie`, показывает постер 80×120, название (жирным), год (серым) и рейтинг «⭐ 8.8» или «⭐ —», если рейтинга нет.
- `lib/screens/home_screen.dart` — `HomeScreen` (`StatefulWidget`): `AppBar` с названием «CineTrack» и `ListView.builder` с карточками. Фильмы хранятся в изменяемой копии `[...mockMovies]` — она понадобится в следующем задании.
- `assets/images/placeholder.png` — заглушка постера в виде киноплёнки.

### Изменено
- `lib/main.dart`: временный консольный вывод из Лекции 3 удалён (вместе с `ignore_for_file: avoid_print`). Стартовый экран — `HomeScreen`. Используются стандартные шрифты Flutter.
- `pubspec.yaml`: зарегистрирована папка `assets/images/`.

### Отличие от примера в задании
- Если у фильма нет `posterPath`, `MovieCard` сразу показывает заглушку. Иначе `Image.network('')` отправил бы запрос на пустой адрес и вывел ошибку в лог. `errorBuilder` с той же заглушкой оставлен на случай, когда постер есть, но не загрузился.

### Проверка
- `flutter analyze` — без замечаний.
- Временный виджет-тест (удалён после проверки): все 5 карточек на месте, у Parasite показано «⭐ —»; на снимке экрана у каждой карточки заглушка постера.

## Лекция 5 — Dart: асинхронное программирование (`lesson_5`)

Задание выполняется на чистом Dart, само приложение не изменилось.

### Добавлено
- `dart_exercises/lesson_5.dart` — решения пяти упражнений задания:
  1. `fetchMovieTitle(int id)` — задержка 2 секунды через `Future.delayed`, название берётся из `Map<int, String>` (если id нет, возвращается `'Фильм #id'`). Строка «Загружаю фильм...» выводится до паузы.
  2. `fetchMovie(title, delaySeconds)` и `fetchMovies()` — `Future.wait` запускает три загрузки (1, 2 и 3 секунды) параллельно; время измеряется через `Stopwatch`.
  3. `loadMovie()` с вероятностью 50% бросает `Exception('Сервер недоступен')`. `loadMovieWithFallback()` перехватывает ошибку в `try/catch` и не пробрасывает её дальше. Вызывается 5 раз.
  4. Обратный отсчёт 5 → 0 через `StreamController<int>` (не broadcast): значения отправляются в `sink.add` с интервалом в 1 секунду, после 0 вызывается `close()`. Чтение — через `await for`.
  5. `generateRatings(movies)` — генератор на `async*`/`yield`: раз в секунду выдаёт фильм со случайной оценкой от 6.0 до 9.9.

### Проверка
- `dart run dart_exercises/lesson_5.dart` — вывод совпадает с ожидаемым в задании. `Future.wait` занимает 3,0 с, а не 6, — загрузки идут параллельно.
- `flutter analyze` — без замечаний.

## Лекция 4 — Dart: ООП (`lesson_4`)

Задание выполняется на чистом Dart, само приложение не изменилось.

### Добавлено
- `dart_exercises/lesson_4.dart` — решения пяти упражнений задания:
  1. Абстрактный `Shape` с абстрактным `area()` и конкретным `describe()`; наследники `Circle` и `Rectangle`.
  2. Mixin `Printable` с методом `printInfo()`: выводит `runtimeType` и поля из геттера `printableFields`. Класс задаёт этот геттер сам. Подключён к учебному `Movie(title, year, rating)` через `with`.
  3. `Repository<T>`: приватный `_items`, `add`, `findById` (`null` при индексе вне диапазона, в том числе отрицательном), `getAll` (возвращает копию). Проверено на `Movie` и `String`.
  4. `extension MovieListExtension on List<Movie>` с методом `sortedByRating()`: возвращает новый список, исходный не меняется.
  5. `enum MovieGenre` (`action`, `comedy`, `drama`, `sciFi`) с полем `label`, `const`-конструктором и геттером `description`. В `Movie` добавлено поле `genre` (именованный параметр, по умолчанию `MovieGenre.action`), поэтому вызов `Movie('Mad Max', 2015, 8.1)` из задания компилируется.

Учебный `Movie` из этого файла не связан с моделью `lib/models/movie.dart` из Лекции 3.

### Проверка
- `dart run dart_exercises/lesson_4.dart` — вывод совпадает с ожидаемым в задании.
- `flutter analyze` — без замечаний.

## Лекция 3 — Dart: Null Safety (`lesson_3`)

Фильмы теперь описываются типизированной моделью `Movie` вместо `Map<String, double>` из Лекции 2. Экранов пока нет, модель проверяется через консоль.

### Добавлено
- `lib/models/movie.dart` — класс `Movie`:
  - обязательные поля: `id`, `title`, `releaseDate`, `genreIds` (по умолчанию `const []`);
  - nullable-поля: `overview`, `posterPath`, `backdropPath`, `voteAverage`;
  - геттеры `year`, `rating` (`?.` + `??` → «—»), `posterUrl` (URL постера TMDB или пустая строка).
- `lib/data/mock_movies.dart` — `mockMovies`: 5 фильмов; у `Parasite` намеренно нет `overview` и `voteAverage`.
- `lib/utils/movie_utils.dart` — `filterByRating`, `sortByRating` (по убыванию, не меняет исходный список), `searchByTitle` (без учёта регистра).

### Изменено
- `lib/main.dart`: перед `runApp` временно выводит в консоль моковые фильмы и результаты фильтрации, сортировки и поиска. Для nullable-полей используются `?.` и `??`, оператор `!` не используется. На время этого вывода в файле отключён линт `avoid_print`.

### Проверка
- Консольный вывод: для `Parasite` печатаются «—» и «Описание отсутствует»; `filterByRating(8.5)` → Inception, Interstellar, The Dark Knight; `sortByRating` → The Dark Knight, Inception, Interstellar, Dune, Parasite; `searchByTitle('in')` → Inception, Interstellar.
- `flutter analyze` — без замечаний.

## Лекция 2 — Dart: синтаксис и основы (`lesson_2`)

Задание выполняется на чистом Dart, само приложение не изменилось.

### Добавлено
- `dart_exercises/lesson_2.dart` — решения пяти упражнений задания:
  1. `greet(String name, {int age = 0})` — приветствие с именованным параметром и тернарным оператором.
  2. `fizzbuzz(int n)` — проверка на `FizzBuzz` стоит первой в цепочке `if/else if`.
  3. `filterLongTitles()` — фильтрация названий длиннее 8 символов через `.where().toList()`.
  4. `printTopRated()` — `Map<String, double>`, вывод фильмов с рейтингом > 8.0 через перебор `entries`.
  5. `int? findMax(List<int>)` — поиск максимума циклом, `null` для пустого списка, вывод через `??`.

### Проверка
- `dart run dart_exercises/lesson_2.dart` — вывод совпадает с примерами из задания.
- `flutter analyze` — без замечаний.

## Лекция 1 — Введение, настройка среды (`lesson_1`)

Стартовая точка проекта: предыдущей версии нет.

### Добавлено
- Flutter-проект `cine_track`, созданный командой `flutter create cine_track` (платформы: Android, iOS, Web).
- `notes.md` — письменные ответы на вопросы о структуре проекта (`lib/`, `pubspec.yaml`, `android/` и `ios/`, `build/`).
- `CHANGELOG.md` — этот файл.

### Изменено
- `pubspec.yaml`: описание — «Персональный трекер фильмов», версия — `1.0.0+1`.
- `lib/main.dart`: стартовый код заменён на минимальный `MyApp` — `MaterialApp` с заголовком `CineTrack` и текстом «CineTrack — скоро здесь будут фильмы» по центру экрана.
- `lib/main.dart`: `debugShowCheckedModeBanner: false` — красная лента «DEBUG» в углу экрана скрыта.
- `README.md`: описание проекта.
- `.gitignore`: `.vscode/launch.json` и `.vscode/settings.json` — личные настройки VS Code (в `launch.json` позже будет лежать ключ TMDB, см. Лекцию 11).

### Проверка
- `flutter analyze` — без замечаний.
