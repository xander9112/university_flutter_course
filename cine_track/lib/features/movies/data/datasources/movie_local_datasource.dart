import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_dto.dart';

abstract class MovieLocalDataSource {
  Future<void> cacheMovies(List<MovieDto> movies);
  Future<List<MovieDto>> getCachedMovies();
}

/// Кэш последнего списка популярных фильмов.
///
/// На Android и iOS — файл `movies_cache.json` в папке документов. В браузере
/// файловой системы нет, поэтому там JSON хранится в `SharedPreferences`
/// (`localStorage`), как в Лекции 14.
class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  static const _webKey = 'movies_cache';

  Future<File> _getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/movies_cache.json');
  }

  @override
  Future<void> cacheMovies(List<MovieDto> movies) async {
    final json = jsonEncode({
      'results': movies.map((m) => m.toJson()).toList(),
    });
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_webKey, json);
        return;
      }
      final file = await _getCacheFile();
      await file.writeAsString(json);
    } catch (_) {} // ошибка записи кэша не должна ломать загрузку
  }

  @override
  Future<List<MovieDto>> getCachedMovies() async {
    String? cached;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      cached = prefs.getString(_webKey);
    } else {
      final file = await _getCacheFile();
      if (await file.exists()) cached = await file.readAsString();
    }
    if (cached == null) {
      throw Exception('Нет сети и нет сохранённых данных');
    }
    final data = jsonDecode(cached) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((json) => MovieDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
