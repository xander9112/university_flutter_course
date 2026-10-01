// Задание 2 — Dart: первые программы.
// Чистый Dart, Flutter не нужен. Запуск: dart run dart_exercises/lesson_2.dart
// (или вставить содержимое в DartPad).

// ignore_for_file: avoid_print

void main() {
  print('--- Задание 1: Функция приветствия ---');
  print(greet('Анна'));
  print(greet('Борис', age: 21));
  print(greet('Виктор', age: 35));

  print('\n--- Задание 2: FizzBuzz ---');
  fizzbuzz(20);

  print('\n--- Задание 3: Фильтрация списка ---');
  filterLongTitles();

  print('\n--- Задание 4: Рейтинги фильмов ---');
  printTopRated();

  print('\n--- Задание 5: Максимальный элемент ---');
  final lists = [
    [3, 7, 1, 9, 4],
    [-5, -2, -8],
    <int>[],
  ];
  for (final numbers in lists) {
    print('Максимум $numbers: ${findMax(numbers) ?? 'список пустой'}');
  }
}

// Задание 1
String greet(String name, {int age = 0}) {
  return age == 0 ? 'Привет, $name!' : 'Привет, $name! Тебе $age лет.';
}

// Задание 2
void fizzbuzz(int n) {
  for (int i = 1; i <= n; i++) {
    if (i % 3 == 0 && i % 5 == 0) {
      print('FizzBuzz');
    } else if (i % 3 == 0) {
      print('Fizz');
    } else if (i % 5 == 0) {
      print('Buzz');
    } else {
      print(i);
    }
  }
}

// Задание 3
void filterLongTitles() {
  List<String> movies = [
    'Дюна',
    'Интерстеллар',
    'Оно',
    'Начало',
    'Властелин колец',
  ];
  List<String> longTitles = movies.where((title) => title.length > 8).toList();

  print('Все фильмы: $movies');
  print('Длинные названия: $longTitles');
}

// Задание 4
void printTopRated() {
  Map<String, double> ratings = {
    'Побег из Шоушенка': 9.3,
    'Зелёная миля': 8.6,
    'Интерстеллар': 8.7,
    'Дюна': 8.0,
    'Оно': 7.3,
  };

  print('Фильмы с рейтингом выше 8.0:');
  for (var entry in ratings.entries) {
    if (entry.value > 8.0) {
      print('${entry.key}: ${entry.value}');
    }
  }
}

// Задание 5
int? findMax(List<int> numbers) {
  if (numbers.isEmpty) {
    return null;
  }
  int max = numbers[0];
  for (int number in numbers) {
    if (number > max) {
      max = number;
    }
  }
  return max;
}
