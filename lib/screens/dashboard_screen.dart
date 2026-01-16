import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_image_slider.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_menu_item.dart';
import '../widgets/today_schedule_widget.dart';
import 'profile_screen.dart';
import 'attendance_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).getDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHome(),
          _buildPlaceholder("Halaman Belajar"),
          _buildPlaceholder("Halaman Notifikasi"),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildAnimatedNavBar(),
    );
  }

  Widget _buildHome() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final stats = auth.dashboardStats;
        final isDinas = user?.role == 'dinas';

        return Column(
          children: [
            DashboardHeader(
              userName: user?.name ?? "User",
              schoolName: user?.schoolName ?? user?.role ?? "Literasia",
              onProfileTap: () => setState(() => _selectedIndex = 3),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 5),
                  AppImageSlider(sliders: auth.sliders),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Transform.translate(
                          offset: const Offset(0, -35),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: stats.isEmpty
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Row(
                                      children: List.generate(
                                        4,
                                        (index) => const StatSkeleton(),
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: isDinas
                                        ? [
                                            StatCard(
                                              title: "Total Sekolah",
                                              value:
                                                  "${stats['total_sekolah'] ?? 0}",
                                              icon: Icons.school_rounded,
                                              color: Colors.blue,
                                            ),
                                            StatCard(
                                              title: "Menunggu",
                                              value:
                                                  "${stats['menunggu_persetujuan'] ?? 0}",
                                              icon:
                                                  Icons.pending_actions_rounded,
                                              color: Colors.orange,
                                            ),
                                            StatCard(
                                              title: "Sekolah Aktif",
                                              value:
                                                  "${stats['sekolah_aktif'] ?? 0}",
                                              icon: Icons.check_circle_rounded,
                                              color: Colors.green,
                                            ),
                                            StatCard(
                                              title: "Total Siswa",
                                              value:
                                                  "${stats['total_siswa_nasional'] ?? 0}",
                                              icon: Icons.groups_rounded,
                                              color: Colors.purple,
                                            ),
                                          ]
                                        : [
                                            StatCard(
                                              title: "Total Siswa",
                                              value:
                                                  "${stats['total_siswa'] ?? 0}",
                                              icon: Icons.groups_rounded,
                                              color: Colors.blue,
                                            ),
                                            StatCard(
                                              title: "Total Guru",
                                              value:
                                                  "${stats['total_guru'] ?? 0}",
                                              icon: Icons.person_rounded,
                                              color: Colors.orange,
                                            ),
                                            StatCard(
                                              title: "Total Kelas",
                                              value:
                                                  "${stats['total_kelas'] ?? 0}",
                                              icon:
                                                  Icons.door_front_door_rounded,
                                              color: Colors.green,
                                            ),
                                            StatCard(
                                              title: "Total Buku",
                                              value:
                                                  "${stats['total_buku'] ?? 0}",
                                              icon: Icons.menu_book_rounded,
                                              color: Colors.purple,
                                            ),
                                          ],
                                  ),
                          ),
                        ),
                        const Text(
                          "Menu Utama",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.8,
                          children: [
                            ActionMenuItem(
                              icon: user?.role == 'siswa'
                                  ? Icons.how_to_reg_rounded
                                  : Icons.face,
                              label: user?.role == 'siswa'
                                  ? "Absensi"
                                  : "Siswa",
                              color: Colors.blue,
                              onTap: () {
                                if (user?.role == 'siswa') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AttendanceScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                            ActionMenuItem(
                              icon: Icons.co_present,
                              label: "Guru",
                              color: Colors.orange,
                              onTap: () {},
                            ),
                            ActionMenuItem(
                              icon: Icons.calendar_today_rounded,
                              label: "Jadwal",
                              color: Colors.red,
                              onTap: () {},
                            ),
                            ActionMenuItem(
                              icon: Icons.score_rounded,
                              label: "Nilai",
                              color: Colors.green,
                              onTap: () {},
                            ),
                            ActionMenuItem(
                              icon: Icons.local_library_rounded,
                              label: "Perpus",
                              color: Colors.purple,
                              onTap: () {},
                            ),
                            ActionMenuItem(
                              icon: Icons.assignment_rounded,
                              label: "Tugas",
                              color: Colors.teal,
                              onTap: () {},
                            ),
                            ActionMenuItem(
                              icon: Icons.analytics_rounded,
                              label: "Laporan",
                              color: Colors.indigo,
                              onTap: () {},
                            ),
                            ActionMenuItem(
                              icon: Icons.grid_view_rounded,
                              label: "Lainnya",
                              color: Colors.grey,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        if (user?.role == 'siswa') ...[
                          TodayScheduleWidget(
                            schedules: auth.todaySchedule,
                            serverTime: auth.serverTime,
                            onAttendanceTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AttendanceScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedNavBar() {
    return FloatingNavbar(
      selectedIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Fitur ini sedang dalam pengembangan",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
