import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../../domain/models.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final years = statsProvider.diary.map((e) => e.watchedDate.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    
    if (_selectedYear == null && years.isNotEmpty) {
      _selectedYear = years.first;
    }

    final yearDiary = statsProvider.diary.where((e) => e.watchedDate.year == _selectedYear).toList();
    final yearStats = statsProvider.calculateStatsFor(yearDiary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTIVITY'),
        actions: [
          if (years.isNotEmpty)
            DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: const Color(0xFF1a1a1a),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
              onChanged: (val) => setState(() => _selectedYear = val),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTapDown: (details) => _handleHeatmapTap(context, details, statsProvider, _selectedYear!),
                child: CustomPaint(
                  size: const Size(53 * 14.0, 7 * 14.0), // 12px + 2px gap
                  painter: GitHubHeatmapPainter(
                    data: statsProvider.watchingFrequency,
                    year: _selectedYear ?? DateTime.now().year,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryRow(yearDiary.length, yearStats.totalRuntimeMinutes),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int count, int minutes) {
    final hours = (minutes / 60).toStringAsFixed(0);
    final avgPerWeek = (count / 52).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '$count films · $hours hours · $avgPerWeek avg per week',
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  void _handleHeatmapTap(BuildContext context, TapDownDetails details, StatsProvider provider, int year) {
    const double cellSize = 12.0;
    const double gap = 2.0;
    const double step = cellSize + gap;

    final int week = (details.localPosition.dx / step).floor();
    final int day = (details.localPosition.dy / step).floor();

    if (week >= 0 && week < 53 && day >= 0 && day < 7) {
      final startDate = DateTime(year, 1, 1);
      // Find the first Sunday (or Monday) of the year to align grid
      final firstDayOfYear = DateTime(year, 1, 1);
      final offset = firstDayOfYear.weekday % 7;
      final tappedDate = startDate.add(Duration(days: (week * 7 + day) - offset));

      if (tappedDate.year == year) {
        _showDayDetails(context, tappedDate, provider);
      }
    }
  }

  void _showDayDetails(BuildContext context, DateTime date, StatsProvider provider) {
    final dayMovies = provider.diary.where((e) {
      return e.watchedDate.year == date.year &&
             e.watchedDate.month == date.month &&
             e.watchedDate.day == date.day;
    }).toList();

    if (dayMovies.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00C030)),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dayMovies.length,
                  itemBuilder: (context, index) {
                    final entry = dayMovies[index];
                    final movie = provider.getMovieMetadata(entry.title, entry.year);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: movie?.posterUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(movie!.posterUrl!, width: 40, height: 60, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.movie, size: 40),
                      title: Text(entry.title),
                      subtitle: Text('${entry.year}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFF00C030), size: 16),
                          const SizedBox(width: 4),
                          Text(entry.rating.toString()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GitHubHeatmapPainter extends CustomPainter {
  final Map<DateTime, int> data;
  final int year;

  GitHubHeatmapPainter({required this.data, required this.year});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const double cellSize = 12.0;
    const double gap = 2.0;

    final firstDayOfYear = DateTime(year, 1, 1);
    final offset = firstDayOfYear.weekday % 7;

    for (int week = 0; week < 53; week++) {
      for (int day = 0; day < 7; day++) {
        final dayIndex = week * 7 + day;
        final date = firstDayOfYear.add(Duration(days: dayIndex - offset));

        if (date.year != year) {
          paint.color = Colors.transparent;
        } else {
          final cleanDate = DateTime(date.year, date.month, date.day);
          final count = data[cleanDate] ?? 0;
          paint.color = _getColorForCount(count);
        }

        final rect = Rect.fromLTWH(
          week * (cellSize + gap),
          day * (cellSize + gap),
          cellSize,
          cellSize,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
      }
    }
  }

  Color _getColorForCount(int count) {
    if (count == 0) return const Color(0xFF1a1a1a);
    if (count == 1) return const Color(0xFF1a6b30);
    if (count == 2) return const Color(0xFF00C030);
    return const Color(0xFF00ff44);
  }

  @override
  bool shouldRepaint(GitHubHeatmapPainter oldDelegate) => oldDelegate.year != year || oldDelegate.data != data;
}
