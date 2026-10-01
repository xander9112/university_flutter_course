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
