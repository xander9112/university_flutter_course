import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/core/widgets/loading_animation.dart';

void main() {
  double angle(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(LoadingAnimation),
        matching: find.byType(Transform),
      ),
    );
    // угол поворота из матрицы: atan2(sin, cos)
    return math.atan2(transform.transform[1], transform.transform[0]);
  }

  testWidgets('иконка плёнки вращается: четверть оборота за 300 мс', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoadingAnimation(size: 64)),
    );
    expect(find.byIcon(Icons.movie), findsOneWidget);
    expect(angle(tester), closeTo(0, 1e-6));

    await tester.pump(const Duration(milliseconds: 300)); // 1200 мс — оборот
    expect(angle(tester), closeTo(math.pi / 2, 1e-6));
  });

  testWidgets('контроллер останавливается вместе с виджетом', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingAnimation()));
    // работающий Ticker — это колбэк кадра (transient callback)
    expect(tester.binding.transientCallbackCount, 1);

    // Если бы dispose() не вызывал _controller.dispose(), flutter_test
    // сообщил бы об активном Ticker при удалении виджета.
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
  });
}
