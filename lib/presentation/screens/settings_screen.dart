import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();

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
            Text('Settings', style: GoogleFonts.newsreader(fontSize: 48, fontWeight: FontWeight.w600)),
            const Text('Manage your cinematic profile and data preferences.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            
            _buildSectionHeader('DATA'),
            const SizedBox(height: 16),
            _buildActionGroup([
              _buildActionTile(Icons.upload_file, 'Import CSV', onTap: () => statsProvider.importCSV()),
              _buildActionTile(Icons.sync, 'Re-sync TMDB', onTap: () {}),
            ]),
            
            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT'),
            const SizedBox(height: 16),
            _buildActionGroup([
              _buildValueTile(Icons.person, 'Username', 'cinephile_92', onEdit: () {}),
              _buildToggleTile(Icons.key, 'TMDB API Key', statsProvider.isApiEnabled, (val) => statsProvider.toggleApi(val)),
            ]),
            
            const SizedBox(height: 32),
            _buildSectionHeader('SHARING'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSquareShareTile(Icons.grid_view, 'Share Heatmap', 'Generate a high-res visual of your frequency.')),
                const SizedBox(width: 16),
                Expanded(child: _buildSquareShareTile(Icons.movie, 'Share Wrapped', 'Your cinematic year in review, optimized for stories.')),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('APP'),
            const SizedBox(height: 16),
            _buildActionGroup([
              _buildValueTile(Icons.dark_mode, 'Appearance', 'Always Dark'),
              _buildValueTile(Icons.info, 'Version', '2.4.0 (Pro)'),
              _buildActionTile(Icons.logout, 'Log Out', color: Colors.red, onTap: () {}),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00C030), letterSpacing: 2));
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

  Widget _buildActionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) Container(height: 1, color: Colors.white.withOpacity(0.05), margin: const EdgeInsets.symmetric(horizontal: 16)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey, size: 20),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 16, color: color ?? Colors.white)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile(IconData icon, String title, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
              Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              child: const Text('Edit', style: TextStyle(color: Color(0xFF00C030), fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00C030),
            activeTrackColor: const Color(0xFF00C030).withOpacity(0.2),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildSquareShareTile(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00C030).withOpacity(0.1)),
            child: Icon(icon, color: const Color(0xFF00C030), size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
