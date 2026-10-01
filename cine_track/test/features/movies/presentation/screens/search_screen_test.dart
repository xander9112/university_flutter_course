import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:cine_track/core/di/injection.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_bloc.dart';
import 'package:cine_track/features/movies/presentation/screens/search_screen.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_card.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late MockSearchMovies searchMovies;
  late MockFavoritesProvider favorites;

  setUp(() {
    searchMovies = MockSearchMovies();
    favorites = MockFavoritesProvider();
    when(() => favorites.isFavorite(any())).thenReturn(false);
    // SearchScreen берёт свой MoviesBloc из GetIt — регистрируем настоящий
    // блок с моками use cases вместо configureDependencies().
    sl.registerFactory<MoviesBloc>(
      () => MoviesBloc(
        getPopularMovies: MockGetPopularMovies(),
        searchMovies: searchMovies,
      ),
    );
  });

  tearDown(() => sl.reset());

  Future<void> pumpSearch(WidgetTester tester) {
    return tester.pumpWidget(
      ChangeNotifierProvider<FavoritesProvider>.value(
        value: favorites,
        child: MaterialApp(
          home: const SearchScreen(),
          routes: {
            '/movie-detail': (context) => Scaffold(
              body: Text(
                'Детали: ${(ModalRoute.of(context)!.settings.arguments as Movie).title}',
              ),
            ),
          },
        ),
      ),
    );
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 500)); // debounce
    await tester.pump(); // ответ use case
  }

  testWidgets('до ввода показывает подсказку', (tester) async {
    await pumpSearch(tester);
    expect(find.text('Введите название фильма'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Введите название фильма'),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets('запрос уходит один раз — после паузы в 500 мс', (tester) async {
    when(() => searchMovies(any()))
        .thenAnswer((_) async => const [Movie(id: 1, title: 'Matrix')]);
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'Ma');
    await tester.pump(const Duration(milliseconds: 300));
    verifyNever(() => searchMovies(any()));
    await search(tester, 'Matrix');

    verify(() => searchMovies('Matrix')).called(1);
    verifyNever(() => searchMovies('Ma'));
    expect(find.byType(MovieCard), findsOneWidget);

    await tester.tap(find.byType(MovieCard));
    await tester.pumpAndSettle();
    expect(find.text('Детали: Matrix'), findsOneWidget);
  });

  testWidgets('пустой результат — «Ничего не найдено»', (tester) async {
    when(() => searchMovies(any())).thenAnswer((_) async => []);
    await pumpSearch(tester);
    await search(tester, 'qwerty');
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('ошибка поиска показывается текстом', (tester) async {
    when(() => searchMovies(any())).thenThrow(Exception('Нет сети'));
    await pumpSearch(tester);
    await search(tester, 'Matrix');
    expect(find.text('Ошибка: Exception: Нет сети'), findsOneWidget);
  });
}
