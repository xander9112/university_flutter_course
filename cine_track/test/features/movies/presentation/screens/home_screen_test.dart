import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cine_track/core/theme/theme_provider.dart';
import 'package:cine_track/core/widgets/loading_animation.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_bloc.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_event.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_state.dart';
import 'package:cine_track/features/movies/presentation/screens/home_screen.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_card.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_preview_card.dart';

import '../../../../mocks/mocks.dart';

void main() {
  const inception = Movie(id: 1, title: 'Inception', voteAverage: 8.8);
  const matrix = Movie(id: 2, title: 'Matrix', voteAverage: 8.7);
  const added = Movie(id: 3, title: 'Новый фильм');

  late MockMoviesBloc bloc;
  late StreamController<MoviesState> states;
  late MockFavoritesProvider favorites;
  late ThemeProvider theme;

  setUpAll(() {
    registerFallbackValue(const MoviesEvent.load());
    registerFallbackValue(inception);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    bloc = MockMoviesBloc();
    states = StreamController<MoviesState>();
    favorites = MockFavoritesProvider();
    theme = ThemeProvider();
    when(() => favorites.isFavorite(any())).thenReturn(false);
  });

  tearDown(() => states.close());

  Future<void> pumpHome(WidgetTester tester, MoviesState state) async {
    whenListen(bloc, states.stream, initialState: state);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider<MoviesBloc>.value(value: bloc),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: MaterialApp(
          home: const HomeScreen(),
          routes: {
            // Заглушки маршрутов: проверяем только, что HomeScreen их открывает
            '/movie-detail': (context) => Scaffold(
              body: Text(
                'Детали: ${(ModalRoute.of(context)!.settings.arguments as Movie).title}',
              ),
            ),
            '/add-movie': (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pop(context, added),
                child: const Text('Вернуть фильм'),
              ),
            ),
          },
        ),
      ),
    );
  }

  testWidgets('во время загрузки показывает индикатор', (tester) async {
    await pumpHome(tester, const MoviesState.loading());
    expect(find.byType(LoadingAnimation), findsOneWidget);
  });

  testWidgets('ошибка: текст и кнопка «Повторить» отправляет load', (
    tester,
  ) async {
    await pumpHome(tester, const MoviesState.error('Нет сети'));
    expect(find.text('Ошибка: Нет сети'), findsOneWidget);

    await tester.tap(find.text('Повторить'));
    verify(() => bloc.add(const MoviesEvent.load())).called(1);
  });

  testWidgets('список: лента «Популярное» и карточки «Все фильмы»', (
    tester,
  ) async {
    await pumpHome(tester, const MoviesState.loaded([inception, matrix]));

    expect(find.text('Популярное'), findsOneWidget);
    expect(find.text('Все фильмы'), findsOneWidget);
    expect(find.byType(MoviePreviewCard), findsNWidgets(2));
    expect(find.byType(MovieCard), findsNWidgets(2));
  });

  testWidgets('тап по карточке открывает детали фильма', (tester) async {
    await pumpHome(tester, const MoviesState.loaded([inception]));

    await tester.tap(find.byType(MovieCard));
    // GestureDetector ждёт второго тапа: одиночный тап засчитывается
    // только после таймаута двойного (300 мс). pumpAndSettle таймеры не ждёт.
    await tester.pump(kDoubleTapTimeout);
    await tester.pumpAndSettle();
    expect(find.text('Детали: Inception'), findsOneWidget);
  });

  testWidgets('двойной тап переключает избранное и показывает SnackBar', (
    tester,
  ) async {
    when(() => favorites.toggleFavorite(inception)).thenAnswer((_) async {
      when(() => favorites.isFavorite(1)).thenReturn(true);
    });
    await pumpHome(tester, const MoviesState.loaded([inception]));

    final card = find.byType(MovieCard);
    await tester.tap(card);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(card);
    await tester.pump();

    verify(() => favorites.toggleFavorite(inception)).called(1);
    expect(find.text('«Inception» добавлен в избранное'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3)); // SnackBar скрывается
    await tester.pumpAndSettle();
  });

  testWidgets('кнопка «+» добавляет фильм из формы', (tester) async {
    await pumpHome(tester, const MoviesState.loaded([inception]));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вернуть фильм'));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const AddMovie(added))).called(1);
    expect(find.text('«Новый фильм» добавлен!'), findsOneWidget);
  });

  testWidgets('свайп с подтверждением удаляет фильм', (tester) async {
    when(() => bloc.add(const RemoveMovie(1)))
        .thenAnswer((_) => states.add(const MoviesState.loaded([matrix])));
    await pumpHome(tester, const MoviesState.loaded([inception, matrix]));

    await tester.drag(find.text('Inception').last, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Удалить фильм?'), findsOneWidget);
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const RemoveMovie(1))).called(1);
    expect(find.byType(MovieCard), findsOneWidget);
  });

  testWidgets('отмена в диалоге оставляет фильм', (tester) async {
    await pumpHome(tester, const MoviesState.loaded([inception]));

    await tester.drag(find.byType(MovieCard), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.add(any(that: isA<RemoveMovie>())));
    expect(find.byType(MovieCard), findsOneWidget);
  });

  testWidgets('pull-to-refresh ждёт completer из события refresh', (
    tester,
  ) async {
    await pumpHome(tester, const MoviesState.loaded([inception, matrix]));

    await tester.fling(
      find.byType(MovieCard).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final event =
        verify(() => bloc.add(captureAny(that: isA<RefreshMovies>())))
                .captured
                .single
            as RefreshMovies;
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    event.completer!.complete(); // блок закончил обновление
    await tester.pumpAndSettle();
    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });

  testWidgets('кнопки в AppBar: перемешать и сменить тему', (tester) async {
    await pumpHome(tester, const MoviesState.loaded([inception]));

    await tester.tap(find.byTooltip('Перемешать'));
    verify(() => bloc.add(const ShuffleMovies())).called(1);

    await tester.tap(find.byTooltip('Тёмная тема'));
    await tester.pumpAndSettle();
    expect(theme.isDark, isTrue);
    expect(find.byTooltip('Светлая тема'), findsOneWidget);
  });

  // Задание 20: «Все фильмы» — список на узком экране, сетка на широком
  group('адаптивность', () {
    Future<void> pumpAtWidth(WidgetTester tester, double width) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return pumpHome(tester, const MoviesState.loaded([inception, matrix]));
    }

    testWidgets('ширина < 600 — список', (tester) async {
      await pumpAtWidth(tester, 400);
      expect(find.byType(SliverGrid), findsNothing);
      // карточки идут друг под другом
      final cards = find.byType(MovieCard);
      expect(
        tester.getTopLeft(cards.at(1)).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(cards.at(0)).dy),
      );
    });

    testWidgets('ширина >= 600 — сетка, карточки в одном ряду', (tester) async {
      await pumpAtWidth(tester, 1000);
      expect(find.byType(SliverGrid), findsOneWidget);
      final cards = find.byType(MovieCard);
      expect(
        tester.getTopLeft(cards.at(0)).dy,
        tester.getTopLeft(cards.at(1)).dy,
      );
    });

    testWidgets('в сетке работает удаление свайпом', (tester) async {
      when(() => bloc.add(const RemoveMovie(1)))
          .thenAnswer((_) => states.add(const MoviesState.loaded([matrix])));
      await pumpAtWidth(tester, 1000);

      await tester.drag(find.text('Inception').last, const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const RemoveMovie(1))).called(1);
    });
  });
}
