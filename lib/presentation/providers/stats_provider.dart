import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models.dart';
import '../../data/csv_parser.dart';
import '../../data/tmdb_client.dart';
import '../../data/sqlite_repository.dart';

class StatsProvider with ChangeNotifier {
  final CSVParser _csvParser = CSVParser();
  final TMDBClient _tmdbClient = TMDBClient();
  final SQLiteRepository _repository = SQLiteRepository();

  List<DiaryEntry> _diary = [];
  Map<String, Movie> _movieMetadata = {};
  bool _isLoading = false;
  bool _isApiEnabled = false;

  List<DiaryEntry> get diary => _diary;
  bool get isLoading => _isLoading;
  bool get isApiEnabled => _isApiEnabled;

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

        List<DiaryEntry> newEntries = [];
        if (fileName.contains('diary')) {
          newEntries = await _csvParser.parseDiaryCSV(file);
        } else if (fileName.contains('watched')) {
          newEntries = await _csvParser.parseWatchedCSV(file);
        } else if (fileName.contains('ratings')) {
          newEntries = await _csvParser.parseRatingsCSV(file);
        } else {
          // Fallback to diary parsing if unknown
          newEntries = await _csvParser.parseDiaryCSV(file);
        }

        // Merge entries if needed, or replace
        // For simplicity, we'll replace for now, but in a real app we might merge
        _diary = newEntries;
        
        if (_isApiEnabled) {
          await _enrichMetadata();
        }
      } catch (e) {
        print('Import error: $e');
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _enrichMetadata() async {
    for (var entry in _diary) {
      final key = '${entry.title}_${entry.year}';
      if (!_movieMetadata.containsKey(key)) {
        // Check cache
        Movie? movie = await _repository.getMovie(entry.title, entry.year);
        
        if (movie == null) {
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
}
