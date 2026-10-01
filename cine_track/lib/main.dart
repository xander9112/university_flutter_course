import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'core/di/injection.dart';
import 'core/theme/theme_provider.dart';
import 'features/favorites/presentation/providers/favorites_provider.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'features/movies/presentation/blocs/movies_bloc.dart';
import 'features/movies/presentation/blocs/movies_event.dart';
import 'features/movies/presentation/screens/add_movie_screen.dart';
import 'features/movies/presentation/screens/movie_detail_screen.dart';
import 'features/ratings/presentation/providers/ratings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // В браузере нет встроенного SQLite: sqflite_common_ffi_web запускает его
    // через WebAssembly (web/sqlite3.wasm, web/sqflite_sw.js) и хранит базу
    // в IndexedDB. На Android и iOS используется стандартная фабрика sqflite.
    databaseFactory = databaseFactoryFfiWeb;
  }
  await configureDependencies(); // регистрируем все зависимости до runApp

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (_) => sl<MoviesBloc>()..add(LoadMovies())),
        ChangeNotifierProvider(create: (_) => sl<FavoritesProvider>()),
        ChangeNotifierProvider(create: (_) => sl<RatingsProvider>()),
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
