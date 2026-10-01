import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'blocs/movies/movies_bloc.dart';
import 'blocs/movies/movies_event.dart';
import 'providers/favorites_provider.dart';
import 'providers/ratings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_movie_screen.dart';
import 'screens/main_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'services/movie_api_service.dart';

void main() {
  if (kIsWeb) {
    // В браузере нет встроенного SQLite: sqflite_common_ffi_web запускает его
    // через WebAssembly (web/sqlite3.wasm, web/sqflite_sw.js) и хранит базу
    // в IndexedDB. На Android и iOS используется стандартная фабрика sqflite.
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(
          create: (_) => MoviesBloc(MovieApiService())..add(LoadMovies()),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => RatingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineTrack',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/movie-detail': (context) => const MovieDetailScreen(),
        '/add-movie': (context) => const AddMovieScreen(),
      },
    );
  }
}
