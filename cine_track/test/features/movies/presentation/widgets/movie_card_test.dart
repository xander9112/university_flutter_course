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
}
