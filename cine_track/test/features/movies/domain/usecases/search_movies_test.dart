import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';
import 'package:cine_track/features/movies/domain/usecases/search_movies.dart';

import '../../../../mocks/mock_movie_repository.dart';

void main() {
  test('передаёт запрос в репозиторий и возвращает результат', () async {
    final repository = MockMovieRepository();
    const tMovies = [Movie(id: 1, title: 'Матрица')];
    when(() => repository.searchMovies('Матрица'))
        .thenAnswer((_) async => tMovies);

    final result = await SearchMovies(repository)('Матрица');

    expect(result, tMovies);
    verify(() => repository.searchMovies('Матрица')).called(1);
  });
}
