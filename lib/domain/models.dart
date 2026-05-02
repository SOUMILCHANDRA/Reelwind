class DiaryEntry {
  final String title;
  final int year;
  final DateTime watchedDate;
  final double rating; // 0.5 to 5.0
  final bool isRewatch;
  final String? letterboxdUri;

  DiaryEntry({
    required this.title,
    required this.year,
    required this.watchedDate,
    required this.rating,
    required this.isRewatch,
    this.letterboxdUri,
  });
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

  WatchStats({
    required this.totalWatched,
    required this.averageRating,
    required this.yearDistribution,
    required this.genreDistribution,
  });
}
