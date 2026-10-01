import 'package:flutter/material.dart';

import '../../../../core/widgets/adaptive_scaffold.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../movies/presentation/screens/home_screen.dart';
import '../../../movies/presentation/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const _destinations = [
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
    AdaptiveDestination(
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Избранное',
    ),
  ];

  // У каждой вкладки свой ScaffoldMessenger: SnackBar показывается в Scaffold
  // вкладки, и её FloatingActionButton поднимается над ним. Иначе SnackBar
  // выводился бы во внешнем Scaffold и перекрывал кнопку «+».
  static const _screens = [
    ScaffoldMessenger(child: HomeScreen()),
    ScaffoldMessenger(child: SearchScreen()),
    ScaffoldMessenger(child: FavoritesScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      destinations: _destinations,
      // IndexedStack держит все вкладки в дереве и показывает только активную:
      // при уходе на другую вкладку HomeScreen не теряет добавленные фильмы.
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Скрытые вкладки остаются в дереве, и их Hero тоже участвуют
          // в переходе: фильм с главной и из избранного дал бы два Hero
          // с одним тегом. HeroMode выключает Hero во всех вкладках, кроме
          // активной. А TickerMode останавливает их анимации: IndexedStack
          // сам этого не делает, и Lottie пустого избранного или индикатор
          // загрузки поиска крутились бы на скрытой вкладке (Задание 19).
          for (var i = 0; i < _screens.length; i++)
            HeroMode(
              enabled: i == _selectedIndex,
              child: TickerMode(
                enabled: i == _selectedIndex,
                child: _screens[i],
              ),
            ),
        ],
      ),
    );
  }
}
