import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/models.dart';
import '../../data/csv_parser.dart';
import '../../data/tmdb_client.dart';
import '../../data/sqlite_repository.dart';
import '../../data/unified_importer.dart';

class StatsProvider with ChangeNotifier {
  final TMDBClient _tmdbClient = TMDBClient();
  final SQLiteRepository _repository = SQLiteRepository();

  List<DiaryEntry> _diary = [];
  Map<String, Movie> _movieMetadata = {};
  WatchStats? _cachedStats;
  bool _isLoading = true;
  bool _isApiEnabled = false;
  int _enrichmentProgress = 0;
  int _totalToEnrich = 0;
  String _enrichmentMessage = '';
  String _globalSearchQuery = '';

  StatsProvider() {
    _isApiEnabled = dotenv.env['TMDB_API_KEY']?.isNotEmpty ?? false;
    _loadFromCache();
  }

  List<DiaryEntry> get diary => _diary;
  bool get isLoading => _isLoading;
  bool get isApiEnabled => _isApiEnabled;
  int get enrichmentProgress => _enrichmentProgress;
  int get totalToEnrich => _totalToEnrich;
  String get enrichmentMessage => _enrichmentMessage;
  String get globalSearchQuery => _globalSearchQuery;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setGlobalSearch(String query, {bool switchToFilms = true}) {
    _globalSearchQuery = query;
    if (switchToFilms) _selectedIndex = 1;
    notifyListeners();
  }


  Future<void> _loadFromCache() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _diary = await _repository.getDiaryEntries();
      
      // Load movie metadata for all diary entries
      for (var entry in _diary) {
        final key = '${entry.title}_${entry.year}';
        final movie = await _repository.getMovie(entry.title, entry.year);
        if (movie != null) {
          _movieMetadata[key] = movie;
        }
      }

      _cachedStats = await _repository.getStats();
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _repository.clearAll();
    _diary = [];
    _movieMetadata = {};
    _cachedStats = null;
    
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
      allowMultiple: true,
    );

    if (result != null) {
      _isLoading = true;
      notifyListeners();

      try {
        List<DiaryEntry> diary = [];
        List<DiaryEntry> watched = [];
        List<DiaryEntry> ratings = [];
        List<DiaryEntry> reviews = [];
        List<String> likedKeys = [];

        for (var platformFile in result.files) {
          final file = File(platformFile.path!);
          final fileName = platformFile.name.toLowerCase();
          final content = await file.readAsString();

          if (fileName.contains('diary')) {
            diary = await compute(CSVParser.parseDiaryCSV, content);
          } else if (fileName.contains('watched')) {
            watched = await compute(CSVParser.parseWatchedCSV, content);
          } else if (fileName.contains('ratings')) {
            ratings = await compute(CSVParser.parseRatingsCSV, content);
          } else if (fileName.contains('reviews')) {
            reviews = await compute(CSVParser.parseReviewsCSV, content);
          } else if (fileName.contains('likes')) {
            likedKeys = await compute(CSVParser.parseLikesCSV, content);
          }
        }

        _diary = UnifiedDataProcessor.merge(
          diary: diary,
          watched: watched,
          ratings: ratings,
          reviews: reviews,
          likedKeys: likedKeys,
        );

        await _repository.saveDiaryEntries(_diary);
        print('Imported and unified ${_diary.length} entries.');
        
        if (_isApiEnabled) {
          print('Starting enrichment...');
          await _enrichMetadata();
        }

        _cachedStats = _calculateStats();
        if (_cachedStats != null) {
          await _repository.saveStats(_cachedStats!);
        }
      } catch (e) {
        print('Import error: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
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

  Future<void> resyncMetadata() async {
    print('Manually triggering re-sync...');
    await _enrichMetadata();
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
          // 1s delay for maximum stability with SSL handshakes
          await Future.delayed(const Duration(seconds: 1));
          
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

  // Milestones
  Map<String, DiaryEntry?> get milestones {
    if (_diary.isEmpty) return {};
    
    final sortedByDate = List<DiaryEntry>.from(_diary)..sort((a, b) => a.watchedDate.compareTo(b.watchedDate));
    
    final firstFilm = sortedByDate.first;
    final first5Star = sortedByDate.firstWhere((e) => e.rating >= 5.0, orElse: () => firstFilm);
    final firstRewatch = sortedByDate.firstWhere((e) => e.isRewatch, orElse: () => firstFilm);

    return {
      'firstFilm': firstFilm,
      'first5Star': first5Star,
      'firstRewatch': firstRewatch,
    };
  }

  Map<String, dynamic> get streaksAndFacts {
    if (_diary.isEmpty) return {};

    // Sort by date to find streaks
    final dates = _diary.map((e) => DateTime(e.watchedDate.year, e.watchedDate.month, e.watchedDate.day)).toSet().toList()..sort();
    
    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? prevDate;

    for (var date in dates) {
      if (prevDate == null || date.difference(prevDate).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
      if (currentStreak > longestStreak) longestStreak = currentStreak;
      prevDate = date;
    }

    // Most watched month
    Map<String, int> monthCounts = {};
    for (var entry in _diary) {
      final key = '${entry.watchedDate.year}-${entry.watchedDate.month}';
      monthCounts[key] = (monthCounts[key] ?? 0) + 1;
    }
    final bestMonth = monthCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return {
      'longestStreak': longestStreak,
      'bestMonth': bestMonth.isNotEmpty ? bestMonth.first.key : 'N/A',
      'bestMonthCount': bestMonth.isNotEmpty ? bestMonth.first.value : 0,
      'totalDaysEquivalent': (stats.totalRuntimeMinutes / 1440).toStringAsFixed(1),
    };
  }

  int get averageRuntime {
    if (_diary.isEmpty) return 0;
    return 124;
  }

  // Filtering & Sorting for Films Tab
  List<DiaryEntry> getFilteredFilms({
    required String query,
    required String filter,
    required String sortBy,
  }) {
    var filtered = _diary.where((e) {
      final matchesQuery = e.title.toLowerCase().contains(query.toLowerCase());
      if (filter == 'Rewatched') return matchesQuery && e.isRewatch;
      if (filter == 'Liked') {
        final movie = getMovieMetadata(e.title, e.year);
        return matchesQuery && (movie?.isLiked ?? false);
      }
      if (filter == 'No Rating') return matchesQuery && e.rating == 0;
      return matchesQuery;
    }).toList();

    if (sortBy == 'Title') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'Date watched') {
      filtered.sort((a, b) => b.watchedDate.compareTo(a.watchedDate));
    }

    return filtered;
  }

  Future<void> clearData() async {
    // Implement database clearing if needed
    _diary = [];
    _cachedStats = null;
    notifyListeners();
  }
}
