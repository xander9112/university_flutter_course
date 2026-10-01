# CHANGELOG — CineTrack

Каждая лекция курса — отдельная ветка `lesson_N`. Здесь описано, что изменилось в приложении по сравнению с предыдущей лекцией.

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
