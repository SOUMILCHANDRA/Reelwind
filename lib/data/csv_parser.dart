import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';

class CSVParser {
  static List<DiaryEntry> parseDiaryCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];

    final Set<String> seen = {};
    final List<DiaryEntry> entries = [];

    for (final row in fields.skip(1)) {
      if (row.length < 6) continue;

      final title = row[1].toString();
      final year = int.tryParse(row[2].toString()) ?? 0;
      final watchedDateStr = row[7].toString().isEmpty ? row[0].toString() : row[7].toString();
      final watchedDate = _parseDate(watchedDateStr);
      
      final key = '$title|$year|${watchedDate.toIso8601String().split('T')[0]}';
      if (seen.contains(key)) continue;
      seen.add(key);

      entries.add(DiaryEntry(
        title: title,
        year: year,
        watchedDate: watchedDate,
        rating: double.tryParse(row[4].toString()) ?? 0.0,
        isRewatch: row[5].toString().toLowerCase() == 'yes',
        letterboxdUri: row[3].toString(),
      ));
    }
    return entries;
  }

  static List<DiaryEntry> parseWatchedCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];

    return fields.skip(1).map((row) {
      return DiaryEntry(
        title: row[1].toString(),
        year: int.tryParse(row[2].toString()) ?? 0,
        watchedDate: _parseDate(row[0].toString()),
        rating: 0.0,
        isRewatch: false,
        letterboxdUri: row[3].toString(),
      );
    }).toList();
  }

  static List<DiaryEntry> parseRatingsCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];

    return fields.skip(1).map((row) {
      return DiaryEntry(
        title: row[1].toString(),
        year: int.tryParse(row[2].toString()) ?? 0,
        watchedDate: _parseDate(row[0].toString()),
        rating: double.tryParse(row[4].toString()) ?? 0.0,
        isRewatch: false,
        letterboxdUri: row[3].toString(),
      );
    }).toList();
  }

  static List<DiaryEntry> parseReviewsCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];

    return fields.skip(1).map((row) {
      return DiaryEntry(
        title: row[1].toString(),
        year: int.tryParse(row[2].toString()) ?? 0,
        watchedDate: _parseDate(row[0].toString()),
        rating: double.tryParse(row[4].toString()) ?? 0.0,
        isRewatch: false,
        review: row[3].toString(),
        letterboxdUri: row[5].toString(),
      );
    }).toList();
  }

  static List<String> parseLikesCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];
    return fields.skip(1).map((row) => '${row[1]}_${row[2]}').toList();
  }

  static List<DiaryEntry> parseWatchlistCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];

    return fields.skip(1).map((row) {
      return DiaryEntry(
        title: row[1].toString(),
        year: int.tryParse(row[2].toString()) ?? 0,
        watchedDate: _parseDate(row[0].toString()),
        rating: 0.0,
        isRewatch: false,
        letterboxdUri: row[3].toString(),
      );
    }).toList();
  }

  static DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}
