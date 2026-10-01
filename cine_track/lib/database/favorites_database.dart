import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';

class FavoritesDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cine_track.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            overview TEXT,
            poster_path TEXT,
            backdrop_path TEXT,
            vote_average REAL,
            release_date TEXT NOT NULL,
            genre_ids TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insert(Movie movie) async {
    final db = await database;
    await db.insert('favorites', {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate,
      // SQLite не хранит списки — сохраняем жанры строкой «28,878,12»
      'genre_ids': movie.genreIds.join(','),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Movie>> getAll() async {
    final db = await database;
    final maps = await db.query('favorites');
    return maps
        .map(
          (map) => Movie(
            id: map['id'] as int,
            title: map['title'] as String,
            overview: map['overview'] as String?,
            posterPath: map['poster_path'] as String?,
            backdropPath: map['backdrop_path'] as String?,
            voteAverage: (map['vote_average'] as num?)?.toDouble(),
            releaseDate: map['release_date'] as String,
            genreIds: (map['genre_ids'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .map(int.parse)
                .toList(),
          ),
        )
        .toList();
  }
}
