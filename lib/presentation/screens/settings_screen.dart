import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('DATA MANAGEMENT'),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Color(0xFF00C030)),
            title: const Text('Import Letterboxd Data'),
            subtitle: const Text('Upload diary.csv or watched.csv'),
            onTap: () => statsProvider.importCSV(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Local Data'),
            onTap: () => _confirmClear(context, statsProvider),
          ),
          const Divider(height: 32, color: Colors.grey),
          _buildSectionHeader('API CONFIGURATION'),
          SwitchListTile(
            title: const Text('Enable TMDB Enrichment'),
            subtitle: const Text('Fetch posters, directors, and genres'),
            value: statsProvider.isApiEnabled,
            onChanged: (val) => statsProvider.toggleApi(val),
            activeColor: const Color(0xFF00C030),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'TMDB API Key',
                hintText: 'Enter your API key',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Letterboxd Username',
                hintText: 'For RSS features',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(height: 32, color: Colors.grey),
          _buildSectionHeader('ABOUT'),
          const ListTile(
            title: Text('Reelwind v1.0.0'),
            subtitle: Text('Built for film lovers'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {}, // Share stats logic
            icon: const Icon(Icons.share),
            label: const Text('Share My Stats'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C030),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  void _confirmClear(BuildContext context, StatsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Data?'),
        content: const Text('This will remove all imported films from the local database.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              provider.clearData();
              Navigator.pop(context);
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
