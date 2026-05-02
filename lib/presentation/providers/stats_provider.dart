import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models.dart';
import '../../data/csv_parser.dart';
import '../../data/tmdb_client.dart';
import '../../data/sqlite_repository.dart';

class StatsProvider with ChangeNotifier {
  final TMDBClient _tmdbClient = TMDBClient();
  final SQLiteRepository _repository = SQLiteRepository();

  List<DiaryEntry> _diary = [];
  Map<String, Movie> _movieMetadata = {};
  WatchStats? _cachedStats;
  bool _isLoading = false;
  bool _isApiEnabled = false;
  int _enrichmentProgress = 0;
  int _totalToEnrich = 0;
  String _enrichmentMessage = '';

  StatsProvider() {
    _loadFromCache();
  }

  List<DiaryEntry> get diary => _diary;
  bool get isLoading => _isLoading;
  bool get isApiEnabled => _isApiEnabled;
  int get enrichmentProgress => _enrichmentProgress;
  int get totalToEnrich => _totalToEnrich;
  String get enrichmentMessage => _enrichmentMessage;

  Future<void> _loadFromCache() async {
    _isLoading = true;
    notifyListeners();
    
    _diary = await _repository.getDiaryEntries();
    _cachedStats = await _repository.getStats();
    
    _isLoading = false;
    notifyListeners();
  }

  void toggleApi(bool value) {
    _isApiEnabled = value;
    notifyListeners();
  }

  Future<void> importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final fileName = platformFile.name.toLowerCase();
        final content = await file.readAsString();

        List<DiaryEntry> newEntries = [];
        if (fileName.contains('diary')) {
          newEntries = await compute(CSVParser.parseDiaryCSV, content);
        } else if (fileName.contains('watched')) {
          newEntries = await compute(CSVParser.parseWatchedCSV, content);
        } else if (fileName.contains('ratings')) {
          newEntries = await compute(CSVParser.parseRatingsCSV, content);
        } else {
          newEntries = await compute(CSVParser.parseDiaryCSV, content);
        }

        _diary = newEntries;
        await _repository.saveDiaryEntries(_diary);
        
        if (_isApiEnabled) {
          await _enrichMetadata();
        }

        // Pre-compute and cache stats
        _cachedStats = _calculateStats();
        if (_cachedStats != null) {
          await _repository.saveStats(_cachedStats!);
        }
      } catch (e) {
        print('Import error: $e');
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  WatchStats _calculateStats() {
    return calculateStatsFor(_diary);
  }

  WatchStats calculateStatsFor(List<DiaryEntry> subset) {
    final total = subset.length;
    final avgRating = total == 0 ? 0.0 : subset.map((e) => e.rating).reduce((a, b) => a + b) / total;
    
    Map<int, int> years = {};
    Map<String, int> genres = {};
    int totalRuntime = 0;

    for (var entry in subset) {
      years[entry.watchedDate.year] = (years[entry.watchedDate.year] ?? 0) + 1;
      
      final movie = getMovieMetadata(entry.title, entry.year);
      if (movie != null) {
        totalRuntime += movie.runtimeMinutes ?? 0;
        for (var genre in movie.genres) {
          genres[genre] = (genres[genre] ?? 0) + 1;
        }
      }
    }

    return WatchStats(
      totalWatched: total,
      averageRating: avgRating,
      yearDistribution: years,
      genreDistribution: genres,
      totalRuntimeMinutes: totalRuntime,
    );
  }

  Future<void> _enrichMetadata() async {
    // Filter for unique title + year combinations to enrich
    final uniqueFilms = <String, DiaryEntry>{};
    for (var entry in _diary) {
      uniqueFilms['${entry.title}_${entry.year}'] = entry;
    }

    _totalToEnrich = uniqueFilms.length;
    _enrichmentProgress = 0;

    for (var entry in uniqueFilms.values) {
      _enrichmentProgress++;
      _enrichmentMessage = 'Enriching $_enrichmentProgress of $_totalToEnrich films...';
      notifyListeners();

      final key = '${entry.title}_${entry.year}';
      if (!_movieMetadata.containsKey(key)) {
        // Check cache
        Movie? movie = await _repository.getMovie(entry.title, entry.year);
        
        if (movie == null) {
          // 200ms delay to avoid rate limits
          await Future.delayed(const Duration(milliseconds: 200));
          
          movie = await _tmdbClient.fetchMovieDetails(entry.title, entry.year);
          if (movie != null) {
            await _repository.saveMovie(movie);
          }
        }

        if (movie != null) {
          _movieMetadata[key] = movie;
          notifyListeners();
        }
      }
    }
    _enrichmentMessage = '';
    notifyListeners();
  }

  Movie? getMovieMetadata(String title, int year) {
    return _movieMetadata['${title}_$year'];
  }

  // Analytics
  WatchStats get stats {
    final total = _diary.length;
    final avgRating = total == 0 ? 0.0 : _diary.map((e) => e.rating).reduce((a, b) => a + b) / total;
    
    Map<int, int> years = {};
    Map<String, int> genres = {};
    int totalRuntime = 0;

    for (var entry in _diary) {
      years[entry.watchedDate.year] = (years[entry.watchedDate.year] ?? 0) + 1;
      
      final movie = getMovieMetadata(entry.title, entry.year);
      if (movie != null) {
        totalRuntime += movie.runtimeMinutes ?? 0;
        for (var genre in movie.genres) {
          genres[genre] = (genres[genre] ?? 0) + 1;
        }
      }
    }

    return WatchStats(
      totalWatched: total,
      averageRating: avgRating,
      yearDistribution: years,
      genreDistribution: genres,
      totalRuntimeMinutes: totalRuntime,
    );
  }

  Map<DateTime, int> get watchingFrequency {
    Map<DateTime, int> freq = {};
    for (var entry in _diary) {
      final date = DateTime(entry.watchedDate.year, entry.watchedDate.month, entry.watchedDate.day);
      freq[date] = (freq[date] ?? 0) + 1;
    }
    return freq;
  }

  Map<double, int> get ratingDistribution {
    Map<double, int> dist = {};
    for (var entry in _diary) {
      if (entry.rating > 0) {
        dist[entry.rating] = (dist[entry.rating] ?? 0) + 1;
      }
    }
    return dist;
  }

  Map<String, int> get topDirectors {
    Map<String, int> directors = {};
    for (var entry in _diary) {
      final movie = getMovieMetadata(entry.title, entry.year);
      if (movie?.director != null) {
        directors[movie!.director!] = (directors[movie.director!] ?? 0) + 1;
      }
    }
    // Sort and take top 8
    final sorted = directors.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(8));
  }

  Map<String, int> get topGenres {
    Map<String, int> genres = {};
    for (var entry in _diary) {
      final movie = getMovieMetadata(entry.title, entry.year);
      if (movie != null) {
        for (var genre in movie.genres) {
          genres[genre] = (genres[genre] ?? 0) + 1;
        }
      }
    }
    // Sort and take top 6
    final sorted = genres.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(6));
  }

  Map<String, int> get yearComparison {
    final now = DateTime.now();
    final thisYear = now.year;
    final lastYear = thisYear - 1;

    int thisYearCount = _diary.where((e) => e.watchedDate.year == thisYear).length;
    int lastYearCount = _diary.where((e) => e.watchedDate.year == lastYear).length;

    return {
      'thisYear': thisYearCount,
      'lastYear': lastYearCount,
    };
  }
}
