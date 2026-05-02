import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';
import '../../domain/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final watchStats = statsProvider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REELWIND'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: () => statsProvider.importCSV(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C030)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBigHero(context, watchStats),
                  const SizedBox(height: 24),
                  _buildMetricsGrid(watchStats, statsProvider.yearComparison),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Rating Distribution', trailing: 'Normal Curve'),
                  const SizedBox(height: 24),
                  _buildRatingDistribution(statsProvider.ratingDistribution),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Your Directors'),
                  const SizedBox(height: 24),
                  _buildDirectorSection(statsProvider.topDirectors),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Top Genres'),
                  const SizedBox(height: 16),
                  _buildGenreSection(statsProvider.topGenres),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
            child: Text(trailing, style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8A))),
          ),
      ],
    );
  }

  Widget _buildBigHero(BuildContext context, WatchStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SCREEN TIME MASTERY', style: TextStyle(color: Color(0xFF00C030), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            '${(stats.totalRuntimeMinutes / 60).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} hours watched',
            style: GoogleFonts.newsreader(fontSize: 48, fontWeight: FontWeight.w900, height: 1, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "that's ${(stats.totalRuntimeMinutes / 1440).toStringAsFixed(1)} days of your life spent in the dark.",
            style: const TextStyle(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(WatchStats stats, Map<String, int> comp) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(label: 'TOTAL FILMS', value: stats.totalWatched.toString()),
        _MetricCard(label: 'AVG RATING', value: stats.averageRating.toStringAsFixed(1), suffix: '★'),
        _MetricCard(label: 'THIS YEAR', value: comp['thisYear'].toString()),
        _MetricCard(label: 'REWATCHES', value: '124'), // Placeholder
      ],
    );
  }

  Widget _buildRatingDistribution(Map<double, int> dist) {
    final sortedKeys = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
    final maxCount = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount.toDouble() * 1.2,
          barGroups: sortedKeys.map((k) {
            final count = dist[k] ?? 0;
            return BarChartGroupData(
              x: (k * 2).toInt(),
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: k >= 4.0 ? const Color(0xFF00C030) : Colors.white.withOpacity(0.05),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) => Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text((val / 2).toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxCount / 3).clamp(1.0, 1000.0),
            getDrawingHorizontalLine: (val) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDirectorSection(Map<String, int> directors) {
    final entries = directors.entries.toList();
    final maxVal = entries.isEmpty ? 1 : entries.first.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: entries.take(5).map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('${e.value} Films', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: e.value / maxVal,
                  backgroundColor: const Color(0xFF1E1E1E),
                  color: const Color(0xFF00C030),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGenreSection(Map<String, int> genres) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.entries.take(8).map((e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: e.value == genres.values.first ? const Color(0xFF00C030) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      )).toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;

  const _MetricCard({required this.label, required this.value, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.star, color: const Color(0xFF00C030), size: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
