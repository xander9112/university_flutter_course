import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Изменяемая копия: в следующем задании список будет перемешиваться
  // и из него будут удаляться фильмы.
  final List<Movie> _movies = [...mockMovies];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CineTrack')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _movies.length,
        itemBuilder: (context, index) => MovieCard(movie: _movies[index]),
      ),
    );
  }
}
