import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/ratings_provider.dart';
import 'screens/add_movie_screen.dart';
import 'screens/main_screen.dart';
import 'screens/movie_detail_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => RatingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineTrack',
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/movie-detail': (context) => const MovieDetailScreen(),
        '/add-movie': (context) => const AddMovieScreen(),
      },
    );
  }
}
