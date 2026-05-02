import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/movie.dart';

class CSVService {
  Future<List<LetterboxdEntry>> pickAndParseCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      // Skip header row
      if (fields.isEmpty) return [];
      
      return fields.skip(1).map((row) => LetterboxdEntry.fromCsv(row)).toList();
    }
    return [];
  }

  // Pre-defined mapping for Letterboxd CSV columns:
  // Date, Name, Year, Letterboxd URI, Rating
  List<LetterboxdEntry> parseRawCSV(String content) {
    final fields = const CsvToListConverter().convert(content);
    if (fields.isEmpty) return [];
    return fields.skip(1).map((row) => LetterboxdEntry.fromCsv(row)).toList();
  }
}
