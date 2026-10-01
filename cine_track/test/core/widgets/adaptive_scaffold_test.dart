import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/core/widgets/adaptive_scaffold.dart';

void main() {
  const destinations = [
    AdaptiveDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Главная',
    ),
    AdaptiveDestination(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      label: 'Поиск',
    ),
  ];

  late List<int> selected;
  late EdgeInsets bodyPadding;

  Future<void> pumpAt(WidgetTester tester, Size size, {double left = 0}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(left: left);
    addTearDown(tester.view.reset);
    selected = [];
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          selectedIndex: 0,
          onDestinationSelected: selected.add,
          destinations: destinations,
          body: Builder(
            builder: (context) {
              bodyPadding = MediaQuery.paddingOf(context);
              return const Text('Тело');
            },
          ),
        ),
      ),
    );
  }

  testWidgets('телефон (< 600): BottomNavigationBar', (tester) async {
    await pumpAt(tester, const Size(400, 800));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    // у активного пункта — заполненная иконка, у остальных — контурная
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);

    await tester.tap(find.text('Поиск'));
    expect(selected, [1]);
  });

  testWidgets('планшет (>= 600): NavigationRail, подпись только у активного', (
    tester,
  ) async {
    await pumpAt(tester, const Size(800, 600));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.labelType, NavigationRailLabelType.selected);

    await tester.tap(find.byIcon(Icons.search_outlined));
    expect(selected, [1]);
  });

  testWidgets('десктоп (>= 1200): подписи у всех пунктов', (tester) async {
    await pumpAt(tester, const Size(1300, 800));
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.labelType, NavigationRailLabelType.all);
  });

  testWidgets('левый вырез обходит NavigationRail, а не тело', (tester) async {
    await pumpAt(tester, const Size(850, 390), left: 47);
    expect(bodyPadding.left, 0);
  });
}
