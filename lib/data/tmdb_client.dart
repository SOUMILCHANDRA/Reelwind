import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/models.dart';

class TMDBClient {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];

  Future<Movie?> fetchMovieDetails(String title, int year) async {
    if (_apiKey == null || _apiKey!.isEmpty) return null;

    try {
      final response = await http.get(Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(title)}&year=$year'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final int id = data['results'][0]['id'];
          return await _fetchFullDetails(id);
        }
      }
    } catch (e) {
      print('TMDB Client Error: $e');
    }
    return null;
  }

  Future<Movie?> _fetchFullDetails(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/$id?api_key=$_apiKey&append_to_response=credits'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      String? director;
      final crew = data['credits']?['crew'] as List?;
      if (crew != null) {
        director = crew.firstWhere((c) => c['job'] == 'Director', orElse: () => {'name': null})['name'];
      }

      return Movie(
        title: data['title'],
        year: DateTime.tryParse(data['release_date'])?.year ?? 0,
        posterUrl: 'https://image.tmdb.org/t/p/w500${data['poster_path']}',
        director: director,
        genres: (data['genres'] as List).map((g) => g['name'].toString()).toList(),
        runtimeMinutes: data['runtime'],
        isLiked: false, // Letterboxd specific, usually not from TMDB search
        watchCount: 1,
      );
    }
    return null;
  }
}
