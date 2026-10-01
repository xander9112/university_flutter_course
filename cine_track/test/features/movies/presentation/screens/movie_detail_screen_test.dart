import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/screens/movie_detail_screen.dart';
import 'package:cine_track/features/ratings/presentation/providers/ratings_provider.dart';

import '../../../../mocks/mocks.dart';

void main() {
  const movie = Movie(
    id: 1,
    title: 'Inception',
    overview: 'Сон внутри сна',
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
    genreIds: [28, 878, 99999], // неизвестный жанр пропускается
  );

  late MockSetRating setRating;
  late RatingsProvider ratings;

  setUp(() {
    final getRatings = MockGetRatings();
    setRating = MockSetRating();
    when(() => getRatings()).thenAnswer((_) async => {});
    when(() => setRating(any(), any())).thenAnswer((_) async {});
    ratings = RatingsProvider(getRatings: getRatings, setRating: setRating);
  });

  Future<void> pumpDetail(WidgetTester tester, Movie movie) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ratings,
        // Экран читает фильм из аргументов маршрута, как при pushNamed
        child: MaterialApp(
          onGenerateRoute: (_) => MaterialPageRoute(
            settings: RouteSettings(arguments: movie),
            builder: (_) => const MovieDetailScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('показывает название, год, жанры, описание и рейтинг', (
    tester,
  ) async {
    await pumpDetail(tester, movie);

    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('2010 · Боевик, Фантастика'), findsOneWidget);
    expect(find.text('Сон внутри сна'), findsOneWidget);
    expect(find.text('⭐ 8.8'), findsOneWidget);
    expect(find.text('Вы ещё не оценили этот фильм'), findsOneWidget);
  });

  testWidgets('без жанров и описания — только год и заглушка', (tester) async {
    await pumpDetail(tester, const Movie(id: 2, title: 'X'));
    expect(find.text('N/A'), findsOneWidget);
    expect(find.text('Описание отсутствует'), findsOneWidget);
  });

  testWidgets('оценка: неверный ввод → ошибка, верный → сохраняется', (
    tester,
  ) async {
    await pumpDetail(tester, movie);

    await tester.tap(find.text('Оценить'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '11');
    await tester.tap(find.text('Сохранить'));
    await tester.pump();
    expect(find.text('Введите число от 1 до 10'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '8,5');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    verify(() => setRating(1, 8.5)).called(1);
    expect(find.text('Ваша оценка: 8.5'), findsOneWidget);
    expect(find.text('Изменить оценку'), findsOneWidget);
    expect(find.text('Ваша оценка «Inception»: 8.5'), findsOneWidget);
  });

  testWidgets('отмена диалога ничего не сохраняет', (tester) async {
    await pumpDetail(tester, movie);

    await tester.tap(find.text('Оценить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    verifyNever(() => setRating(any(), any()));
    expect(find.text('Вы ещё не оценили этот фильм'), findsOneWidget);
  });

  // Задание 20: макет зависит от ориентации
  Future<Rect> posterRect(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpDetail(tester, movie);
    return tester.getRect(find.byType(Hero));
  }

  testWidgets('портрет: постер сверху на всю ширину', (tester) async {
    final rect = await posterRect(tester, const Size(400, 800));
    expect(rect, const Rect.fromLTWH(0, 0, 400, 300));
    expect(
      find.ancestor(of: find.text('Оценить'), matching: find.byType(SafeArea)),
      findsOneWidget,
    );
  });

  testWidgets('ландшафт: постер слева на 40% ширины и всю высоту', (
    tester,
  ) async {
    final rect = await posterRect(tester, const Size(1000, 500));
    expect(rect, const Rect.fromLTWH(0, 0, 400, 500));
    // название — справа от постера, а не поверх него
    expect(tester.getTopLeft(find.text('Inception')).dx, greaterThan(400));
    expect(find.text('Оценить'), findsOneWidget);
  });
}
