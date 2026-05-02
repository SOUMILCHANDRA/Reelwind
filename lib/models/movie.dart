import 'package:intl/intl.dart';

class LetterboxdEntry {
  final String date;
  final String name;
  final int year;
  final String letterboxdUri;
  final double? rating; // Rating out of 5.0

  LetterboxdEntry({
    required this.date,
    required this.name,
    required this.year,
    required this.letterboxdUri,
    this.rating,
  });

  DateTime get dateTime => DateFormat('yyyy-MM-dd').parse(date);

  factory LetterboxdEntry.fromCsv(List<dynamic> row) {
    // Assuming format: Date, Name, Year, Letterboxd URI, Rating (optional)
    return LetterboxdEntry(
      date: row[0].toString(),
      name: row[1].toString(),
      year: int.tryParse(row[2].toString()) ?? 0,
      letterboxdUri: row[3].toString(),
      rating: row.length > 4 ? double.tryParse(row[4].toString()) : null,
    );
  }
}

class MovieMetadata {
  final int tmdbId;
  final String title;
  final String posterPath;
  final List<String> genres;
  final String overview;
  final double voteAverage;
  final String releaseDate;

  MovieMetadata({
    required this.tmdbId,
    required this.title,
    required this.posterPath,
    required this.genres,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'tmdbId': tmdbId,
      'title': title,
      'posterPath': posterPath,
      'genres': genres.join(','),
      'overview': overview,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
    };
  }

  factory MovieMetadata.fromMap(Map<String, dynamic> map) {
    return MovieMetadata(
      tmdbId: map['tmdbId'],
      title: map['title'],
      posterPath: map['posterPath'],
      genres: map['genres'].toString().split(','),
      overview: map['overview'],
      voteAverage: map['voteAverage'],
      releaseDate: map['releaseDate'],
    );
  }
}

class WatchHistoryItem {
  final LetterboxdEntry entry;
  final MovieMetadata? metadata;

  WatchHistoryItem({required this.entry, this.metadata});
}
