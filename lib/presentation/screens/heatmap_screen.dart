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
  DateTime _focusedDate = DateTime.now();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('REELWIND'),
        leading: const Icon(Icons.menu),
        actions: [
          if (years.isNotEmpty)
            DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: const Color(0xFF1a1a1a),
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
              onChanged: (val) => setState(() => _selectedYear = val),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Watching History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_selectedYear.toString(), style: const TextStyle(color: Color(0xFF00C030), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTapDown: (details) => _handleHeatmapTap(context, details, statsProvider, _selectedYear!),
                child: CustomPaint(
                  size: const Size(53 * 14.0, 7 * 14.0),
                  painter: GitHubHeatmapPainter(
                    data: statsProvider.watchingFrequency,
                    year: _selectedYear ?? DateTime.now().year,
                    focusedDate: _focusedDate,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildOnThisDaySection(statsProvider),
            const SizedBox(height: 32),
            _buildStreakCard(statsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildOnThisDaySection(StatsProvider provider) {
    final dayMovies = provider.diary.where((e) {
      return e.watchedDate.year == _focusedDate.year &&
             e.watchedDate.month == _focusedDate.month &&
             e.watchedDate.day == _focusedDate.day;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'On this day',
                style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dayMovies.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1a1a1a), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('No films watched on this day', style: TextStyle(color: Colors.grey))),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dayMovies.length,
                itemBuilder: (context, index) {
                  final entry = dayMovies[index];
                  final movie = provider.getMovieMetadata(entry.title, entry.year);
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: movie?.posterUrl != null
                                ? Image.network(movie!.posterUrl!, fit: BoxFit.cover, width: double.infinity)
                                : Container(color: Colors.grey[900], child: const Icon(Icons.movie)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 10, color: Color(0xFF00C030)),
                            const SizedBox(width: 4),
                            Text(entry.rating.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(StatsProvider provider) {
    final facts = provider.streaksAndFacts;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1a1a1a), Colors.grey[900]!]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your longest streak', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('Keep it up, you\'re on fire!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${facts['longestStreak']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00C030))),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('DAYS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ],
          ),
        ],
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
      final firstDayOfYear = DateTime(year, 1, 1);
      final offset = firstDayOfYear.weekday % 7;
      final tappedDate = startDate.add(Duration(days: (week * 7 + day) - offset));

      if (tappedDate.year == year) {
        setState(() {
          _focusedDate = tappedDate;
        });
      }
    }
  }
}

class GitHubHeatmapPainter extends CustomPainter {
  final Map<DateTime, int> data;
  final int year;
  final DateTime focusedDate;

  GitHubHeatmapPainter({required this.data, required this.year, required this.focusedDate});

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
          
          final isFocused = cleanDate.year == focusedDate.year && 
                            cleanDate.month == focusedDate.month && 
                            cleanDate.day == focusedDate.day;

          paint.color = _getColorForCount(count);
          
          if (isFocused) {
            paint.strokeWidth = 2;
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromLTWH(
              week * (cellSize + gap) - 1,
              day * (cellSize + gap) - 1,
              cellSize + 2,
              cellSize + 2,
            );
            canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1);
            paint.style = PaintingStyle.fill;
          }
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
  bool shouldRepaint(GitHubHeatmapPainter oldDelegate) => 
    oldDelegate.year != year || oldDelegate.data != data || oldDelegate.focusedDate != focusedDate;
}
