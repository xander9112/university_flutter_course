import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cine_track/features/movies/domain/entities/movie.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late MockGetFavorites getFavorites;
  late MockToggleFavorite toggleFavorite;
  const saved = Movie(id: 1, title: 'Сохранённый');
  const other = Movie(id: 2, title: 'Новый');

  setUpAll(() => registerFallbackValue(saved));

  setUp(() {
    getFavorites = MockGetFavorites();
    toggleFavorite = MockToggleFavorite();
    when(() => getFavorites()).thenAnswer((_) async => [saved]);
    when(() => toggleFavorite(any(), isFavorite: any(named: 'isFavorite')))
        .thenAnswer((_) async {});
  });

  Future<FavoritesProvider> createLoaded() async {
    final provider = FavoritesProvider(
      getFavorites: getFavorites,
      toggleFavorite: toggleFavorite,
    );
    await Future<void>.delayed(Duration.zero); // ждём _load()
    return provider;
  }

  test('при создании загружает избранное из базы', () async {
    final provider = await createLoaded();
    expect(provider.favorites, [saved]);
    expect(provider.isFavorite(1), isTrue);
    expect(provider.isFavorite(2), isFalse);
  });

  test(
    'toggleFavorite добавляет новый фильм и уведомляет слушателей',
    () async {
      final provider = await createLoaded();
      var notified = 0;
      provider.addListener(() => notified++);

      await provider.toggleFavorite(other);

      verify(() => toggleFavorite(other, isFavorite: false)).called(1);
      expect(provider.isFavorite(2), isTrue);
      expect(notified, 1);
    },
  );

  test('toggleFavorite убирает фильм, который уже в избранном', () async {
    final provider = await createLoaded();

    await provider.toggleFavorite(saved);

    verify(() => toggleFavorite(saved, isFavorite: true)).called(1);
    expect(provider.favorites, isEmpty);
  });

  test('список избранного нельзя изменить снаружи', () async {
    final provider = await createLoaded();
    expect(() => provider.favorites.add(other), throwsUnsupportedError);
  });
}
