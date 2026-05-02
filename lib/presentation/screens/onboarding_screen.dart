import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage(
                'Welcome to Reelwind',
                'Your personal cinema dashboard. Track, analyze, and celebrate your movie-watching journey.',
                Icons.movie_filter,
                const Color(0xFF00C030),
              ),
              _buildPage(
                'Get Your Data',
                'Go to Letterboxd Settings → Import & Export → Export Your Data. We use your diary.csv to build your dashboard.',
                Icons.import_export,
                Colors.blue,
              ),
              _buildImportPage(context),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(desc, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildImportPage(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Color(0xFF00C030)),
          const SizedBox(height: 40),
          const Text('Ready to go?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Import your Letterboxd CSV to unlock your personalized dashboard.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              await statsProvider.importCSV();
              if (statsProvider.diary.isNotEmpty) {
                // Navigate to home if import successful
                // We'll handle this in the main build logic
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C030),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('IMPORT & START'),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF00C030) : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
