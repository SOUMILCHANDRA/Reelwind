import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
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

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
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
          secondary: const Color(0xFFe4c53d),
          surface: const Color(0xFF121414),
          surfaceContainer: const Color(0xFF141414),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF00C030),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.newsreader(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
          headlineMedium: GoogleFonts.newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          headlineSmall: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF141414),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white10, width: 0.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F0F0F),
          selectedItemColor: Color(0xFF00C030),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: -0.5),
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
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C030)))
        : IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), 
              activeIcon: Icon(Icons.grid_view, fill: 1),
              label: 'HEATMAP',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), 
              activeIcon: Icon(Icons.bar_chart, fill: 1),
              label: 'STATS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_outlined), 
              activeIcon: Icon(Icons.movie, fill: 1),
              label: 'FILMS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined), 
              activeIcon: Icon(Icons.emoji_events, fill: 1),
              label: 'MILESTONES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), 
              activeIcon: Icon(Icons.settings, fill: 1),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}
