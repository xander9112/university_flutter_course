import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_api_service.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _apiService = MovieApiService();
  Timer? _debounce;
  List<Movie> _results = []; // до ввода запроса экран пуст
  bool _isSearching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    // Пока ждём паузу в наборе и ответ сервера, показываем индикатор,
    // а не «Ничего не найдено».
    setState(() => _isSearching = query.trim().isNotEmpty);
    // Запрос уходит, только если пользователь не печатал 500 мс.
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _apiService.searchMovies(query.trim());
        // Пока шёл запрос, текст могли изменить — тогда этот ответ устарел,
        // и показывать его поверх более нового запроса нельзя.
        if (!mounted || query != _controller.text) return;
        setState(() {
          _results = results;
          _isSearching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка поиска: $e')));
      }
    });
  }

  Widget _buildBody() {
    if (_controller.text.trim().isEmpty) {
      return const Center(child: Text('Введите название фильма'));
    }
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final movie = _results[index];
        return GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, '/movie-detail', arguments: movie),
          child: MovieCard(movie: movie),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _onSearch,
          decoration: const InputDecoration(
            hintText: 'Название фильма...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }
}
