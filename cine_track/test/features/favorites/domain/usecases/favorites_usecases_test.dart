import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/favorites/domain/usecases/get_favorites.dart';
import 'package:cine_track/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late MockFavoritesRepository repository;
  const movie = Movie(id: 7, title: 'Интерстеллар');

  // any() для аргумента типа Movie требует значение-заглушку
  setUpAll(() => registerFallbackValue(movie));

  setUp(() {
    repository = MockFavoritesRepository();
    when(() => repository.addFavorite(movie)).thenAnswer((_) async {});
    when(() => repository.removeFavorite(7)).thenAnswer((_) async {});
  });

  test('GetFavorites возвращает фильмы из репозитория', () async {
    when(() => repository.getFavorites()).thenAnswer((_) async => [movie]);
    expect(await GetFavorites(repository)(), [movie]);
  });

  test('ToggleFavorite добавляет фильм, которого нет в избранном', () async {
    await ToggleFavorite(repository)(movie, isFavorite: false);
    verify(() => repository.addFavorite(movie)).called(1);
    verifyNever(() => repository.removeFavorite(any()));
  });

  test('ToggleFavorite убирает фильм, который уже в избранном', () async {
    await ToggleFavorite(repository)(movie, isFavorite: true);
    verify(() => repository.removeFavorite(7)).called(1);
    verifyNever(() => repository.addFavorite(any()));
  });
}
