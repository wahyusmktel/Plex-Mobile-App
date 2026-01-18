import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/notification_helper.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'notification_settings_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final Map<String, dynamic> stats = auth.profileData?['stats'] != null
              ? Map<String, dynamic>.from(auth.profileData!['stats'])
              : {};
          String name = user?.name ?? "User";
          String role = user?.schoolName ?? user?.role ?? "Literasia";

          if (user?.role == 'dinas') {
            name = "Admin Dinas";
            role = "Dinas Pendidikan";
          }

          return RefreshIndicator(
            onRefresh: () => auth.fetchProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ProfileHeader(
                    name: name,
                    role: role,
                    avatarUrl:
                        user?.avatar ??
                        "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&size=256",
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStatsContainer(stats),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildSectionHeader(
                          "Pengaturan Akun",
                          "Kelola akses dan preferensi",
                        ),
                        const SizedBox(height: 15),
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: "Edit Profil",
                          subtitle: "Kelola data diri dan bio",
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: "Notifikasi",
                          subtitle: "Atur pemberitahuan aplikasi",
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.security_rounded,
                          title: "Keamanan",
                          subtitle: "Ubah kata sandi & privasi",
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SecurityScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        _buildSectionHeader(
                          "Informasi Lainnya",
                          "Bantuan dan aplikasi",
                        ),
                        const SizedBox(height: 15),
                        ProfileMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: "Tentang Aplikasi",
                          subtitle: "Versi 1.0.0",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutAppScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: "Keluar",
                          subtitle: "Keluar dari akun Anda",
                          color: AppTheme.error,
                          isDestructive: true,
                          onTap: () => _handleLogout(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsContainer(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
              "Activity",
              stats['activity'] ?? '0%',
              Icons.insights_rounded,
              Colors.blue,
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              "Books",
              stats['books'] ?? '0',
              Icons.book_rounded,
              Colors.orange,
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              "Points",
              stats['points'] ?? '0',
              Icons.star_rounded,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.black.withOpacity(0.06),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
                NotificationHelper.showSuccess(
                  context,
                  "Berhasil keluar. Sampai jumpa lagi!",
                );
              }
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}
