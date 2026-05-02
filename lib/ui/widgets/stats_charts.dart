import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RatingChart extends StatelessWidget {
  final Map<double, int> data;

  const RatingChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No rating data'));

    final sortedKeys = data.keys.toList()..sort();
    final barGroups = sortedKeys.map((rating) {
      return BarChartGroupData(
        x: (rating * 2).toInt(), // Scale to avoid decimal x-axis issues
        barRods: [
          BarChartRodData(
            toY: data[rating]!.toDouble(),
            color: const Color(0xFF00E054), // Letterboxd Green
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.values.isEmpty ? 10 : data.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  (value / 2).toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
