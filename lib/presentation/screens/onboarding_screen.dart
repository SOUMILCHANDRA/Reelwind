import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF121414)],
          ),
        ),
        child: Stack(
          children: [
            // Background Image Overlay (Subtle)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCf2L_Hjh1cNWdLyuSMgjb55UU3KKkGWADSxCTpz50K-rx-JYHcy-oHrlDhRBCFryzR-kLP93Xx3K7OVnYCxNa2X7d4mdegEbuleeD0gRjf40jBUgWTFcLpSJdm1rdpSIKTqBCxv9fC-7mRhOCc3PXOJF1YcUxk3DiBwWBG10f6vvZJUETSlvml0ki3mVwttLZ_kEsjmm97-WYGmSJ7aeuN99kYRq2K02jJ29XMhHBTQYBYtNKXoPsU2SLX436i2MzDEcUYc8Z0mrU',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            PageView(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildSlide1(),
                _buildSlide2(),
                _buildSlide3(context),
              ],
            ),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF00C030).withOpacity(0.1), blurRadius: 100)],
              ),
            ),
            const Icon(Icons.movie, size: 120, color: Color(0xFF00C030)),
          ],
        ),
        const SizedBox(height: 40),
        Text('Your cinema, quantified.', style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Connect your Letterboxd and dive deep into your watch history',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 80),
        _buildActionButton('Get Started', () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
      ],
    );
  }

  Widget _buildSlide2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.import_export, size: 120, color: Color(0xFF00C030)),
        const SizedBox(height: 40),
        Text('Get Your Data', style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Go to Letterboxd Settings → Import & Export → Export Your Data. We use your diary.csv to build your dashboard.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 80),
        _buildActionButton('Next Step', () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
      ],
    );
  }

  Widget _buildSlide3(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 120, color: Color(0xFF00C030)),
        const SizedBox(height: 40),
        Text('Ready to go?', style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Import your Letterboxd CSV to unlock your personalized dashboard.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 80),
        _buildActionButton('IMPORT & START', () => context.read<StatsProvider>().importCSV()),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C030),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 10,
          shadowColor: const Color(0xFF00C030).withOpacity(0.5),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildPagination() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) => Container(
          width: _currentPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentPage == index ? const Color(0xFF00C030) : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    );
  }
}
