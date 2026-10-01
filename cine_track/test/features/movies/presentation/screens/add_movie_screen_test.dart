import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/screens/add_movie_screen.dart';

void main() {
  Movie? result;

  // Форма открывается поверх другого экрана и возвращает фильм через pop
  Future<void> pumpForm(WidgetTester tester) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.push<Movie>(
                context,
                MaterialPageRoute(builder: (_) => const AddMovieScreen()),
              );
            },
            child: const Text('Открыть форму'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть форму'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('пустая форма показывает ошибки обязательных полей', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.tap(find.text('Добавить фильм'));
    await tester.pump();

    expect(find.text('Введите название (минимум 2 символа)'), findsOneWidget);
    expect(find.text('Введите год из 4 цифр'), findsOneWidget);
    expect(find.byType(AddMovieScreen), findsOneWidget);
  });

  testWidgets('рейтинг вне диапазона — ошибка', (tester) async {
    await pumpForm(tester);

    await tester.enterText(field('Название *'), 'Матрица');
    await tester.enterText(field('Год выпуска *'), '1999');
    await tester.enterText(field('Рейтинг'), '12');
    await tester.tap(find.text('Добавить фильм'));
    await tester.pump();

    expect(find.text('Рейтинг — число от 0 до 10'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('верная форма возвращает фильм', (tester) async {
    await pumpForm(tester);

    await tester.enterText(field('Название *'), '  Матрица ');
    await tester.enterText(field('Год выпуска *'), '1999');
    await tester.enterText(field('Рейтинг'), '8,7');
    await tester.tap(find.text('Добавить фильм'));
    await tester.pumpAndSettle();

    expect(find.byType(AddMovieScreen), findsNothing);
    expect(result!.title, 'Матрица');
    expect(result!.year, '1999');
    expect(result!.voteAverage, 8.7);
    expect(result!.overview, isNull); // пустое описание не сохраняется
  });
}
