import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/ratings/domain/usecases/get_ratings.dart';
import 'package:cine_track/features/ratings/domain/usecases/set_rating.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late MockRatingsRepository repository;

  setUp(() => repository = MockRatingsRepository());

  test('GetRatings возвращает оценки из репозитория', () async {
    when(() => repository.getRatings()).thenAnswer((_) async => {1: 9.0});
    expect(await GetRatings(repository)(), {1: 9.0});
  });

  test('SetRating сохраняет оценку в репозиторий', () async {
    when(() => repository.setRating(1, 7.5)).thenAnswer((_) async {});
    await SetRating(repository)(1, 7.5);
    verify(() => repository.setRating(1, 7.5)).called(1);
  });
}
