import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';

class HeatmapView extends StatelessWidget {
  final Map<DateTime, int> data;

  const HeatmapView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF2C3440),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('No activity data', style: TextStyle(color: Colors.grey))),
      );
    }

    // Prepare data for fl_heatmap
    // We'll show the last 6 months
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 180));
    
    List<HeatMapItem> items = [];
    for (int i = 0; i <= 180; i++) {
      final date = startDate.add(Duration(days: i));
      final cleanDate = DateTime(date.year, date.month, date.day);
      final count = data[cleanDate] ?? 0;
      
      items.add(HeatMapItem(
        value: count.toDouble(),
        xAxis: (i / 7).floor().toDouble(), // Weeks
        yAxis: (i % 7).toDouble(), // Days
      ));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3440),
        borderRadius: BorderRadius.circular(8),
      ),
      child: HeatMap(
        dataGroups: [
          HeatMapGroup(
            items: items,
            color: const Color(0xFF00E054),
          ),
        ],
        showCellText: false,
        indicatorBuilder: (context, value) {
          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 8));
        },
      ),
    );
  }
}
