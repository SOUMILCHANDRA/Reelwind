import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final milestones = statsProvider.milestones;
    final facts = statsProvider.streaksAndFacts;

    if (milestones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('MILESTONES')),
        body: const Center(child: Text('Import data to see your milestones')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('MILESTONES')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your Firsts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildMilestoneCard('First Film Logged', milestones['firstFilm']?.title ?? 'N/A', milestones['firstFilm']?.watchedDate),
          _buildMilestoneCard('First 5-Star Rating', milestones['first5Star']?.title ?? 'N/A', milestones['first5Star']?.watchedDate),
          _buildMilestoneCard('First Rewatch', milestones['firstRewatch']?.title ?? 'N/A', milestones['firstRewatch']?.watchedDate),
          const SizedBox(height: 32),
          const Text('Streaks & Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFactCard('Longest Streak', '${facts['longestStreak']} days', Icons.fireplace, Colors.orange),
          _buildFactCard('Most Watched Month', '${facts['bestMonth']} (${facts['bestMonthCount']} films)', Icons.calendar_month, Colors.blue),
          _buildFactCard('Time Spent', '${facts['totalDaysEquivalent']} days of film', Icons.timer, Colors.green),
          const SizedBox(height: 32),
          const Text('Fun Facts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFactCard('Cinematic Life', 'You have watched ${statsProvider.diary.length} unique film sessions', Icons.movie, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(String title, String film, DateTime? date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(film, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            if (date != null)
              Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFactCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
