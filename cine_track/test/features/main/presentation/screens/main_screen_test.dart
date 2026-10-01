import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cine_track/core/di/injection.dart';
import 'package:cine_track/core/theme/theme_provider.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/main/presentation/screens/main_screen.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_bloc.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_state.dart';

import '../../../../mocks/mocks.dart';

void main() {
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

  testWidgets('нижняя панель переключает вкладки', (tester) async {
    final homeBloc = MockMoviesBloc();
    whenListen(
      homeBloc,
      const Stream<MoviesState>.empty(),
      initialState: const MoviesState.loaded([]),
    );
    final favorites = MockFavoritesProvider();
    when(() => favorites.favorites).thenReturn([]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider<MoviesBloc>.value(value: homeBloc),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: MainScreen()),
      ),
    );

    expect(find.text('Популярное'), findsOneWidget);

    await tester.tap(find.text('Поиск'));
    await tester.pump();
    expect(find.text('Введите название фильма'), findsOneWidget);
    expect(find.text('Популярное'), findsNothing); // вкладка скрыта

    await tester.tap(find.text('Избранное'));
    await tester.pump();
    expect(find.text('Нет избранных фильмов'), findsOneWidget);

    await tester.tap(find.text('Главная'));
    await tester.pump();
    expect(find.text('Популярное'), findsOneWidget);
  });
}
