import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';

void main() {
  const movie = Movie(
    id: 1,
    title: 'Inception',
    posterPath: '/inception.jpg',
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
  );

  test('year — первые 4 символа даты, N/A без даты', () {
    expect(movie.year, '2010');
    expect(const Movie(id: 2, title: 'X').year, 'N/A');
  });

  test('rating — одна цифра после точки, прочерк без рейтинга', () {
    expect(movie.rating, '8.8');
    expect(const Movie(id: 2, title: 'X').rating, '—');
  });

  test('posterUrl — полный адрес TMDB, пустая строка без постера', () {
    expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/inception.jpg');
    expect(const Movie(id: 2, title: 'X').posterUrl, '');
  });

  test('Freezed: сравнение по значению и copyWith', () {
    expect(
      movie,
      const Movie(
        id: 1,
        title: 'Inception',
        posterPath: '/inception.jpg',
        voteAverage: 8.8,
        releaseDate: '2010-07-16',
      ),
    );
    final renamed = movie.copyWith(title: 'Начало');
    expect(renamed.title, 'Начало');
    expect(renamed.id, movie.id);
    expect(renamed, isNot(movie));
  });
}
