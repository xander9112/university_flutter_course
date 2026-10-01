import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cine_track/features/ratings/presentation/providers/ratings_provider.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late MockGetRatings getRatings;
  late MockSetRating setRating;

  setUp(() {
    getRatings = MockGetRatings();
    setRating = MockSetRating();
    when(() => getRatings()).thenAnswer((_) async => {1: 9.0});
    when(() => setRating(any(), any())).thenAnswer((_) async {});
  });

  test('загружает сохранённые оценки, null для неоценённого фильма', () async {
    final provider = RatingsProvider(
      getRatings: getRatings,
      setRating: setRating,
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.ratingOf(1), 9.0);
    expect(provider.ratingOf(2), isNull);
  });

  test('setRating сразу обновляет оценку и сохраняет её', () async {
    final provider = RatingsProvider(
      getRatings: getRatings,
      setRating: setRating,
    );
    await Future<void>.delayed(Duration.zero);
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.setRating(2, 7.5);

    expect(provider.ratingOf(2), 7.5);
    expect(notified, 1);
    verify(() => setRating(2, 7.5)).called(1);
  });
}
