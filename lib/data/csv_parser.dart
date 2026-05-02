import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';

class CSVParser {
  Future<List<DiaryEntry>> parseDiaryCSV(File file) async {
    final fields = await _getFields(file);
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

  Future<List<DiaryEntry>> parseWatchedCSV(File file) async {
    final fields = await _getFields(file);
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

  Future<List<DiaryEntry>> parseRatingsCSV(File file) async {
    final fields = await _getFields(file);
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

  Future<List<List<dynamic>>> _getFields(File file) async {
    final input = file.openRead();
    return await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
  }

  DateTime _parseDate(String dateStr) {
    try {
      // Letterboxd uses YYYY-MM-DD
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}
