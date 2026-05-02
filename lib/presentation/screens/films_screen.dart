import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';
import '../../domain/models.dart';

class FilmsScreen extends StatefulWidget {
  const FilmsScreen({super.key});

  @override
  State<FilmsScreen> createState() => _FilmsScreenState();
}

class _FilmsScreenState extends State<FilmsScreen> {
  String _searchQuery = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final filteredFilms = statsProvider.diary.where((film) {
      final matchesSearch = film.title.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_filter == 'All') return matchesSearch;
      if (_filter == 'Loved') return matchesSearch && film.rating >= 4.5;
      if (_filter == 'Rewatched') return matchesSearch && film.isRewatch;
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('REELWIND'),
        actions: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredFilms.length,
              itemBuilder: (context, index) {
                final film = filteredFilms[index];
                final movie = statsProvider.getMovieMetadata(film.title, film.year);
                return _buildFilmCard(film, movie);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDurZME-ROXTCUPysygOAd2K6nhk02UlpaxkGcj_4X64PfstilNmCRZ8UgPxZolwihxrn3uoMCdoaA_NUtwJpwV6Hq_xD66ZBiV3eQevIau1N3aUni_1dPEI9A0ySJZP0KbvBtzuEcPk_CHL8f-OIjETVJ6cUqJyug0zhuPENuyU8KE0hveNZTTJGAJaI1QToY9UrNrgF-YbeZx36I6LMJuBBPppZd18FFxgjtIj3BSegQM5QU_axIXTp232v7d-JKrndmIG7xYy7Y'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search your films...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF0A0A0A),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E1E1E))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E1E1E))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00C030))),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Rewatched', 'Loved', 'Unrated'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filter == filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00C030) : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(filter, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilmCard(DiaryEntry film, Movie? movie) {
    final isLoved = film.rating >= 4.5;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: isLoved ? const Color(0xFF00C030) : Colors.transparent, width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[800],
              image: movie?.posterUrl != null ? DecorationImage(image: NetworkImage(movie!.posterUrl!), fit: BoxFit.cover) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(film.title, style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${film.year} • ${movie?.director ?? 'Unknown'}', style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(5, (i) {
              final starValue = i + 1;
              if (film.rating >= starValue) {
                return const Icon(Icons.star, color: Color(0xFFe4c53d), size: 16);
              } else if (film.rating >= starValue - 0.5) {
                return const Icon(Icons.star_half, color: Color(0xFFe4c53d), size: 16);
              } else {
                return const Icon(Icons.star_border, color: Colors.white12, size: 16);
              }
            }),
          ),
        ],
      ),
    );
  }
}
