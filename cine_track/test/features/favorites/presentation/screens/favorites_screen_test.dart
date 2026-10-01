import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_card.dart';

class MockFavoritesProvider extends Mock implements FavoritesProvider {}

void main() {
  testWidgets('FavoritesScreen показывает сообщение при пустом списке', (
    tester,
  ) async {
    final mockProvider = MockFavoritesProvider();
    when(() => mockProvider.favorites).thenReturn([]);

    await tester.pumpWidget(
      ChangeNotifierProvider<FavoritesProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );

    expect(find.text('Нет избранных фильмов'), findsOneWidget);
  });

  // Сверх задания: непустой список
  testWidgets('FavoritesScreen показывает карточки и открывает детали', (
    tester,
  ) async {
    const movie = Movie(id: 1, title: 'Inception');
    final mockProvider = MockFavoritesProvider();
    when(() => mockProvider.favorites).thenReturn([movie]);
    when(() => mockProvider.isFavorite(1)).thenReturn(true);

    await tester.pumpWidget(
      ChangeNotifierProvider<FavoritesProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: const FavoritesScreen(),
          routes: {
            '/movie-detail': (context) => const Scaffold(body: Text('Детали')),
          },
        ),
      ),
    );

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();
    expect(find.text('Детали'), findsOneWidget);
  });
}
