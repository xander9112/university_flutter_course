// Задание 5 — Dart: асинхронное программирование.
// Чистый Dart, Flutter не нужен. Запуск: dart run dart_exercises/lesson_5.dart
// (или вставить содержимое в DartPad).

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

Future<void> main() async {
  print('--- Задание 1: Имитация сетевого запроса ---');
  print('Загружаю фильм...');
  final title = await fetchMovieTitle(1);
  print('Готово: $title');

  print('\n--- Задание 2: Параллельные запросы с Future.wait ---');
  print('Загружаю 3 фильма параллельно...');
  final stopwatch = Stopwatch()..start();
  final movies = await fetchMovies();
  stopwatch.stop();
  movies.forEach(print);
  print(
    'Время: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)} с',
  );

  print('\n--- Задание 3: Обработка ошибок с запасным значением ---');
  for (var i = 0; i < 5; i++) {
    print('Результат: ${await loadMovieWithFallback()}');
  }

  print('\n--- Задание 4: Обратный отсчёт через StreamController ---');
  final controller = StreamController<int>();
  countdown(controller);
  await for (final i in controller.stream) {
    print(i == 0 ? 'Пуск!' : 'До старта: $i');
  }

  print('\n--- Задание 5: Генератор оценок через async* ---');
  final titles = ['Inception', 'Dune', 'The Matrix', 'Interstellar'];
  await for (final line in generateRatings(titles)) {
    print(line);
  }
}

// Задание 1

const Map<int, String> _titles = {1: 'Inception', 2: 'Dune', 3: 'The Matrix'};

Future<String> fetchMovieTitle(int id) async {
  await Future.delayed(const Duration(seconds: 2));
  return _titles[id] ?? 'Фильм #$id';
}

// Задание 2

Future<String> fetchMovie(String title, int delaySeconds) async {
  await Future.delayed(Duration(seconds: delaySeconds));
  return '[данные] $title';
}

Future<List<String>> fetchMovies() {
  return Future.wait([
    fetchMovie('Inception', 1),
    fetchMovie('Dune', 2),
    fetchMovie('The Matrix', 3),
  ]);
}

// Задание 3

Future<String> loadMovie() async {
  if (Random().nextBool()) {
    throw Exception('Сервер недоступен');
  }
  return 'Inception (2010)';
}

Future<String> loadMovieWithFallback() async {
  try {
    return await loadMovie();
  } catch (e) {
    final reason = e.toString().replaceFirst('Exception: ', '');
    return 'Фильм недоступен (произошла ошибка: $reason)';
  }
}

// Задание 4

Future<void> countdown(StreamController<int> controller) async {
  for (var i = 5; i >= 0; i--) {
    controller.sink.add(i);
    if (i > 0) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  await controller.close();
}

// Задание 5

Stream<String> generateRatings(List<String> movies) async* {
  final random = Random();
  for (final movie in movies) {
    await Future.delayed(const Duration(seconds: 1));
    final rating = random.nextDouble() * 4 + 6;
    yield '$movie — оценка: ${rating.toStringAsFixed(1)}';
  }
}
