import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'blocs/movies/movies_bloc.dart';
import 'blocs/movies/movies_event.dart';
import 'providers/favorites_provider.dart';
import 'providers/ratings_provider.dart';
import 'screens/add_movie_screen.dart';
import 'screens/main_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'services/movie_api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        BlocProvider(
          create: (_) => MoviesBloc(MovieApiService())..add(LoadMovies()),
        ),
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
