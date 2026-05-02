import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/heatmap_view.dart';
import '../widgets/stats_charts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final watchStats = statsProvider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REELWIND', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, statsProvider),
          ),
        ],
      ),
      body: statsProvider.diary.isEmpty
          ? _buildEmptyState(context, statsProvider)
          : RefreshIndicator(
              onRefresh: () async => await statsProvider.importCSV(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(watchStats),
                    const SizedBox(height: 24),
                    const Text('Activity Heatmap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    HeatmapView(data: statsProvider.watchingFrequency),
                    const SizedBox(height: 24),
                    const Text('Rating Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(height: 200, child: RatingChart(data: statsProvider.ratingDistribution)),
                    const SizedBox(height: 24),
                    const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildRecentActivity(statsProvider),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => statsProvider.importCSV(),
        label: const Text('Import CSV'),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, StatsProvider stats) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No data found.', style: TextStyle(fontSize: 20, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Import your Letterboxd CSV to get started.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => stats.importCSV(),
            child: const Text('Select CSV File'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(dynamic watchStats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SummaryCard(
            title: 'Watched',
            value: watchStats.totalWatched.toString(),
            subtitle: 'Total Films',
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Average',
            value: watchStats.averageRating.toStringAsFixed(1),
            subtitle: 'Rating',
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Time',
            value: (watchStats.totalRuntimeMinutes / 60).toStringAsFixed(0),
            subtitle: 'Hours Spent',
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'This Year',
            value: (watchStats.yearDistribution[DateTime.now().year] ?? 0).toString(),
            subtitle: '${DateTime.now().year} Watches',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(StatsProvider statsProvider) {
    final diary = statsProvider.diary;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: diary.length > 5 ? 5 : diary.length,
      itemBuilder: (context, index) {
        final entry = diary[index];
        final movie = statsProvider.getMovieMetadata(entry.title, entry.year);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.refresh, size: 14, color: Colors.blue),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.year} • Dir. ${movie?.director ?? "Loading..."}'),
                Text(
                  '${_formatDate(entry.watchedDate)} • ${movie?.runtimeMinutes ?? "?"} min',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: entry.rating > 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFF00E054), size: 20),
                      Text(entry.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSettings(BuildContext context, StatsProvider stats) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Enable TMDB API'),
                    subtitle: const Text('Fetch posters and metadata (Requires Key)'),
                    value: stats.isApiEnabled,
                    onChanged: (val) {
                      stats.toggleApi(val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Built with ❤️ for Film Lovers', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _SummaryCard({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
