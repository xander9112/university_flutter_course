# CineTrack

Персональный трекер фильмов — учебное приложение курса по Flutter.

История изменений по лекциям — в [CHANGELOG.md](CHANGELOG.md).

## Запуск

Начиная с Лекции 11, фильмы загружаются из [TMDB API](https://www.themoviedb.org). Ключ API не хранится в коде, его нужно передать при запуске:

```bash
flutter run --dart-define=TMDB_API_KEY=ваш_ключ
```

Без ключа главный экран покажет ошибку «Не задан ключ TMDB».

В VS Code ключ можно указать в `.vscode/launch.json`, в `"args": ["--dart-define=TMDB_API_KEY=ваш_ключ"]`. Этот файл указан в `.gitignore`, поэтому ключ не попадёт в git.

## Кодогенерация

Начиная с Лекции 16, часть кода генерируется: DI-конфигурация `lib/core/di/injection.config.dart` (Injectable), а с Лекции 17 — модели и события (`*.freezed.dart`, `*.g.dart`, Freezed и json_serializable) и API-клиент TMDB (`movie_api_client.g.dart`, Retrofit). Сгенерированные файлы лежат в репозитории, поэтому проект собирается сразу. Не редактируйте их вручную: после изменения аннотаций (`@injectable`, `@freezed`, `@GET` и т. д.) перегенерируйте их:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Тесты

Начиная с Лекции 18:

```bash
flutter test               # unit- и widget-тесты (test/)
flutter test --coverage    # то же с отчётом coverage/lcov.info

# интеграционный тест (integration_test/) — на эмуляторе или устройстве,
# с настоящим TMDB, поэтому нужен ключ; рассчитан на чистую установку
flutter test integration_test/app_test.dart --dart-define=TMDB_API_KEY=ваш_ключ
```

## Релизная сборка

Начиная с Лекции 21. Иконки и сплэш-экран генерируются из настроек в `pubspec.yaml` (исходники — `assets/icon/`, `assets/images/splash_logo*.png`):

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Подпись Android берётся из `android/key.properties` — он и файл `*.jks` в git не попадают:

```properties
storePassword=...
keyPassword=...
keyAlias=cinetrack-key
storeFile=/полный/путь/к/cinetrack-release.jks
```

Без `key.properties` релиз подписывается debug-ключом: его можно запустить, но нельзя загрузить в магазин.

```bash
flutter build appbundle --release --obfuscate \
  --split-debug-info=build/debug-info/android \
  --dart-define=TMDB_API_KEY=ваш_ключ
```

Папку `build/debug-info/` сохраните — без неё не расшифровать стектрейсы обфусцированной сборки (`flutter symbolize`).

### Свой сервер вместо TMDB

Адреса API и картинок задаются при сборке, по умолчанию — TMDB. Для `cine_track_api` из репозитория курса:

```bash
flutter build web --release --no-web-resources-cdn \
  --dart-define=TMDB_API_KEY=ключ_из_админки \
  --dart-define=TMDB_BASE_URL=https://cinetrack-api.example.com/3 \
  --dart-define=TMDB_IMAGE_BASE_URL=https://cinetrack-api.example.com/t/p/w500
```

Публикация веб-версии на сервер — `./deploy.sh web` в корне репозитория курса.

Перед публикацией в Google Play замените `applicationId` `com.example.cine_track` в `android/app/build.gradle.kts` на свой: идентификаторы `com.example.*` магазин не принимает.
