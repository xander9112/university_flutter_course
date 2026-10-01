import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../utils/movie_utils.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Movie> _results = mockMovies; // при пустом запросе показываем все фильмы

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _results = searchByTitle(mockMovies, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onSearch,
          decoration: const InputDecoration(
            hintText: 'Название фильма...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _results.isEmpty
          ? const Center(child: Text('Ничего не найдено'))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final movie = _results[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  ),
                  child: MovieCard(movie: movie),
                );
              },
            ),
    );
  }
}
