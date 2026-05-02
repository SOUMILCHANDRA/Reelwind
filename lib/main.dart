import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/providers/stats_provider.dart';
import 'presentation/screens/dashboard_screen.dart';

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
          seedColor: const Color(0xFFFF8000), // Letterboxd Orange
          brightness: Brightness.dark,
          primary: const Color(0xFFFF8000),
          secondary: const Color(0xFF00E054), // Letterboxd Green
          surface: const Color(0xFF14181C), // Letterboxd Dark Blue/Grey
          background: const Color(0xFF14181C),
        ),
        scaffoldBackgroundColor: const Color(0xFF14181C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B2228),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2C3440),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
