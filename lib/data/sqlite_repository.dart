import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/models.dart';

class SQLiteRepository {
  static final SQLiteRepository _instance = SQLiteRepository._internal();
  factory SQLiteRepository() => _instance;
  SQLiteRepository._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'reelwind_v4.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE movies(title TEXT, year INTEGER, posterUrl TEXT, director TEXT, genres TEXT, runtimeMinutes INTEGER, isLiked INTEGER, watchCount INTEGER, PRIMARY KEY(title, year))',
        );
        await db.execute(
          'CREATE TABLE diary_entries(title TEXT, year INTEGER, watchedDate TEXT, rating REAL, isRewatch INTEGER, letterboxdUri TEXT, review TEXT, isLiked INTEGER)',
        );
        await db.execute(
          'CREATE TABLE cached_stats(key TEXT PRIMARY KEY, totalWatched INTEGER, averageRating REAL, yearDistribution TEXT, genreDistribution TEXT, totalRuntimeMinutes INTEGER)',
        );
      },
    );
  }

  // Movies
  Future<void> saveMovie(Movie movie) async {
    final db = await database;
    await db.insert('movies', movie.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Movie?> getMovie(String title, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movies', where: 'title = ? AND year = ?', whereArgs: [title, year]);
    if (maps.isEmpty) return null;
    return Movie.fromMap(maps.first);
  }

  // Diary Entries
  Future<void> saveDiaryEntries(List<DiaryEntry> entries) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('diary_entries'); // Clear old entries for now
    for (var entry in entries) {
      batch.insert('diary_entries', entry.toMap());
    }
    await batch.commit();
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diary_entries');
    return maps.map((m) => DiaryEntry.fromMap(m)).toList();
  }

  // Stats
  Future<void> saveStats(WatchStats stats) async {
    final db = await database;
    await db.insert('cached_stats', {'key': 'latest', ...stats.toMap()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<WatchStats?> getStats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cached_stats', where: 'key = ?', whereArgs: ['latest']);
    if (maps.isEmpty) return null;
    return WatchStats.fromMap(maps.first);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('movies');
    await db.delete('diary_entries');
    await db.delete('cached_stats');
  }
}
