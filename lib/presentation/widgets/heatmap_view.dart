import 'package:flutter/material.dart';

class HeatmapView extends StatelessWidget {
  final Map<DateTime, int> data;

  const HeatmapView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3440),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: HeatmapPainter(data: data),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey)),
              SizedBox(width: 4),
              _HeatBox(level: 0),
              _HeatBox(level: 1),
              _HeatBox(level: 2),
              _HeatBox(level: 3),
              _HeatBox(level: 4),
              SizedBox(width: 4),
              Text('More', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final Map<DateTime, int> data;

  HeatmapPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 182)); // ~26 weeks
    
    const double spacing = 3.0;
    final double cellSize = (size.width - (26 * spacing)) / 26;
    
    final paint = Paint()..style = PaintingStyle.fill;

    for (int week = 0; week < 26; week++) {
      for (int day = 0; day < 7; day++) {
        final date = startDate.add(Duration(days: week * 7 + day));
        final cleanDate = DateTime(date.year, date.month, date.day);
        final count = data[cleanDate] ?? 0;

        paint.color = _getColorForCount(count);
        
        final rect = Rect.fromLTWH(
          week * (cellSize + spacing),
          day * (cellSize + spacing),
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
    if (count == 0) return const Color(0xFF1B2228);
    if (count == 1) return const Color(0xFF004018);
    if (count == 2) return const Color(0xFF006D31);
    if (count == 3) return const Color(0xFF00A647);
    return const Color(0xFF00E054); // Max Letterboxd Green
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) => oldDelegate.data != data;
}

class _HeatBox extends StatelessWidget {
  final int level;
  const _HeatBox({required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF1B2228),
      const Color(0xFF004018),
      const Color(0xFF006D31),
      const Color(0xFF00A647),
      const Color(0xFF00E054),
    ];
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: colors[level],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
