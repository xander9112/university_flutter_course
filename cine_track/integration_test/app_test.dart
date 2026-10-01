import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cine_track/main.dart' as app;
import 'package:cine_track/features/movies/presentation/screens/movie_detail_screen.dart';
import 'package:cine_track/features/movies/presentation/widgets/movie_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Пользователь открывает детали фильма и добавляет его в избранное',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // ждём загрузки

      // Главный экран загрузился: на нём две ленты (Популярное и Все фильмы)
      expect(find.byType(ListView), findsWidgets);
      expect(find.byType(MovieCard), findsWidgets);

      // Нажимаем на первую карточку — открывается экран деталей
      await tester.tap(find.byType(MovieCard).first);
      // У карточки есть onDoubleTap (Задание 9): одиночный тап засчитывается
      // только после таймаута двойного, а pumpAndSettle таймеры не ждёт.
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
      expect(find.byType(MovieDetailScreen), findsOneWidget);

      // Возвращаемся назад
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MovieDetailScreen), findsNothing);

      // Нажимаем иконку сердца на первой карточке — она становится заполненной.
      // Ищем иконку внутри карточки: Icons.favorite есть и на вкладке
      // «Избранное» в нижней панели, поэтому find.byIcon(Icons.favorite)
      // нашёл бы её даже без нажатия.
      final firstCard = find.byType(MovieCard).first;
      await tester.tap(
        find.descendant(
          of: firstCard,
          matching: find.byIcon(Icons.favorite_border),
        ),
      );
      await tester.pump(
        kDoubleTapTimeout,
      ); // сердце лежит внутри той же карточки
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: firstCard, matching: find.byIcon(Icons.favorite)),
        findsOneWidget,
      );

      // Переходим на вкладку «Избранное» в нижней панели
      await tester.tap(find.text('Избранное'));
      await tester.pumpAndSettle();

      // Фильм должен быть в списке
      expect(find.byType(MovieCard), findsAtLeastNWidgets(1));
    },
  );
}
