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

Начиная с Лекции 16, часть кода генерируется (`lib/core/di/injection.config.dart` и др.). Сгенерированные файлы лежат в репозитории, поэтому проект собирается сразу. После изменения аннотаций (`@injectable`, `@lazySingleton` и т. д.) перегенерируйте их:

```bash
dart run build_runner build --delete-conflicting-outputs
```
