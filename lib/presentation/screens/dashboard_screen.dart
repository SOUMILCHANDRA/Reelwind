import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
        title: const Text('WATCH STATS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => statsProvider.importCSV(),
          ),
        ],
      ),
      body: statsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBigHero(watchStats),
                  const SizedBox(height: 40),
                  _buildMiniStats(watchStats, statsProvider.yearComparison),
                  const SizedBox(height: 40),
                  const Text('Rating Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildRatingDistribution(statsProvider.ratingDistribution),
                  const SizedBox(height: 40),
                  const Text('Your Directors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildDirectorList(statsProvider.topDirectors),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildBigHero(WatchStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SCREEN TIME SUMMARY', style: TextStyle(color: Color(0xFF00C030), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
        const SizedBox(height: 8),
        Text(
          '${(stats.totalRuntimeMinutes / 60).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, height: 1),
        ),
        const Text(
          'hours watched',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Text(
          "That's ${(stats.totalRuntimeMinutes / 1440).toStringAsFixed(1)} days of your life spent in the dark.",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMiniStats(WatchStats stats, Map<String, int> comp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MiniStatItem(label: 'TOTAL FILMS', value: stats.totalWatched.toString()),
        _MiniStatItem(label: 'AVG RATING', value: '${stats.averageRating.toStringAsFixed(1)} ★'),
        _MiniStatItem(label: 'THIS YEAR', value: comp['thisYear'].toString()),
        _MiniStatItem(label: 'REWATCHES', value: '124'), // Placeholder, need actual logic
      ],
    );
  }

  Widget _buildRatingDistribution(Map<double, int> dist) {
    final sortedKeys = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
    final maxCount = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 150,
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
                  color: k >= 4.0 ? const Color(0xFF00C030) : Colors.grey[800]!,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text((val / 2).toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDirectorList(Map<String, int> directors) {
    final entries = directors.entries.toList();
    return Column(
      children: entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(child: Text(e.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            Text('${e.value} Films', style: const TextStyle(color: Color(0xFF00C030), fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
