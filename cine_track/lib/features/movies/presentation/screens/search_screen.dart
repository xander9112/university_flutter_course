import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/movies_bloc.dart';
import '../blocs/movies_event.dart';
import '../blocs/movies_state.dart';
import '../../../../core/di/injection.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Свой экземпляр блока: результаты поиска не должны заменять
    // список на главном экране.
    return BlocProvider(
      create: (_) => sl<MoviesBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    // Запрос уходит, только если пользователь не печатал 500 мс.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MoviesBloc>().add(SearchMoviesRequested(query));
    });
  }

  Widget _buildBody(BuildContext context, MoviesState state) {
    if (state is MoviesInitial) {
      return const Center(child: Text('Введите название фильма'));
    }
    if (state is MoviesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is MoviesError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка: ${state.message}', textAlign: TextAlign.center),
        ),
      );
    }
    final movies = (state as MoviesLoaded).movies;
    if (movies.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
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
      body: BlocBuilder<MoviesBloc, MoviesState>(builder: _buildBody),
    );
  }
}
