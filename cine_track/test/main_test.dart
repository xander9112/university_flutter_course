import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cine_track/core/di/injection.dart';
import 'package:cine_track/core/theme/theme_provider.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_bloc.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_state.dart';
import 'package:cine_track/features/movies/presentation/screens/movie_detail_screen.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_card.dart';
import 'package:cine_track/features/ratings/presentation/providers/ratings_provider.dart';
import 'package:cine_track/main.dart';

import 'mocks/mocks.dart';

void main() {
  const movie = Movie(id: 1, title: 'Inception', releaseDate: '2010-07-16');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sl.registerFactory<MoviesBloc>(
      () => MoviesBloc(
        getPopularMovies: MockGetPopularMovies(),
        searchMovies: MockSearchMovies(),
      ),
    );
  });

  tearDown(() => sl.reset());

  // Настоящий MyApp: маршруты и onGenerateRoute из main.dart
  Future<void> pumpApp(WidgetTester tester) async {
    final bloc = MockMoviesBloc();
    whenListen(
      bloc,
      const Stream<MoviesState>.empty(),
      initialState: const MoviesState.loaded([movie]),
    );
    // Фильм и на главной, и в избранном: в дереве два Hero с тегом poster-1
    final favorites = MockFavoritesProvider();
    when(() => favorites.favorites).thenReturn([movie]);
    when(() => favorites.isFavorite(any())).thenReturn(true);
    final ratings = MockRatingsProvider();
    when(() => ratings.ratingOf(any())).thenReturn(null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider<MoviesBloc>.value(value: bloc),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
          ChangeNotifierProvider<RatingsProvider>.value(value: ratings),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('детали открываются слайдом снизу, постер летит через Hero', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byType(MovieCard).first);
    await tester.pump(kDoubleTapTimeout);
    await tester.pump(); // маршрут добавлен
    await tester.pump(const Duration(milliseconds: 200)); // середина перехода

    // Hero вкладки «Избранное» выключен HeroMode — ошибки
    // «multiple heroes that share the same tag» нет.
    expect(tester.takeException(), isNull);
    final slide = tester.widget<SlideTransition>(
      find
          .ancestor(
            of: find.byType(MovieDetailScreen),
            matching: find.byType(SlideTransition),
          )
          .first,
    );
    expect(slide.position.value.dy, greaterThan(0)); // ещё ниже своего места
    expect(slide.position.value.dy, lessThan(1));

    await tester.pumpAndSettle();
    expect(find.byType(MovieDetailScreen), findsOneWidget);
    // arguments дошли до экрана через settings
    expect(find.text('Вы ещё не оценили этот фильм'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MovieDetailScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
