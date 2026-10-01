import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/features/movies/presentation/widgets/favorite_button.dart';

void main() {
  Widget button(bool isFavorite, VoidCallback onToggle) => MaterialApp(
    home: Scaffold(
      body: FavoriteButton(isFavorite: isFavorite, onToggle: onToggle),
    ),
  );

  testWidgets('нажатие вызывает onToggle', (tester) async {
    var taps = 0;
    await tester.pumpWidget(button(false, () => taps++));
    await tester.tap(find.byType(FavoriteButton));
    expect(taps, 1);
  });

  testWidgets('иконка меняется с анимацией масштаба', (tester) async {
    await tester.pumpWidget(button(false, () {}));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byTooltip('В избранное'), findsOneWidget);

    await tester.pumpWidget(button(true, () {}));
    await tester.pump(const Duration(milliseconds: 150));
    // середина перехода: старая иконка уменьшается, новая растёт
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    final scale = tester.widget<ScaleTransition>(
      find.ancestor(
        of: find.byIcon(Icons.favorite),
        matching: find.byType(ScaleTransition),
      ),
    );
    expect(scale.scale.value, closeTo(0.5, 0.01));

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byTooltip('Убрать из избранного'), findsOneWidget);
  });
}
