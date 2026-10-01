import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/domain/usecases/get_popular_movies.dart';

import '../../../../mocks/mock_movie_repository.dart';

void main() {
  late GetPopularMovies usecase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    usecase = GetPopularMovies(mockRepository);
  });

  final tMovies = [
    const Movie(id: 1, title: 'Test Movie', releaseDate: '2024-01-01'),
  ];

  test('должен вернуть список фильмов из репозитория', () async {
    when(() => mockRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => tMovies);

    final result = await usecase();

    expect(result, equals(tMovies));
    verify(() => mockRepository.getPopularMovies(page: 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('должен пробросить исключение при ошибке репозитория', () async {
    when(() => mockRepository.getPopularMovies(page: any(named: 'page')))
        .thenThrow(Exception('Сетевая ошибка'));

    expect(() => usecase(), throwsException);
  });
}
