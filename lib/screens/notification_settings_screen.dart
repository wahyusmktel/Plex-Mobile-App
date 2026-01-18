import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _forumNotifications = true;
  bool _announcementNotifications = true;
  bool _violationNotifications = true;
  bool _newsNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Pengaturan Notifikasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preferensi Pemberitahuan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Atur bagaimana aplikasi memberikan informasi kepada Anda.",
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            _buildToggleItem(
              title: "Semua Notifikasi",
              subtitle: "Aktifkan atau matikan semua pemberitahuan",
              value: _allNotifications,
              onChanged: (v) {
                setState(() {
                  _allNotifications = v;
                  _forumNotifications = v;
                  _announcementNotifications = v;
                  _violationNotifications = v;
                  _newsNotifications = v;
                });
              },
              isMain: true,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildToggleItem(
              title: "Forum Diskusi",
              subtitle: "Notifikasi saat ada balasan atau topik baru",
              value: _forumNotifications,
              onChanged: _allNotifications
                  ? (v) => setState(() => _forumNotifications = v)
                  : null,
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              title: "Pengumuman Sekolah",
              subtitle: "Informasi resmi dari pihak sekolah",
              value: _announcementNotifications,
              onChanged: _allNotifications
                  ? (v) => setState(() => _announcementNotifications = v)
                  : null,
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              title: "Poin Pelanggaran",
              subtitle: "Peringatan saat ada catatan kedisiplinan",
              value: _violationNotifications,
              onChanged: _allNotifications
                  ? (v) => setState(() => _violationNotifications = v)
                  : null,
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              title: "Berita & Artikel",
              subtitle: "Info terbaru seputar literasi dan sekolah",
              value: _newsNotifications,
              onChanged: _allNotifications
                  ? (v) => setState(() => _newsNotifications = v)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isMain = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
                    color: onChanged == null
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
