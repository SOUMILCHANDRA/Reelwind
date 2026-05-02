import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/models.dart';

class TMDBClient {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String? _accessToken = dotenv.env['TMDB_ACCESS_TOKEN'];
  
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'User-Agent': 'Reelwind/1.0.0 (Flutter; Windows)',
    'Accept': 'application/json',
    'Authorization': 'Bearer $_accessToken',
  };

  Future<Movie?> fetchMovieDetails(String title, int year) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      print('TMDB Error: Access Token missing in .env');
      return null;
    }

    int retries = 3;
    while (retries > 0) {
      try {
        final url = '$_baseUrl/search/movie?query=${Uri.encodeComponent(title)}&year=$year';
        print('Searching TMDB: $title ($year)...');
        final response = await _client.get(Uri.parse(url), headers: _headers);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'].isNotEmpty) {
            final int id = data['results'][0]['id'];
            return await _fetchFullDetails(id);
          }
          return null;
        } else if (response.statusCode == 401) {
          print('TMDB Error: Invalid Access Token (401)');
          return null;
        } else if (response.statusCode == 429) {
          final retryAfter = int.tryParse(response.headers['retry-after'] ?? '2') ?? 2;
          print('Rate limited! Waiting $retryAfter seconds...');
          await Future.delayed(Duration(seconds: retryAfter));
          retries--;
          continue;
        } else {
          print('TMDB Search Error: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        if (e.toString().contains('HandshakeException')) {
          print('SSL Handshake Error, retrying... ($retries left)');
          await Future.delayed(const Duration(seconds: 2));
          retries--;
        } else {
          print('TMDB Network Error: $e');
          return null;
        }
      }
    }
    return null;
  }

  Future<Movie?> _fetchFullDetails(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/movie/$id?append_to_response=credits'),
        headers: _headers,
      );
      
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
          posterUrl: data['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${data['poster_path']}' : null,
          director: director,
          genres: (data['genres'] as List).map((g) => g['name'].toString()).toList(),
          runtimeMinutes: data['runtime'],
          isLiked: false,
          watchCount: 1,
        );
      }
    } catch (e) {
      print('Fetch Details Error: $e');
    }
    return null;
  }
}
