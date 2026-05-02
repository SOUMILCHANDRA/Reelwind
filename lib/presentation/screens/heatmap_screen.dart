import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(),
            const SizedBox(height: 24),
            _buildHeatmapCard(statsProvider, years),
            const SizedBox(height: 32),
            _buildOnThisDayHeader(),
            const SizedBox(height: 16),
            _buildHorizontalFilmGallery(statsProvider),
            const SizedBox(height: 32),
            _buildStreakBadge(statsProvider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WELCOME BACK', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Hey, Cinephile', style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
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

  Widget _buildHeatmapCard(StatsProvider provider, List<int> years) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view, color: Color(0xFF00C030), size: 20),
                  const SizedBox(width: 8),
                  Text('Watching History', style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Text(_selectedYear.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const Icon(Icons.expand_more, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: GestureDetector(
              onTapDown: (details) => _handleHeatmapTap(context, details, provider, _selectedYear!),
              child: CustomPaint(
                size: const Size(53 * 14.0, 7 * 14.0),
                painter: GitHubHeatmapPainter(
                  data: provider.watchingFrequency,
                  year: _selectedYear ?? DateTime.now().year,
                  focusedDate: _focusedDate,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeatmapLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('LESS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        ...[0, 1, 2, 3, 4].map((i) => Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: _getColorForLegend(i),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        const SizedBox(width: 8),
        const Text('MORE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getColorForLegend(int i) {
    if (i == 0) return const Color(0xFF1A1A1A);
    if (i == 1) return const Color(0xFF1A6B30);
    if (i == 2) return const Color(0xFF00C030);
    return const Color(0xFF00ff44);
  }

  Widget _buildOnThisDayHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.event_repeat, color: Color(0xFF00C030), size: 20),
          const SizedBox(width: 8),
          Text('On this day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHorizontalFilmGallery(StatsProvider provider) {
    final dayMovies = provider.diary.where((e) {
      return e.watchedDate.year == _focusedDate.year &&
             e.watchedDate.month == _focusedDate.month &&
             e.watchedDate.day == _focusedDate.day;
    }).toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dayMovies.isEmpty ? 5 : dayMovies.length,
        itemBuilder: (context, index) {
          if (dayMovies.isEmpty) {
            return Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(6)),
              child: const Center(child: Icon(Icons.movie_outlined, color: Colors.white10)),
            );
          }
          final entry = dayMovies[index];
          final movie = provider.getMovieMetadata(entry.title, entry.year);
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: movie?.posterUrl != null
                        ? DecorationImage(image: NetworkImage(movie!.posterUrl!), fit: BoxFit.cover)
                        : null,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakBadge(StatsProvider provider) {
    final facts = provider.streaksAndFacts;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF141414), Color(0xFF1E1E1E)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C030).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3b3000)),
            child: const Icon(Icons.emoji_events, color: Color(0xFFFFFFFF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your longest streak', style: TextStyle(color: Color(0xFFe4c53d), fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Keep it up, you\'re on fire!', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${facts['longestStreak']}', style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFFe4c53d))),
              const Text('DAYS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFe4c53d))),
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

        if (date.year != year) continue;
        
        final cleanDate = DateTime(date.year, date.month, date.day);
        final count = data[cleanDate] ?? 0;
        
        final isFocused = cleanDate.year == focusedDate.year && 
                          cleanDate.month == focusedDate.month && 
                          cleanDate.day == focusedDate.day;

        paint.color = _getColorForCount(count);
        
        final rect = Rect.fromLTWH(
          week * (cellSize + gap),
          day * (cellSize + gap),
          cellSize,
          cellSize,
        );

        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
        
        if (isFocused) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.inflate(1), const Radius.circular(3)),
            Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1
          );
        }
      }
    }
  }

  Color _getColorForCount(int count) {
    if (count == 0) return const Color(0xFF1A1A1A);
    if (count == 1) return const Color(0xFF1A6B30);
    if (count == 2) return const Color(0xFF00C030);
    return const Color(0xFF00ff44);
  }

  @override
  bool shouldRepaint(GitHubHeatmapPainter oldDelegate) => true;
}
