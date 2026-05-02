class DiaryEntry {
  final String title;
  final int year;
  final DateTime watchedDate;
  final double rating; // 0.5 to 5.0
  final bool isRewatch;
  final String? letterboxdUri;

  final String? review;
  bool isLiked;

  DiaryEntry({
    required this.title,
    required this.year,
    required this.watchedDate,
    required this.rating,
    required this.isRewatch,
    this.letterboxdUri,
    this.review,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'watchedDate': watchedDate.toIso8601String(),
      'rating': rating,
      'isRewatch': isRewatch ? 1 : 0,
      'letterboxdUri': letterboxdUri,
      'review': review,
      'isLiked': isLiked ? 1 : 0,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      title: map['title'],
      year: map['year'],
      watchedDate: DateTime.parse(map['watchedDate']),
      rating: map['rating'],
      isRewatch: map['isRewatch'] == 1,
      letterboxdUri: map['letterboxdUri'],
      review: map['review'],
      isLiked: map['isLiked'] == 1,
    );
  }
}

class Movie {
  final String title;
  final int year;
  final String? posterUrl;
  final String? director;
  final List<String> genres;
  final int? runtimeMinutes;
  final bool isLiked;
  final int watchCount;

  Movie({
    required this.title,
    required this.year,
    this.posterUrl,
    this.director,
    required this.genres,
    this.runtimeMinutes,
    required this.isLiked,
    required this.watchCount,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'],
      year: map['year'],
      posterUrl: map['posterUrl'],
      director: map['director'],
      genres: map['genres'].toString().split(','),
      runtimeMinutes: map['runtimeMinutes'],
      isLiked: map['isLiked'] == 1,
      watchCount: map['watchCount'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'posterUrl': posterUrl,
      'director': director,
      'genres': genres.join(','),
      'runtimeMinutes': runtimeMinutes,
      'isLiked': isLiked ? 1 : 0,
      'watchCount': watchCount,
    };
  }
}

class Director {
  final String name;
  final String? bio;
  final String? profileUrl;

  Director({required this.name, this.bio, this.profileUrl});
}

class WatchStats {
  final int totalWatched;
  final double averageRating;
  final Map<int, int> yearDistribution;
  final Map<String, int> genreDistribution;

  final int totalRuntimeMinutes;
  final Map<String, int> directorCounts;
  final Map<double, int> ratingCounts;

  WatchStats({
    required this.totalWatched,
    required this.averageRating,
    required this.yearDistribution,
    required this.genreDistribution,
    required this.totalRuntimeMinutes,
    this.directorCounts = const {},
    this.ratingCounts = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'totalWatched': totalWatched,
      'averageRating': averageRating,
      'yearDistribution': yearDistribution.entries.map((e) => '${e.key}:${e.value}').join(','),
      'genreDistribution': genreDistribution.entries.map((e) => '${e.key}:${e.value}').join(','),
      'totalRuntimeMinutes': totalRuntimeMinutes,
    };
  }

  factory WatchStats.fromMap(Map<String, dynamic> map) {
    return WatchStats(
      totalWatched: map['totalWatched'],
      averageRating: map['averageRating'],
      yearDistribution: _parseMap(map['yearDistribution']),
      genreDistribution: _parseMapString(map['genreDistribution']),
      totalRuntimeMinutes: map['totalRuntimeMinutes'] ?? 0,
    );
  }

  static Map<int, int> _parseMap(String str) {
    if (str.isEmpty) return {};
    return Map.fromEntries(str.split(',').map((s) {
      final parts = s.split(':');
      return MapEntry(int.parse(parts[0]), int.parse(parts[1]));
    }));
  }

  static Map<String, int> _parseMapString(String str) {
    if (str.isEmpty) return {};
    return Map.fromEntries(str.split(',').map((s) {
      final parts = s.split(':');
      return MapEntry(parts[0], int.parse(parts[1]));
    }));
  }
}
