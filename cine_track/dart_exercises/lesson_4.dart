// Задание 4 — Dart: ООП на практике.
// Чистый Dart, Flutter не нужен. Запуск: dart run dart_exercises/lesson_4.dart
// (или вставить содержимое в DartPad).
//
// Класс Movie здесь учебный и не связан с моделью lib/models/movie.dart.

// ignore_for_file: avoid_print

void main() {
  print('--- Задание 1: Абстрактный класс Shape ---');
  List<Shape> shapes = [Circle(5), Rectangle(4, 6)];
  for (var shape in shapes) {
    shape.describe();
  }
  // Shape(); // Ошибка компиляции: абстрактный класс нельзя создать напрямую.

  print('\n--- Задание 2: Mixin Printable ---');
  var movie = Movie('Inception', 2010, 8.8);
  movie.printInfo();

  print('\n--- Задание 3: Generic Repository<T> ---');
  var repo = Repository<Movie>();
  repo.add(Movie('Inception', 2010, 8.8));
  repo.add(Movie('The Matrix', 1999, 8.7));
  repo.add(Movie('Interstellar', 2014, 8.6));

  print(repo.findById(1)?.title); // The Matrix
  print(repo.findById(99)); // null
  print(repo.getAll().length); // 3

  var titles = Repository<String>();
  titles.add('Дюна');
  titles.add('Оно');
  print(titles.findById(0)); // Дюна
  print(titles.findById(-1)); // null

  print('\n--- Задание 4: Extension на List<Movie> ---');
  var movies = [
    Movie('Inception', 2010, 8.8),
    Movie('Dune', 2021, 7.9),
    Movie('The Matrix', 1999, 8.7),
  ];

  var sorted = movies.sortedByRating();
  for (var m in sorted) {
    print('${m.title} — ${m.rating}');
  }
  print('Исходный список: ${movies.map((m) => m.title).toList()}');

  print('\n--- Задание 5: Enum MovieGenre ---');
  for (var genre in MovieGenre.values) {
    print('${genre.name}: ${genre.label} → ${genre.description}');
  }

  var madMax = Movie('Mad Max', 2015, 8.1);
  print('${madMax.title}: ${madMax.genre.label}');
  var dune = Movie('Dune', 2021, 7.9, genre: MovieGenre.sciFi);
  print('${dune.title}: ${dune.genre.label}');
}

// Задание 1

abstract class Shape {
  double area();

  void describe() {
    print('$runtimeType: площадь = ${area().toStringAsFixed(2)}');
  }
}

class Circle extends Shape {
  final double radius;

  Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;
}

class Rectangle extends Shape {
  final double width;
  final double height;

  Rectangle(this.width, this.height);

  @override
  double area() => width * height;
}

// Задание 2

mixin Printable {
  /// Поля объекта для вывода: имя поля → значение.
  Map<String, Object?> get printableFields;

  void printInfo() {
    print('--- $runtimeType ---');
    printableFields.forEach((name, value) => print('$name: $value'));
  }
}

class Movie with Printable {
  final String title;
  final int year;
  final double rating;
  final MovieGenre genre; // Задание 5

  Movie(this.title, this.year, this.rating, {this.genre = MovieGenre.action});

  @override
  Map<String, Object?> get printableFields => {
    'title': title,
    'year': year,
    'rating': rating,
  };
}

// Задание 3

class Repository<T> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
  }

  T? findById(int index) {
    if (index < 0 || index >= _items.length) {
      return null;
    }
    return _items[index];
  }

  List<T> getAll() => List.of(_items);
}

// Задание 4

extension MovieListExtension on List<Movie> {
  List<Movie> sortedByRating() {
    return [...this]..sort((a, b) => b.rating.compareTo(a.rating));
  }
}

// Задание 5

enum MovieGenre {
  action('Боевик'),
  comedy('Комедия'),
  drama('Драма'),
  sciFi('Фантастика');

  final String label;

  const MovieGenre(this.label);

  String get description => '«$label»';
}
