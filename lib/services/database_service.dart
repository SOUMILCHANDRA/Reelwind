import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'reelwind_cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE movie_metadata(tmdbId INTEGER PRIMARY KEY, title TEXT, posterPath TEXT, genres TEXT, overview TEXT, voteAverage REAL, releaseDate TEXT)',
        );
      },
    );
  }

  Future<void> cacheMetadata(MovieMetadata metadata) async {
    final db = await database;
    await db.insert(
      'movie_metadata',
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MovieMetadata?> getMetadata(int tmdbId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movie_metadata',
      where: 'tmdbId = ?',
      whereArgs: [tmdbId],
    );

    if (maps.isEmpty) return null;
    return MovieMetadata.fromMap(maps.first);
  }

  Future<MovieMetadata?> getMetadataByTitle(String title, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movie_metadata',
      where: 'title = ? AND releaseDate LIKE ?',
      whereArgs: [title, '$year%'],
    );

    if (maps.isEmpty) return null;
    return MovieMetadata.fromMap(maps.first);
  }
}
