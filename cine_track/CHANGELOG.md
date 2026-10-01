# CHANGELOG — CineTrack

Каждая лекция курса — отдельная ветка `lesson_N`. Здесь описано, что изменилось в приложении по сравнению с предыдущей лекцией.

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
