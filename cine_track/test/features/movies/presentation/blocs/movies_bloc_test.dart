import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:cine_track/features/movies/domain/usecases/search_movies.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_bloc.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_event.dart';
import 'package:cine_track/features/movies/presentation/blocs/movies_state.dart';

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

class MockSearchMovies extends Mock implements SearchMovies {}

void main() {
  late MoviesBloc bloc;
  late MockGetPopularMovies mockGetPopularMovies;
  late MockSearchMovies mockSearchMovies;

  final tMovies = [
    const Movie(id: 1, title: 'Inception', releaseDate: '2010-07-16'),
  ];

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    mockSearchMovies = MockSearchMovies();
    bloc = MoviesBloc(
      getPopularMovies: mockGetPopularMovies,
      searchMovies: mockSearchMovies,
    );
  });

  tearDown(() => bloc.close());

  blocTest<MoviesBloc, MoviesState>(
    'LoadMovies: должен перейти в Loading → Loaded при успешной загрузке',
    build: () {
      when(() => mockGetPopularMovies()).thenAnswer((_) async => tMovies);
      return bloc;
    },
    act: (bloc) => bloc.add(const MoviesEvent.load()),
    expect: () => [const MoviesState.loading(), MoviesState.loaded(tMovies)],
  );

  blocTest<MoviesBloc, MoviesState>(
    'LoadMovies: должен перейти в Error при сетевой ошибке',
    build: () {
      when(() => mockGetPopularMovies()).thenThrow(Exception('Нет сети'));
      return bloc;
    },
    act: (bloc) => bloc.add(const MoviesEvent.load()),
    expect: () => [const MoviesState.loading(), isA<MoviesError>()],
  );

  // Тесты ниже — сверх задания: остальные события блока.

  group('RefreshMovies', () {
    blocTest<MoviesBloc, MoviesState>(
      'выдаёт новые фильмы без Loading и завершает completer',
      build: () {
        when(() => mockGetPopularMovies()).thenAnswer((_) async => tMovies);
        return bloc;
      },
      act: (bloc) async {
        final completer = Completer<void>();
        bloc.add(RefreshMovies(completer: completer));
        await completer.future;
      },
      expect: () => [MoviesState.loaded(tMovies)],
    );

    blocTest<MoviesBloc, MoviesState>(
      'с теми же фильмами состояние не меняется, но completer завершается',
      build: () {
        when(() => mockGetPopularMovies()).thenAnswer((_) async => tMovies);
        return bloc;
      },
      seed: () => MoviesState.loaded(tMovies),
      act: (bloc) async {
        final completer = Completer<void>();
        bloc.add(RefreshMovies(completer: completer));
        await completer.future.timeout(const Duration(seconds: 1));
      },
      expect: () => <MoviesState>[],
    );

    blocTest<MoviesBloc, MoviesState>(
      'при ошибке выдаёт Error и тоже завершает completer',
      build: () {
        when(() => mockGetPopularMovies()).thenThrow(Exception('Нет сети'));
        return bloc;
      },
      act: (bloc) async {
        final completer = Completer<void>();
        bloc.add(RefreshMovies(completer: completer));
        await completer.future;
      },
      expect: () => [const MoviesState.error('Exception: Нет сети')],
    );
  });

  group('SearchMoviesRequested', () {
    blocTest<MoviesBloc, MoviesState>(
      'находит фильмы: Loading → Loaded',
      build: () {
        when(() => mockSearchMovies('Inception'))
            .thenAnswer((_) async => tMovies);
        return bloc;
      },
      act: (bloc) => bloc.add(const MoviesEvent.search('  Inception ')),
      expect: () => [const MoviesState.loading(), MoviesState.loaded(tMovies)],
    );

    blocTest<MoviesBloc, MoviesState>(
      'пустой запрос возвращает к начальному состоянию без обращения к сети',
      build: () => bloc,
      seed: () => MoviesState.loaded(tMovies),
      act: (bloc) => bloc.add(const MoviesEvent.search('   ')),
      expect: () => [const MoviesState.initial()],
      verify: (_) => verifyNever(() => mockSearchMovies(any())),
    );

    blocTest<MoviesBloc, MoviesState>(
      'ошибка поиска: Loading → Error',
      build: () {
        when(() => mockSearchMovies(any())).thenThrow(Exception('Нет сети'));
        return bloc;
      },
      act: (bloc) => bloc.add(const MoviesEvent.search('Inception')),
      expect: () => [
        const MoviesState.loading(),
        const MoviesState.error('Exception: Нет сети'),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'устаревший ответ отбрасывается: показан результат последнего запроса',
      build: () {
        const latest = [Movie(id: 2, title: 'Interstellar')];
        when(() => mockSearchMovies('In')).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return tMovies;
        });
        when(() => mockSearchMovies('Inter')).thenAnswer((_) async => latest);
        return bloc;
      },
      act: (bloc) {
        bloc
          ..add(const MoviesEvent.search('In'))
          ..add(const MoviesEvent.search('Inter'));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const MoviesState.loading(),
        const MoviesState.loaded([Movie(id: 2, title: 'Interstellar')]),
      ],
    );
  });

  group('операции со списком', () {
    const added = Movie(id: 3, title: 'Новый фильм');
    final twoMovies = [...tMovies, const Movie(id: 2, title: 'Interstellar')];

    blocTest<MoviesBloc, MoviesState>(
      'AddMovie добавляет фильм в начало списка',
      build: () => bloc,
      seed: () => MoviesState.loaded(tMovies),
      act: (bloc) => bloc.add(const AddMovie(added)),
      expect: () => [
        MoviesState.loaded([added, ...tMovies]),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'RemoveMovie удаляет фильм по id',
      build: () => bloc,
      seed: () => MoviesState.loaded(twoMovies),
      act: (bloc) => bloc.add(const RemoveMovie(1)),
      expect: () => [
        MoviesState.loaded([twoMovies[1]]),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'ShuffleMovies сохраняет тот же набор фильмов',
      build: () => bloc,
      seed: () => MoviesState.loaded(twoMovies),
      act: (bloc) => bloc.add(const ShuffleMovies()),
      // порядок случайный: если он не изменился, Bloc ничего не выдаст
      verify: (bloc) => expect(
        (bloc.state as MoviesLoaded).movies,
        unorderedEquals(twoMovies),
      ),
    );

    blocTest<MoviesBloc, MoviesState>(
      'без загруженного списка операции ничего не делают',
      build: () => bloc,
      act: (bloc) => bloc
        ..add(const AddMovie(added))
        ..add(const RemoveMovie(1))
        ..add(const ShuffleMovies()),
      expect: () => <MoviesState>[],
    );
  });
}
