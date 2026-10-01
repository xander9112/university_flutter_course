import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_card.dart';

class MockFavoritesProvider extends Mock implements FavoritesProvider {}

void main() {
  const tMovie = Movie(
    id: 1,
    title: 'Inception',
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
  );

  late MockFavoritesProvider mockFavorites;

  setUp(() {
    mockFavorites = MockFavoritesProvider();
    when(() => mockFavorites.isFavorite(any())).thenReturn(false);
  });

  Future<void> pumpCard(WidgetTester tester) {
    return tester.pumpWidget(
      ChangeNotifierProvider<FavoritesProvider>.value(
        value: mockFavorites,
        child: const MaterialApp(
          home: Scaffold(body: MovieCard(movie: tMovie)),
        ),
      ),
    );
  }

  testWidgets('MovieCard отображает название фильма', (tester) async {
    await pumpCard(tester);
    expect(find.text('Inception'), findsOneWidget);
  });

  testWidgets('MovieCard отображает год выпуска', (tester) async {
    await pumpCard(tester);
    expect(find.textContaining('2010'), findsOneWidget);
  });

  testWidgets('MovieCard отображает рейтинг', (tester) async {
    await pumpCard(tester);
    expect(find.textContaining('8.8'), findsOneWidget);
  });

  testWidgets('Нажатие на сердце вызывает toggleFavorite', (tester) async {
    when(() => mockFavorites.toggleFavorite(tMovie)).thenAnswer((_) async {});
    await pumpCard(tester);

    await tester.tap(find.byIcon(Icons.favorite_border));

    verify(() => mockFavorites.toggleFavorite(tMovie)).called(1);
  });

  // Сверх задания (Задание 19): появление карточки
  testWidgets('MovieCard плавно появляется: opacity 0 → 1 за 500 мс', (
    tester,
  ) async {
    await pumpCard(tester);
    double opacity() =>
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

    // Первый кадр: карточка прозрачна, setState из addPostFrameCallback
    // применится в следующем кадре.
    expect(opacity(), 0.0);
    await tester.pump();
    expect(opacity(), 1.0); // цель анимации — 1
    final fade = find.descendant(
      of: find.byType(AnimatedOpacity),
      matching: find.byType(FadeTransition),
    );
    expect(tester.widget<FadeTransition>(fade).opacity.value, 0.0);

    await tester.pump(const Duration(milliseconds: 250));
    final mid = tester.widget<FadeTransition>(fade).opacity.value;
    expect(mid, greaterThan(0.0));
    expect(mid, lessThan(1.0));

    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(fade).opacity.value, 1.0);
  });
}
