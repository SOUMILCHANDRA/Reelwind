import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/csv_service.dart';
import '../services/tmdb_service.dart';

class StatsProvider with ChangeNotifier {
  final CSVService _csvService = CSVService();
  final TMDBService _tmdbService = TMDBService();

  List<WatchHistoryItem> _history = [];
  bool _isLoading = false;
  bool _isApiEnabled = false;

  List<WatchHistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  bool get isApiEnabled => _isApiEnabled;

  void toggleApi(bool value) {
    _isApiEnabled = value;
    notifyListeners();
  }

  Future<void> importCSV() async {
    _isLoading = true;
    notifyListeners();

    try {
      final entries = await _csvService.pickAndParseCSV();
      _history = entries.map((e) => WatchHistoryItem(entry: e)).toList();
      
      if (_isApiEnabled) {
        await enrichMetadata();
      }
    } catch (e) {
      print('Import error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> enrichMetadata() async {
    for (int i = 0; i < _history.length; i++) {
      if (_history[i].metadata == null) {
        final metadata = await _tmdbService.fetchMovieMetadata(
          _history[i].entry.name,
          _history[i].entry.year,
        );
        if (metadata != null) {
          _history[i] = WatchHistoryItem(entry: _history[i].entry, metadata: metadata);
          notifyListeners(); // Update UI as metadata comes in
        }
      }
    }
  }

  // Analytics Helpers
  Map<DateTime, int> get watchingFrequency {
    Map<DateTime, int> freq = {};
    for (var item in _history) {
      final date = DateTime(item.entry.dateTime.year, item.entry.dateTime.month, item.entry.dateTime.day);
      freq[date] = (freq[date] ?? 0) + 1;
    }
    return freq;
  }

  Map<double, int> get ratingDistribution {
    Map<double, int> dist = {};
    for (var item in _history) {
      if (item.entry.rating != null) {
        dist[item.entry.rating!] = (dist[item.entry.rating!] ?? 0) + 1;
      }
    }
    return dist;
  }

  int get moviesWatchedThisYear {
    final now = DateTime.now();
    return _history.where((e) => e.entry.dateTime.year == now.year).length;
  }

  double get averageRating {
    final ratings = _history.where((e) => e.entry.rating != null).map((e) => e.entry.rating!).toList();
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
