import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';

class CSVParser {
  Future<List<DiaryEntry>> parseDiaryCSV(File file) async {
    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    if (fields.isEmpty) return [];

    // Header: Date, Name, Year, Letterboxd URI, Rating, Rewatch, Tags, Watched Date
    // Note: Column indices might vary by export version, using common indices
    return fields.skip(1).map((row) {
      return DiaryEntry(
        title: row[1].toString(),
        year: int.tryParse(row[2].toString()) ?? 0,
        watchedDate: _parseDate(row[7].toString().isEmpty ? row[0].toString() : row[7].toString()),
        rating: double.tryParse(row[4].toString()) ?? 0.0,
        isRewatch: row[5].toString().toLowerCase() == 'yes' || row[5].toString().toLowerCase() == 'true',
        letterboxdUri: row[3].toString(),
      );
    }).toList();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}
