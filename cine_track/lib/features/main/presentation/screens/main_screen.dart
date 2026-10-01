import 'package:flutter/material.dart';

import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../movies/presentation/screens/home_screen.dart';
import '../../../movies/presentation/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // У каждой вкладки свой ScaffoldMessenger: SnackBar показывается в Scaffold
  // вкладки, и её FloatingActionButton поднимается над ним. Иначе SnackBar
  // выводился бы во внешнем Scaffold и перекрывал кнопку «+».
  final List<Widget> _screens = const [
    ScaffoldMessenger(child: HomeScreen()),
    ScaffoldMessenger(child: SearchScreen()),
    ScaffoldMessenger(child: FavoritesScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack держит все вкладки в дереве и показывает только активную.
      // С `body: _screens[_currentIndex]` HomeScreen уничтожался бы при уходе
      // на другую вкладку — вместе с добавленными фильмами и личными оценками.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Скрытые вкладки остаются в дереве, и их Hero тоже участвуют
          // в переходе: фильм с главной и из избранного дал бы два Hero
          // с одним тегом. HeroMode выключает Hero во всех вкладках, кроме
          // активной. А TickerMode останавливает их анимации: IndexedStack
          // сам этого не делает, и Lottie пустого избранного или индикатор
          // загрузки поиска крутились бы на скрытой вкладке всё время.
          for (var i = 0; i < _screens.length; i++)
            HeroMode(
              enabled: i == _currentIndex,
              child: TickerMode(
                enabled: i == _currentIndex,
                child: _screens[i],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
        ],
      ),
    );
  }
}
