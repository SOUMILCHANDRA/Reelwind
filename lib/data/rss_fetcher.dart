import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../domain/models.dart';

class RSSFetcher {
  Future<List<DiaryEntry>> fetchLetterboxdRss(String username) async {
    final url = 'https://letterboxd.com/$username/rss/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        return items.map((node) {
          final titleFull = node.getElement('title')?.innerText ?? '';
          // Example Title: "Inception, 2010 - ★★★★"
          // This parsing is rudimentary and depends on RSS format
          return DiaryEntry(
            title: titleFull.split(',')[0],
            year: 0, // Year often needs separate parsing or TMDB lookup
            watchedDate: DateTime.now(), // RSS often has pubDate
            rating: 0.0,
            isRewatch: false,
          );
        }).toList();
      }
    } catch (e) {
      print('RSS Fetch Error: $e');
    }
    return [];
  }
}
