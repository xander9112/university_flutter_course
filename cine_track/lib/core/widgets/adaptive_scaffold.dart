import 'package:flutter/material.dart';

/// Каркас с навигацией: BottomNavigationBar на телефоне,
/// NavigationRail сбоку на планшете и десктопе (ширина >= 600).
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveDestination> destinations;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    // Тип навигации зависит от размера всего экрана, а не от места,
    // выделенного виджету, — поэтому MediaQuery, а не LayoutBuilder.
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    if (isTablet) {
      // Планшет: NavigationRail слева
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              // Показываем лейблы рядом с иконками на широких экранах
              labelType: width >= 1200
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Левый вырез экрана (телефон в ландшафте) уже обошла
            // NavigationRail — убираем его из MediaQuery, иначе SafeArea
            // экранов отступили бы от него ещё раз.
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                child: body,
              ),
            ),
          ],
        ),
      );
    }

    // Телефон: BottomNavigationBar
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        items: destinations
            .map(
              (d) => BottomNavigationBarItem(
                icon: Icon(d.icon),
                activeIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Пункт навигации — общий для BottomNavigationBar и NavigationRail.
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
