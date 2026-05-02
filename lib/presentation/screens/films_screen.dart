import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../../domain/models.dart';

class FilmsScreen extends StatefulWidget {
  const FilmsScreen({super.key});

  @override
  State<FilmsScreen> createState() => _FilmsScreenState();
}

class _FilmsScreenState extends State<FilmsScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All';
  String _sortBy = 'Date watched';

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final filteredFilms = statsProvider.getFilteredFilms(
      query: _searchQuery,
      filter: _activeFilter,
      sortBy: _sortBy,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('FILMS'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search films...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1a1a1a),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Rewatched'),
                    _buildFilterChip('Liked'),
                    _buildFilterChip('No Rating'),
                    const SizedBox(width: 16),
                    _buildSortDropdown(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredFilms.length,
        itemBuilder: (context, index) {
          final entry = filteredFilms[index];
          final movie = statsProvider.getMovieMetadata(entry.title, entry.year);
          return ListTile(
            leading: movie?.posterUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(movie!.posterUrl!, width: 45, height: 70, fit: BoxFit.cover),
                  )
                : const Icon(Icons.movie, size: 40),
            title: Row(
              children: [
                Expanded(child: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (entry.isRewatch)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.refresh, size: 14, color: Colors.blue),
                  ),
              ],
            ),
            subtitle: Text('${entry.year} • Watched on ${_formatDate(entry.watchedDate)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.rating > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFF00C030), size: 16),
                      const SizedBox(width: 4),
                      Text(entry.rating.toString()),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isActive ? Colors.black : Colors.white)),
        selected: isActive,
        onSelected: (selected) {
          if (selected) setState(() => _activeFilter = label);
        },
        selectedColor: const Color(0xFF00C030),
        backgroundColor: const Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      dropdownColor: const Color(0xFF1a1a1a),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
      underline: const SizedBox(),
      items: ['Date watched', 'Title', 'Rating', 'Watch count'].map((String val) {
        return DropdownMenuItem<String>(value: val, child: Text(val));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _sortBy = val);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
