import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                boxShadow: AppTheme.primaryShadow,
              ),
              child: Image.asset(
                'assets/logo-nobg.png', // Updated logo path
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.auto_stories_rounded,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Literasia Edutekno Digital",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              "Versi 1.0.0",
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 40),
            const Text(
              "Literasia adalah platform pendidikan digital terintegrasi yang dirancang untuk mendukung ekosistem belajar mengajar di sekolah. Kami menggabungkan kemudahan akses E-Learning, E-Library, dan Sistem Informasi Sekolah dalam satu aplikasi yang modern dan intuitif.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            _buildInfoCard(
              title: "Misi Kami",
              desc:
                  "Menciptakan lingkungan literasi digital yang inklusif dan mempermudah interaksi antara siswa, guru, dan pengelola sekolah.",
              icon: Icons.lightbulb_outline_rounded,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Pengembang",
              desc:
                  "Dikembangkan dengan dedikasi penuh untuk kemajuan pendidikan Indonesia.",
              icon: Icons.code_rounded,
            ),
            const SizedBox(height: 48),
            const Text(
              "© 2026 Literasia Team. All rights reserved.",
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
