import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final facts = statsProvider.streaksAndFacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REELWIND'),
        actions: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Milestones', style: GoogleFonts.newsreader(fontSize: 48, fontWeight: FontWeight.w600)),
            const Text('Your cinematic journey, measured in achievements.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            _buildMilestoneCard(
              icon: '🎬',
              title: 'First Log',
              desc: 'Welcome to the inner circle. You\'ve logged your very first film.',
              isUnlocked: statsProvider.diary.isNotEmpty,
            ),
            _buildMilestoneCard(
              icon: '🔥',
              title: 'Streak Master',
              desc: '7 days of pure cinema. Your commitment to the craft is undeniable.',
              isUnlocked: facts['longestStreak'] >= 7,
            ),
            _buildMilestoneCard(
              icon: '⭐',
              title: 'Century Club',
              desc: 'Almost a centurion. Watch 100 films to join the elite archives.',
              isUnlocked: statsProvider.diary.length >= 100,
              progress: (statsProvider.diary.length / 100).clamp(0.0, 1.0),
              progressText: '${statsProvider.diary.length}/100',
            ),
            _buildMilestoneCard(
              icon: '🎭',
              title: 'Genre Explorer',
              desc: 'Broaden your horizons by watching at least one film from 15 different genres.',
              isUnlocked: statsProvider.topGenres.length >= 15,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fun Stats', style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500)),
                const Text('RANDOM INSIGHTS', style: TextStyle(color: Color(0xFF00C030), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            _buildFunStatsScroll(statsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDurZME-ROXTCUPysygOAd2K6nhk02UlpaxkGcj_4X64PfstilNmCRZ8UgPxZolwihxrn3uoMCdoaA_NUtwJpwV6Hq_xD66ZBiV3eQevIau1N3aUni_1dPEI9A0ySJZP0KbvBtzuEcPk_CHL8f-OIjETVJ6cUqJyug0zhuPENuyU8KE0hveNZTTJGAJaI1QToY9UrNrgF-YbeZx36I6LMJuBBPppZd18FFxgjtIj3BSegQM5QU_axIXTp232v7d-JKrndmIG7xYy7Y'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMilestoneCard({
    required String icon,
    required String title,
    required String desc,
    required bool isUnlocked,
    double? progress,
    String? progressText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? const Color(0xFF00C030).withOpacity(0.2) : Colors.white.withOpacity(0.06)),
        boxShadow: isUnlocked ? [BoxShadow(color: const Color(0xFF00C030).withOpacity(0.05), blurRadius: 20)] : null,
      ),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0A0A0A), border: Border.all(color: isUnlocked ? const Color(0xFF00C030).withOpacity(0.3) : Colors.white.withOpacity(0.05))),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
                      if (progressText != null) 
                        Text(progressText, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))
                      else if (isUnlocked)
                        const Text('UNLOCKED', style: TextStyle(fontSize: 10, color: Color(0xFF00C030), fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  if (progress != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFF0A0A0A), color: const Color(0xFF00C030), minHeight: 4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunStatsScroll(StatsProvider provider) {
    final stats = [
      {'quote': '"You\'ve spent ${(provider.stats.totalRuntimeMinutes * 0.05 / 60).toStringAsFixed(1)} days watching credits roll. Respect the crew."', 'label': 'THE PATIENT OBSERVER'},
      {'quote': '"Average runtime: ${provider.averageRuntime} minutes. You\'re a fan of the slow burn."', 'label': 'DURATIONAL EXPERT'},
      {'quote': '"Midnight is your peak watch time. A true night owl of the screen."', 'label': 'NOCTURNAL VIEWER'},
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final s = stats[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s['quote']!, style: const TextStyle(fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic)),
                Text(s['label']!, style: const TextStyle(color: Color(0xFF00C030), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          );
        },
      ),
    );
  }
}
