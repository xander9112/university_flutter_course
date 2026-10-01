import 'package:flutter/material.dart';

import '../models/movie.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _overviewController = TextEditingController();
  final _ratingController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _overviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  /// Рейтинг допускает и точку, и запятую: «8.5» и «8,5».
  double? _parseRating(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  String? _validateTitle(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Введите название (минимум 2 символа)';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || !RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Введите год из 4 цифр';
    }
    return null;
  }

  String? _validateRating(String? value) {
    if (value == null || value.trim().isEmpty) return null; // необязательное
    final rating = _parseRating(value);
    if (rating == null || rating < 0 || rating > 10) {
      return 'Рейтинг — число от 0 до 10';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final overview = _overviewController.text.trim();
    final newMovie = Movie(
      id: DateTime.now().millisecondsSinceEpoch, // уникальный id для ValueKey
      title: _titleController.text.trim(),
      overview: overview.isEmpty ? null : overview,
      voteAverage: _parseRating(_ratingController.text),
      releaseDate: '${_yearController.text.trim()}-01-01',
    );
    Navigator.pop(context, newMovie); // возвращаем фильм на главный экран
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый фильм')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название *'),
                textInputAction: TextInputAction.next,
                validator: _validateTitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Год выпуска *'),
                keyboardType: TextInputType.number,
                maxLength: 4,
                textInputAction: TextInputAction.next,
                validator: _validateYear,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _overviewController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Рейтинг',
                  hintText: 'от 0 до 10',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateRating,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Добавить фильм'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
