import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/providers/stats_provider.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/heatmap_screen.dart';
import 'presentation/screens/films_screen.dart';
import 'presentation/screens/milestones_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: const ReelwindApp(),
    ),
  );
}

class ReelwindApp extends StatelessWidget {
  const ReelwindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reelwind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C030),
          brightness: Brightness.dark,
          primary: const Color(0xFF00C030),
          secondary: const Color(0xFF00C030),
          surface: const Color(0xFF1a1a1a),
        ),
        scaffoldBackgroundColor: const Color(0xFF0d0d0d),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0d0d0d),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1a1a1a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0d0d0d),
          selectedItemColor: Color(0xFF00C030),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HeatmapScreen(),
    const DashboardScreen(),
    const FilmsScreen(),
    const MilestonesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    
    if (statsProvider.diary.isEmpty && !statsProvider.isLoading) {
      return const OnboardingScreen();
    }

    return Scaffold(
      body: statsProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_outlined), label: 'Films'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Awards'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
