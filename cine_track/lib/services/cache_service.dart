import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Кэш последнего ответа API.
///
/// На Android и iOS — файл в папке документов приложения. В браузере файловой
/// системы нет (`path_provider` не знает папку документов, а `File` из
/// `dart:io` не работает), поэтому там JSON хранится в `SharedPreferences`,
/// то есть в `localStorage` браузера.
class CacheService {
  static const _webKey = 'movies_cache';

  static Future<File> _getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/movies_cache.json');
  }

  static Future<void> saveMovies(String jsonString) async {
    // Кэш — вспомогательная функция: если сохранить не удалось,
    // загрузка фильмов не должна из-за этого ломаться.
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_webKey, jsonString);
        return;
      }
      final file = await _getCacheFile();
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  static Future<String?> loadMovies() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_webKey);
      }
      final file = await _getCacheFile();
      if (await file.exists()) {
        return await file
            .readAsString(); // await нужен, чтобы ошибку чтения поймал catch
      }
    } catch (_) {}
    return null;
  }
}
