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
    String path = join(await getDatabasesPath(), 'reelwind_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE movies(title TEXT, year INTEGER, posterUrl TEXT, director TEXT, genres TEXT, runtimeMinutes INTEGER, isLiked INTEGER, watchCount INTEGER, PRIMARY KEY(title, year))',
        );
      },
    );
  }

  Future<void> saveMovie(Movie movie) async {
    final db = await database;
    await db.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Movie?> getMovie(String title, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'title = ? AND year = ?',
      whereArgs: [title, year],
    );

    if (maps.isEmpty) return null;
    return Movie.fromMap(maps.first);
  }
}
