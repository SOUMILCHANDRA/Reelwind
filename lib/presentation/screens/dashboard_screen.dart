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
        title: const Text('STATISTICS'),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCards(watchStats),
                  const SizedBox(height: 24),
                  _buildYearComparison(statsProvider.yearComparison),
                  const SizedBox(height: 32),
                  const Text('Top Directors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDirectorChart(statsProvider.topDirectors),
                  const SizedBox(height: 32),
                  const Text('Genre Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildGenrePieChart(statsProvider.topGenres),
                  const SizedBox(height: 32),
                  const Text('Rating Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRatingDistribution(statsProvider.ratingDistribution),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCards(WatchStats stats) {
    return Row(
      children: [
        _HeroCard(
          title: 'Films',
          value: stats.totalWatched.toString(),
          color: const Color(0xFF00C030),
        ),
        const SizedBox(width: 12),
        _HeroCard(
          title: 'Hours',
          value: (stats.totalRuntimeMinutes / 60).toStringAsFixed(0),
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _HeroCard(
          title: 'Rating',
          value: stats.averageRating.toStringAsFixed(1),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildYearComparison(Map<String, int> comp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CompItem(label: 'THIS YEAR', value: comp['thisYear']!),
          Container(width: 1, height: 30, color: Colors.grey[800]),
          _CompItem(label: 'LAST YEAR', value: comp['lastYear']!),
        ],
      ),
    );
  }

  Widget _buildDirectorChart(Map<String, int> directors) {
    final entries = directors.entries.toList();
    if (entries.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No data')));

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 100,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Text(
                      entries[index].key,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entries[index].value.toDouble(),
                  color: const Color(0xFF00C030),
                  width: 15,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGenrePieChart(Map<String, int> genres) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    final entries = genres.entries.toList();
    if (entries.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No data')));
    
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: List.generate(entries.length, (index) {
            return PieChartSectionData(
              color: colors[index % colors.length],
              value: entries[index].value.toDouble(),
              title: entries[index].key,
              radius: 50,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(Map<double, int> dist) {
    final sortedKeys = dist.keys.toList()..sort();
    if (sortedKeys.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No data')));

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          barGroups: sortedKeys.map((k) {
            return BarChartGroupData(
              x: (k * 2).toInt(),
              barRods: [
                BarChartRodData(
                  toY: dist[k]!.toDouble(),
                  color: const Color(0xFF00C030),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) => Text((val / 2).toString(), style: const TextStyle(fontSize: 8)),
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
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _HeroCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border(bottom: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CompItem extends StatelessWidget {
  final String label;
  final int value;
  const _CompItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
