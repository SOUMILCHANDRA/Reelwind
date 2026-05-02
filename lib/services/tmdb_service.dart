import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';
import 'database_service.dart';

class TMDBService {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];
  final DatabaseService _db = DatabaseService();

  Future<MovieMetadata?> fetchMovieMetadata(String title, int year) async {
    if (_apiKey == null || _apiKey!.isEmpty) return null;

    // Check cache first
    final cached = await _db.getMetadataByTitle(title, year);
    if (cached != null) return cached;

    try {
      final response = await http.get(Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(title)}&year=$year'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final movieData = data['results'][0];
          final int id = movieData['id'];

          // Fetch full details for genres
          final detailResponse = await http.get(Uri.parse('$_baseUrl/movie/$id?api_key=$_apiKey'));
          
          if (detailResponse.statusCode == 200) {
            final detailData = json.decode(detailResponse.body);
            final metadata = MovieMetadata(
              tmdbId: id,
              title: detailData['title'],
              posterPath: 'https://image.tmdb.org/t/p/w500${detailData['poster_path']}',
              genres: (detailData['genres'] as List)
                  .map((g) => g['name'].toString())
                  .toList(),
              overview: detailData['overview'],
              voteAverage: (detailData['vote_average'] as num).toDouble(),
              releaseDate: detailData['release_date'],
            );

            // Cache it
            await _db.cacheMetadata(metadata);
            return metadata;
          }
        }
      }
    } catch (e) {
      print('TMDB Error: $e');
    }
    return null;
  }
}
